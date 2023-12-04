@istest
public class TestReportHoursCO {
 static testMethod void testReportHoursCO() {            
              
                CurrencyTriggerHelper.stopTrigger = true;
                Novidea_HPC__Claim__c claim = new Novidea_HPC__Claim__c();              
                insert claim;  
                 
                Novidea_HPC__Total_Hours__c th  = new Novidea_HPC__Total_Hours__c(Novidea_HPC__Claim__c = claim.Id);
                insert th;
                         
                Novidea_HPC__Activity_Journal__c aj= new Novidea_HPC__Activity_Journal__c();    
                aj.Name = 'דיווח שעות';
                aj.Novidea_HPC__Start_Time__c= Datetime.now();
                aj.Novidea_HPC__Total_Hours__c = th.Id;
                insert aj;
                                
                PageReference pageRef = Page.ReportHours;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('Id', claim.Id);
                ReportHoursCO con = new ReportHoursCO(new ApexPages.StandardController(claim));
                
                ReportHoursCO.createTempClaim(date.today().day() +'/'+date.today().month()+'/'+date.today().year(),date.today().day() +'/'+date.today().month()+'/'+date.today().year(),claim.Id );
                ReportHoursCO.deleteClaim(claim.Id);                
                        
    }                   
}