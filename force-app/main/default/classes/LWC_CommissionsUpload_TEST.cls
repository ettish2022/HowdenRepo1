@isTest
public with sharing class LWC_CommissionsUpload_TEST {
    @IsTest
    static void testFileSave(){        
        Test.startTest();
        LWC_CommissionsUpload.getFormatsMD();
        List<Commission_Staging__c> records = new List<Commission_Staging__c>();
        for (Integer i = 0; i < 60; i++) {
            records.add(new Commission_Staging__c(Policy_Number__c = '400000' + i,           
                                                    Customer_Name__c = 'Test',
                                                    Currency_Name__c = '1',
                                                    Commission_Amount__c = 100));
        }
        LWC_CommissionsUpload.saveRecords(records);

        Test.stopTest();        
    }
}