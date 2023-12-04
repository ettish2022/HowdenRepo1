public class SumByCarrierHelper {
	public static boolean stopTrigger = false; 
    static final String carrierFieldName 		= 'Novidea_HPC__Carrier__c';
    static final String policyFieldName 		=  'Novidea_HPC__Policy__c';
    static final String sumsByCarrierFieldName 	= 'Sums_by_Carrier__c';
    /*
     * The function connects the objects received to a Sums_by_Carrier__c object if such a connection is not already made.
     * newObjectList : list of Novidea_HPC__Income__c or Novidea_HPC__Collection_From_Carrier__c.
    */
    public static void searchAndCreate(list<sObject> newObjectList, map<Id,sObject> oldObjectMap) {
    	if(stopTrigger) return;
        Set<String> keySet = new Set<String>();
        list<sObject> obj2Perform = new list<sObject>();
        //for insert triger
        if(ArrayUtils.isMapNullOrEmpty(oldObjectMap)) { 
        	for(sObject obj : newObjectList){
        		if(String.isEmpty((String)obj.get(carrierFieldName)) || String.isEmpty((String)obj.get(policyFieldName)))
	                continue;
	                
            	obj.put(sumsByCarrierFieldName, null);//for case 'clone' and field 'Sums_by_Carrier__c' is not null
        	    obj2Perform.add(obj);
            }
        }
        else {//for update trigger
	        for(sObject obj : newObjectList) {
	        	Id oid =  (Id)obj.get('Id');
	        	String carrierId = (String)obj.get(carrierFieldName);
	        	String policyId  = (String)obj.get(policyFieldName);
	        	String sumsId 	 = (String)obj.get(sumsByCarrierFieldName);
	        	
	        	if(String.isEmpty(carrierId) || String.isEmpty(policyId))
	                continue;
	            
	        	sObject old = oldObjectMap.get(oid);
	        	if( carrierId   != (String)old.get(carrierFieldName)
		        	    || policyId != (String)old.get(policyFieldName)
		        	    || sumsId   != (String)old.get(sumsByCarrierFieldName)
		        	    || null     == obj.get(sumsByCarrierFieldName)) {
		        	 
		        	    obj.put(sumsByCarrierFieldName, null); //sums object must be changed
		        	    obj2Perform.add(obj);
		        	    
	            }   
	        }
        }
        for(sObject obj : obj2Perform) {
        	system.debug(LoggingLevel.ERROR,(String)obj.get(carrierFieldName) + (String)obj.get(policyFieldName));
           	keySet.add(getUniqueKey(obj));
        }
        //get existing Sums_By_Carrier__c object
        //TODO: raniz 2/2/2013: this query will raise system.lang.nullpointerexception (internal sf error) when keySet.size()>104
        list<Sums_By_Carrier__c> sumsByCarrierList =    [SELECT Policy__c, 
                                                                Carrier__c,
                                                                //Unique_Key__c,
                                                                Unique_Key_2__c
                                                          FROM Sums_By_Carrier__c
                                                          //WHERE Unique_Key__c IN: keySet //
                                                          WHERE Unique_Key_2__c IN: keySet
                                                          AND Carrier__c <> null
                                                          AND Policy__c <> null];
                                                            
        //create map key (sums.Carrier__c + (string)sums.Policy__c) to Id of Sums_By_Carrier object                              
        map<String, Id> key2SumsMap = new map<String, Id>();                                
        for(Sums_By_Carrier__c sums : sumsByCarrierList) {
            //String key = sums.Unique_Key__c; //=(string)sums.Carrier__c + (string)sums.Policy__c;
            String key = sums.Unique_Key_2__c;
            if(!key2SumsMap.containsKey(key)) 
                key2SumsMap.put(key, sums.Id);
        }
        // if object Sums_By_Carrier__c not exist, create it   
        list<Sums_By_Carrier__c> sumsByCarrier2Insert = new list<Sums_By_Carrier__c>(); 
        for(sObject obj : obj2Perform) {
            String carrierId = (String)obj.get(carrierFieldName);
            String policyId = (String)obj.get(policyFieldName);
            
            String key = carrierId + policyId; 
            if(!key2SumsMap.containsKey(key)) {
                key2SumsMap.put(key,null);
                Sums_By_Carrier__c newSumsByCarrier =  new Sums_By_Carrier__c(
                                                            Carrier__c = carrierId
                                                            ,Policy__c = policyId
                                                            ,Unique_Key_2__c = key);
                                                    
                sumsByCarrier2Insert.add(newSumsByCarrier);
            }
        }
        system.debug('\n\n\n sumsByCarrier2Insert >> ' + sumsByCarrier2Insert);
        Database.insert(sumsByCarrier2Insert);
        // top up the key2SumsMap
        for(Sums_By_Carrier__c sums : sumsByCarrier2Insert) {
            String key = (String)sums.Carrier__c + (String)sums.Policy__c;
            key2SumsMap.put(key, sums.Id);
        }
        // put reference of Sums_By_Carrier__c on sObject (Inome, Collection by Carrier)
        for(sObject obj : obj2Perform) {
            String carrierId = (String)obj.get(carrierFieldName);
            String policyId = (String)obj.get(policyFieldName);
            String key = carrierId + policyId; 
            obj.put(sumsByCarrierFieldName,key2SumsMap.get(key));
        }
    }
    
    private static String getUniqueKey(sObject obj) {
    	return (String)obj.get(carrierFieldName) + (String)obj.get(policyFieldName);
    }
    
    
   
}