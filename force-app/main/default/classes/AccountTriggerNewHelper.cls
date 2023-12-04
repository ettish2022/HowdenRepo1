public with sharing class AccountTriggerNewHelper {
	public static Boolean stopTrigger = false;
	private static boolean inTrigger = false;

	public static void onAfterInsert(List<Account> newAccounts) {
		if (stopTrigger || inTrigger) {
			return;
		}
		inTrigger = true;
		if (NOVU.TriggerUtils.isTriggerEnabled('validateBusinessAccountTaxId')) {
			validateAccountTaxId(newAccounts, null);
		}
		inTrigger = false;
	}

	public static void onAfterUpdate(List<Account> newAccounts, Map<Id, Account> oldAccountsMap) {
		if (stopTrigger || inTrigger) {
			return;
		}
		inTrigger = true;
		if (NOVU.TriggerUtils.isTriggerEnabled('validateBusinessAccountTaxId')) {
			validateAccountTaxId(newAccounts, oldAccountsMap);
		}
		inTrigger = false;
	}

	private static void validateAccountTaxId(List<Account> newAccounts, Map<Id, Account> oldAccountsMap) {
		String businessAccountRecordTypeId = NOVU.RecordTypeUtils.getIdByDevNameAndFullSObjType('Business', 'Account');
		for (Account newAccount : newAccounts) {
			Boolean isTaxIdValid = true;
			String currentTaxId = newAccount.Novidea_HPC__Tax_ID__c;
			if (
				newAccount.RecordTypeId.equals(businessAccountRecordTypeId) &&
				String.isNotBlank(currentTaxId) &&
				(oldAccountsMap == null ||
				currentTaxId != oldAccountsMap.get(newAccount.Id).Novidea_HPC__Tax_ID__c)
			) {
				// Maximum 9 characters long
				if (currentTaxId.length() > 9) {
					isTaxIdValid = false;
				}

				// Can only contain numbers
				if (!System.Pattern.matches('\\d+', currentTaxId)) {
					isTaxIdValid = false;
				}

				// Can not be a sequence of the same digit
				Pattern pattern = System.Pattern.compile('(\\d)\\1+');
				Matcher matcher = pattern.matcher(currentTaxId);
				if (matcher.matches()) {
					isTaxIdValid = false;
				}
			}

			if (!isTaxIdValid) {
				newAccount.Novidea_HPC__Tax_ID__c.addError(Label.Business_Account_Invalid_Tax_Id);
			}
		}
	}
}