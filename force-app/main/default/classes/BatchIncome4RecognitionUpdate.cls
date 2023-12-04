global  class BatchIncome4RecognitionUpdate  extends BatchRefresh {

	static final String QUERY_TMPL  = 'Select Novidea_HPC__Income_Recognition_Date__c, Commission_From_Production_After_Tax__c, ' + 
       								  'Novidea_HPC__Fees_From_Production__c, Novidea_HPC__Premium_From_Production__c, Id ' +
									  'FROM Novidea_HPC__Income__c WHERE  Novidea_HPC__Income_Recognition_Date__c >= 2012-10-01 ' +
									  'AND Commission_From_Production_After_Tax_USD__c=null ' +
									  'AND Novidea_HPC__Policy__r.Novidea_HPC__Value_Date__c>2007-01-01 AND Novidea_HPC__Policy__r.Novidea_HPC__Value_Date__c< 2012-11-20 ' +
									  'AND Value_Date__c>2007-01-01 AND Value_Date__c< 2012-11-20';
	
	
	global BatchIncome4RecognitionUpdate(Boolean isTest) {
		String sql = QUERY_TMPL;
		this.query = sql;	
	}
	
	override protected void refresh(sObject obj) {
		if(Test.isRunningTest()) {
		}
		
	}
}