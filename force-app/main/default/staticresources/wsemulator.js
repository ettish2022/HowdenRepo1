
function wsexecuteAsync(wspackage, wsfunction, wsinput, options, callbackObj){

   if (!options.onFailure)
       throw "Error: options.onFailure not set.";
       
   if (!options.onSuccess)
       throw "Error: options.onSuccess not set.";       


   return wsemulator.execute(wspackage, wsfunction, wsinput, options, callbackObj, true, options.timeout);
}

function wsexecuteSync(wspackage, wsfunction, wsinput){

   return wsemulator.execute(wspackage, wsfunction, wsinput, null, null, false, null);
}


var wsemulator;

if (!wsemulator) {
    wsemulator = {};
}

wsemulator._connections = [];

wsemulator.serviceurl = "/apex/wsemulatorpg";

wsemulator.newconnection = function () {
    if (typeof XMLHttpRequest != 'undefined') {
        return new XMLHttpRequest();
    }
    try {
        return new ActiveXObject("Msxml2.XMLHTTP");
    } catch (e) {
        try {
            return new ActiveXObject("Microsoft.XMLHTTP");
        } catch (e) {}
    }
    return false;
};

wsemulator.execute = function (wspackage, wsfunction, wsinput, callback, callbackObj, async, timeout){

   if (!wsinput || wsinput == "")
       throw "Invalid wsinput, can not be empty or null";

   if (!wsfunction|| wsfunction== "")
       throw "Invalid wsfunction, can not be empty or null";
   
   if (!wspackage || wspackage== "")
       throw "Invalid wspackage, can not be empty or null"; 
       
   var connection = this.newconnection();
   
   if (async){
       connection.onreadystatechange = wsemulator.httpConnectionCallback;
   }
   
   var holder = {connection:connection, callback:callback, timedout:false, callbackObj:callbackObj};    
   wsemulator._connections.push(holder);
   //connection.open("GET", this.serviceurl + "?wspackage=" + escape(wspackage) + "&wsinput=" + escape(unescape(JSON.stringify(wsinput).replace(/\\u/g, '%u'))) +
   connection.open("GET", this.serviceurl + "?wspackage=" + escape(wspackage) + "&wsinput=" + escape(unescape(Sfdc.JSON.stringify(wsinput).replace(/\\u/g, '%u'))) + 
		   "&wsfunction=" + escape(wsfunction) + "&core.apexpages.devmode.url=1", async);
   connection.send(null);
   
    if (async && typeof(timeout) !== "undefined") {
        wsemulator.setTimeoutOn(holder, timeout);
    }
   
   if (!async) {
       return wsemulator.httpConnectionCallback();
   } else
     return true;
};

wsemulator.setTimeoutOn = function (holder, timeout) {
        function abortConnection() {
            if (holder.connection.readyState !== 4) {
                holder.timedout = true;
                holder.connection.abort();
            }
        }
        setTimeout(abortConnection, timeout);
};        

wsemulator.httpConnectionCallback = function () {

        for (var i = 0; i < wsemulator._connections.length; i++) {
            var holder = wsemulator._connections[i];
            if (holder !== null) {
                if (holder.timedout) {
                    wsemulator._connections[i] = null;
                    wsemulator._connections.slice(i,1);
                    holder.callback.onFailure(callbackObj, "Remote invocation timed out");
                } else  if (holder.connection.readyState == 4) {
                    wsemulator._connections[i] = null;
                    wsemulator._connections.slice(i,1);
                    var success = holder.connection.status == 200;                    
                    
                    if (success && holder.connection.responseText) {
                        try{
                            var respObj = JSON.parse(holder.connection.responseText);
                            
                            var isAsync = (holder.callback != null);
                            
                            if (respObj.errorCode == 'OK'){
                                
                                if (isAsync)
                                    holder.callback.onSuccess(holder.callbackObj, Base64.decode(respObj.result));
                                else
                                    return Base64.decode(respObj.result);
                                
                            } else {
                                
                                if (isAsync)
                                    holder.callback.onFailure(holder.callbackObj,respObj.errorDesc);                                
                                else
                                    return respObj.errorDesc;
                            }
                        } catch (err){
                        
                            if (isAsync)
                                holder.callback.onFailure(holder.callbackObj, err);
                            else {
                            	if (typeof respObj != 'undefined' && respObj != null)
                            		return respObj.errorDesc;
                            	else
                            		return err;
                            }
                        }
                    } else {
                        if (isAsync)                    
                            holder.callback.onFailure(holder.callbackObj, "Remote invocation failed. Responce: " + holder.connection.responseText);
                        else
                            return "Remote invocation failed. Responce: " + holder.connection.responseText;
                    }
                }
            }
        }

};

