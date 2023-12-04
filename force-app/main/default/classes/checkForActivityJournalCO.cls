public with sharing class checkForActivityJournalCO {

    //TODO : on deploy update values instad of 00ND0000004SqMf 

    public static Id currentUserId;
    public static Id CurrentObjectID;
    public checkForActivityJournalCO(ApexPages.StandardController controller) {
        
        currentUserId = Userinfo.getUserId();
        CurrentObjectID = controller.getRecord().Id;
        system.debug(' duduav is in controler ');
        
    }
    
    //TODO : hard coded value for the field id 
    public pageReference onLoad(){
    
        list<Novidea_HPC__Activity_Journal__c> lstActivityJournal  = [Select n.Novidea_HPC__End_Time__c,n.Novidea_HPC__Start_Time__c, n.Novidea_HPC__Manage_Person__c, n.Novidea_HPC__Entered_Time__c, n.Novidea_HPC__Comment__c, n.Novidea_HPC__Claim__c From Novidea_HPC__Activity_Journal__c n where n.Novidea_HPC__Claim__c =: CurrentObjectID and n.Novidea_HPC__Manage_Person__c =: currentUserId and n.Novidea_HPC__End_Time__c = null];
        if ( lstActivityJournal.size()>0){
            DateTime nowDate = Datetime.now();      
            Pagereference p = new Pagereference('/'+lstActivityJournal[0].Id+'/e?retURL=%2F'+CurrentObjectID+'&00ND0000004SqMf='+ Datetime.now().hour()+':'+Datetime.now().minute() +'%20'+ Datetime.now().day() +'/'+Datetime.now().month()+ '/'+Datetime.now().year() );
                                                                                                                                
            return p;
        }else{
            createActivityJournal();
            Pagereference p = new Pagereference('/'+CurrentObjectID);
            return p;
        }
    }
    
    public static void createActivityJournal(){
        Novidea_HPC__Activity_Journal__c aj= new Novidea_HPC__Activity_Journal__c();
        aj.Novidea_HPC__Manage_Person__c = currentUserId;
        aj.Name = 'דיווח שעות';
        //TBD set role field
        aj.Novidea_HPC__Hourly_Rate__c =getHourlyRate(aj.Novidea_HPC__Manage_Person__c);
        aj.Novidea_HPC__Claim__c = CurrentObjectID;
        aj.Novidea_HPC__Total_Hours__c = checkForTotalHours();
        aj.Novidea_HPC__Start_Time__c= Datetime.now();
        insert aj;
    }
    
    public static Id checkForTotalHours(){
        Novidea_HPC__Total_Hours__c th ;
        try{            
            th =[Select n.Novidea_HPC__Total_Reported_By__c, n.Novidea_HPC__Claim__c From Novidea_HPC__Total_Hours__c n where n.Novidea_HPC__Total_Reported_By__c = : currentUserId AND n.Novidea_HPC__Claim__c =: CurrentObjectID  ];
        }catch(exception e){
            th  = new Novidea_HPC__Total_Hours__c(Novidea_HPC__Claim__c = CurrentObjectID,Novidea_HPC__Total_Reported_By__c=currentUserId);
            try{    
                User user = [select Name from User where id =: currentUserId];
                th.Name = 'דיווח שעות עבור '+ user.Name;
            }catch(exception ex){}
            insert th;
            return th.Id;
        }
        return th.Id;   
    }
    
    
    
    public static decimal getHourlyRate(ID personId){
        Novidea_HPC__Professional_Rate__c  pr;
        try{
            pr = [Select n.Novidea_HPC__Professional__c, n.Novidea_HPC__Hourly_Rate__c From Novidea_HPC__Professional_Rate__c n where n.Id =:personId];
        }catch(exception e){return 0;}      
        return pr.Novidea_HPC__Hourly_Rate__c ;             
    }
}