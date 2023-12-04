@isTest(seeAllData=false)
private class TestAutoComplete_Controller {
	@isTest
	private static void testAutocomplete() {
		Database.insert(
			new Novidea_HPC__Time_Periods__c(
				Novidea_HPC__Minimum_Number_of_Days_for_Policy__c = 1,
				Novidea_HPC__Number_of_Days_Before_Effective__c = 0
			)
		);
		Database.insert(
			new Novidea_TMF__Time_Measurement_Settings__c(
				Name = 'Default',
				Novidea_TMF__DefaultServiceTaskName__c = 'Test',
				Novidea_TMF__limit_rows__c = '1000'
			)
		);
		AutoComplete_Controller co = new AutoComplete_Controller();
		Account acc = new Account(name = 'test');
		Database.insert(acc);
		acc = new Account(name = 'test1');
		Database.insert(acc);
		AutoComplete_Controller.searchSuggestionArray2('Account', '', 'test', 'Name', true);
		AutoComplete_Controller.searchSuggestionArray('Account', 'stam', 'test', 'Name');
	}

	@isTest
	private static void testCoverage() {
		AutoComplete_Controller.testCoverage();
	}
}