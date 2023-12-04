@isTest(seeAllData=false)
private with sharing class AccountTriggerNewHelperTest {
	@TestSetup
	private static void makeData() {
		Database.insert(
			new Novidea_TMF__Time_Measurement_Settings__c(
				Name = 'Default',
				Novidea_TMF__DefaultServiceTaskName__c = 'Test',
				Novidea_TMF__limit_rows__c = '1000'
			)
		);
	}

	@isTest
	private static void testValidateBusinessAccountTaxId() {
		String validTaxId = '123456789';
		String invalidTaxId = '123aBc7d9';
		String invalidTaxId2 = '1234567891';
		String invalidTaxId3 = '111111111';

		String businessAccountRecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Business', 'Account');
		Account acc1 = new Account(Name = 'Test', RecordTypeId = businessAccountRecordTypeId, Novidea_HPC__Tax_ID__c = validTaxId);
		Database.insert(acc1);

		try {
			Database.insert(new Account(Name = 'Test2', RecordTypeId = businessAccountRecordTypeId, Novidea_HPC__Tax_ID__c = invalidTaxId));
			System.assert(false, 'Insert should have failed');
		} catch (Exception exc) {
			System.assert(exc.getMessage().contains(Label.Business_Account_Invalid_Tax_Id), 'Insert failed for different error');
		}

		Database.insert(
			new Account(
				Name = 'Test2',
				RecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Household', 'Account'),
				Novidea_HPC__Tax_ID__c = invalidTaxId
			)
		);

		acc1.Novidea_HPC__Tax_ID__c = invalidTaxId2;
		try {
			Database.update(acc1);
			System.assert(false, 'Update should have failed');
		} catch (Exception exc) {
			System.assert(exc.getMessage().contains(Label.Business_Account_Invalid_Tax_Id), 'Update failed for different error');
		}

		acc1.Novidea_HPC__Tax_ID__c = invalidTaxId3;
		try {
			Database.update(acc1);
			System.assert(false, 'Update should have failed');
		} catch (Exception exc) {
			System.assert(exc.getMessage().contains(Label.Business_Account_Invalid_Tax_Id), 'Update failed for different error');
		}
	}
}