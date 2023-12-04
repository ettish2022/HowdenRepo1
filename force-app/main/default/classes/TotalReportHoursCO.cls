// StandardController Account
global class TotalReportHoursCO {

    
     
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
     global static list<pdfInfo> createTempClaim(string startDate, string endDate,string sobjId){
         
        tempObjectResult result  = copyClaimToTempRecord(startDate,endDate,sobjId);
        system.debug('duduav is prinign result '+result );
         if (result == null) {
                 return null;
        }
        
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
        p1.formId = formId;
        p1.recordId = result.claimId;
        listPdfInfo.add(p1);
        
        pdfInfo p2 = new pdfInfo();
        p2.formId = formId2;
        p2.recordId = result.claimId;
        listPdfInfo.add(p2);
        
        return listPdfInfo;
     }
    
    
    public string startDate{get;set;}
    public string endDate{get;set;} 
    public  Id CurrentObjectID{get;set;}
    public static string tempClaimId;
    public static string sId;
     
    public TotalReportHoursCO(ApexPages.StandardController controller) {
        sId = Userinfo.getSessionId();
        CurrentObjectID = controller.getRecord().Id;            
        startDate = Date.today().format();                     
        endDate =   Date.today().format();
        tempClaimId = null;

    }
    
    public void testCallOut(){
        GenerateFormHelper.callGenerateForm(sid);
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
     
    public static tempObjectResult copyClaimToTempRecord(string startDate, string endDate,string CurrentObjectIDG ){
        system.debug('duduav is printing + '+ startDate );
        string startDstr = formatDateForQuery(startDate,true);
        string endDstr = formatDateForQuery(endDate,false);
        dateTime startD = Datetime.valueOf(startDstr);
        dateTime endD = Datetime.ValueOf(endDstr);
        system.debug('duduav is printign startD'+startD);
        system.debug('duduav is printign endD'+endD);
        system.debug('duduav is pritnig + CurrentObjectIDG '+ CurrentObjectIDG );
        List<Novidea_HPC__Claim__c> listClaims; 
        List<Novidea_HPC__Activity_Journal__c> listActivityJournals;
        List<Novidea_HPC__Total_Hours__c> listTotalHours ;               
        
        listClaims = [Select n.OwnerId, n.Novidea_HPC__Status__c, n.Novidea_HPC__Product_Definition__c, n.Novidea_HPC__Policy__c, n.Novidea_HPC__Policy_Expiration_Date__c, n.Novidea_HPC__Policy_Effective_Date__c, n.Novidea_HPC__Maximum_Deductible__c, n.Novidea_HPC__Is_Malus__c, n.Novidea_HPC__Is_Claimant_A_Client__c, n.Novidea_HPC__Event_Description__c, n.Novidea_HPC__Event_Date_and_Time__c, n.Novidea_HPC__Date_Message_Recieved__c, n.Novidea_HPC__Damage_Description__c, n.Novidea_HPC__Court_Expenses__c, n.Novidea_HPC__Client__c, n.Novidea_HPC__Claimed_Person__c, n.Novidea_HPC__Claimant_Name__c, n.Novidea_HPC__Claimant_Foreign_Name__c, n.Novidea_HPC__Claim_Type__c, n.Novidea_HPC__Claim_Reference_No__c, n.Novidea_HPC__Claim_Payment_Amount__c, n.Novidea_HPC__Claim_Number__c, n.Novidea_HPC__Claim_Number_At_Carrier__c, n.Novidea_HPC__Carrier__c, n.Novidea_HPC__Amount_To_be_Paid_by_Carrier__c, n.Novidea_HPC__Amount_Claimed__c, n.Novidea_HPC__Amount_Claimed_Currency__c, n.Novidea_HPC__Agency__c, n.Name, n.Id From Novidea_HPC__Claim__c n where n.Novidea_HPC__Client__c =: CurrentObjectIDG];
        if ( listClaims.size()>0 ){
             
            set<Id> setClaimIds = new set<Id>();
            for (Novidea_HPC__Claim__c  claim :listClaims){
            	setClaimIds.add(claim.Id);
            }    
             
            listActivityJournals =[Select n.SystemModstamp,n.Novidea_HPC__Total_Hours__r.Novidea_HPC__Total_Reported_By__c ,n.Novidea_HPC__Total_Hours__c, n.Novidea_HPC__Start_Time__c, n.Novidea_HPC__Manage_Person__c, n.Novidea_HPC__Hourly_Rate__c, n.Novidea_HPC__Hourly_Rate_Currency__c, n.Novidea_HPC__Entered_Time__c, n.Novidea_HPC__End_Time__c, n.Novidea_HPC__Comment__c, n.Novidea_HPC__Claim__c, n.Novidea_HPC__Calculated_Time__c, n.Novidea_HPC__Calculated_Cost__c, n.Name, n.Id From Novidea_HPC__Activity_Journal__c n where n.Novidea_HPC__Claim__c IN : setClaimIds AND n.Novidea_HPC__Start_Time__c  >= :startD AND  n.Novidea_HPC__Start_Time__c <= :endD];
            listTotalHours =[Select n.SystemModstamp ,n.Novidea_HPC__Total_Time__c, n.Novidea_HPC__Total_Reported_By__c, n.Novidea_HPC__Total_Cost__c, n.Novidea_HPC__Claim__c, n.Name, n.Id From Novidea_HPC__Total_Hours__c n where n.Novidea_HPC__Claim__c IN : setClaimIds  ];      
            Novidea_HPC__Claim__c tempClaim  = new Novidea_HPC__Claim__c();
            tempClaim.Name = 'סיכום שעות בכלל התביעות';
            tempClaim.Novidea_HPC__Client__c = listClaims[0].Novidea_HPC__Client__c;
            tempClaim.R_Date_Begin__c = Date.valueOf(startDstr);
        	tempClaim.R_Date_End__c = Date.valueOf(endDstr);
        	Novidea_HPC__Trigger__c triggerSetting  = Novidea_HPC__Trigger__c.getInstance();
        	Boolean currentValue = triggerSetting.Novidea_HPC__Prevent_Running__c;
        	triggerSetting.Novidea_HPC__Prevent_Running__c = true;
        	Database.insert(tempClaim);
            triggerSetting.Novidea_HPC__Prevent_Running__c = currentValue;
             
             map<ID,Novidea_HPC__Total_Hours__c> mapTotalHoursIdToInProcessObj = new map<ID,Novidea_HPC__Total_Hours__c>();
             Double totalCost = 0;
        	 Double totalHours = 0;
             if ( listTotalHours.size() > 0 ){
                set<Id> setTotalHoursUser = new set<Id>();
                for (Novidea_HPC__Total_Hours__c totalHoursRecord : listTotalHours){
                    Novidea_HPC__Total_Hours__c tempTotalHours = new Novidea_HPC__Total_Hours__c();
                    tempTotalHours =totalHoursRecord.clone(false,true,false,true);
                    totalCost += tempTotalHours.Novidea_HPC__Total_Cost__c;
                	totalHours += tempTotalHours.Novidea_HPC__Total_Time__c;
                    tempTotalHours.Novidea_HPC__Claim__c = tempClaim.Id;
                    if ( totalHoursRecord.Novidea_HPC__Total_Reported_By__c != null && !setTotalHoursUser.contains(totalHoursRecord.Novidea_HPC__Total_Reported_By__c)){
                        setTotalHoursUser.contains(totalHoursRecord.Novidea_HPC__Total_Reported_By__c);
                        mapTotalHoursIdToInProcessObj.put(totalHoursRecord.Novidea_HPC__Total_Reported_By__c,tempTotalHours);
                    }
                    
                }
                Database.insert(mapTotalHoursIdToInProcessObj.values());
             }
              
            if (listActivityJournals.size()>0 && listTotalHours.size()>0){ 
            	List<Novidea_HPC__Activity_Journal__c> listActivityJournal = new List<Novidea_HPC__Activity_Journal__c>();         
                for (Novidea_HPC__Activity_Journal__c activityJournal : listActivityJournals){
                	Novidea_HPC__Activity_Journal__c tempActivityJornal = new Novidea_HPC__Activity_Journal__c();
                    tempActivityJornal = activityJournal.clone(false,true,false,true); 
                    if (mapTotalHoursIdToInProcessObj.get(activityJournal.Novidea_HPC__Total_Hours__r.Novidea_HPC__Total_Reported_By__c) != null )    
                    	tempActivityJornal.Novidea_HPC__Total_Hours__c = mapTotalHoursIdToInProcessObj.get(activityJournal.Novidea_HPC__Total_Hours__r.Novidea_HPC__Total_Reported_By__c).Id;
                    tempActivityJornal.Novidea_HPC__Claim__c = tempClaim.Id; 
                    listActivityJournal.add(tempActivityJornal);
              	}
                if (listActivityJournal.size() >0 ){
                	Database.insert (listActivityJournal);
                	totalHours /= 60.0;
                	if (totalHours != null)
                		totalHours = Math.round(totalHours * 100.0) / 100.0;
	        		if (totalCost != null)
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
		return null;
	}
}