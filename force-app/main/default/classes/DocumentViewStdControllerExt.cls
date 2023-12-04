public with sharing class DocumentViewStdControllerExt {
    public DocumentSearchParams searchparams{get;set;}
    public string defaultFaxNumber{get;set;}
    public string defaultEmail{get;set;}
    public string defaultMobileSMS{get;set;}    
    public DocumentViewStdControllerExt(ApexPages.StandardController stdController) {
        String stype = stdController.getRecord().getSObjectType().getDescribe().getLocalName();
        Id id = stdController.getId();
        String name;
        if('Task'.equalsIgnoreCase(stype)) name = (String)stdController.getRecord().get('Subject');
        else name = (String)stdController.getRecord().get('name');
        system.debug('entname: ' + stype + ' entId: ' + id + ' name: ' + name);
        searchparams = createSearchParams(stype, id, name, true);
        //when fetching docs for a specific entity, fetch the imported and creaqted docs seperatly
        searchparams.splitQueryByImportedVSCreated = true;
        string entName = id.getSObjectType().getDescribe().getLocalName();
        string key;
        if(entName.contains('__c')) key= entName.left(entName.indexOf('__c'));
        else key = entName;
        if(key.contains('__'))key = key.substring(key.indexOf('__') + 2);
        system.debug(key);
        if( Novidea_Document_Management_List__c.getInstance(key)!=null){
            String defaultFaxNumberField = Novidea_Document_Management_List__c.getInstance(key).Default_Fax_Number_Field__c,
                   defaultEmailField = Novidea_Document_Management_List__c.getInstance(key).Default_Email_Field__c,
                   defaultMobileSMSField = Novidea_Document_Management_List__c.getInstance(key).Default_SMS_Phone_Field__c;
            String selectList = '';
            if(!string.isblank(defaultFaxNumberField))
                selectList += defaultFaxNumberField;
            if(!string.isblank(defaultEmailField)){
                if(selectList!='')selectList += ',';
                selectList += defaultEmailField;
            }
            if(!string.isblank(defaultMobileSMSField)){
                if(selectList!='')selectList += ',';
                selectList += defaultMobileSMSField;
            }
            if(!string.isEmpty(selectList)){
                sobject obj = database.query('SELECT ' + selectList + ' FROM ' + entName + ' WHERE Id=\'' + id + '\'')[0];
                if(!string.isblank(defaultFaxNumberField))defaultFaxNumber = (String)obj.get(defaultFaxNumberField);
                if(!string.isblank(defaultEmailField))defaultEmail = (String)obj.get(defaultEmailField);
                if(!string.isblank(defaultMobileSMSField))defaultMobileSMS = (String)obj.get(defaultMobileSMSField);                
            }
        }
    }
    
    public void init(){
        String stype = Apexpages.currentPage().getParameters().get('entstype');
        String entId = Apexpages.currentPage().getParameters().get('entid');
        String entname = Apexpages.currentPage().getParameters().get('entname');
        defaultFaxNumber = Apexpages.currentPage().getParameters().get('deffax');
        defaultEmail = Apexpages.currentPage().getParameters().get('defemail');
        defaultMobileSMS = Apexpages.currentPage().getParameters().get('defSMS');
        system.debug('entname: ' + stype + ' entId: ' + entId);
        if(null!=stype && !''.equals(stype) && null!=entId && !''.equals(entId)){
            searchparams = createSearchParams(stype, entId, entname, false);
        }
        system.debug(searchparams);
    }
    
    public DocumentViewStdControllerExt(){}
    
    public DocumentSearchParams createSearchParams(String stype, String entId, String entname, boolean addOrderByCreated){
        DocumentSearchParams retval = new DocumentSearchParams();
        retval.acts = new List<DocumentSearchParams.CustomEntityFilter>();
        if('Account'.equalsIgnoreCase(stype)){
            retval.act = entId;
            retval.actname = entname;
            DocumentSearchParams.CustomEntityFilter cef = new DocumentSearchParams.CustomEntityFilter();
            cef.idStr = entId;
            cef.name = entname;
            retval.acts.add(cef);
        }
        else if('Contact'.equalsIgnoreCase(stype)){
            retval.cnt = entId;
            retval.cntname = entname;
            // TBD - add the same feature for contacts.
        }

        FilingCriterionObject fco = FilingUtils.getFilingCriterionByApiName(stype);
        retVal.customEnts = new Map<String,DocumentSearchParams.CustomEntityFilter>();
        DocumentSearchParams.CustomEntityFilter cef = new DocumentSearchParams.CustomEntityFilter();
        cef.idStr = entId;
        cef.name = entname;
        retVal.customEnts.put(fco.jsonPrefix,cef);
        try {
            AccountSObjectRelation[] asors = FilingUtils.getAccountSObjectRelationsById(entId);
            for (AccountSObjectRelation asor: asors){
                cef = new DocumentSearchParams.CustomEntityFilter();
                cef.idStr = asor.accountId;
                cef.name = asor.accountName;
                retval.acts.add(cef);
            }
            // TODO: Rolan insert custom implementation here. DONE.
            //retval.accountId = (String)(database.query('SELECT ' + fco.accountFieldName + ' FROM ' + fco.apiName + ' WHERE id=\'' + entId + '\' LIMIT 1')[0].get(fco.accountFieldName));
        } 
        catch (Exception e) {
            // TODO: Rolan - handle exceptions
        }

        if(addOrderByCreated){
            retval.orderby  = new DocumentSearchParams.DocumentSearchOrderByParam[]{};
            retval.orderby.add(new DocumentSearchParams.DocumentSearchOrderByParam('CreatedDate','DESC'));
        }

        return retval;
    }
}