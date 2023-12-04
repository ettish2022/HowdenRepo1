global with sharing class raniztestco{}
/*  @RemoteAction
    public static integer insertdata(integer startCounter){
        list<Document__c> docs = new list<Document__c>();
        list<Application__c> apps = [SELECT Account__c from Application__c];
        list<Policy__c> plcs = [SELECT  Account__c from Policy__c];
        list<Claim__c> clms = [SELECT Account__c from Claim__c];
        list<Account> acts = [Select Id from Account];
        list<Contact> cnts = [Select Id from Contact];
        map<Id,list<Id>> appsmap = new map<Id,list<Id>>();
        map<Id,list<Id>> plcsmap = new map<Id,list<Id>>();
        map<Id,list<Id>> clmsmap = new map<Id,list<Id>>();
        list<Id> tmpList;
        for(Application__c app: apps){
            if((tmpList=appsmap.get(app.Account__c))==null)
                tmpList = new list<Id>();
            tmpList.add(app.Id);
            appsmap.put(app.Account__c,tmpList); 
        }
        apps = null;
        for(Policy__c plc: plcs){
            if((tmpList=plcsmap.get(plc.Account__c))==null)
                tmpList = new list<Id>();
            tmpList.add(plc.Id);
            plcsmap.put(plc.Account__c,tmpList); 
        }
        plcs=null;
        for(Claim__c clm: clms){
            if((tmpList=clmsmap.get(clm.Account__c))==null)
                tmpList = new list<Id>();
            tmpList.add(clm.Id);
            clmsmap.put(clm.Account__c,tmpList); 
        }
        clms = null;
        map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType targetType = gd.get('Document__c');
        map<String, Schema.SObjectField> fieldsMap = targetType.getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldDesc = fieldsMap.get('Type1__c').getDescribe();
        list<Schema.PicklistEntry> ple = fieldDesc.getPicklistValues();
        
        
        
        String out = '';
        Id actid;
        list<Id> tempId;
        integer counter;
        for (counter =startCounter;counter<9998+startCounter;counter++){
            actid = acts.get(math.mod(counter,acts.size()-1)).Id;
            /*docs.add(new Document__c(Subject__c= 'Subject ' + Counter, Type1__c= ple.get(math.mod(counter,ple.size()-1)).getValue(),  
                    Account__c=actid, EntType1__c='Application__c', EntId1__c=((tempId=appsmap.get(actid))==null?'':tempId.get(math.mod(counter,tempId.size()-1))), 
                 EntType2__c='Policy__c', EntId2__c=((tempId=plcsmap.get(actid))==null?'':tempId.get(math.mod(counter,tempId.size()-1))),                   
                 EntType3__c='Claim__c', EntId3__c=((tempId=clmsmap.get(actid))==null?'':tempId.get(math.mod(counter,tempId.size()-1))), 
                 Contact1__c =  cnts.get(math.mod(counter,cnts.size()-1)).Id , Contact2__c = cnts.get(math.mod(counter+1,cnts.size()-1)).Id ,
                 Contact3__c = cnts.get(math.mod(counter+2,cnts.size()-1)).id,Contact4__c = cnts.get(math.mod(counter+3,cnts.size()-1)).id));*/
            /*out+= (actid + ',' + 
                ((tempId=appsmap.get(actid))==null?'':tempId.get(math.mod(counter,tempId.size()-1))) + ',' + 
                ((tempId=plcsmap.get(actid))==null?'':tempId.get(math.mod(counter,tempId.size()-1))) + ',' + 
                ((tempId=clmsmap.get(actid))==null?'':tempId.get(math.mod(counter,tempId.size()-1))) + ',' + 
                cnts.get(math.mod(counter,cnts.size()-1)).Id + ',' + cnts.get(math.mod(counter+1,cnts.size()-1)).id + 
                ',' + cnts.get(math.mod(counter+2,cnts.size()-1)).id+ ',' + cnts.get(math.mod(counter+3,cnts.size()-1)).id + '\n');*/
        /*}
        system.debug('new Start counter : '+ counter);
        //Savepoint sp = database.setSavePoint();
        database.insert(docs);
        //database.rollback(sp);
        return counter;
    }
    

    
    private static Id[] getParams(){
        list<Application__c> apps = [SELECT Id from Application__c];
        list<Policy__c> plcs = [SELECT  Id from Policy__c];
        list<Claim__c> clms = [SELECT Id from Claim__c];
        list<Account> acts = [Select Id from Account];
        list<Contact> cnts = [Select Id from Contact];
        
        Id plcId ;
        Id appId;
        Id clmId;
        Id actId;
        Id cntId;

        integer index=0;
        integer rand = math.mod(math.round(math.random()*100),apps.size()-1);
        for(Application__c app: apps){
            if(index++==rand){
                appId = app.Id;
                break;
            }
        }
        apps = null;
        index=0;
        rand = math.mod(math.round(math.random()*100),plcs.size()-1);
        for(Policy__c plc: plcs){
            if(index++==rand){
                plcId = plc.Id;
                break;
            }
        }
        plcs=null;
        rand = math.mod(math.round(math.random()*100),clms.size()-1);
        for(Claim__c clm: clms){
            if(index++==rand){
                clmId = clm.Id;
                break;
            }
        }
        clms = null;
        index=0;
        rand = math.mod(math.round(math.random()*100),acts.size()-1);
        for(Account act: acts){
            if(index++==rand){
                actId = act.Id;
                break;
            }
        }
        acts = null;
        index=0;
        rand = math.mod(math.round(math.random()*100),cnts.size()-1);
        for(Contact cnt: cnts){
            if(index++==rand){
                cntId = cnt.Id;
                break;
            }
        }
        cnts = null;
        index=0;
        
        return new String[]{appId, plcId, clmId, actId, cntId};
    }
    
    @RemoteAction
    public static String[] finder(){
        String[] res = getParams();
        Id appId = res[0];
        Id plcId = res[1];
        Id clmId = res[2];
        Id actId = res[3];
        Id cntId = res[4];
        
        Datetime maxDatefiled = Date.Today().addDays(1), minDateFiled = Date.Today().addDays(-2);
        string[] retarr = new String[]{Datetime.now().format('HH:mm:ss:SSS')};
        String query = 'FIND \'';
        query+= appId + ' AND ' + plcId + ' AND ' + clmId  + ' AND ' + actId + ' AND ' + cntId + '\'';
        query+=' RETURNING document__c(Id,Name,Subject__c,Type1__c WHERE lastmodifieddate > ' + 
                minDateFiled.format('yyyy-MM-dd')+'T'+ minDateFiled.format('HH:mm:ss')+'Z' + 
                ' AND lastmodifieddate < '+ maxDatefiled.format('yyyy-MM-dd') + 'T'+ maxDatefiled.format('HH:mm:ss')+'Z)';
        search.query(query);
        retarr.add(Datetime.now().format('HH:mm:ss:SSS'));
        return retarr;
    }
    
    @RemoteAction
    public static String[] testComplex2Fields(){
        list<Document__c> docs;
        String query = 'SELECT Id\n'+ 
                        'FROM  Document__c\n'+
                        'WHERE (';
        String temp = ''; 

        String[] res = getParams();
        Id appId = res[0];
        Id plcId = res[1];
        Id clmId = res[2];
        Id actId = res[3];
        Id cntId = res[4];


        Datetime maxDatefiled = Date.Today().addDays(1), minDateFiled = Date.Today().addDays(-2);
        for(integer i =1;i<=10;++i){
            query+= (temp + '(EntType' + i + '__c = \'Policy__c\' AND EntId' + i + '__c=\'' + plcId + '\')\n');
            temp = 'OR ';
        }
        query+= ')\nAND (';
        temp = '';
        for(integer i =1;i<=10;++i){
            query+= (temp + '(EntType' + i + '__c = \'Application__c\' AND EntId' + i + '__c=\'' + appId + '\')\n');
            temp = 'OR ';
        }
        query+= ')\nAND (';
        temp = '';
        for(integer i =1;i<=10;++i){
            query+= (temp + '(EntType' + i + '__c = \'Claim__c\' AND EntId' + i + '__c=\'' + clmId + '\')\n');
            temp = 'OR ';
        }
        query+= ')\nAND (';
        temp = '';
        for(integer i =1;i<=10;++i){
            query+= (temp + '(EntType' + i + '__c = \'Account__c\' AND EntId' + i + '__c=\'' + actId + '\')\n');
            temp = 'OR ';
        }
        query+= ')\nAND (';
        temp = '';
        for(integer i =1;i<=10;++i){
            query+= (temp + '(EntType' + i + '__c = \'Contact__c\' AND EntId' + i + '__c=\'' + cntId + '\')\n');
            temp = 'OR ';
        }
        query+= ')\nAND (';
        temp = '';
        for(integer i =1;i<=10;++i){
            query+= (temp + 'Contact' +i + '__c=\'' + cntId + '\'');
            temp = ' OR ';
        }
        query+= ')\n';
        query+= 'AND lastmodifieddate > ' + minDateFiled.format('yyyy-MM-dd')+'T'+ minDateFiled.format('HH:mm:ss')+'Z' + ' AND lastmodifieddate < '+ maxDatefiled.format('yyyy-MM-dd') + 'T'+ maxDatefiled.format('HH:mm:ss')+'Z\n';
        
        query+= 'LIMIT 10\n';
        //system.debug(query);
        string[] retarr = new String[]{Datetime.now().format('HH:mm:ss:SSS')};
        docs = database.query(query);

        retarr.add(Datetime.now().format('HH:mm:ss:SSS'));
        return retarr;
    }

    @RemoteAction
    public static String[] testComplex1Field(){
        list<Document__c> docs;
        String query = 'SELECT Id\n'+ 
                        'FROM  Document__c\n'+
                        'WHERE (';
        String temp = ''; 

        String[] res = getParams();
        Id appId = res[0];
        Id plcId = res[1];
        Id clmId = res[2];
        Id actId = res[3];
        Id cntId = res[4];


        Datetime maxDatefiled = Date.Today().addDays(1), minDateFiled = Date.Today().addDays(-2);
        for(integer i =1;i<=10;++i){
            query+= (temp + 'EntId' + i + '__c=\'' + plcId + '\' ');
            temp = 'OR ';
        }
        query+= ')\nAND (';
        temp = '';
        for(integer i =1;i<=10;++i){
            query+= (temp + 'EntId' + i + '__c=\'' + appId + '\' ');
            temp = 'OR ';
        }
        query+= ')\n';
        /*query+= ')\nAND (';
        temp = '';
        for(integer i =1;i<=10;++i){
            query+= (temp + 'EntId' + i + '__c=\'' + clmId + '\' ');
            temp = 'OR ';
        }
        query+= ')\nAND (';
        temp = '';
        for(integer i =1;i<=10;++i){
            query+= (temp + 'EntId' + i + '__c=\'' + actId + '\' ');
            temp = 'OR ';
        }
        query+= ')\nAND (';
        temp = '';
        for(integer i =1;i<=10;++i){
            query+= (temp + 'EntId' + i + '__c=\'' + cntId + '\' ');
            temp = 'OR ';
        }
        query+= ')\nAND (';
        temp = '';
        for(integer i =1;i<=10;++i){
            query+= (temp + 'Contact' +i + '__c=\'' + cntId + '\'');
            temp = ' OR ';
        }
        query+= ')\n';
        */
