@isTest
public class TestHowdenProductionHandler {
    
    @testSetup
	private static void setup() {
    	Novidea_TMF__Time_Measurement_Settings__c setting = new Novidea_TMF__Time_Measurement_Settings__c();
        setting.Name = 'Default';
        setting.Novidea_TMF__DefaultServiceTaskName__c = 'כללי';
        setting.Novidea_TMF__limit_rows__c = '1000';
        insert setting;
    }
    
	@istest(seeAlldata=false)
    public static void testHandler(){
        CurrencyTriggerHelper.stopTrigger = true;
    	Account profCenter = new Account(recordTypeId=NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Agency','Account'),name='testPF');
    	Account carr = new Account(recordTypeId=NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Carrier','Account'),name='testPF');
    	Database.insert(new Account[]{profCenter,carr});
    	Novidea_HPC__Broker_Number__c bn = new Novidea_HPC__Broker_Number__c(name='testBroker', Novidea_HPC__Carrier__c=carr.Id,Novidea_HPC__Profit_Center__c=profCenter.Id );
    	Database.insert(bn);
    	Database.insert(new  NOVIPROD__General__c(NOVIPROD__Resolve_Broker_Numbers_By_Profit_Center__c=profCenter.Id));
    	map<string,Novidea_HPC__Broker_Number__c> mapCarrierBroker = new map<string,Novidea_HPC__Broker_Number__c>{bn.Novidea_HPC__Carrier__c+bn.Novidea_HPC__Broker_Number_In_Carrier__c=>null};
    	system.assert(new HowdenProductionHandler().isBrokerToBeProcessed(mapCarrierBroker,bn));
    }
}