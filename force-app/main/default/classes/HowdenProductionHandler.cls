global with sharing class HowdenProductionHandler implements NOVIPROD.IProductionHandler {
    public boolean isBrokerToBeProcessed(map<string,Novidea_HPC__Broker_Number__c> mapCarrierBroker, Novidea_HPC__Broker_Number__c broker){
        return mapCarrierBroker.containsKey(broker.Novidea_HPC__Carrier__c + broker.Novidea_HPC__Broker_Number_In_Carrier__c) &&
            NOVIPROD__General__c.getInstance().NOVIPROD__Resolve_Broker_Numbers_By_Profit_Center__c!= null && 
            broker.Novidea_HPC__Profit_Center__c==Id.valueOf(NOVIPROD__General__c.getInstance().NOVIPROD__Resolve_Broker_Numbers_By_Profit_Center__c) ||
            !mapCarrierBroker.containsKey(broker.Novidea_HPC__Carrier__c + broker.Novidea_HPC__Broker_Number_In_Carrier__c);
    }
}