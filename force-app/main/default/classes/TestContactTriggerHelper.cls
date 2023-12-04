@isTest
private class TestContactTriggerHelper {
    
    @testSetup
	private static void setup() {
    	Novidea_TMF__Time_Measurement_Settings__c setting = new Novidea_TMF__Time_Measurement_Settings__c();
        setting.Name = 'Default';
        setting.Novidea_TMF__DefaultServiceTaskName__c = 'כללי';
        setting.Novidea_TMF__limit_rows__c = '1000';
        insert setting;
    }
	
	private static testMethod void test001() {
		CurrencyTriggerHelper.stopTrigger = true;
		Account acc = TestUtils.createAccount('test acc', true);
		Contact cont = new Contact( LastName = 'test cont');
		insert cont;
		Novidea_HPC__Associated_Person__c ap = new Novidea_HPC__Associated_Person__c();
		ap.Novidea_HPC__Account__c = acc.Id;
		ap.Novidea_HPC__Contact__c = cont.Id;
		insert ap;
		
		delete cont;
		
		
	}
}