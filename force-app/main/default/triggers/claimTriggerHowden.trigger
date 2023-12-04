trigger claimTriggerHowden on Novidea_HPC__Claim__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

	 Novidea_HPC__Trigger__c triggerSetting  = Novidea_HPC__Trigger__c.getInstance(); 
    if (triggerSetting.Novidea_HPC__Prevent_Running__c || TriggerHelpper.preventInboundRunning)return;
	   	if (Trigger.isBefore && Trigger.isInsert) // Before Insert
		    {
		    }
		    else if (Trigger.isBefore && Trigger.isUpdate) // Before Update
		    {
		    	
		    }
		    else if (Trigger.isBefore && Trigger.isDelete) // Before Delete
		    { 
		    	
		    }
		    // ------------------------------------------------------------------------
		    //  ---------------------------- AFTER EVENTS -----------------------------
		    // ------------------------------------------------------------------------
		    else  if(Trigger.isInsert && Trigger.isAfter){	 	
				ClaimTriggerHelperHowden.onAfterInsert((list<Novidea_HPC__Claim__c>)Trigger.new);	 	      	
   			 } 
		    else if (Trigger.isAfter && Trigger.isUpdate) // After Update
		    {	
		    	ClaimTriggerHelperHowden.onAfterUpdate((list<Novidea_HPC__Claim__c>)Trigger.old,
 	    			(map<Id,Novidea_HPC__Claim__c>)Trigger.newMap);  	    	
		    }
		    else if (Trigger.isAfter && Trigger.isDelete) // After Delete
		    {
				
		    }
		    
}