global class BatchCreateSumByCarrier4Income extends BatchRefresh {

	
	static final String QUERY_TMPL  = 'Select Id, Novidea_HPC__Policy__c, Novidea_HPC__Carrier__c '+
			' FROM Novidea_HPC__Income__c ' +
			' WHERE Novidea_HPC__Policy__r.Novidea_HPC__Expiration_Date__c >= TODAY\n'+
			'AND Sums_by_Carrier__c=null';
	
	global BatchCreateSumByCarrier4Income() {
		this.query = QUERY_TMPL;
	}
	
	override protected void refresh(sObject obj) {
	}
	
}