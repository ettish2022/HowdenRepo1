function unescapeRemoteDocSearchResult(str){
	if(str===undefined || str==null || ""==str) return "";
	//return str.replace(/&quot;/g,"\"").replace(/&amp;/g,"&").replace(/&#39;/g,"'");
	return jQuery('<textarea />').html(str).text();
}