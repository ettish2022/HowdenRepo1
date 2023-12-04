public with sharing class FlatModelHelper {
    private static Map<String, Schema.SObjectType> globalDescribe;
    private static Map<String, Schema.DescribeSObjectResult> objectDescriptionMap;
    private static Map<String, Map<String,Map<String,String>>> picklistVlaueToLabel;
    public static Map<String, Map<String, String>> allFieldsObjectsMap = new Map<String, Map<String, String>>();
    private static Map<String, Map<String,Schema.DescribeFieldResult>> fieldsDescriptionMap;
    
    
    
    // TBD - save the field description in order to prevent describe limits.
    // Go over all places needing and Schema.DescribeFieldResult use getFieldDescription
    
    /**/
     
    // Determines to which object each relationship field belongs  

    public static map<String,map<String, Object>> answerMap = null;
     
    public class FieldQueryException extends Exception {}

    public static String createCacheKey(String objectName, ID recordId){
        return objectName.toLowerCase() + recordId;
    }
     
    /**/
    
    public static String getSObjectKeyPrefix(String objectName){
        if (globalDescribe == null)
            globalDescribe = Schema.getGlobalDescribe();
        if (objectDescriptionMap == null)
            objectDescriptionMap = new Map<String, Schema.DescribeSObjectResult>();
                    
        SObjectType objToken = globalDescribe.get(objectName);
        if (objToken != null){
            if (!objectDescriptionMap.containsKey(objectName)) {
                objectDescriptionMap.put(objectName, objToken.getDescribe());
            }
            DescribeSObjectResult o = objectDescriptionMap.get(objectName);
            return o.getKeyPrefix();
        }
        
        return null;
    }
    
    public static Map<String, Schema.SObjectField> getSObjectFieldsMap(String objectName){
        if (globalDescribe == null)
            globalDescribe = Schema.getGlobalDescribe();
        if (objectDescriptionMap == null)
            objectDescriptionMap = new Map<String, Schema.DescribeSObjectResult>();
            
        if (!objectDescriptionMap.containsKey(objectName)) {
            SObjectType objToken = globalDescribe.get(objectName);
            objectDescriptionMap.put(objectName, objToken.getDescribe());
        }
        
        return objectDescriptionMap.get(objectName).fields.getMap();
    }
    
     public static Schema.DisplayType getFieldDataType(String objectName, String fieldName){
        String tmpFieldName = fieldName;
        String tmpObjectName = objectName;
        
        if (fieldName.contains('.')){
            // The field name is the last element
            List<String> splitByDot = fieldName.split('[.]');
            tmpFieldName =  splitByDot[splitByDot.size() - 1];
            tmpObjectName = allFieldsObjectsMap.get(objectName).get(fieldName.toLowerCase());
        }
        
        Schema.DescribeFieldResult fieldDescription = getFieldDescription(tmpObjectName, tmpFieldName);
        
        if (fieldDescription.getType()  == Schema.DisplayType.Picklist) {
            if (picklistVlaueToLabel == null)
                picklistVlaueToLabel = new Map<String, Map<String,Map<String,String>>>(); 
            if (!picklistVlaueToLabel.containsKey(objectName))
                picklistVlaueToLabel.put(objectName, new Map<String,Map<String,String>>());
            if (!picklistVlaueToLabel.get(objectName).containsKey(fieldName))
                picklistVlaueToLabel.get(objectName).put(fieldName, new Map<String,String>());
            List<Schema.PicklistEntry> picklistValues = fieldDescription.getPicklistValues();
            for (Schema.PicklistEntry picklistValue:picklistValues)
                picklistVlaueToLabel.get(objectName).get(fieldName).put(picklistValue.getValue(), picklistValue.getLabel());
        }
        return fieldDescription.getType();
    }
    
    public static Schema.DescribeFieldResult getFieldDescription(String objectName, String fieldName) {
        if (fieldsDescriptionMap == null)
            fieldsDescriptionMap = new Map<String, Map<String,Schema.DescribeFieldResult>>();
        if (!fieldsDescriptionMap.containsKey(objectName))
            fieldsDescriptionMap.put(objectName, new Map<String,Schema.DescribeFieldResult>());
        if (!fieldsDescriptionMap.get(objectName).containsKey(fieldName)) {
            Schema.SObjectField field = getSObjectFieldsMap(objectName).get(fieldName);
            System.debug(LoggingLevel.INFO, 'objectName = ' + objectName + ' fieldName = '+fieldName);
            if (field == null) {
                System.debug(LoggingLevel.INFO, getSObjectFieldsMap(objectName).keySet());
                System.debug(LoggingLevel.INFO, 'objectName = ' + objectName + ' fieldName = '+fieldName);
            }
            Schema.DescribeFieldResult describeField = field.getDescribe();
            fieldsDescriptionMap.get(objectName).put(fieldName,describeField);
        }
        return fieldsDescriptionMap.get(objectName).get(fieldName);
    }
    
    /**/
    public Static String createObjectFieldsString(String objectName){
        String queryText = '';
        Map<String, Schema.SObjectField> insuranceFieldMap = FlatModelHelper.getSObjectFieldsMap(objectName);
        //build dynamic list of fieldnames
        for (String fieldKey : insuranceFieldMap.keySet()) {
            Schema.SObjectField fsObj = insuranceFieldMap.get(fieldKey);
            Schema.DescribeFieldResult f = fsObj.getDescribe();
            String fieldName = f.getName();
            queryText += fieldName + ', ';
        }
        queryText = queryText.substring(0, queryText.length() - 2);
        
        return queryText;
    }

    private static void createAnswers(String answersObject, String answerKeyField, ID answerId)
    {
        String cacheKey = createCacheKey(answersObject, answerId);
        if (answerMap.get(cacheKey) == null)
            answerMap.put(cacheKey, new map<String, Object>());
            
        String answerQuery = 'SELECT ';
        
        Map<String, Schema.SObjectField> fieldsMap = getSObjectFieldsMap(answersObject);
        Set<String> fields = fieldsMap.keySet();
        Boolean firstField = true;
        for(String field:fields){
            if (firstField)
                firstField = false;
            else
                answerQuery += ', ';
            
            answerQuery += String.escapeSingleQuotes(field);
        }
        
        answerQuery += ' FROM ' + String.escapeSingleQuotes(answersObject)
            + ' WHERE ' + String.escapeSingleQuotes(answerKeyField) + ' = ' + 
            '\'' + String.escapeSingleQuotes(answerId) + '\'';
            
        sObject queryResult = Database.query(answerQuery);        
        
        for(String answerField:fields){
            answerMap.get(cacheKey).put(answerField.toLowerCase(), queryResult.get(answerField));
        }
    }

    public static void createAnswersByList(String answersObject, String[] fieldsList, String answerKeyField, ID[] answerIds){
        if (answerIds == null || answerIds.size() == 0)
            return;
            
        if (answerMap == null)
            answerMap = new map<String, map<String, Object>>();
    
        if (!String.isNotEmpty(answersObject) || !String.isNotEmpty(answerKeyField))
            return;

        if (fieldsList == null || fieldsList.Size() == 0)
            return;

        String selectClause = '';
        boolean firstField = true;
        for(String field:fieldsList){
            if (firstField)
                firstField = false;
            else
                selectClause += ',';
            
            selectClause += String.escapeSingleQuotes(field);
        }
        
        String fromClause = ' FROM ' + String.escapeSingleQuotes(answersObject);
        String whereClause = ' WHERE ' + String.escapeSingleQuotes(answerKeyField) + ' in(';
        Integer counter = 1;
        for (ID currId:answerIds) {
            whereClause += '\'' + currId + '\'';
            if (counter < answerIds.size())
                whereClause += ',';
            else 
                whereClause += ')';
            counter++;
        }
            
        String selectStmt = 'SELECT ';
        
        // Avoid reaching Statement Character Limit http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_soql_select.htm
        final Integer STATEMENT_CHAR_LIMIT = 10000;
        Integer queryLength = selectStmt.length() + fromClause.length() + whereClause.length();
        while ((queryLength + selectClause.length()) > STATEMENT_CHAR_LIMIT){
            Integer selectClauseSplitIdx = selectClause.indexOf(',', STATEMENT_CHAR_LIMIT-queryLength-1);
            if (selectClauseSplitIdx < 0)
                selectClauseSplitIdx = selectClause.lastIndexOf(',');
            
            String tempSelectClause = selectClause.substring(0, selectClauseSplitIdx-1);
            selectClause = selectClause.substring(selectClauseSplitIdx+1);
            
            String tempQueryString = selectStmt + tempSelectClause + fromClause + whereClause;
            String[] currFieldsList = selectClause.split(',');
            SObject[] queryResults = Database.query(tempQueryString);
            for (Sobject currResult: queryResults){
                String cacheKey = createCacheKey(answersObject, (ID)currResult.get('ID'));
                if (answerMap.get(cacheKey) == null)
                    answerMap.put(cacheKey, new map<String, Object>());
                for(String field:currFieldsList){
                    answerMap.get(cacheKey).put(field.toLowerCase(), getFieldFromQueryResult(field,currResult));
                }
            }
        }

        String tempQueryString = selectStmt + selectClause + fromClause + whereClause;

            String[] currFieldsList = selectClause.split(',');
            SObject[] queryResults = Database.query(tempQueryString);
            for (Sobject currResult: queryResults){
                String cacheKey = createCacheKey(answersObject, (ID)currResult.get('ID'));
                if (answerMap.get(cacheKey) == null)
                    answerMap.put(cacheKey, new map<String, Object>());
                for(String field:currFieldsList){
                    answerMap.get(cacheKey).put(field.toLowerCase(), getFieldFromQueryResult(field,currResult));
                }
            }
    }

    public static void createAnswersByList(String answersObject, String[] fieldsList, String answerKeyField, ID answerId){
        String cacheKey = createCacheKey(answersObject,answerId);
        if (cacheKey == null || cacheKey == '')
            return;
            
        if (answerMap == null)
            answerMap = new map<String, map<String, Object>>();

        if (answerMap.get(cacheKey) == null)
            answerMap.put(cacheKey, new map<String, Object>());
            
        if (!String.isNotEmpty(answersObject) || !String.isNotEmpty(answerKeyField))
            return;
        
        if (fieldsList == null || fieldsList.Size() == 0)
            return;
            
        String selectClause = '';
        boolean firstField = true;
        Map<String,String> fieldMapped = new Map<String,String>();
        Set<String> uniqueFieldsList = new Set<String>();
        for (String field:fieldsList)
            uniqueFieldsList.add(field.toLowerCase());
        for(String field:uniqueFieldsList){
            if (!String.isNotEmpty(field)) {
                if (fieldMapped.containsKey(field.toLowerCase()))
                    continue;
                fieldMapped.put(field.toLowerCase(),field);
                if (firstField)
                    firstField = false;
                else
                    selectClause += ',';
                
                selectClause += String.escapeSingleQuotes(field);
            }
        }
        if (selectClause == '')
            return;
        
        String fromClause = ' FROM ' + String.escapeSingleQuotes(answersObject);
        String whereClause = ' WHERE ' + String.escapeSingleQuotes(answerKeyField) + '=' + 
            '\'' + String.escapeSingleQuotes(answerId) + '\'';
            
        String selectStmt = 'SELECT ';
        
        // Avoid reaching Statement Character Limit http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_soql_select.htm
        final Integer STATEMENT_CHAR_LIMIT = 10000;
        Integer queryLength = selectStmt.length() + fromClause.length() + whereClause.length();
        while ((queryLength + selectClause.length()) > STATEMENT_CHAR_LIMIT){
            Integer selectClauseSplitIdx = selectClause.indexOf(',', STATEMENT_CHAR_LIMIT-queryLength-1);
            if (selectClauseSplitIdx < 0)
                selectClauseSplitIdx = selectClause.lastIndexOf(',');
            
            String tempSelectClause = selectClause.substring(0, selectClauseSplitIdx-1);
            selectClause = selectClause.substring(selectClauseSplitIdx+1);
            
            String tempQueryString = selectStmt + tempSelectClause + fromClause + whereClause;
            cacheFieldsByQuery(cacheKey, tempSelectClause.split(','), tempQueryString);
        }

        String tempQueryString = selectStmt + selectClause + fromClause + whereClause;
        cacheFieldsByQuery(cacheKey, selectClause.split(','), tempQueryString);
    }
    
    public static void cacheFieldsByQuery(String cacheKey, String[] fieldsList, String queryString){
        SObject queryResult = Database.query(queryString);
        for(String field:fieldsList){
            String formatedField = field;
            if (field.startsWith('toLabel('))
                formatedField = formatedField.substring(field.indexOf('(') + 1, field.length() - 1);
            answerMap.get(cacheKey).put(formatedField.toLowerCase(), getFieldFromQueryResult(formatedField,queryResult));
        }
    }
    
    public static Object getAnswerByCustomId(String answersObject, String answerKeyField, String answerField, ID answerId){
        return getAnswerByCustomId(answersObject, answerKeyField, answerField, answerId, true);
    }
    
    public static Object getAnswerByCustomId(String answersObject, String answerKeyField, String answerField, ID answerId, Boolean useTranslation){
        String cacheKey = createCacheKey(answersObject, answerId);
        if (answerMap == null)
            answerMap = new map<String, map<String, Object>>();
        if (answerMap.get(cacheKey) == null)
            createAnswers(answersObject, answerKeyField, answerId);
        
        Object fieldValue;
        
        if (answerMap.get(cacheKey).containsKey(answerField.toLowerCase())){
            fieldValue = answerMap.get(cacheKey).get(answerField.toLowerCase());
        } else {
            String answerFieldFormated = String.escapeSingleQuotes(answerField);
            String answerQuery = 'SELECT ' + answerFieldFormated
                + ' FROM ' + String.escapeSingleQuotes(answersObject)
                + ' WHERE ' + String.escapeSingleQuotes(answerKeyField) + ' =\''
                + String.escapeSingleQuotes(answerId) + '\' LIMIT 1';
            sObject queryResult = Database.query(answerQuery);
            
            fieldValue = getFieldFromQueryResult(answerField, queryResult);
        }
        
        if (getFieldDataType(answersObject, answerField) == Schema.DisplayType.Picklist && useTranslation)
            fieldValue = picklistVlaueToLabel.get(answersObject).get(answerField).get(String.valueOf(fieldValue));

        return fieldValue;
    }
    
    public static object getFieldFromQueryResult(String answerField, SObject queryResult){
        String field = answerField;
        if (field.indexOf('.') < 0)
            return queryResult.get(field);
            
        SObject objResult;
        String objName = field.substring(0,field.indexOf('.'));
        field = field.substring(field.indexOf('.')+1);
        objResult = queryResult.getSObject(objName);
        while (field.indexOf('.') > 0 && objResult != null){
            objName = field.substring(0,field.indexOf('.'));
            field = field.substring(field.indexOf('.')+1);
            objResult = objResult.getSObject(objName);
        }
        
        if (objResult != null)
            return objResult.get(field);
        else
            return null;
    }
    /*
    public static Object getAnswer(AnswerSObject ansObj, String answerField){
        return getAnswer(ansObj, answerField, true);
    }
    
    public static Object getAnswer(AnswerSObject ansObj, String answerField, Boolean useTranslation){
        try {
            return getAnswerByCustomId(ansObj.objectName, ansObj.referenceField, answerField, ansObj.answerId, useTranslation);
        } catch (Exception e){
            String fieldLabel = FlatModelHelper.getFieldLabel(ansObj.objectName, answerField);
            String objectLabel = FlatModelHelper.getSObjectLabel(ansObj.objectName);
            throw new FieldQueryException('Failed querying the filed "' + fieldLabel+ 
                                        '" from the object "' + objectLabel + '" by the ID "' + ansObj.answerId);
        }
    }
*/
   
    public static SelectOption[] getAnswersSelectOptions(String objectName){
        return getAnswersSelectOptions(objectName, null);
    }
    
    public static final Integer STRING_TYPE = 0;
    public static final Integer BOOLEAN_TYPE = 1;
    public static final Integer NUMBER_TYPE = 2;
    public static final Integer DATETIME_TYPE = 3;
    public static final Integer REFERENCE_TYPE = 4;

    public static Map<String, Schema.DescribeFieldResult> getFieldsDescribeByFilter(String objectName, Integer[] filters){
        Map<String, Schema.DescribeFieldResult> result = new Map<String, Schema.DescribeFieldResult>();
                
        Map<String, Schema.SObjectField> fieldsMap = getSObjectFieldsMap(objectName);
        Set<String> fields = fieldsMap.keySet();
        Boolean match;
        
        for (String field: fields){
            match = false;
            SOBjectField f = fieldsMap.get(field);
            Schema.DescribeFieldResult fdr = f.getDescribe();
            
            if (fdr.getLabel() != 'Deleted' && fdr.isAccessible()){                
                if (filters != null){
                    Schema.DisplayType fieldType = fdr.getType();
                    
                    for (Integer filter: filters){
                    
                        if (fieldType == Schema.DisplayType.BASE64 ||
                            fieldType == Schema.DisplayType.ANYTYPE ||
                            fieldType == Schema.DisplayType.ENCRYPTEDSTRING)
                            match = false;
                        else if (filter == STRING_TYPE)                 
                            match = true;
                        else if (filter == BOOLEAN_TYPE){                        
                             if (fieldType == Schema.DisplayType.Boolean)                                                                                                             
                                 match = true;         
                                                       
                        } else if (filter == NUMBER_TYPE) {
                             if (fieldType == Schema.DisplayType.Double ||
                                 fieldType == Schema.DisplayType.Integer)
                                 match = true;
                        } else if (filter == DATETIME_TYPE) {
                             if (fieldType == Schema.DisplayType.Date ||
                                 fieldType == Schema.DisplayType.DateTime ||
                                 fieldType == Schema.DisplayType.Time)
                                 match = true;
                        } else if (filter == REFERENCE_TYPE) {
                            if (fieldType == Schema.DisplayType.Reference)
                                match = true;
                        }           
                        
                        if (match)
                            break;
                    }                
                } else {
                    match = true;
                }
                
                if (match == true){
                    result.put(field, fdr);
                }                                             
            }
        }

        return result;
        
    }
    
    public static Map<String, Schema.DescribeFieldResult> getFieldsByLabel(String objectName, Integer[] filters){
        // For sorting by label
        Map<String, Schema.DescribeFieldResult> fieldsByLabel = new Map<String, Schema.DescribeFieldResult>();

        // For finding duplicate lables
        Map<String, Schema.DescribeFieldResult> dupLabels = new Map<String, Schema.DescribeFieldResult>();

        Map<String, Schema.DescribeFieldResult> fieldsMap = getFieldsDescribeByFilter(objectName, filters);
        Set<String> fields = fieldsMap.keySet();
        
        for (String field: fields){
            Schema.DescribeFieldResult fdr = fieldsMap.get(field);
            String label = fdr.getLabel();
            if (fieldsByLabel.containsKey(label)) {
                Schema.DescribeFieldResult f = (Schema.DescribeFieldResult)fieldsByLabel.get(label);
                String newLabel = label + ':' + f.getLocalName();
                fieldsByLabel.put(newLabel, f);
                fieldsByLabel.remove(label);
                dupLabels.put(label, fdr);
            }
            
            if (dupLabels.containsKey(label))
                label += ':' + field;
             
            fieldsByLabel.put(label, fdr);
        }

        return fieldsByLabel;
    }

    public static SelectOption[] getAnswersSelectOptions(String objectName, Integer[] filters){
    
        SelectOption[] answersList = new List<SelectOption>();
        answersList.add(new SelectOption('','-'));
        
        // For sorting by label
        Map<String, Schema.DescribeFieldResult> fieldsByLabel = getFieldsByLabel(objectName, filters);

        String[] tmp = new List<String>();
        tmp.addAll(fieldsByLabel.keySet());
        tmp.sort();


        for (String label: tmp){
            Schema.DescribeFieldResult f = (Schema.DescribeFieldResult)fieldsByLabel.get(label);
            answersList.add(new SelectOption(f.getName().toLowerCase(), label));
        }
        return answersList;
    }

    public static SelectOption[] getSObjectsFieldOptions(String objectName, String fieldName){
        SelectOption[] objectsList = new List<SelectOption>();
        
        Map<String, Schema.SObjectField> fieldsMap = getSObjectFieldsMap(objectName);
        Schema.SObjectField field = fieldsMap.get(fieldName);
        Schema.DescribeFieldResult dfr = field.getDescribe();

        List <Schema.PicklistEntry> pickList = dfr.getPicklistValues();
        
        for (Schema.PicklistEntry entery: pickList){
            objectsList.add(new SelectOption(entery.getValue(), entery.getLabel()));                                             
        }
        
        return objectsList;
    }
    
    public static SelectOption[] getSObjectsSelectOptions(){
        SelectOption[] objectsList = new List<SelectOption>();

        if (globalDescribe == null)
            globalDescribe = Schema.getGlobalDescribe();
        if (objectDescriptionMap == null)
            objectDescriptionMap = new Map<String, Schema.DescribeSObjectResult>();
        
        Set<String> objectNames = globalDescribe.keySet();
        Map<String, String> sortMap = new Map<String, String>();
        
        for (String objName: objectNames){
            if (!objectDescriptionMap.containsKey(objName)) {
                SObjectType objToken = globalDescribe.get(objName);
                objectDescriptionMap.put(objName, objToken.getDescribe());
            }
            DescribeSObjectResult o = objectDescriptionMap.get(objName);
            if (o.isAccessible() && o.isQueryable()){
                if (sortMap.containsKey(o.getLabel()))
                    sortMap.put(o.getLabel() + ':' + objName, objName);
                else
                    sortMap.put(o.getLabel(), objName);
            }
        }
        
        List<String> sortList = new List<String>();
        sortList.addAll(sortMap.keySet());
        sortList.sort();
        for (String key : sortList)        
            objectsList.add(new SelectOption(sortMap.get(key), key));                                             
        
        return objectsList;
    }
    /*
    public static String getAnswerRecordNameById(AnswerSObject ansObj){
        String query = 'SELECT ' + String.escapeSingleQuotes(ansObj.descriptionField)
                     + ' FROM ' + String.escapeSingleQuotes(ansObj.objectName)
                     + ' WHERE ' + String.escapeSingleQuotes(ansObj.referenceField) + ' = \'' + String.escapeSingleQuotes(ansObj.answerId) + '\'';
    
        SObject obj = Database.query(query);        
        return (String)obj.get(ansObj.descriptionField);
    }
    */
    public static String getSObjectLabel(String objectName){
        // describe doesn't work with package namespace prefix
        if(objectName == null)
            return null;
        if (objectName.indexOf('__') > -1 && objectName.indexOf('__') < objectName.length() - 3)
            objectName = objectName.subString(objectName.indexOf('__') + 2, objectName.length()); 
        if (globalDescribe == null)
            globalDescribe = Schema.getGlobalDescribe();
        if (objectDescriptionMap == null)
            objectDescriptionMap = new Map<String, Schema.DescribeSObjectResult>();
        
        SObjectType objToken = globalDescribe.get(objectName);
        if (objToken != null){
            if (!objectDescriptionMap.containsKey(objectName)) {
                objectDescriptionMap.put(objectName, objToken.getDescribe());
            }
            DescribeSObjectResult o = objectDescriptionMap.get(objectName);         
            return o.getLabel();
        }
        
        return null;
    }
    

    private static Map<String,String> keyPrefixMap;
    //static section init   
    private static void iniTypesMap(){
        if (globalDescribe == null)
            globalDescribe = Schema.getGlobalDescribe(); 
        if (objectDescriptionMap == null)
            objectDescriptionMap = new Map<String, Schema.DescribeSObjectResult>();
                    
        keyPrefixMap = new Map<String,String>{};
        Set<String> keyPrefixSet = globalDescribe.keySet();
        for(String sObj : keyPrefixSet){
            if (!objectDescriptionMap.containsKey(sObj)) {
                SObjectType objToken = globalDescribe.get(sObj);
                objectDescriptionMap.put(sObj, objToken.getDescribe());
            }
            Schema.DescribeSObjectResult r =  objectDescriptionMap.get(sObj);
            String tempName = sObj;
            String tempPrefix = r.getKeyPrefix();
            keyPrefixMap.put(tempPrefix,tempName);
        }   
    }
    
    public static String getObjectTypeById(ID objectId){        
        String idPrefix = String.valueOf(objectId).subString(0,3);
        
        if (keyPrefixMap == null)
            iniTypesMap();
        
        return keyPrefixMap.get(idPrefix);      
    }
    
    public static Schema.ChildRelationship[] getSObjectRelationList(String objectName){
        if (globalDescribe == null)
            globalDescribe = Schema.getGlobalDescribe();
        if (objectDescriptionMap == null)
            objectDescriptionMap = new Map<String, Schema.DescribeSObjectResult>();
            
        if (!objectDescriptionMap.containsKey(objectName)) {
            SObjectType objToken = globalDescribe.get(objectName);
            objectDescriptionMap.put(objectName, objToken.getDescribe());
        }
        
        return objectDescriptionMap.get(objectName).childRelationships;
    }

    
    
    public static String getSObjectNameField(String objectName){
        Map<String, Schema.SObjectField> fieldsMap = getSObjectFieldsMap(objectName);
        Set<String> fieldNames = fieldsMap.keySet();
        for (String fieldName:fieldNames){
            Schema.SObjectField field = fieldsMap.get(fieldName);
            Schema.DescribeFieldResult dfr = field.getDescribe();
            if (dfr.isNameField())
                return fieldName;
        }
        
        return null;
    }
    
    public static String getRelationshipSObjectName(String objectName, String answerKeyFieldName, String relFieldName, ID answerId){
        Map<String, Schema.SObjectField> fieldsMap = FlatModelHelper.getSObjectfieldsMap(objectName);
        Schema.SObjectField field = fieldsMap.get(relFieldName);
        Schema.DescribeFieldResult describeField = field.getDescribe();

        if (describeField.getRelationshipName() != null && !describeField.isNamePointing()){
            SObjectType[] refTo = describeField.referenceTo;
            if (refTo.size() > 0){
                DescribeSObjectResult objDef = refTo[0].getDescribe();
                return objDef.getName();
            }
        } else if (describeField.isNamePointing()){
            String relName = describeField.getRelationshipName();
            String result = (String)getAnswerByCustomId(objectName, answerKeyFieldName, relName+'.Type', answerId);
            return result;
        }

        return null;
    }
    
    public static String getNameByRelField(String objectName, String answerKeyFieldName, String fieldName, ID answerId, ID relId){
        String relObjName = getRelationshipSObjectName(objectName, answerKeyFieldName, fieldName, answerId);
        String relNameField = getSObjectNameField(relObjName);
        String result = (String)getAnswerByCustomId(relObjName, 'ID', relNameField, relId);
        
        return result;
    }
    
   
    
    

    //add by B&L
    public static Schema.SObjectField getSObjectField(String objectName, String fieldName){
        try {                     
            return  getSObjectFieldsMap(objectName).get(fieldName);
        } catch (Exception e) {
            //NoviLog.error('Failed geting Schema.SObjectField for obj=' + objectName + ', field =' + fieldName, 'FlatModelHelper.getSObjectField');
            return null;
        }
    }
    

    public static String getFieldLabel(String objectName, String fieldName){
        try {
            Schema.SObjectField field = getSObjectFieldsMap(objectName).get(fieldName);
            Schema.DescribeFieldResult describeField = field.getDescribe();
            return describeField.getLabel();
        } catch (Exception e) {
            //NoviLog.error('Failed geting field label for obj=' + objectName + ', field =' + fieldName, 'FlatModelHelper.getFieldLabel');
            return null;
        }
    }
    /**/
}