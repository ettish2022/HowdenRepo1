public with sharing class InsuranceCrossSalesAnalysysController {
	
	public static final String IN_PROCESS	= 'In Process';
	public static final String CONVERTED	= 'Converted';
	public static final String CLOSED		= 'Closed';
	public static final String SUSPENDED	= 'Suspended';
	public static final String APPOINTMENT_SET = 'Appointment Set';

    private ID insCrossSaleId { get; set; } 
    
    public InsuranceCrossSalesAnalysysController(ApexPages.StandardController controller) {
        this.insCrossSaleId = controller.getId();
        
    }

    private Insurance_Cross_Sale__c theInsCrossSale { 
    	get{
    		if(null == theInsCrossSale) {
    			if(String.isNotBlank(insCrossSaleID))
        			theInsCrossSale = getInsuranceCrossSaleBy(insCrossSaleId);
    		}
    		return theInsCrossSale;
    	} 
    	set; 
    }
    
    public PageReference runanalytics(){
		PageReference destinationPage =  new PageReference('/'+insCrossSaleId ).setRedirect(true);
		try {
	    	if(null == theInsCrossSale)
	    		return destinationPage;
	    		
	    	list<Novidea_HPC__Lead__c> leadList = getLeadListByInsCrossSaleId(insCrossSaleId);
	    	
	    	calculateStatistic(leadList, theInsCrossSale);
	    	
	    	Database.update(theInsCrossSale);
	        return destinationPage;
	        
		} catch(Exception exp) {
			
			TestUtils.performException(exp);
			return null;
		}
    }
    
    private static void calculateAndSetStatistic(list<Novidea_HPC__Lead__c> leadList, Insurance_Cross_Sale__c insCrossSaleObj) {
    	for(Novidea_HPC__Lead__c lead : leadList) { 
	    		
	    		if(String.isBlank(lead.Novidea_HPC__Status__c))
	    			continue;
	    		if(IN_PROCESS.equalsIgnoreCase(lead.Novidea_HPC__Status__c)
	    		   || SUSPENDED.equalsIgnoreCase(lead.Novidea_HPC__Status__c)
	    		   || APPOINTMENT_SET.equalsIgnoreCase(lead.Novidea_HPC__Status__c))
		    		insCrossSaleObj.Open__c ++;
		    	if(CLOSED.equalsIgnoreCase(lead.Novidea_HPC__Status__c))	
					insCrossSaleObj.Rejected__c++;
				if(CONVERTED.equalsIgnoreCase(lead.Novidea_HPC__Status__c))
					insCrossSaleObj.Converted__c++;
				if(true == lead.Responded__c)	
					insCrossSaleObj.Responded__c++;
				if(true == lead.Sent__c)
					insCrossSaleObj.Sent__c++;
    	}
		insCrossSaleObj.Total__c = leadList.size();
		insCrossSaleObj.Leads_Changed__c = false;
    }
    
	private static void resetInsuranceCrossSale(Insurance_Cross_Sale__c insCrossSaleObj) {
		insCrossSaleObj.Sent__c 		= 0; 
		insCrossSaleObj.Open__c			= 0;
		insCrossSaleObj.Total__c		= 0;
		insCrossSaleObj.Rejected__c		= 0;
		insCrossSaleObj.Converted__c	= 0;
		insCrossSaleObj.Responded__c	= 0;
	}  
	
	public static void calculateStatistic(list<Novidea_HPC__Lead__c> leadList, Insurance_Cross_Sale__c insCrossSaleObj) {
		resetInsuranceCrossSale(insCrossSaleObj);
		calculateAndSetStatistic(leadList, insCrossSaleObj);
	}    
    
    /*
		DAL
    */
    
    public static list<Novidea_HPC__Lead__c> getLeadListByInsCrossSaleId(ID insCrossSaleId) {
    	return
	    	[SELECT Id, Name
	    		   ,OwnerID
	    		   ,Sent__c
	    		   ,Responded__c
	    		   ,Novidea_HPC__Status__c 
	    		   ,Insurance_Cross_Sale__c
	    		   ,Novidea_HPC__Contact_Email__c 
	    	  FROM Novidea_HPC__Lead__c
	    	 WHERE Insurance_Cross_Sale__c =: insCrossSaleId];	
    }
    
    public static Insurance_Cross_Sale__c getInsuranceCrossSaleBy(Id insCrossSaleId) {
    	return
	    	[SELECT Id, Name
	    			,Sent__c 
	    			,Open__c
	    			,Total__c
	    			,Rejected__c
	    			,Due_Date__c
	    			,Converted__c 
	    	   FROM Insurance_Cross_Sale__c
	    	  WHERE Id =:  insCrossSaleId];
    }
}