/*      query+= 'AND lastmodifieddate > ' + minDateFiled.format('yyyy-MM-dd')+'T'+ minDateFiled.format('HH:mm:ss')+'Z' + ' AND lastmodifieddate < '+ maxDatefiled.format('yyyy-MM-dd') + 'T'+ maxDatefiled.format('HH:mm:ss')+'Z\n';
        query+= 'LIMIT 10\n';
        //system.debug(query);
        string[] retarr = new String[]{Datetime.now().format('HH:mm:ss:SSS')};
        docs = database.query(query);

        retarr.add(Datetime.now().format('HH:mm:ss:SSS'));
        return retarr;
    }
    
    private testmethod static void testFind(){
        system.debug(finder());
    }
    
    private testmethod static void test1Filed(){
        system.debug(testComplex1Field());
    }
    private testmethod static void test2Fileds(){
        system.debug(testComplex2Fields());
    }
    
    @RemoteAction
    public static string[] runJob(){
        Database.executeBatch(new raniztestco(),9997);
        return new string[]{'tatam','tatam'};
    }
    
    global Database.Querylocator start(Database.BatchableContext info){
        String Query = 'Select Id,' +
                        'EntId11__c,EntId12__c,EntId13__c,EntId14__c,EntId15__c,EntId16__c,EntId17__c,'+
                        'EntId18__c,EntId19__c,EntId10__c '+
                        'FROM Document__c';
        return database.getQueryLocator(Query);

    }

    global void execute(Database.BatchableContext info, list<Document__c> scope)
    {   
        for(Document__c doc: scope){
            /*if(doc.EntId11__c==null) doc.EntId11__c= doc.Contact1__c;
            if(doc.EntId12__c==null)doc.EntId12__c = doc.Contact2__c;
            if(doc.EntId13__c==null)doc.EntId13__c = doc.Contact3__c;
            if(doc.EntId14__c==null)doc.EntId14__c = doc.Contact4__c;
            if(doc.EntId15__c==null)doc.EntId15__c = doc.Account__c;*/
     /* }
    //database.update(scope);
    }
     
    global void finish(Database.BatchableContext info)
    {   
    }

}*/