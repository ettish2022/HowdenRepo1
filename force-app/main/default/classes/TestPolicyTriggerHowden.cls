@isTest(seeAllData=false)
private with sharing class TestPolicyTriggerHowden {
	@TestSetup
	private static void makeData() {
		Database.insert(
			new Policy_Currency__c(
				Agency_Fee__c = 'Novidea_HPC__Agency_Fees_Currency__c',
				Commission_Amount__c = 'Novidea_HPC__Premium_Amount_Currency__c',
				Income_Amount__c = 'Novidea_HPC__Premium_Amount_Currency__c',
				Premium_Amount__c = 'Novidea_HPC__Premium_Amount_Currency__c',
				Premium_to_Pay__c = 'Novidea_HPC__Premium_Amount_Currency__c',
				Unpaid_Agency_Fee__c = 'Novidea_HPC__Agency_Fees_Currency__c',
				Unpaid_Premium__c = 'Novidea_HPC__Premium_Amount_Currency__c',
				Value_Date_Field__c = 'Novidea_HPC__Value_Date__c'
			)
		);
		Database.insert(
			new Income_Currency__c(
				Agency_Fee__c = 'Novidea_HPC__Agency_Fee_Currency__c',
				Agent_Discount_From_Production__c = 'Novidea_HPC__Premium_Currency__c',
				Agent_Discount__c = 'Novidea_HPC__Premium_Currency__c',
				Commission_Amount__c = 'Novidea_HPC__Premium_Currency__c',
				Commission_Amount_from_Production__c = 'Novidea_HPC__Premium_Currency__c',
				Commission_From_Production_After_Tax__c = 'Novidea_HPC__Premium_Currency__c',
				Credit_Fees__c = 'Novidea_HPC__Premium_Currency__c',
				Credit_Fees_From_Production__c = 'Novidea_HPC__Premium_Currency__c',
				Fees__c = 'Novidea_HPC__Premium_Currency__c',
				Fees_From_Production__c = 'Novidea_HPC__Premium_Currency__c',
				Other_Commission__c = 'Novidea_HPC__Premium_Currency__c',
				Premium__c = 'Novidea_HPC__Premium_Currency__c',
				Premium_Bruto__c = 'Novidea_HPC__Premium_Currency__c',
				Premium_From_Production__c = 'Novidea_HPC__Premium_Currency__c',
				Premium_To_Pay__c = 'Novidea_HPC__Premium_Currency__c',
				subagentfees__c = 'Novidea_HPC__Premium_Currency__c',
				Underwriter_Commission__c = 'Novidea_HPC__Premium_Currency__c',
				Value_Date_Field__c = 'Value_Date__c'
			)
		);
	}
	@isTest
	private static void testInsert() {
		Database.insert(new Novidea_HPC__Policy__c());
	}
}