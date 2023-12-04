public with sharing class InboundDocumentTriggerHelper {
     // Make sure to query akk entId fields and account__c field too.
     public static Boolean preventInboundRunning = false;
     public static void setAccountOnDocument(List<InboundDocument__c> documents){
     	for (InboundDocument__c document:documents){
			setAccountByFilingCriteria(document);     		
     	}
     }
     
     public static void handleChangeOfAccount(List<InboundDocument__c> newDocs, Map<Id, InboundDocument__c>oldMap){
     	for (InboundDocument__c document:newDocs){
     		// If account changed
     		if (document.account__c != null && document.account__c != oldMap.get(document.id).account__c){
     			boolean accountAdded = false; 
				for(integer i=1; i<=20; ++i){
					String currEntField = 'EntId' + i + '__c';
					String s = (String)document.get(currEntField);
					if(String.isNotBlank(s) && !s.startsWith('00T')){
						if (!accountAdded){
							document.put(currEntField, String.valueOf(document.account__c));
							accountAdded = true;
						} else {
							document.put(currEntField, null);
						}
					}
				}
     		} else {
     			// If account field wasn't changed, check whether one of the account ents was changed:
				setAccountByFilingCriteria(document);     		
     		}
     	}
     }

     private static void setAccountByFilingCriteria(InboundDocument__c document){
		for(integer i=1;i<=20;++i){
			String s = (String)document.get('EntId' + i + '__c');
			if(s != null && s.startsWith('001')){
				document.put('account__c', (Id)s);
				return;
			}
		}
     }
}