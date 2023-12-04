global interface IProductionHandler{
	boolean isBrokerToBeProcessed(map<string,Novidea_HPC__Broker_Number__c> mapCarrierBroker, Novidea_HPC__Broker_Number__c broker);
}