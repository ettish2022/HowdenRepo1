@isTest
public class TestTriggerHelpper {
    
    @testSetup
	private static void setup() {
    	Novidea_TMF__Time_Measurement_Settings__c setting = new Novidea_TMF__Time_Measurement_Settings__c();
        setting.Name = 'Default';
        setting.Novidea_TMF__DefaultServiceTaskName__c = 'כללי';
        setting.Novidea_TMF__limit_rows__c = '1000';
        insert setting;
    }
	@isTest
    private static void testcoverage(){
    	Account acc = new Account(name='test account');
        database.insert(acc);
        
    	InboundDocument__c doc = new InboundDocument__c(EntId1__c = acc.Id);
    	Database.insert(doc); 
    	Database.update(doc);
    }
}