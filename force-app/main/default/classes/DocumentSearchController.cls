global with sharing class DocumentSearchController {
	public static Integer MAX_RECORDS {
    	get {
    		if(Novidea_Document_Management__c.getInstance().get('Number_of_Records_to_Show__c') != null)
    			return Integer.valueOf(Novidea_Document_Management__c.getInstance().get('Number_of_Records_to_Show__c'));
    		return 500;
    	} 
	}
	
	public Novidea_Document_Management__c novideaDocumentManagment {
		get {
			return Novidea_Document_Management__c.getInstance();
		}
	}
	
	
	public static final Integer LIMIT_SOSL_QUERY_RECORDS = 200;
	
    public FilingCriterionObject[] getFilingCriterionObjects() {
    	return FilingUtils.getFilingCriterionObjects();
    }
    
    
    public class FilingCriterionPair {
    	public FilingCriterionObject fco1 {get; set;}
    	public FilingCriterionObject fco2 {get; set;}
    	public FilingCriterionPair(){}
    }

    private FilingCriterionPair[] filingCriterionPairs;
    public FilingCriterionPair[] getFilingCriterionPairs(){
    	if (filingCriterionPairs == null){
    		filingCriterionPairs = new List<FilingCriterionPair>();
    	
	    	FilingCriterionPair fcp = new FilingCriterionPair();
	    	for (FilingCriterionObject fco: getFilingCriterionObjects()){
	    		if (fcp.fco1 == null){
	    			fcp.fco1 = fco;
	    			filingCriterionPairs.add(fcp);
	    		} else if (fcp.fco2 == null){
	    			fcp.fco2 = fco;
	    			fcp = new FilingCriterionPair();
	    		}
	    	}
    	}
    	
    	return filingCriterionPairs;
    }
    
    public Integer getCalculatedColspan(){
    	// These are all the fields that take part in the table
    	Integer accountAndContact = 1;
    	Integer ownerAndFreetext = 1;
    	Integer dates = 1;
    	Integer customPairsCount = getFilingCriterionPairs().size();
    	
    	return accountAndContact + ownerAndFreetext + dates + customPairsCount;
    }
    
    
    @RemoteAction    
     global static void markObject(string wantedId, String entityType){
         Object_for_Document__c documentationData = new Object_for_Document__c();
         try {
         	Database.delete([SELECT OwnerId FROM Object_for_Document__c WHERE OwnerId = :UserInfo.getUserId()]);
         } catch (Exception e) { }
         
        if (entityType.toLowerCase() == 'account') {
            documentationData.Account_Id__c = wantedId;
        } 
        else if (entityType.toLowerCase() == 'contact') {
            Contact contact = [SELECT AccountId FROM Contact WHERE Id = :wantedId];
            documentationData.Account_Id__c = contact.AccountId;
            documentationData.Contact_Id__c = wantedId;
        } 
        else{
        	string query ='SELECT ';
        	list<String> tmparr;
        	String tmpstr;

	        FilingCriterionObject fco = FilingUtils.getFilingCriterionByApiName(entityType);
	        
            if(fco.nameFieldsCsv != null)
            	tmparr = fco.nameFieldsCsv.split(',');
            query+= fco.accountFieldName + 
            		(String.isNotBlank(fco.nameFieldsCsv)?
            		',' + String.join(tmparr,','):'') + '\n';
            query+= 'FROM ' + fco.apiName + '\n'+
            		'WHERE Id =\'' + wantedId + '\'\n';
            system.debug(query);
            sObject obj = database.query(query);
            documentationData.put(fco.name + '_Id__c', wantedId);
            documentationData.Account_Id__c =(Id)obj.get(fco.accountFieldName);
            if(tmparr != null){ 
	            for(String str: tmparr){
	            	tmpstr = str.reverse().substring(str.reverse().indexOf('__')+2).reverse();
	            	if(tmpstr.indexOf('__')>-1)
	            		documentationData.put(tmpstr.substring(tmpstr.indexOf('__')+2) + '_Id__c', (Id)obj.get(str));
	            	else documentationData.put(tmpstr + '_Id__c', (Id)obj.get(str));
	            }
            }
        }
        list<Account> acclist = [SELECT Name FROM Account WHERE id = :documentationData.Account_Id__c];
        if(!acclist.isEmpty()) documentationData.Account_Name__c = acclist[0].Name;
        Database.insert(documentationData);
        System.debug([SELECT OwnerId , Account_Id__c, Contact_Id__c , 
        					 Policy_Id__c , Claim_Id__c , Application_Id__c , 
							 Lead_Id__c, Account_Name__c 
                      FROM Object_for_Document__c
                      WHERE User__c =: UserInfo.getUserId()]
                    );
     }

    private final static map<String, Schema.SObjectType> gd;
    public final static Integer RECORDS_FROM_DAYS_BACK{get;set;}
    public String strInitSearchResult{get{if(strInitSearchResult==null)init();return strInitSearchResult;} private set;}
    public String jsonDocTypes{get{if(jsonDocTypes==null)init();return jsonDocTypes;}set;}

    
    private static boolean initialized = false;
    //mapped to psearchparams component attribute
    public DocumentSearchParams searchparams{get;set;}
     //mapped to component pdisplayFiletr attribute
    public boolean bDisplayFilter{get;set;}
    //when this module is displayed inside an entity a defaukt fax number can be obtained
    static{
        //when loading not remoting
        if(Apexpages.currentPage()!=null){
            String days = Apexpages.currentPage().getParameters().get('days');
            integer numDays = 1;
            if(days!=null && !''.equals(days))
                numDays = Integer.valueOf(days);
            RECORDS_FROM_DAYS_BACK = numDays;
            gd = Schema.getGlobalDescribe();
        }
    }
    public list<Selectoption> doctypeOpts {get{if(doctypeOpts==null) init(); return doctypeOpts;}private set;}

    private list<Schema.PicklistEntry> getPicklistEntries(String entityName,String fieldName){
        Schema.SObjectType targetType = gd.get(entityName);
        map<String, Schema.SObjectField> fieldsMap = targetType.getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldDesc = fieldsMap.get(fieldName).getDescribe();
        return fieldDesc.getPicklistValues();
    }
    
    public map<String,String> getPicklistValues(String entityName, String pickListField){
        list<Schema.PicklistEntry> ple = getPicklistEntries(entityName, pickListField);
        map<String,String> retmap = new map<String,String>();
        for (Schema.PicklistEntry p:ple) {
            retmap.put(p.getValue(), p.getLabel());
        }
        return retmap;          
    }
    
    private list<PickListValue> getPicklistValuesSortable(String entityName, String pickListField){
        list<Schema.PicklistEntry> ple = getPicklistEntries(entityName, pickListField);
        list<PickListValue> retlist = new list<PickListValue>();
        for (Schema.PicklistEntry p:ple) {
            retlist.add(new PickListValue(p.getValue(), p.getLabel()));
        }
        return retlist;          
    }
    
    public class PickListValue implements Comparable{
        public Integer compareTo(Object inval){
            PickListValue val = (PickListValue)inval;
            if(String.isEmpty(val.label) && String.isEmpty(this.label))  return 0;
            return this.label.compareTo(val.label);
        }
        public String value;
        public String label;
        public PickListValue(String value, String label){
            this.value= value;
            this.label = label;
        }
    }
    
    public void init(){
        if(initialized) return;
        initialized = true;
        list<PickListValue> doctypes = getPicklistValuesSortable('InboundDocument__c', 'Type__c');
        doctypes.sort();
        system.debug(doctypes.size());
        doctypeOpts = new list<Selectoption>();
        Jsongenerator jgen = Json.createGenerator(false);
        jgen.writeStartArray();
        for(PickListValue key: doctypes){
            jgen.writeStartObject();
            jgen.writeStringField('value',key.value);
            jgen.writeStringField('label',key.label);
            jgen.writeEndObject();
            doctypeOpts.add(new Selectoption(key.value, key.label));
        }
        jgen.writeEndArray();
        jsonDocTypes = jgen.getAsString();
        System.debug('jsonDocTypes:' + jsonDocTypes);
        if(searchparams==null)searchparams = new DocumentSearchParams();
        if(null==searchparams.orderby){
            searchparams.orderby  = new DocumentSearchParams.DocumentSearchOrderByParam[]{};
        }
        searchparams.orderby.add(new DocumentSearchParams.DocumentSearchOrderByParam('Date_Received__c','DESC'));
        
        if(bDisplayFilter && false != Novidea_Document_Management__c.getInstance().Auto_Set_Owner_Filter_In_Doc_Search__c){
            searchparams.owner = Userinfo.getUserId();
            searchparams.ownername = Userinfo.getName(); 
        } 
        else if(!bDisplayFilter){
            searchparams.queryLimit = 6; // Display 6 lines when the page shows up and comlete the list afterwords.
        }    
        list<InboundDocument__c> res = DocumentSearchController.doRemoteSearch(searchparams);
        searchparams.queryLimit = null;
        strInitSearchResult = JSON.serialize(res);
    }

    private static list<String> getSearchFieldList(){
        return new list<String>{'Account__r.Name', 'CreatedDate', 'toLabel(Type__c)', 'Subject__c', 'Comments__c','LastModifiedDate', 'Owner.Name', 'Private__c', 'Date_Received__c', 'Physical_Path__c', 'Email_Preview__c', 'Attachments__c'};
    }
    
    private static list<String> getSearchOrderByList(DocumentSearchParams oParams){
        list<String> retset = new list<String>();
        if(null!=oParams.orderby && !oParams.orderby.isEmpty()){
            for(DocumentSearchParams.DocumentSearchOrderByParam obp: oParams.orderby){
                retset.add(obp.fieldName + ' ' + obp.sortdir);
            }
        }
        return retset;
    }

    private static String getSearchLimit(integer recordLimit, boolean isSoslMode){
        //if the LIMIT_SOSL_QUERY_RECORDS is smaller than recordLimit then no need to specify because the limit is don automatically. 
        if(isSoslMode && LIMIT_SOSL_QUERY_RECORDS <= recordLimit) 
        	return '';
        	
        return '\nLIMIT ' + recordLimit;
    }

    private static String getSearchWhereClause(DocumentSearchParams oParams, boolean searchImported){
        String whereClause =  'WHERE ';
        if (oParams.acts != null && oParams.acts.size() > 0){
        	String[] inAccounts = new list<String>();
        	for (DocumentSearchParams.CustomEntityFilter cef:oParams.acts){
        		if (String.isNotEmpty(cef.idStr))
        			inAccounts.add('\'' + cef.idStr + '\'');
        	}
        	if (inAccounts.size() > 0 && System.Label.Account_Required.equalsIgnoreCase('true'))
        		whereClause += ' account__c in (' + String.join(inAccounts,',') + ') AND ';
        }
        
        // Use to search files that were imported during the migration.
        // TODO: Rolan - Move the External_Id__c to configuration
        if(searchImported!=null){
            if(!searchImported) 
                whereClause+='External_Id__c=null\n';
            else{
                whereClause+='External_Id__c!=null\n';
            } 
            whereClause+='AND ';             
        }
        whereClause+='(';
         
        String tempStr = '';
        // TODO: Rolan - EntIdRefactor (consider using lookups from configuration)
        if (oParams.customEnts != null){
        	for (DocumentSearchParams.CustomEntityFilter cef:oParams.customEnts.values()){
		        if(String.isNotBlank(cef.idStr)){ 
		            for(integer i=1; i<=20; ++i){
		                whereClause+= (tempStr + 'EntId' + i + '__c=\'' + cef.idStr + '\'');
		                tempStr = ' OR ';
		            }
		            whereClause+= ')\nAND (';
		            tempStr = '';
		        }
        	}
        }

        if(String.isNotBlank(oParams.act)){ 
            for(integer i =1;i<=20;++i){
                whereClause+= (tempStr + 'EntId' + i + '__c=\'' + oParams.act + '\'');
                tempStr = ' OR ';
            }
            whereClause+= ')\nAND (';
            tempStr = '';
        }
        if(String.isNotBlank(oParams.cnt)){ 
            for(integer i =1;i<=20;++i){
                whereClause+= (tempStr + 'EntId' + i + '__c=\'' + oParams.cnt + '\'');
                tempStr = ' OR ';
            }
            whereClause+= ')\nAND (';
            tempStr = '';
        }

        if(String.isNotBlank(oParams.tsk)){ 
            for(integer i =1;i<=20;++i){
                whereClause+= (tempStr + 'EntId' + i + '__c=\'' + oParams.tsk + '\'');
                tempStr = ' OR ';
            }
            whereClause+= ')\nAND (';
            tempStr = '';
        }

        if(null!=oParams.doctype && !oParams.doctype.isEmpty()){
            for(String doctype: oParams.doctype){
                tempStr+= ('\'' + doctype + '\',');
            }
            tempStr = tempStr.substring(0,tempStr.length()-1);
        }
        if(String.isNotBlank(tempStr)){
            whereClause+='Type__c IN(' + tempStr + ')';
            whereClause+= ')\nAND (';
            tempStr = '';
        }
        
        if(String.isNotBlank(oParams.startDate)){
            Datetime sd = Datetime.newInstance(Date.parse(oParams.startDate),Time.newInstance(0,0,0,0));
            whereClause+= 'Date_Received__c >= ' + sd.format('yyyy-MM-dd')+'T'+ sd.format('HH:mm:ss.SSS')+'Z';
            whereClause+= ')\nAND (';
        }
		
        if(String.isNotBlank(oParams.endDate)){ 
            Datetime ed =  Datetime.newInstance(Date.parse(oParams.endDate),Time.newInstance(23,59,59,0));
            whereClause+= 'Date_Received__c <= ' + ed.format('yyyy-MM-dd')+'T'+ ed.format('HH:mm:ss.SSS')+'Z';
            whereClause+= ')\nAND (';
        }
        if(String.isNotBlank(oParams.owner)){ 
            whereClause+= 'OwnerId = \'' + oParams.owner + '\'';
            whereClause+= ')\n';
        }
        
        if(whereClause.endsWith('AND (')) 
        	whereClause = whereClause.substring(0,whereClause.length()-'AND ('.length());
        else if(whereClause.endsWith('WHERE ('))  
        	whereClause = whereClause.substring(0,whereClause.length()-'WHERE ('.length());
        
        return whereClause;
    }
    
    private static String getSearchWhereOrderByAndLimit(DocumentSearchParams oParams, boolean searchImported, integer recordLimit){
        return  getSearchWhereClause(oParams, searchImported) + 'ORDER BY ' + String.join(getSearchOrderByList(oParams),',') + getSearchLimit(recordLimit, isUseSoslQuery(oParams));
    }
    
    public static String getSoslSearchFreeTextTerm(String term){
        String termCorrected = '';
        for (String textPart:term.split(' ')){
            if (!String.isBlank(textPart)) {
                if(!String.isBlank(termCorrected))
                    termCorrected += ' AND ';
                //escape all sosl reserved characters: ? & | ! { } [ ] ( ) ^ ~ * : \ " ' + - 
                textPart = textPart.replaceAll('([\\?&\\|!{}\\[\\]\\(\\)\\^~\\*:\\\\"\'\\+-])','\\\\$1');
                termCorrected += '"*' + textPart + '*"';
            }
        }
        return termCorrected;
    }
    
    public static String prepareSoqlSearchQuery(DocumentSearchParams oParams, boolean searchImported, integer recordLimit){
        String query = '\nSELECT ' + String.join(getSearchFieldList(),',') + '\n'+
                       'FROM InboundDocument__c\n';
        query += getSearchWhereOrderByAndLimit(oParams, searchImported, recordLimit);
        return query;
    }

    public static String prepareSoslSearchQuery(DocumentSearchParams oParams, boolean searchImported, integer recordLimit){
        String searchterm = getSoslSearchFreeTextTerm(oParams.freeText);
        String query = '\nFIND {' + searchterm + '} RETURNING InboundDocument__c(' + String.join(getSearchFieldList(),',') + '\n';
        query += (getSearchWhereOrderByAndLimit(oParams, searchImported, recordLimit) + ')');
        return query;
    }

    private static boolean isUseSoslQuery(DocumentSearchParams oParams){
        return !String.isEmpty(oParams.freeText);
    }

    public static list<InboundDocument__c> executeQuery(DocumentSearchParams oParams, boolean searchImported, Integer queryLimit){
        String query;
        if(isUseSoslQuery(oParams)){
            query = prepareSoslSearchQuery(oParams, searchImported, queryLimit);
            System.debug(query);
            return (list<InboundDocument__c>)(Search.query(query)[0]);
        }
        else{
            query = prepareSoqlSearchQuery(oParams, searchImported, queryLimit);
            System.debug(query);
            
            // PATCH by Rolan: Avoid non selective queries.
            if (query.indexOfIgnoreCase('WHERE') < 0)
            	return new list<InboundDocument__c>();
            // PATCH by Rolan: Avoid not indexed queries
            if (System.Label.Account_Required.equalsIgnoreCase('true') 
            		&& query.indexOfIgnoreCase('account__c') < 0 && query.indexOfIgnoreCase('OwnerId') < 0)
            	return new list<InboundDocument__c>();
            
            return database.query(query);
        }
    }

    public static list<InboundDocument__c> doRemoteSearch(DocumentSearchParams oParams){
        String query;
        list<InboundDocument__c> retlist, templist;
        // If query is required to display both imported and created docs seperatly then do union (oParams.splitQueryByImportedVSCreated==true)
        // the logic is: 
        // 1. fetch the newly created docs ordered by their creation date desc
        // 2. union fetch the imported docs ordered by date received/set desc 
        Integer queryLimit = oParams.queryLimit; 
        if (queryLimit == null)
            queryLimit = MAX_RECORDS;

        if(oParams.splitQueryByImportedVSCreated!=null && oParams.splitQueryByImportedVSCreated){
            retlist = executeQuery(oParams, false, queryLimit);
            //don't let the amount of records pass the limit of max records
            if(queryLimit>retlist.size()){
                oParams.removeOrderByElement('CreatedDate');
                retlist.addAll(executeQuery(oParams, true, queryLimit - retlist.size()));
            }
        }
        else{
            retlist = executeQuery(oParams, null, queryLimit);
        }
        
        return retlist;
    } 
    
   
}