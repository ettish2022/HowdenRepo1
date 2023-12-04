/**
 * This class contains unit tests for validating the behavior of ProductManagements controller
 * Initial Author: rani
*/
@isTest
private class TestProductManagements {

     @testSetup
	private static void setup() {
    	Novidea_TMF__Time_Measurement_Settings__c setting = new Novidea_TMF__Time_Measurement_Settings__c();
        setting.Name = 'Default';
        setting.Novidea_TMF__DefaultServiceTaskName__c = 'כללי';
        setting.Novidea_TMF__limit_rows__c = '1000';
        insert setting;
    }
    
   @isTest
   static void testAddingLines() {
         Schema.FieldSetMember[] fsMembers = Schema.SObjectType.Novidea_HPC__Lead__c.fieldSets.Novidea_HPC__Fields_To_Clear_Upon_Lead_Loss.getFields();
         boolean found = false;
         for(FieldSetMember fsm:fsMembers){
            if(fsm.getFieldPath().contains('Liability_Limit__c')){
                found = true;
                break;
            }
         }
        system.assert(found,'The field Liability_Limit__c is not in Fields_To_Clear_Upon_Lead_Loss. Change the test to pass.');
        //Init:
        Novidea_HPC__General_Switches__c settings = new Novidea_HPC__General_Switches__c(Name = 'Default');
        Database.insert(settings);
        Novidea_HPC__Product_Category__c dataCategory = new Novidea_HPC__Product_Category__c(name='test cat');
        Database.insert(dataCategory);
        Novidea_HPC__Product_Def__c[] dataProDefs = new Novidea_HPC__Product_Def__c[]{ new Novidea_HPC__Product_Def__c(name='prodef1', Novidea_HPC__Category__c=dataCategory.Id), 
                                                    new Novidea_HPC__Product_Def__c(name='prodef2', Novidea_HPC__Category__c=dataCategory.Id)};
        Database.insert(dataProDefs);
        Account carrierAccount1 = new Account(name = 'Test Carrier', Novidea_HPC__Tax_ID__c = '456987', RecordTypeId=NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Carrier','Account'));
        Account dataAccount = new Account(name = 'Test Customer', Novidea_HPC__Tax_ID__c = '5678941', RecordTypeId=NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Business','Account'));
        Database.Insert(new Account[]{carrierAccount1, dataAccount});
        //using this fieldset (Fields_To_Clear_Upon_Lead_Loss) since its a part of the package disregarding its use ini case of lost lead. It includes the Liability_Limit__c field
        Novidea_HPC__Process__c renewalViaLeadProcess = new Novidea_HPC__Process__c(name ='Lead Process', Novidea_HPC__Renewal__c='Lead',Novidea_HPC__Create_Policy_Product__c = true, 
                                                        Novidea_HPC__Renewal_Lead_Record_Type__c = 'Standard_Lead', Novidea_HPC__Fieldset__c='Fields_To_Clear_Upon_Lead_Loss');
        Database.insert(renewalViaLeadProcess);
        
        Novidea_HPC__Process_Connection__c[] processConnections = new Novidea_HPC__Process_Connection__c[]{
            new Novidea_HPC__Process_Connection__c(Novidea_HPC__Process__c = renewalViaLeadProcess.Id, Novidea_HPC__Product_Def__c = dataProDefs[0].Id, Novidea_HPC__Product_Record_Type__c = 'General_Product', Novidea_HPC__Not_Create_Product__c=false),
            new Novidea_HPC__Process_Connection__c(Novidea_HPC__Process__c = renewalViaLeadProcess.Id, Novidea_HPC__Product_Def__c = dataProDefs[1].Id, Novidea_HPC__Product_Record_Type__c = 'General_Product', Novidea_HPC__Not_Create_Product__c=true)
            };
        Database.insert(processConnections);

        Novidea_HPC.TriggerUtils.disableTrigger('autoCreateLead','testCreateLeadProductsOnlyWhenNew');
        Novidea_HPC__Lead__c lead = new Novidea_HPC__Lead__c(name='test lead', Novidea_HPC__Liability_Limit__c=57, Novidea_HPC__Required_Policy_Type__c='New', Novidea_HPC__Process__c = renewalViaLeadProcess.id);
        Database.insert(lead);
        
        ApexPages.StandardController standCont = new ApexPages.StandardController(lead); 
        ProductManagements controller = new ProductManagements(standCont);
        system.assertEquals(1,controller.products.size());
        System.assertEquals(57, [SELECT Novidea_HPC__Liability_Limit__c FROM Novidea_HPC__Product__c WHERE Id =:controller.products[0].product.Id][0].Novidea_HPC__Liability_Limit__c);
        controller.selectedId = dataProDefs[1].Id;
        controller.createProduct();
        controller.products = null;
        system.assertEquals(2,controller.products.size());      
        System.assertEquals(57, [SELECT Novidea_HPC__Liability_Limit__c FROM Novidea_HPC__Product__c WHERE Id =:controller.products[0].product.Id][0].Novidea_HPC__Liability_Limit__c);
        System.assertEquals(57, [SELECT Novidea_HPC__Liability_Limit__c FROM Novidea_HPC__Product__c WHERE Id =:controller.products[1].product.Id][0].Novidea_HPC__Liability_Limit__c);
        controller.lineToRemove=1;
        controller.removeLine();
        controller.products = null;
        system.assertEquals(1,controller.products.size());
        controller.selectedProdDefId = dataProDefs[1].Id;
        controller.addLine();
        system.assertEquals(2,controller.products.size());      
        System.assertEquals(57, [SELECT Novidea_HPC__Liability_Limit__c FROM Novidea_HPC__Product__c WHERE Id =:controller.products[0].product.Id][0].Novidea_HPC__Liability_Limit__c);
        System.assertEquals(57, [SELECT Novidea_HPC__Liability_Limit__c FROM Novidea_HPC__Product__c WHERE Id =:controller.products[1].product.Id][0].Novidea_HPC__Liability_Limit__c);
    }
}