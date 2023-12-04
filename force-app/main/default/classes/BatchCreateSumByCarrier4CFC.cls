global class BatchCreateSumByCarrier4CFC extends BatchRefresh {
	static final String QUERY_TMPL  = 'SELECT Id, Novidea_HPC__Carrier__c, Novidea_HPC__Policy__c ' +
	' FROM Novidea_HPC__Collection_From_Carrier__c ' +
	' WHERE Novidea_HPC__Policy__r.Novidea_HPC__Expiration_Date__c >= TODAY';
	
	global BatchCreateSumByCarrier4CFC() {
		this.query = QUERY_TMPL;
	}
	
	override protected void refresh(sObject obj) {
	}
}