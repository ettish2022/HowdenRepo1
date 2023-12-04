public with sharing class LWC_CommissionsUpload {
    @AuraEnabled(cacheable=true)
    public static List<Commission_Upload_Format__mdt> getFormatsMD(){
        try {
            return [SELECT MasterLabel, DeveloperName, Record_Type__c,
                    (SELECT MasterLabel, Field_API_Name__c, Default_Value__c, Is_Input_Value__c, Input_Type__c FROM Commission_Upload_Field_Mappings__r) 
                    FROM Commission_Upload_Format__mdt 
                    ORDER BY MasterLabel];
        } catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
    }

    @AuraEnabled
    public static void saveRecords(List<Commission_Staging__c> records){
        try {
            insert records;
            // List<Commission_Staging__c> tempList = new List<Commission_Staging__c>();
            // for (Commission_Staging__c commission : records) {
            //     tempList.add(commission);

            //     if(tempList.size() == 10){
            //         insert tempList;
            //         tempList = new List<Commission_Staging__c>();
            //     }
            // }
            // insert tempList;
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }
}