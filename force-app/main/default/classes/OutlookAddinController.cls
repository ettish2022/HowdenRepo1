public with sharing class OutlookAddinController {

    public static final String DATA_DELIMITER = ' ';
    public static final String RECEIVER_SEARCH_PREFIX_TO = 'to__';
    public static final String RECEIVER_SEARCH_PREFIX_CC = 'cc__';
    public static final String RECEIVER_SEARCH_PREFIX_BCC = 'bcc__';

    private final static map<String, Schema.SObjectType> gd;
    public final static String networkBasePath {get;private set;}
    private final static boolean isOutlookDeleteActive;
    public static boolean uiActivateDeleteAfterFile{get;private set;}
    public static boolean usePredefDir{get;private set;}
    public final static String currDate {get;private set;}
    public static final String ACCOUNT_JSON_BASE_FIELD_NAME = FilingUtils.getFilingCriterionByApiName('Account').jsonBaseFieldName; 
    public static final String CONTACT_JSON_BASE_FIELD_NAME = FilingUtils.getFilingCriterionByApiName('Contact').jsonBaseFieldName;
    public /*final*/ static String predefFileSelDir {get;private set;}
    public final static boolean showSetPrivate {get;private set;}
    public final static String docTemplatePath{get;private set;}
    public final static boolean isCreateFileOpen{get;private set;}
    public static integer fileWhatParam {get;private set;} //diana added 23/06/2013
    
    public String getAccountDisplayFieldsCsv(){
    	return StringUtils.getValIfBlank(FilingUtils.getFilingCriterionByApiName('Account').nameFieldsCsv, 'Name');
    }
    
    static{
        if(Apexpages.currentPage()!=null){
        	Novidea_Document_Management__c docManage = Novidea_Document_Management__c.getInstance();
            networkBasePath = (String)docManage.Network_Base_Path__c;
         /*   string currentUserId = UserInfo.getUserId();
			list<User> users = [select Predefined_Filing_Dir__c from User where Id=: currentUserId];
			string todayDate = Datetime.now().format('yyyyMMdd');
		*/	
			string path = (String)docManage.Predefined_File_Selection_Dir__c;

		//	if(users[0].Predefined_Filing_Dir__c != null && path != null)
        //        predefFileSelDir = string.format(path,new string[] {todayDate , users[0].Predefined_Filing_Dir__c });
			
            showSetPrivate = (boolean)docManage.Show_Set_Private__c;
            if(networkBasePath==null){
                throw new DocumentManagementCustomSettingsException('Missing Custome Setting parameter "Network Base Path"');
            }
            isOutlookDeleteActive = docManage.Is_Outlook_Delete_Active__c;
            if (isOutlookDeleteActive == null)
            	isOutlookDeleteActive = false;
            uiActivateDeleteAfterFile = true;
            //made for not having to get global when doing remote
            gd = Schema.getGlobalDescribe();
            String cfo = Apexpages.currentPage().getParameters().get('cfo');
            if(!string.isBlank(cfo) && '1'.equals(cfo)) isCreateFileOpen = true;
			else isCreateFileOpen = false;
            if(isCreateFileOpen){
            	String docType = Apexpages.currentPage().getParameters().get('dct');
            	if('word'.equalsIgnoreCase(docType)){
	           		docTemplatePath = (String)docManage.WordTemplatePath__c;
            	}
            	else if('excel'.equalsIgnoreCase(docType)){
	            	docTemplatePath = (String)docManage.ExcelTemplatePath__c;
            	}
            }
            
        }
        //TODO: the later format is better but does not workl in addin need to check this against user locale and file format
        currDate  = Datetime.Now().format('MM/dd/yyyy');/*('yyyy-MM-dd')*/
    }
    public class DocumentManagementCustomSettingsException extends Exception{}

    public String jsonInitialData{get;set;}
    private Integer fileEmailsCount = 0;
    public String userEmail {get;private set;}
    //true for email, false for files
    public boolean filingMode{get;private set;}

	// Begin: Added by Rolan - PerForm local generation of files
	public String getTodaysDateFiling (){
        return Datetime.Now().format('yyyy-MM-dd') + 'T' + Datetime.Now().format('hh:mm:ss');
	}
	
	// End: Added by Rolan - PerForm local generation of files

    private InitialFilingParam getFilingParam(String entId){
        if(String.isEmpty(entId) || entId.length() < 15 || entId.length() > 18) 
        	return null;

    	ID entIdId = id.valueOf(entId);
    	String entTypeName = entIdId.getSobjectType().getDescribe().getName();

		AccountSObjectRelation[] asors = FilingUtils.getAccountSObjectRelationsById(entId);
		if(!asors.isEmpty()){
			list<InitialFilingParamEntity> pes = new list<InitialFilingParamEntity>();
			InitialFilingParamEntity pe;
			for(AccountSObjectRelation asor: asors){
				if (asor.accountId != null){
					pe = new InitialFilingParamEntity(asor.accountName, asor.accountId);
					system.debug(pe);
					pes.add(pe);
				}
			}
			return new InitialFilingParam(entTypeName,!pes.isEmpty()?pes:null, asors[0].objectName, asors[0].objectId);
		}           
		return null;
    }

    /*
        currently used to describe an account
        more than one account can be attached to a contact
    */
    private class InitialFilingParamEntity{
        public String name;
        public String id;
        public InitialFilingParamEntity(String name, String id){
            this.name = name;
            this.id = id;
        }
    }

    private class InitialFilingParam{
        public String entTypeName{get;set;}
        public list<InitialFilingParamEntity> acts;
        public String entName{get;set;}
        public Id entId{get;set;}
        public InitialFilingParam(String entTypeName, list<InitialFilingParamEntity> acts, String entName,Id entId){
            this.entTypeName=entTypeName; 
            this.acts = acts;
            this.entName=entName;
            this.entId = entId;
        }
    }

    public void init(){
        system.debug(Apexpages.currentPage().getUrl());
        String filemode = Apexpages.currentPage().getParameters().get('mode');
        if(string.isBlank(filemode) || !'1'.equals(filemode))
        	filingMode=false;
        else
        	filingMode=true;

    	// diana added 23/06/2013
        fileWhatParam = 2;
        if(filingMode && !String.isBlank(Apexpages.currentPage().getParameters().get('fileWhat')))
        	fileWhatParam = integer.valueOf(Apexpages.currentPage().getParameters().get('fileWhat')); 
        
        //if enmail and custom setting is false then deactivate checkbox
        if(filingMode && !isOutlookDeleteActive) 
        	uiActivateDeleteAfterFile = false;
        	
        String usePathStr = Apexpages.currentPage().getParameters().get('usepath');
        usePredefDir = !filingMode && '1'.equals(usePathStr) || '2'.equals(usePathStr);
        system.debug('filingMode : ' + filingMode + ' filemode:' + filemode);
        
        string currentUserId = UserInfo.getUserId();
		list<User> users = [select Predefined_Filing_Dir__c from User where Id=: currentUserId];
		string todayDate = Datetime.now().format('yyyyMMdd');
		
		string path;
		if(usePathStr == '1'){
			path = (String)Novidea_Document_Management__c.getInstance().Predefined_File_Selection_Dir__c;
			predefFileSelDir = string.format(path,new string[] {todayDate , users[0].Predefined_Filing_Dir__c });
		}
		else if(usePathStr == '2'){
			path = (String)Novidea_Document_Management__c.getInstance().Predefined_File_Selection_Dir_Scan__c;
			predefFileSelDir = path;
		} 
        
        map<String,String> doctypes = getPicklistValues('InboundDocument__c', 'Type__c');
        map<String,String> taskStatus = getPicklistValues('Task', 'Status');
        map<String,String> taskPriority = getPicklistValues('Task', 'Priority');
        if(filingMode){
        	Object_for_Document__c objForDocument = queryObjectForDocument();
            InitEmailResult cnts = initemail(objForDocument);
            jsonInitialData = createInitialJsonEmail(cnts,objForDocument,doctypes,taskStatus, taskPriority);
        }
        else{
            String entId = Apexpages.currentPage().getParameters().get('entid');
            InitialFilingParam filingParam = getFilingParam(entId);
            jsonInitialData = createInitialJsonFile(doctypes,taskStatus, taskPriority, filingParam);
        }
    }
    
    public FilingCriterionObject[] getFilingCriterionObjects() {
    	return FilingUtils.getFilingCriterionObjects();
    }

    private class InitEmailResult{
       public list<AccountSObjectRelation> aps;
       public list<Contact> cnts;
       public InitEmailResult(list<AccountSObjectRelation> aps, list<Contact> cnts){
            this.aps = aps;
            this.cnts = cnts;
        }
    }
    
    private InitEmailResult initemail(Object_for_Document__c objForDocument){
        String mails = Apexpages.currentPage().getParameters().get('addresses');
        String emailnum = Apexpages.currentPage().getParameters().get('emailnum');
        if(emailnum!=null && emailnum!='')
        	fileEmailsCount = Integer.valueOf(emailnum);
        system.debug(mails);
        User u = [SELECT email from User WHERE id=:Userinfo.getUserId()];
        userEmail = u.email;
        if(mails!=null && !''.equals(mails) && userEmail!=null && !''.equals(userEmail)) 
        	mails.replace(userEmail,'').replace(',,',',');
        	
        if(mails!=null && !''.equals(mails)) {
            list<String> lsmails = mails.split(',');
            
            // Query contacts by email addresses
            map<Id,Contact> contactsById = new map<Id,Contact>([SELECT Name, Email, AccountId, Account.Name FROM Contact WHERE Email IN :lsmails]);

			// Get accounts for these contacts
        	FilingCriterionObject fco = FilingUtils.getFilingCriterionByApiName(Schema.SObjectType.Contact.getName());
			AccountSObjectRelation[] asors = new List<AccountSObjectRelation>();
            if(String.isNotEmpty(fco.relationshipToAccountImpClass)){
				AccountSObjectInterface accRelImpl = (AccountSObjectInterface)fco.getInstanceOfRelationshipToAccountImpl();
				if (accRelImpl != null){
					List<ID> cntIds = new List<ID>(contactsById.keySet());
					if (objForDocument != null && !StringUtils.isNullOrEmpty(objForDocument.Contact_Id__c))
						cntIds.add(objForDocument.Contact_Id__c);
					asors = accRelImpl.getAccountSObjectRelations(cntIds);
				}
            }
			
			list<Contact> contactsWithoutAccounts = new List<Contact>();

			// Filter double links
			for(AccountSObjectRelation asor:asors){
				if(contactsById.containsKey(asor.objectId))
					contactsById.remove(asor.objectId);
			}

			// Add contact-account relation to the list, not only by the custom logic, but by direct link. 
			for (ID cId: contactsById.keySet()){
				Contact c = contactsById.get(cId);
				if (c.AccountId != null)
					asors.add(new AccountSObjectRelation(cId, c.Name, c.Email, c.AccountId, c.Account.Name));
				else
					contactsWithoutAccounts.add(c);
			}
			
            return new InitEmailResult(asors, contactsWithoutAccounts);
        }
        return null;        
    }

    private list<Schema.PicklistEntry> getPicklistEntries(String entityName,String fieldName){
        Schema.SObjectType targetType = gd.get(entityName);
        map<String, Schema.SObjectField> fieldsMap = targetType.getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldDesc = fieldsMap.get(fieldName).getDescribe();
        return fieldDesc.getPicklistValues();
    }
    
    private map<String,String> getPicklistValues(String entityName, String pickListField){
        list<Schema.PicklistEntry> ple = getPicklistEntries(entityName, pickListField);
        map<String,String> retmap = new map<String,String>();
        for (Schema.PicklistEntry p:ple) {
            retmap.put(p.getValue(), p.getLabel());
        }
        return retmap;          
    }
    
    /*
        initialEntityFilingParam: entity type name=>list=>FileEntity
    */
    private String createInitialJsonFile(map<String,String> doctypes, map<String,String> taskStatus,map<String,String> taskPriority, InitialFilingParam initialFilingParam){
        JSONGenerator jsongen = Json.createGenerator(false);
        jsongen.writeStartObject();
        jsongen.writeNumberField('emailnum', fileEmailsCount);
        system.debug('initialFilingParam:' + initialFilingParam);
        
        if(initialFilingParam!=null){
            jsongen.writeFieldName('init');
            jsongen.writeStartObject();
            jsongen.writeStringField('enttype', initialFilingParam.entTypeName);
            jsongen.writeStringField('entName',initialFilingParam.entName);
            jsongen.writeIdField('entId', initialFilingParam.entId);
            jsongen.writeFieldName(ACCOUNT_JSON_BASE_FIELD_NAME +'s');
            jsongen.writeStartArray();
            if( initialFilingParam.acts!=null){
                for(InitialFilingParamEntity act: initialFilingParam.acts){
                    jsongen.writeStartObject();
                    jsongen.writeStringField(ACCOUNT_JSON_BASE_FIELD_NAME +'Name', act.name);
                    jsongen.writeStringField(ACCOUNT_JSON_BASE_FIELD_NAME +'Id', act.id);
                    jsongen.writeEndObject();
                }
            }
            jsongen.writeEndArray();
            jsongen.writeEndObject();
        }
        createInitialJsonCommon(jsongen, doctypes, taskStatus, taskPriority);
        jsongen.writeEndObject();
        system.debug('json : ' + jsongen.getAsString());
        return jsongen.getAsString();
        
    }
    

	/**
	* This method handles the query from the Object_for_Document__c
	*
	*/
    private Object_for_Document__c queryObjectForDocument(){
        Object_for_Document__c initialObjectData;

        List<String> criteriaFields = new List<String>();
        for (FilingCriterionObject fco: FilingUtils.getAllFilingCriterionObjects())
        	criteriaFields.add(fco.name);

        if(criteriaFields.isEmpty())
        	return null;

        String query = 'SELECT OwnerId, Account_Name__c,' + string.join(criteriaFields,'_Id__c,') + '_Id__c\n' +
		      			'FROM Object_for_Document__c\n' + 
						'WHERE OwnerId = \'' + UserInfo.getUserId() + '\'\n';
        try {
			 initialObjectData = (Object_for_Document__c)database.query(query);
        } 
        catch (Exception e) {}
        
        return initialObjectData;
    }
    
    private String createInitialJsonEmail(InitEmailResult initres, Object_for_Document__c initialObjectData, map<String,String> doctypes, map<String,String> taskStatus,map<String,String> taskPriority){
        List<String> criteriaFields = new List<String>();
        for (FilingCriterionObject fco: FilingUtils.getAllFilingCriterionObjects())
        	criteriaFields.add(fco.name);

        if(criteriaFields.isEmpty())
        	return null;
        
		// Create a map of AccountSObjectRelation by account id
        map<Id, list<AccountSObjectRelation>> asorByAccountId = new map<Id, list<AccountSObjectRelation>>();
        list<AccountSObjectRelation> templist;
        
        // Params for initializations
        String initialAccountId;
        String initialAccountName;
        
        if(initres!=null && initres.aps!=null && !initres.aps.isEmpty()){
            for(AccountSObjectRelation ap: initres.aps){
                if((templist = asorByAccountId.get(ap.accountId)) == null)
                    templist = new list<AccountSObjectRelation>();
                templist.add(ap);
                asorByAccountId.put(ap.accountId,templist);
            }
            
            initialAccountId = initres.aps[0].accountId;
            initialAccountName = initres.aps[0].accountName;
        }
        
        
        if (initialObjectData != null && initialObjectData.Account_Id__c != null){
        	initialAccountId = initialObjectData.Account_Id__c;
        	initialAccountName = initialObjectData.Account_Name__c;
        }
        
        
        // Start building the JSON
        JSONGenerator jsongen = Json.createGenerator(false);
        jsongen.writeStartObject();
        jsongen.writeNumberField('emailnum', fileEmailsCount);
        
        jsongen.writeFieldName(ACCOUNT_JSON_BASE_FIELD_NAME + 's');
        jsongen.writeStartArray();
        if (initialObjectData != null && initialObjectData.Account_Id__c != null) {
            jsongen.writeStartObject();
            jsongen.writeIdField(ACCOUNT_JSON_BASE_FIELD_NAME + 'Id', initialObjectData.Account_Id__c);
            jsongen.writeStringField(ACCOUNT_JSON_BASE_FIELD_NAME + 'Name', initialObjectData.Account_Name__c);
            jsongen.writeEndObject();
        }
        system.debug('asorByAccountId>' + asorByAccountId.size() + ' ' + asorByAccountId);
        for(Id key: asorByAccountId.keyset()){
            jsongen.writeStartObject();
            if (String.isNotBlank(key)){
	            jsongen.writeIdField(ACCOUNT_JSON_BASE_FIELD_NAME + 'Id', key);
	            jsongen.writeStringField(ACCOUNT_JSON_BASE_FIELD_NAME + 'Name', asorByAccountId.get(key)[0].accountName);
            }
            jsongen.writeFieldName(CONTACT_JSON_BASE_FIELD_NAME + 's');
            jsongen.writeStartArray();
            for(AccountSObjectRelation ap: asorByAccountId.get(key)){
                jsongen.writeStartObject();
               	jsongen.writeStringField('email',ap.objectEmail==null?'':ap.objectEmail);
                jsongen.writeStringField(CONTACT_JSON_BASE_FIELD_NAME + 'Name',ap.objectName);
                jsongen.writeIdField(CONTACT_JSON_BASE_FIELD_NAME + 'Id',ap.objectId);
                jsongen.writeEndObject();
            }
            jsongen.writeEndArray();
            jsongen.writeEndObject();
        }
        asorByAccountId = null;
        jsongen.writeEndArray();
        //"independent" contacts (no account)
        jsongen.writeFieldName('indcnts');
        jsongen.writeStartArray();
        if (initialObjectData != null && initialObjectData.Contact_Id__c != null) {
            Contact tc = [SELECT Name, Email From Contact Where id = :initialObjectData.Contact_Id__c];
            jsongen.writeStartObject();
            jsongen.writeStringField('email',tc.Email==null?'':tc.Email);
            jsongen.writeIdField(CONTACT_JSON_BASE_FIELD_NAME + 'Id', initialObjectData.Contact_Id__c);
            jsongen.writeStringField(CONTACT_JSON_BASE_FIELD_NAME + 'Name', tc.Name);
            jsongen.writeEndObject();
        }
        if(initres!=null && initres.cnts!=null && !initres.cnts.isEmpty())
        for(Contact cnt: initres.cnts){
            jsongen.writeStartObject();
           	jsongen.writeStringField('email',cnt.Email==null?'':cnt.Email);
            jsongen.writeStringField(CONTACT_JSON_BASE_FIELD_NAME + 'Name',cnt.Name);
            jsongen.writeIdField(CONTACT_JSON_BASE_FIELD_NAME + 'Id',cnt.Id);
            jsongen.writeEndObject();
        }
        jsongen.writeEndArray();
        createInitialJsonCommon(jsongen, doctypes, taskStatus, taskPriority);
        
        if (initialObjectData != null) {
            jsongen.writeFieldName('init');
            
            jsongen.writeStartObject();
            
            if(String.IsNotBlank(initialAccountId)){
	            jsongen.writeIdField(ACCOUNT_JSON_BASE_FIELD_NAME + 'Id', initialAccountId);
	            jsongen.writeStringField(ACCOUNT_JSON_BASE_FIELD_NAME + 'Name', initialAccountName);
            }
            else{
            	jsongen.writeNullField(ACCOUNT_JSON_BASE_FIELD_NAME + 'Id');
            	jsongen.writeNullField(ACCOUNT_JSON_BASE_FIELD_NAME + 'Name');
            }
            
            jsongen.writeFieldName('entities');
            jsongen.writeStartArray();
            for(String criteriaField: CriteriaFields){
            	if (initialObjectData.get(criteriaField + '_Id__c')!= null){
            		String entname = '';
                	list<sobject> ls= database.query('SELECT Name FROM ' + Novidea_Document_Management_List__c.getInstance(criteriaField).Object_Type_Name__c + ' WHERE Id=\'' + initialObjectData.get(criteriaField + '_Id__c') + '\'');
                	if(!ls.isempty())entname = (String)ls[0].get('Name');
                		createInitialJsonValue(jsongen, (Id)initialObjectData.get(criteriaField + '_Id__c'), Novidea_Document_Management_List__c.getInstance(criteriaField).Object_Type_Name__c.toLowerCase(), entname);
            	}
					
            }
            jsongen.writeEndArray();
            
            jsongen.writeFieldName(ACCOUNT_JSON_BASE_FIELD_NAME + 's');
            jsongen.writeStartArray();
            jsongen.writeStartObject();
            if(String.IsNotBlank(initialAccountId)){
	            jsongen.writeIdField(ACCOUNT_JSON_BASE_FIELD_NAME + 'Id', initialAccountId);
	            jsongen.writeStringField(ACCOUNT_JSON_BASE_FIELD_NAME + 'Name', initialAccountName);
            }
            else{
            	jsongen.writeNullField(ACCOUNT_JSON_BASE_FIELD_NAME + 'Id');
            	jsongen.writeNullField(ACCOUNT_JSON_BASE_FIELD_NAME + 'Name');
            }
            jsongen.writeEndObject();
            jsongen.writeEndArray();
            
            Database.delete(initialObjectData);
            
            jsongen.writeEndObject();
        } 
        
        jsongen.writeEndObject();
        system.debug('json : ' + jsongen.getAsString());
        return jsongen.getAsString();
    }
    
    private void createInitialJsonValue(JSONGenerator jsongen, String entId, String entTypeName, String entname) {
	    jsongen.writeStartObject();
	    jsongen.writeStringField('enttype', entTypeName);
	    jsongen.writeIdField('entId', entId);
	    jsongen.writeStringField('entname', entname);
	    jsongen.writeEndObject();
    }
    
    
    private void createInitialJsonCommon(JSONGenerator jsongen, map<String,String> doctypes, map<String,String> taskStatus,map<String,String> taskPriority){
        jsongen.writeFieldName('doctypes');
        jsongen.writeStartArray();
        List<String> orderDocTypes = new List<String>(doctypes.keyset());
        orderDocTypes.sort();
        for(String key: orderDocTypes){
            jsongen.writeStartObject();
            jsongen.writeStringField('value', key);
            jsongen.writeStringField('label', doctypes.get(key));
            jsongen.writeEndObject();
        }
        jsongen.writeEndArray();
        jsongen.writeFieldName('taskstatus');
        jsongen.writeStartArray();
        for(String key: taskStatus.keyset()){
            jsongen.writeStartObject();
            jsongen.writeStringField('value', key);
            jsongen.writeStringField('label', taskStatus.get(key));
            jsongen.writeEndObject();
        }
        jsongen.writeEndArray();
        jsongen.writeFieldName('taskprio');
        jsongen.writeStartArray();
        for(String key: taskPriority.keyset()){
            jsongen.writeStartObject();
            jsongen.writeStringField('value', key);
            jsongen.writeStringField('label', taskPriority.get(key));
            jsongen.writeEndObject();
        }
        jsongen.writeEndArray();
    }
    
    @RemoteAction
    public static String getAccountRelatedDataLists(String accountId){
        String query='SELECT Name,\n';
        String subQuery = '(SELECT Name,Is_Active_In_Filing_Criteria__c{0} FROM {1} ORDER BY LastModifiedDate DESC LIMIT 50),\n';
        for(FilingCriterionObject fco: FilingUtils.getFilingCriterionObjects()){
            query+=String.format(subQuery, new String[]{String.isBlank(fco.idFieldsCsv)?'':
            					',' + fco.idFieldsCsv, fco.relationToAccountFieldName});
        }
        query = query.removeEnd(',\n') + '\n';
        string strActId = (accountId==null || accountId=='0')?'null':('\'' + accountId + '\'');
        query += 'FROM Account\n' +
				 'WHERE Id=' + strActId + '\n';
		system.debug(query);
		list<Account> lsaccounts = (list<Account>)database.query(query);		 
        return buildAccountRelatedDataJson(lsaccounts);
    }

    private static Boolean getStatus(sObject sobj){
    	return 1==((Decimal)sobj.get('Is_Active_In_Filing_Criteria__c')).intValue();
    } 

    private static String buildAccountRelatedDataJson(list<Account> acts){
        JSONGenerator jsongen = Json.createGenerator(false);
        jsongen.writeStartObject();
        jsongen.writeFieldName(ACCOUNT_JSON_BASE_FIELD_NAME +'s');
        jsongen.writeStartArray();
        for(Account act: acts){
            jsongen.writeStartObject();
            jsongen.writeIdField(ACCOUNT_JSON_BASE_FIELD_NAME + 'Id', act.Id);
            for(FilingCriterionObject fco: FilingUtils.getFilingCriterionObjects()){
				jsongen.writeFieldName(fco.jsonBaseFieldName + 's');
	            jsongen.writeStartArray();
	            if(act.getSObjects(fco.relationToAccountFieldName)!=null){
		            for(sObject obj: act.getSObjects(fco.relationToAccountFieldName)){
		                jsongen.writeStartObject();
		                jsongen.writeIdField(fco.jsonBaseFieldName + 'Id', obj.Id);
		                jsongen.writeStringField(fco.jsonBaseFieldName + 'Name', (String)obj.get('Name'));
		                jsongen.writeBooleanField(fco.jsonBaseFieldName + 'Status', getStatus(obj));
		                jsongen.writeEndObject();
	            	}
	            }
             	jsongen.writeEndArray();
            }
            jsongen.writeEndObject();
        }
        jsongen.writeEndArray();
        jsongen.writeEndObject();
        system.debug('json : ' + jsongen.getAsString());
        return jsongen.getAsString();
    }


    public class FileEmailAdress{
        String email {get;set;}
        String nick {get;set;}
        public FileEmailAdress(String email, String nick){
            this.email = email;
            this.nick = nick;
        }
    }
    public class FileEmailAttachment{
        Long size {get;set;}
        String name {get;set;}
        integer index {get;set;} // diana added index 25/06/2013
        public FileEmailAttachment(Long size, String name, integer index){
            this.size = size;
            this.name = name;
            this.index = index;
        }
    }
    
    public class FileEmail{
        String subject {get;set;}
        Datetime datereceived {get;set;}
        list<FileEmailAttachment> attachments {get;set;}
        list<FileEmailAdress> to {get;set;}
        list<FileEmailAdress> cc {get;set;}
        list<FileEmailAdress> bcc {get;set;}
        FileEmailAdress sender {get;set;}
        String preview {get;set;}
        boolean isfiled {get;set;}
        String entryid {get;set;}
        
        public FileEmail(String subject, Datetime datereceived, list<FileEmailAttachment> attachments, 
                list<FileEmailAdress> to, list<FileEmailAdress> cc, list<FileEmailAdress> bcc, 
                FileEmailAdress sender, String preview, boolean isfiled, String entryid){
            this.subject = subject;
            this.datereceived = datereceived;
            this.attachments = attachments;
            this.to = to;
            this.cc = cc;
            this.bcc = bcc;
            this.sender = sender;
            this.preview = preview;
            this.isfiled = isfiled;
            this.entryid = entryid; 
        }
    }
    
    
    public class FileAccount{
        String acid {get;set;}
        String acname {get;set;}
        String selId {get;set;} 
        String selName {get;set;}
        String name {get;set;}
        // TODO: Rolan - refactor to map
        Map<String, Integer> dynEntFilters;
        Integer appfilter {get;set;}
        Integer plcfilter {get;set;}
        Integer clmfilter {get;set;}
        Integer ptlfilter {get;set;}
        Integer prjfilter {get;set;}
        Integer iicfilter {get;set;}
        public FileAccount(String acid, String acname, String selId, String selName, String name, Map<String, Integer> dynEntFilters){
            this.acid = acid;
            this.acname = acname;
            this.selId = selId;
            this.selName = selName;
            this.name = name;
			this.dynEntFilters = dynEntFilters;
        }
        
        public FileAccount(String acid, String acname, String selId, String selName, String name, Integer appfilter, Integer plcfilter,  Integer clmfilter, Integer ptlfilter, Integer prjfilter, Integer iicfilter){
            this.acid = acid;
            this.acname = acname;
            this.selId = selId;
            this.selName = selName;
            this.name = name;
            this.appfilter = appfilter;
            this.plcfilter = plcfilter;
            this.clmfilter = clmfilter;
            this.ptlfilter = ptlfilter;
            this.prjfilter = prjfilter;
            this.iicfilter = iicfilter;
        }
        
    }
    public class FileContact{
        String acid {get;set;} 
        String email {get;set;}
        String name {get;set;}
        Boolean newcnt {get;set;}
        Boolean filecnt {get;set;}
        
        public FileContact(String acid, String email, String name, Boolean newcnt, Boolean filecnt){
            this.acid = acid;
            this.email = email;
            this.name = name;
            this.newcnt = newcnt;
            this.filecnt = filecnt;
        }
    }
    
    public class FileEntity{
        String selId {get;set;} 
        String selName{get;set;}
        public FileEntity(String selId, String selName){
            this.selId= selId;
            this.selName = selName;
        }
    }
    
    public class FileTask{
        String status {get;set;}
        String connectto {get;set;}
        String connecttocnt {get;set;}
        String prio {get;set;} 
        String subject {get;set;}
        String due {get;set;}
        String remind {get;set;}
        String remindtime{get;set;}
        String assignedTo{get;set;}
        public FileTask(String status, String connectto, String connecttocnt, String prio, String subject, String due, String remind, String remindtime){
            this.status = status;
            this.connectto = connectto;
            this.connecttocnt = connecttocnt;
            this.prio =  prio;
            this.subject = subject;
            this.due = due;
            this.remind = remind;
            this.remindtime = remindtime;
        }
    }
    public class File{
        Boolean istemplate {get;set;}
        Integer id {get;set;}
        String path {get;set;}
        list<String> dtypes {get;set;}
        FileAccount act {get;set;}
        list<FileContact> cnts {get;set;}

		Map<String, FileEntity> dynEnts {get; set;}
		// TODO: Rolan - delete the specific ents, this might affect outlook addin
        FileEntity app {get;set;}
        FileEntity plc {get;set;}
        FileEntity clm {get;set;}
        FileEntity ptl {get;set;}
        FileEntity prj {get;set;}
        FileEntity iic {get;set;}

        String cmnt {get;set;}
        Boolean prvt {get;set;}
        Boolean newtsk {get;set;}
        FileTask tsk  {get;set;}
        integer fileWhat { get; set; } //diana
        List<integer> fileAttachmentInds { get; set; } //diana
        
        public File(Boolean istemplate, Integer id, String path, list<String> dtypes,FileAccount act,list<FileContact> cnts,
            Map<String, FileEntity> dynEnts, String cmnt, Boolean prvt, Boolean newtsk, FileTask tsk,
            integer fileWhat, List<integer> fileAttachmentInds){
            this.istemplate = istemplate; 
            this.id = id;
            this.path = path;
            this.dtypes =dtypes; 
            this.act = act;
            this.cnts = cnts;
            this.dynEnts = dynEnts;
            this.cmnt = cmnt;
            this.prvt = prvt;
            this.newtsk = newtsk;
            this.tsk = tsk;
            this.fileWhat = fileWhat;
            this.fileAttachmentInds = fileAttachmentInds;
            	
        }

		// TODO: Rolan - delete the constructor for specific ents, this might affect outlook addin
        public File(Boolean istemplate, Integer id, String path, list<String> dtypes,FileAccount act,list<FileContact> cnts,
            FileEntity app, FileEntity plc, FileEntity clm, FileEntity ptl, FileEntity prj, FileEntity iic, String cmnt, Boolean prvt, Boolean newtsk, FileTask tsk,
            integer fileWhat, List<integer> fileAttachmentInds){
            
            this.istemplate = istemplate; 
            this.id = id;
            this.path = path;
            this.dtypes =dtypes; 
            this.act = act;
            this.cnts = cnts;
            this.app = app;
            this.plc = plc;
            this.clm = clm;
            this.ptl = ptl;
            this.prj = prj;
            this.iic = iic;
            this.cmnt = cmnt;
            this.prvt = prvt;
            this.newtsk = newtsk;
            this.tsk = tsk;
            this.fileWhat = fileWhat;
            this.fileAttachmentInds = fileAttachmentInds;
        }
    }
    
    public class FileWrapper{
        File file {get;set;}
        public FileWrapper(File file){
            this.file = file;
        }
    }
    
    public class FilesData{
        list<FileWrapper> files{get;set;}
        list<FileEmail> emails{get;set;}
        public FilesData(list<FileWrapper> files, list<FileEmail> emails){
            this.files = files;
            this.emails = emails;
        }
    }

    public class FileResult{
          public Boolean success = true;
          public String errordesc='';
          public  boolean isSingleFiling = false;
          public FileResult(String errordesc, boolean isSingleFiling){
              this.success = false;
              this.errordesc  = errordesc ;
          }
          public FileResult(boolean isSingleFiling){this.isSingleFiling = isSingleFiling;}
    }

    public void dummy(){}

    @RemoteAction
    public static Contact initContact(String cntId){
        Contact c = [select firstName, lastName, Name, AccountId from contact where id=:cntId];
        return c;
    }
    
    private static String[] getNameParts(String name){
        String fname, lname;
        String[] namecrumbs = name.split(' ');
        for(integer i=0; i<namecrumbs.size();++i){
            if(namecrumbs.get(i).trim()=='')continue;
            if(fname==null) fname=namecrumbs.get(i);
            else lname = namecrumbs.get(i);
            if(fname!=null && lname!=null)break;
        }
        if(fname!=null && lname==null){
            lname = fname; fname = null;
        }
        return new String[]{fname, lname};
        
    }


    private static map<Boolean,list<String>> getUsedFieldsMapInstance(map<String, Schema.SObjectField> fieldmap){
        map<Boolean,list<String>> usedFieldsMap = new map<Boolean,list<String>>{true=>new list<String>()};
        list<String> fieldList = new list<String>();
        for(String key: fieldmap.keyset()){
            if(key.toLowerCase().startsWith('entid'))fieldList.add(key);
        }
        usedFieldsMap.put(false,fieldList);
        return usedFieldsMap;
        
    }
    
    private static boolean isNewContactExists(File file){
        boolean retval = false;
        for(FileContact cnt: file.cnts){
            
        }
        return retval;
    }
    
    //TODO: this depends if a value in hebrew is set in dept. filed for an english user we'll get a problem of not locating the value...
    private static String getUserDeptValue(){
        String userDept = [SELECT Department FROM User WHERE Id=:Userinfo.getUserId()].Department;
        system.debug('userDept: ' + userDept);
        map<String,String> depts = ArrayUtils.getPicklistValues('Department__c', InboundDocument__c.sObjectType);
        system.debug(depts.values());
        if(!depts.containsKey(userDept)){
            if(!(new set<String>(depts.values())).contains(userDept)){
                userDept=null;
            }
            else{
                boolean deptFound = false;
                for(String key:depts.keyset()){
                    system.debug(key + ' depts.get(key): ' + depts.get(key) + ' userDept: ' + userDept);
                    if(depts.get(key).equalsIgnoreCase(userDept)){
                        userDept=key;
                        deptFound= true;
                        break;
                    }
                }
                if(!deptFound)userDept= null;
            }
        }
        return userDept;
    }
    
    private static void file(FilesData filesdata, boolean isEmail){
        map<Integer,list<Contact>> cntsByFileId = new map<Integer,list<Contact>>();
        File file;
        FileEmail fileEmail;
        list<Contact> cnts;
        integer index = -1;
        map<Integer,InboundDocument__c> docs = new map<Integer,InboundDocument__c>();
        map<Integer,Task> tasks = new map<Integer,Task>();
        set<Integer> tasksConnectedToDoc = new set<Integer>();
        set<Integer> tasksConnectedToNewCnt = new set<Integer>();
        map<String, Schema.SObjectField> fieldmap = Schema.SObjectType.InboundDocument__c.fields.getMap();
        map<Boolean,list<String>> usedFieldsMap;
        map<Integer, map<Boolean,list<String>>> usedFieldsMaps = new map<Integer, map<Boolean,list<String>>>();
        boolean singleTaskAdded = false, newContactsCreated = false, newContactTaskCreated = false;
        String userDept = getUserDeptValue();
        system.debug(userDept);
        for(FileWrapper fw : filesdata.files){
            //do not refile an already filed mail
            if(filesdata.emails[++index].isfiled!=null && filesdata.emails[index].isfiled){
                //TODO: assumes that new contacts and tasks in this mail have been created so no need to create again
                //this might need to handle differently since filing can change after "filing one"
                newContactsCreated = newContactTaskCreated = singleTaskAdded =true;
                continue;
            }
            file = fw.file;
            fileEmail = filesdata.emails[index];
            //TODO: handle template data
            if(file==null)continue;
            //build new contacts if required
            if(!newContactsCreated){
                for(FileContact cnt: file.cnts){
                    system.debug(cnt.filecnt + '; ' + cnt.newcnt  + '; ' + cnt.acid);
                    if(cnt.filecnt && cnt.newcnt &&  (cnt.acid==null || ''.equals(cnt.acid))){
                        String[] nameparts = getNameParts(cnt.name);
                        if((cnts=cntsByFileId.get(file.id))==null)
                            cnts = new list<Contact>();
                        cnts.add(new Contact(Email=cnt.email, firstname=nameparts[0], lastname = nameparts[1] ));
                        cntsByFileId.put(file.id,cnts);
                        newContactsCreated = true;
                    }
                }
            }
            //build actual filing in a map according to file.id. Leave space for later Id of newly created contacts 
            //that will be identified by crossing cnt email and file.id
            usedFieldsMap = getUsedFieldsMapInstance(fieldmap);
            InboundDocument__c doc =  getPopulatedDoc(file, fileEmail, isEmail, usedFieldsMap, userDept);
            usedFieldsMaps.put(file.id, usedFieldsMap);
            docs.put(file.id,doc);
            if(!singleTaskAdded){
                Task task = createTask(file);
                if(task!=null){
                    tasks.put(file.id, task);
                    singleTaskAdded = true;
                }

                if(isTaskConnectedToDoc(file)){
                    tasksConnectedToDoc.add(file.id);
                }
                if(isTaskRequireNewCnt(file)){
                    tasksConnectedToNewCnt.add(file.id);
                }
            }
        }
        system.debug(cntsByFileId);
        cnts = new list<Contact>();
        for(Integer key : cntsByFileId.keyset()){
            cnts.addAll(cntsByFileId.get(key));
        }
        System.SavePoint sp = Database.setSavepoint();
        try{
            system.debug(cnts);
            if(cnts!=null && !cnts.isEmpty())Database.insert(cnts);

            list<Task> newContactTasks = new list<Task>();
            for(Integer key : docs.keyset()){
            	InboundDocument__c doc = docs.get(key);
            	usedFieldsMap = usedFieldsMaps.get(key);
            	//raniz 31/1/13: here only one set of contacts exist and is relavant for all docs
            	//it was built as list per doc to support different list per doc - not supported now 
                for(list<Contact> cntls : cntsByFileId.values()){
                    for(Contact cnt: cntls){
                        if(!newContactTaskCreated) {
                            newContactTasks.add(createNewContactTask(cnt));
                        }
                        doc.put(usedFieldsMap.get(false)[0],cnt.Id);
                        usedFieldsMap.get(true).add(usedFieldsMap.get(false).remove(0));
                    }
                }
                newContactTaskCreated = true;
            }
            String cntname;
            String[] nameparts; 
            for(Integer i: tasksConnectedToNewCnt){
                cntname = filesData.files[i].file.tsk.connecttocnt;
                system.debug(filesData.files[i].file.tsk);
                nameparts = getNameParts(cntname);
                system.debug('nameparts : ' + nameparts);
                for(Contact cnt: cntsByFileId.get(i)){
                    system.debug(cnt);
                    if(cnt.FirstName.equalsIgnoreCase(nameparts[0]) && cnt.LastName.equalsIgnoreCase(nameparts[1])){
                        Task tsk = tasks.get(i);
                        tsk.WhoId = cnt.id;
                        break;
                    }
                }
            }
            newContactTasks.addall(tasks.values());
            system.debug(newContactTasks);
            if(!newContactTasks.isEmpty())database.insert(newContactTasks);
			newContactTasks = null;
			
			Task tmpTask;
			if(!tasks.isempty()){
				for(Integer key: docs.keyset()){
					usedFieldsMap = usedFieldsMaps.get(key);
					//raniz: 31/1/2013: here also treat the task map as relevant for all docs
					//originaly built to enable saving different task per doc - not supported now
					docs.get(key).put(usedFieldsMap.get(false)[0],tasks.values()[0].Id);
                    usedFieldsMap.get(true).add(usedFieldsMap.get(false).remove(0));
				}
			}
            system.debug(docs.values());
            database.insert(docs.values());
            
            //update the tasks that are doc related
            Task[] tasksToUpdate = new Task[]{};
            for(Integer i: tasksConnectedToDoc){
                tmpTask = tasks.get(i);
                tmpTask.WhatId = docs.get(i).id;
                tasksToUpdate.add(tmpTask);
            }
            Database.update(tasksToUpdate);

        }
        catch(Exception ex){
            Database.rollback(sp);
            throw ex;
        }
    }
    
    private static InboundDocument__c populateDoc(InboundDocument__c doc,File file, FileEmail fileEmail, boolean isEmail){
    	
    	doc.Subject__c = fileEmail.subject;
    	doc.Email_Preview__c = isEmail?fileEmail.preview:null; 
    	if(fileEmail.attachments!=null && !fileEmail.attachments.isEmpty())doc.Attachments__c = JSON.serialize(fileEmail.attachments); 
    	doc.Sender__c =  isEmail?fileEmail.sender.nick:null;
        doc.Sender_Email__c =  isEmail?fileEmail.sender.email:null;
        doc.Has_Attachment__c = isEmail && fileEmail.attachments!=null && !fileEmail.attachments.isEmpty();
        //AEF: 09/06/2014
        doc.TO__c = '';
        if(!ArrayUtils.isListNullOrEmpty(fileEmail.to))
        	doc.TO__c += joinEmails(fileEmail.to, RECEIVER_SEARCH_PREFIX_TO);
        
        if(!ArrayUtils.isListNullOrEmpty(fileEmail.cc))
        	doc.TO__c += DATA_DELIMITER + joinEmails(fileEmail.cc, RECEIVER_SEARCH_PREFIX_CC);
        	
    	if(!ArrayUtils.isListNullOrEmpty(fileEmail.bcc))
        	doc.TO__c += DATA_DELIMITER + joinEmails(fileEmail.bcc, RECEIVER_SEARCH_PREFIX_BCC);
        
    	return doc; 
    	
    }
    //AEF: 09/06/2014
    private static String joinEmails(list<FileEmailAdress> emailList, String prefix) {
    	
    	String joinEmailStr;
    	for(FileEmailAdress fea : emailList) {
    		String data = prefix + fea.email;
    		if(String.isNotBlank(joinEmailStr))
    			joinEmailStr += DATA_DELIMITER + data;
    		else
    			joinEmailStr = data;
    	}
    	return joinEmailStr;
    }
    /*
    	create one inboundDoc obj per one attachment, requirement for one inboundDoc and many attachments requires changes
    */
   
    private static InboundDocument__c populateDocForAttachment(InboundDocument__c doc,File file, FileEmail fileEmail, boolean isEmail){
    
		system.debug('fileEmail.attachments: ' + fileEmail.attachments);
		system.debug('file.fileAttachmentInds: '+ file.fileAttachmentInds);
		doc.Email_Preview__c = null;
		doc.Sender__c = null;
		doc.Sender_Email__c = null;
		doc.Has_Attachment__c = false; 
		FileEmailAttachment[] fileEmailAttachment = new FileEmailAttachment[]{};
		for(FileEmailAttachment fma :fileEmail.attachments){
			for(integer f: file.fileAttachmentInds){
				if(fma.index == f){
					doc.Subject__c = fma.name;
					fma.name = fileEmail.subject + string.valueOf(fileEmail.datereceived) +'/'+ fma.name;
					fileEmailAttachment.add(fma);
        			break;
				}
			}
		}
		doc.Attachments__c = JSON.serialize(fileEmailAttachment); 
		return doc;  	
    }
    
    private static InboundDocument__c getPopulatedDoc(File file, FileEmail fileEmail, boolean isEmail, map<Boolean,list<String>> usedFieldsMap, String userDept){
        
        system.debug('diana' + fileWhatParam);
        InboundDocument__c doc = new InboundDocument__c();
        if(!isEmail || file.fileWhat == 2 || file.fileWhat == null)//diana
        	doc = populateDoc(doc, file, fileEmail, isEmail);
        else if(isEmail && file.fileWhat == 1)//diana
        	doc = populateDocForAttachment(doc, file, fileEmail, isEmail);
        
        doc.Date_Received__c = fileEmail.datereceived;
        doc.Comments__c = file.cmnt;
        doc.Private__c = file.prvt;
        String strtemp = '';
        for(String doctype: file.dtypes) strtemp+=doctype+';';
        doc.Type__c = strtemp;
        doc.Physical_Path__c = file.path;
        if(file.act!=null){
            String actId = file.act.acid!=null && !''.equals(file.act.acid)?file.act.acid:file.act.selid!=null && !''.equals(file.act.selid)?file.act.selid: null;
            if(actId!=null){
                doc.put(usedFieldsMap.get(false)[0],actId);
                usedFieldsMap.get(true).add(usedFieldsMap.get(false).remove(0));
            }
        }

        system.debug(doc);
        for (FileEntity dynEnt: file.dynEnts.values()){
            doc.put(usedFieldsMap.get(false)[0],dynEnt.selId);
            usedFieldsMap.get(true).add(usedFieldsMap.get(false).remove(0));
        }

        if(file.cnts!=null && !file.cnts.isEmpty()){
            String cntId = null;
            for(FileContact fc:file.cnts){
                if(fc.filecnt && !fc.newcnt){
                    cntId = fc.acid!=null && !''.equals(fc.acid)?fc.acid:null;
                }
                if(cntId!=null){
                    doc.put(usedFieldsMap.get(false)[0],cntId);
                    usedFieldsMap.get(true).add(usedFieldsMap.get(false).remove(0));
                }
                cntId=null;
            }
        }
        
        doc.Department__c = userDept;
        return doc;
    }
 
    private static Task createNewContactTask(Contact cnt){
        Task task = new Task();
        task.OwnerId = Userinfo.getUserId();
        task.Subject = 'טיוב איש קשר חדש';
        task.ReminderDateTime = Datetime.now().addDays(1);
        task.IsReminderSet = true;
        task.WhoId = cnt.Id;
        task.ActivityDate = Date.Today().addDays(7);
        task.Priority = 'Normal';
        task.Status = 'Not Started';
        return task;
    } 
    
    private static Task createTask(File file){
        if(file.tsk==null || !file.newtsk)return null;
        Task task = new Task();
        if (String.isNotBlank(file.tsk.assignedTo))
        	task.OwnerId = file.tsk.assignedTo;
        else
        	task.OwnerId = Userinfo.getUserId();
        	
        task.Subject = file.tsk.subject;
        if(file.tsk.remind!=null && !''.equals(file.tsk.remind) && file.tsk.remindtime!=null){
            //TODO: handle this parsing correctly depending on the datetime format
            task.ReminderDateTime = Datetime.parse(file.tsk.remindtime +  ' ' + file.tsk.remind);
            task.IsReminderSet = true;
        }
        task.WhatId = getTaskWhatId(file);
        if (task.WhatId == null)
        	task.WhoId = getTaskWhoId(file);
        if(file.tsk.due!=null && !''.equals(file.tsk.due)) task.ActivityDate = Date.parse(file.tsk.due);
        task.Priority = file.tsk.prio;
        task.Status = file.tsk.status;
        return task;
    }
    
    private static boolean isTaskConnectedToDoc(File file){
        if(file.tsk==null || file.tsk.connectto==null)return false;
        return '1'.equals(file.tsk.connectto);
    }
 

    private static boolean isTaskRequireNewCnt(File file){
        if(file.tsk==null || !file.newtsk || file.tsk.connectto==null )return false;
        return 'cnt'.equals(file.tsk.connectto) && null==getTaskWhoId(file);
    }

    private static Id getTaskWhatId(File file){
        String DOC = '1', ACT = 'act',CNT  = 'cnt';
        if(file.tsk==null || file.tsk.connectto==null || ''.equals(file.tsk.connectto) || '0'.equals(file.tsk.connectto))return null;
        if(file.tsk.connectto==ACT)
            return getAccountId(file);
        else if (file.tsk.connectto==DOC)
            return null;//TODO: handle
        else if (file.tsk.connectto==CNT)
            return null;//TODO: handle
        else {
            FileEntity currEnt = file.dynEnts.get(file.tsk.connectto);
            if (currEnt != null && currEnt.selId != '0')
            	return currEnt.selId;
            	 
            return null;
        }
    }
    private static Id getTaskWhoId(File file){
        if(file.tsk==null || file.tsk.connectto==null || ''.equals(file.tsk.connectto) || !'cnt'.equals(file.tsk.connectto) || file.tsk.connecttocnt==null || 
            ''.equals(file.tsk.connecttocnt) || !file.tsk.connecttocnt.startsWith('003') || file.tsk.connecttocnt.length()<15)return null;
        return file.tsk.connecttocnt;
    }    
    private static String getAccountId(File file)
    {
        if (String.isNotBlank(file.act.acid)){
            return file.act.acid;
        }
        else{
            return file.act.selId;
        }
    }
    
    @RemoteAction
    public static FileResult file(String jsonEmails, boolean isSingleFiling, boolean isEmail){
    	system.debug('rrrr>'+jsonEmails);
        JSONParser parser = JSON.createParser(jsonEmails);
        FilesData filesdata  = (FilesData)parser.readValueAs(OutlookAddinController.FilesData.class);
    	system.debug('rrrr2>'+filesdata);
        try{
            file(filesdata, isEmail);
        }
        catch(Exception ex){
           system.debug(LoggingLevel.ERROR, ex);
           return new FileResult(ex.getMessage(),isSingleFiling);
        }
        return new FileResult(isSingleFiling);
    }
    
}