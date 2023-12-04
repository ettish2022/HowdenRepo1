@isTest
public class TestCheckForActivityJournalCO {
	    static testMethod void testcheckForActivity() {         
                Profile profile = [Select p.Name, p.Id From Profile p where name='מנהל מערכת' Or name='System Administrator'] ;
                User user = [select Id from User where  profileId = : profile.Id  limit 1];
            
                CurrencyTriggerHelper.stopTrigger = true;
                Novidea_HPC__Claim__c claim = new Novidea_HPC__Claim__c();  
                insert claim;           
                PageReference pageRef = Page.checkForActivityJournal;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('Id', claim.Id);
                checkForActivityJournalCO con = new checkForActivityJournalCO(new ApexPages.StandardController(claim));
                con.onLoad();
                checkForActivityJournalCO.currentUserId = user.Id;
                checkForActivityJournalCO.checkForTotalHours();
                checkForActivityJournalCO.getHourlyRate(user.Id);
                checkForActivityJournalCO.createActivityJournal();
            
    }                   
    
}