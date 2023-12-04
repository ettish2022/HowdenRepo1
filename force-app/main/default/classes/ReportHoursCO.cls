global with sharing class ReportHoursCO {

    
    public static string  formName = 'מסמך פרוט שעות עבודה';
    
    public static string formname2 = 'מסמך פרוט חשבון';
        
        
        public class tempObjectResult{
                string claimId;
                Integer numberOfActivityJournal;
                Integer numberOfTotalHours;             
        }

        global class pdfInfo {
                public string formId;
                public string recordId;
        }
     
     
     @RemoteAction    
     global static string deleteClaim(string claimId ){
        system.debug('duduav  '+ claimId );
        id newclaimId = claimId;
        try{
                Database.delete(newclaimId);
        }catch(exception  e){
                
        }
        return 'claimId';
        
     }
     
     @RemoteAction    
     global static list<pdfInfo> createTempClaim(string startDate, string endDate ,string sobjId){
         
        tempObjectResult result  = copyClaimToTempRecord(startDate,endDate,sobjId);
        system.debug('duduav is prinign result '+result );
        
        ID formId; 
                try{
                        formId = [select Form__r.Id
                        from    Form_Assignment__c
                        where   Name = :formName
                        and     Rows_From__c <= :result.numberOfActivityJournal 
                        and     Rows_To__c >= :result.numberOfActivityJournal LIMIT 1][0].Form__r.Id;
                        }catch(exception e){
                                
                        }
                 system.debug('duduav is prinign result '+formId );        
        
         ID formId2;
                try{
                         formId2 = [select Form__r.Id
                        from    Form_Assignment__c
                        where   Name = :formName2
                        and     Rows_From__c <= : result.numberOfTotalHours 
                        and     Rows_To__c >= : result.numberOfTotalHours LIMIT 1][0].Form__r.Id;
                        }catch(exception ex){
                                
                        }
                        
                 system.debug('duduav is prinign result '+formId ); 
        
        list<pdfInfo> listPdfInfo = new list<pdfInfo>();        
        pdfInfo p1 = new pdfInfo();
        if ( formId != null){   
                p1.formId = formId; 
        }
        if (result.claimId != null)
                p1.recordId = result.claimId;
        listPdfInfo.add(p1);
        
        pdfInfo p2 = new pdfInfo();
        if (formId2!= null ){
                p2.formId = formId2;
        }
        if (result.claimId != null ){
                p2.recordId = result.claimId;
        }
        
        listPdfInfo.add(p2);
        
        return listPdfInfo;
     }
    
    
    
    
    public static string startDate{get;set;}
    public static string endDate{get;set;}
    public  Id CurrentObjectID{get;set;}
    public static string tempClaimId;
    public ReportHoursCO(ApexPages.StandardController controller){
        CurrentObjectID = controller.getRecord().Id;            
        startDate = Date.today().format();                     
        endDate = Date.today().format();
        tempClaimId = null;
       
    }
    
    
   
   
    
    
    private static string formatDateForQuery(string dateStr,Boolean isStartDate){
        string[] dateArr = dateStr.split('/');
        string newFormatedDate = dateArr[2] +'-' + dateArr[1] +'-' + dateArr[0];
        if ( !isStartDate ) 
            newFormatedDate +=' 23:59:00';
        else    
            newFormatedDate += ' 00:00:00';                                     
        return newFormatedDate ;
    }   
    
     
    
     public static tempObjectResult copyClaimToTempRecord(string startDateStr, string endDateStr,string currentObjectIdG ){
        string startDstr = formatDateForQuery(startDateStr,true);
        string endDstr = formatDateForQuery(endDateStr,false);
        dateTime startD = Datetime.valueOf(startDstr);
        dateTime endD = Datetime.ValueOf(endDstr);
        Novidea_HPC__Claim__c claim; 
        List<Novidea_HPC__Activity_Journal__c> listActivityJournals;
        List<Novidea_HPC__Total_Hours__c> listTotalHours ;        
        try{ 
        	claim = [Select n.OwnerId, n.Novidea_HPC__Status__c, n.Novidea_HPC__Product_Definition__c, n.Novidea_HPC__Policy__c, n.Novidea_HPC__Policy_Expiration_Date__c, n.Novidea_HPC__Policy_Effective_Date__c, n.Novidea_HPC__Maximum_Deductible__c, n.Novidea_HPC__Is_Malus__c, n.Novidea_HPC__Is_Claimant_A_Client__c, n.Novidea_HPC__Event_Description__c, n.Novidea_HPC__Event_Date_and_Time__c, n.Novidea_HPC__Date_Message_Recieved__c, n.Novidea_HPC__Damage_Description__c, n.Novidea_HPC__Court_Expenses__c, n.Novidea_HPC__Client__c, n.Novidea_HPC__Claimed_Person__c, n.Novidea_HPC__Claimant_Name__c, n.Novidea_HPC__Claimant_Foreign_Name__c, n.Novidea_HPC__Claim_Type__c, n.Novidea_HPC__Claim_Reference_No__c, n.Novidea_HPC__Claim_Payment_Amount__c, n.Novidea_HPC__Claim_Number__c, n.Novidea_HPC__Claim_Number_At_Carrier__c, n.Novidea_HPC__Carrier__c, n.Novidea_HPC__Amount_To_be_Paid_by_Carrier__c, n.Novidea_HPC__Amount_Claimed__c, n.Novidea_HPC__Amount_Claimed_Currency__c, n.Novidea_HPC__Agency__c, n.Name, n.Id From Novidea_HPC__Claim__c n where n.Id =: currentObjectIdG];
        }catch(exception e){return null;}   
                  
        listActivityJournals = [Select n.SystemModstamp, n.Novidea_HPC__Total_Hours__c, n.Novidea_HPC__Start_Time__c, n.Novidea_HPC__Manage_Person__c, n.Novidea_HPC__Hourly_Rate__c, n.Novidea_HPC__Hourly_Rate_Currency__c, n.Novidea_HPC__Entered_Time__c, n.Novidea_HPC__End_Time__c, n.Novidea_HPC__Comment__c, n.Novidea_HPC__Claim__c, n.Novidea_HPC__Calculated_Time__c, n.Novidea_HPC__Calculated_Cost__c, n.Name, n.Id From Novidea_HPC__Activity_Journal__c n where n.Novidea_HPC__Claim__c =: currentObjectIdG AND n.Novidea_HPC__Start_Time__c  >= :startD AND  n.Novidea_HPC__Start_Time__c <= :endD];
        listTotalHours = [Select n.SystemModstamp, n.Novidea_HPC__Total_Time__c, n.Novidea_HPC__Total_Reported_By__c, n.Novidea_HPC__Total_Cost__c, n.Novidea_HPC__Claim__c, n.Name, n.Id From Novidea_HPC__Total_Hours__c n where n.Novidea_HPC__Claim__c =: currentObjectIdG  ];        
        Novidea_HPC__Claim__c tempClaim  = new Novidea_HPC__Claim__c();
        tempClaim = claim.clone(false,true,false,true);
        tempClaim.R_Date_Begin__c = Date.valueOf(startDstr);
        tempClaim.R_Date_End__c = Date.valueOf(endDstr);
        Database.insert(tempClaim);
         
        map<ID,Novidea_HPC__Total_Hours__c> mapTotalHoursIdToInProcessObj = new map<ID,Novidea_HPC__Total_Hours__c>();
        Double totalCost = 0;
        Double totalHours = 0;
        if ( listTotalHours.size() > 0 ){
        	for (Novidea_HPC__Total_Hours__c totalHoursRecord : listTotalHours){
            	Novidea_HPC__Total_Hours__c tempTotalHours = new Novidea_HPC__Total_Hours__c();
                tempTotalHours =totalHoursRecord.clone(false,true,false,true);
                totalCost += tempTotalHours.Novidea_HPC__Total_Cost__c;
                totalHours += tempTotalHours.Novidea_HPC__Total_Time__c;
                tempTotalHours.Novidea_HPC__Claim__c = tempClaim.Id;
                mapTotalHoursIdToInProcessObj.put(totalHoursRecord.Id,tempTotalHours);
			}
            Database.insert(mapTotalHoursIdToInProcessObj.values());
		}
       
        if (listActivityJournals.size()>0 && listTotalHours.size()>0) { 
        	List<Novidea_HPC__Activity_Journal__c> listActivityJournal = new List<Novidea_HPC__Activity_Journal__c>();         
	        for (Novidea_HPC__Activity_Journal__c activityJournal : listActivityJournals){
	        	Novidea_HPC__Activity_Journal__c tempActivityJornal = new Novidea_HPC__Activity_Journal__c();
	            tempActivityJornal = activityJournal.clone(false,true,false,true);
	            tempActivityJornal.Novidea_HPC__Total_Hours__c = mapTotalHoursIdToInProcessObj.get(activityJournal.Novidea_HPC__Total_Hours__c).Id;
	            tempActivityJornal.Novidea_HPC__Claim__c = tempClaim.Id; 
	            listActivityJournal.add(tempActivityJornal);
	    	}
	        if (listActivityJournal.size() >0 ) {
	        	Database.insert (listActivityJournal);
	        	totalHours /= 60.0;
	        	totalHours = Math.round(totalHours * 100.0) / 100.0;
	        	totalCost = Math.round(totalCost * 100.0) / 100.0;
	        	tempClaim.R_Total_Hours__c  = totalHours;
	        	tempClaim.R_Total_Credit__c = totalCost;
	        	tempClaim.R_Total_Owing__c = totalCost; // Maybe in the future howden will ask to change the refund on claim basis, for now the service is given for free.
	        	tempClaim.R_Net_Owing_Final__c = tempClaim.R_Total_Owing__c - tempClaim.R_Total_Credit__c; 
	        	tempClaim.R_Total_Currency__c = '$'; // Again, for now this is enough.
	        	Database.update(tempClaim); 
	      	}
         }
                 
		tempObjectResult result = new tempObjectResult();
        result.claimId = tempClaim.Id;
        result.numberOfActivityJournal = listActivityJournals.size();
        result.numberOfTotalHours = mapTotalHoursIdToInProcessObj.values().size();
        return result;
    }
    
       
    /*       
    public void copyClaimToTempObj(){
        
        DateTime startD = dateTime.parse(startDate);
        DateTime endD = dateTime.parse(endDate);
        system.debug('duduav is pritnig + CurrentObjectID '+ CurrentObjectID );
        Novidea_HPC__Claim__c claim; 
        List<Novidea_HPC__Activity_Journal__c> listActivityJournals;
        List<Novidea_HPC__Total_Hours__c> listTotalHours ;        
         try{
                claim = [Select n.OwnerId, n.Novidea_HPC__Status__c, n.Novidea_HPC__Product_Definition__c, n.Novidea_HPC__Policy__c, n.Novidea_HPC__Policy_Expiration_Date__c, n.Novidea_HPC__Policy_Effective_Date__c, n.Novidea_HPC__Maximum_Deductible__c, n.Novidea_HPC__Is_Malus__c, n.Novidea_HPC__Is_Claimant_A_Client__c, n.Novidea_HPC__Event_Description__c, n.Novidea_HPC__Event_Date_and_Time__c, n.Novidea_HPC__Date_Message_Recieved__c, n.Novidea_HPC__Damage_Description__c, n.Novidea_HPC__Court_Expenses__c, n.Novidea_HPC__Client__c, n.Novidea_HPC__Claimed_Person__c, n.Novidea_HPC__Claimant_Name__c, n.Novidea_HPC__Claimant_Foreign_Name__c, n.Novidea_HPC__Claim_Type__c, n.Novidea_HPC__Claim_Reference_No__c, n.Novidea_HPC__Claim_Payment_Amount__c, n.Novidea_HPC__Claim_Number__c, n.Novidea_HPC__Claim_Number_At_Carrier__c, n.Novidea_HPC__Carrier__c, n.Novidea_HPC__Amount_To_be_Paid_by_Carrier__c, n.Novidea_HPC__Amount_Claimed__c, n.Novidea_HPC__Amount_Claimed_Currency__c, n.Novidea_HPC__Agency__c, n.Name, n.Id From Novidea_HPC__Claim__c n where n.Id =: CurrentObjectID];
         }catch(exception e){return;}   
         system.debug('duduav is pritnig + claim '+ claim );
          
          
         listActivityJournals =[Select n.SystemModstamp, n.Novidea_HPC__Total_Hours__c, n.Novidea_HPC__Start_Time__c, n.Novidea_HPC__Manage_Person__c, n.Novidea_HPC__Hourly_Rate__c, n.Novidea_HPC__Hourly_Rate_Currency__c, n.Novidea_HPC__Entered_Time__c, n.Novidea_HPC__End_Time__c, n.Novidea_HPC__Comment__c, n.Novidea_HPC__Claim__c, n.Novidea_HPC__Calculated_Time__c, n.Novidea_HPC__Calculated_Cost__c, n.Name, n.Id From Novidea_HPC__Activity_Journal__c n where n.Novidea_HPC__Claim__c =: CurrentObjectID AND n.Novidea_HPC__Start_Time__c  >= :startD AND  n.Novidea_HPC__Start_Time__c > :endD];
         listTotalHours =[Select n.SystemModstamp, n.Novidea_HPC__Total_Time__c, n.Novidea_HPC__Total_Reported_By__c, n.Novidea_HPC__Total_Cost__c, n.Novidea_HPC__Claim__c, n.Name, n.Id From Novidea_HPC__Total_Hours__c n where n.Novidea_HPC__Claim__c =: CurrentObjectID  ];        
         In_Process_Claim__c iPClaim = new In_Process_Claim__c();
         //TBD fill all the field for claim
         system.debug('duduav is pritnig + listActivityJournals '+ listActivityJournals );
         system.debug('duduav is pritnig + listTotalHours '+ listTotalHours );  
         insert iPClaim;                         
                 map<ID,In_Process_Total_Hours__c> mapTotalHoursIdToInProcessObj = new map<ID,In_Process_Total_Hours__c>();
                 if ( listTotalHours.size() > 0 ){
                        for (Novidea_HPC__Total_Hours__c totalHours : listTotalHours){
                                In_Process_Total_Hours__c iPTotalHours = new In_Process_Total_Hours__c();
                                iPTotalHours.In_Process_Claim__c = iPClaim.Id;
                                mapTotalHoursIdToInProcessObj.put(totalHours.Id,iPTotalHours);
                                
                        }
                        insert mapTotalHoursIdToInProcessObj.values();
                 }
                  
                 if (listActivityJournals.size()>0 && listTotalHours.size()>0){ 
                         List<In_Process_Activity_Journal__c> listInProcessActivityJournal = new List<In_Process_Activity_Journal__c>();            
                 for (Novidea_HPC__Activity_Journal__c activityJournal : listActivityJournals){  
                          In_Process_Activity_Journal__c inProcessActivityJornal = new In_Process_Activity_Journal__c();
                          inProcessActivityJornal.In_Process_Total_Hours__c = mapTotalHoursIdToInProcessObj.get(activityJournal.Novidea_HPC__Total_Hours__c).Id;
                          inProcessActivityJornal.In_Process_Claim__c = iPClaim.Id; 
                          listInProcessActivityJournal.add(inProcessActivityJornal);
                 }
                 if (listInProcessActivityJournal.size() >0 ){
                        insert  listInProcessActivityJournal;
                 }
                 }
          
    }
    
    */
    /*
    <apex:page standardController="Quote" extensions="vf_QuoteToPerFormPdf" action="{!generatePdf}">
<apex:pageMessages />
<apex:outputPanel layout="none" rendered="false">
{!Quote.LineItemCount}
</apex:outputPanel>
</apex:page>

with sharing class vf_QuoteToPerFormPdf {
    public Quote currQuote {get; set;}
    public Integer quoteLineItemsCount {get; set;}
    public String formName {get; set;}
    
    public vf_QuoteToPerFormPdf(ApexPages.StandardController controller) {
        currQuote = (Quote)controller.getRecord();
        formName = ApexPages.currentPage().getParameters().get('formName');   

    }
    
    public PageReference generatePdf(){
        Id formId = getFormByQuoteLineItemsCount(formName, currQuote.LineItemCount);
        if (formId != null)
            return getPerFormGeneratePR(formId, currQuote.Id);
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'לא נמצא טופס מתאים לכמות הפריטים בהצעת המחיר. על מנת לייצר הצעת מחיר זו יש להגדיר טופס המתאים ל-' + currQuote.LineItemCount + ' רשומות.'));
            return null;
        }
    }
    
    private ID getFormByQuoteLineItemsCount(String formName, Integer rowCount){
        try {
            ID formId = [select Form__r.Id
                        from    Form_Assignment__c
                        where   Name = :formName
                        and     Rows_From__c <= :rowCount 
                        and     Rows_To__c >= :rowCount LIMIT 1][0].Form__r.Id;
            
            return formId;
        } catch (Exception e){
            return null;
        }
    }
    
    private PageReference getPerFormGeneratePR(String formId, String quoteId){
        return new PageReference ('/apex/NPERFORM__generateForm?sourceObjectDescField=Name&targetId='+formId+'&sourceObjectsType=quote&sourceId='+quoteId+'&mergeWithPdf=true&lockData=true');
    }
    
    public static TestMethod void testGeneration(){
        ApexPages.StandardController stdCo = new ApexPages.StandardController(new Quote());
        vf_QuoteToPerFormPdf co = new vf_QuoteToPerFormPdf(stdCo);
        PageReference pr = co.generatePdf();
        System.assert(co != null);
    }
}
    
    
    
    */
    

}