@isTest
public class TestTotalReportHoursCO {
    
    @testSetup
	private static void setup() {
    	Novidea_TMF__Time_Measurement_Settings__c setting = new Novidea_TMF__Time_Measurement_Settings__c();
        setting.Name = 'Default';
        setting.Novidea_TMF__DefaultServiceTaskName__c = 'כללי';
        setting.Novidea_TMF__limit_rows__c = '1000';
        insert setting;
    }
    static testmethod void testReportHoursCO() {            
                Account acc = new Account(Name = 'test');
                insert acc;
                CurrencyTriggerHelper.stopTrigger = true;
                Novidea_HPC__Claim__c claim = new Novidea_HPC__Claim__c();
                claim.Novidea_HPC__Client__c = acc.Id;              
                insert claim;  
                 
                Novidea_HPC__Total_Hours__c th  = new Novidea_HPC__Total_Hours__c(Novidea_HPC__Claim__c = claim.Id);
                insert th;
                         
                Novidea_HPC__Activity_Journal__c aj= new Novidea_HPC__Activity_Journal__c();    
                aj.Name = 'דיווח שעות';
                aj.Novidea_HPC__Start_Time__c= Datetime.now();
                aj.Novidea_HPC__Total_Hours__c = th.Id;
                aj.Novidea_HPC__Claim__c =claim.Id;
                insert aj;
                                
                PageReference pageRef = Page.TotalReportHours;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('Id', acc.Id);
                TotalReportHoursCO con = new TotalReportHoursCO(new ApexPages.StandardController(acc));
                
                TotalReportHoursCO.createTempClaim(date.today().day() +'/'+date.today().month()+'/'+date.today().year(), date.today().day() +'/'+date.today().month()+'/'+date.today().year(),acc.Id );
                TotalReportHoursCO.deleteClaim(claim.Id);               
                        
    }                   
}