var Base64 = {
		 
	// private property
	_keyStr : "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
 
	// public method for encoding
	encode : function (input) {
		var output = "";
		var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
		var i = 0;
 
		input = Base64._utf8_encode(input);
 
		while (i < input.length) {
 
			chr1 = input.charCodeAt(i++);
			chr2 = input.charCodeAt(i++);
			chr3 = input.charCodeAt(i++);
 
			enc1 = chr1 >> 2;
			enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
			enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
			enc4 = chr3 & 63;
 
			if (isNaN(chr2)) {
				enc3 = enc4 = 64;
			} else if (isNaN(chr3)) {
				enc4 = 64;
			}
 
			output = output +
			this._keyStr.charAt(enc1) + this._keyStr.charAt(enc2) +
			this._keyStr.charAt(enc3) + this._keyStr.charAt(enc4);
 
		}
 
		return output;
	},
 
	// public method for decoding
	decode : function (input) {
		var output = "";
		var chr1, chr2, chr3;
		var enc1, enc2, enc3, enc4;
		var i = 0;
 
		input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");
 
		while (i < input.length) {
 
			enc1 = this._keyStr.indexOf(input.charAt(i++));
			enc2 = this._keyStr.indexOf(input.charAt(i++));
			enc3 = this._keyStr.indexOf(input.charAt(i++));
			enc4 = this._keyStr.indexOf(input.charAt(i++));
 
			chr1 = (enc1 << 2) | (enc2 >> 4);
			chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
			chr3 = ((enc3 & 3) << 6) | enc4;
 
			output = output + String.fromCharCode(chr1);
 
			if (enc3 != 64) {
				output = output + String.fromCharCode(chr2);
			}
			if (enc4 != 64) {
				output = output + String.fromCharCode(chr3);
			}
 
		}
 
		output = Base64._utf8_decode(output);
 
		return output;
 
	},
 
	// private method for UTF-8 encoding
	_utf8_encode : function (string) {
		string = string.replace(/\r\n/g,"\n");
		var utftext = "";
 
		for (var n = 0; n < string.length; n++) {
 
			var c = string.charCodeAt(n);
 
			if (c < 128) {
				utftext += String.fromCharCode(c);
			}
			else if((c > 127) && (c < 2048)) {
				utftext += String.fromCharCode((c >> 6) | 192);
				utftext += String.fromCharCode((c & 63) | 128);
			}
			else {
				utftext += String.fromCharCode((c >> 12) | 224);
				utftext += String.fromCharCode(((c >> 6) & 63) | 128);
				utftext += String.fromCharCode((c & 63) | 128);
			}
 
		}
 
		return utftext;
	},
 
	// private method for UTF-8 decoding
	_utf8_decode : function (utftext) {
		var string = "";
		var i = 0;
		var c = c1 = c2 = 0;
 
		while ( i < utftext.length ) {
 
			c = utftext.charCodeAt(i);
 
			if (c < 128) {
				string += String.fromCharCode(c);
				i++;
			}
			else if((c > 191) && (c < 224)) {
				c2 = utftext.charCodeAt(i+1);
				string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
				i += 2;
			}
			else {
				c2 = utftext.charCodeAt(i+1);
				c3 = utftext.charCodeAt(i+2);
				string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
				i += 3;
			}
 
		}
 
		return string;
	}
 
}