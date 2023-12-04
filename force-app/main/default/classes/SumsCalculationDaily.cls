global class SumsCalculationDaily implements Database.Batchable<SObject>, Schedulable {
	
	String sql;
	
	global SumsCalculationDaily() {
		sql = 'SELECT Total_Premium__c, Total_Commision__c, Id ' 
		            +', (SELECT Novidea_HPC__Premium_To_Pay__c,Novidea_HPC__Commission_Amount__c FROM Incomes__r) ' 
		            +', (SELECT Novidea_HPC__Payment__c FROM Collection_From_Carrier__r) '+
		            ' FROM Sums_By_Carrier__c';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(sql);
	}
	
	global virtual void execute(Database.BatchableContext BC,List<sObject> scope) {
		for(sObject obj : scope) {
			Sums_By_Carrier__c sums = (Sums_By_Carrier__c)obj;
			sums.Total_Commision__c = 0.0;
			for(Novidea_HPC__Income__c income : sums.Incomes__r) {
				if(income.Novidea_HPC__Commission_Amount__c!=null)
					sums.Total_Commision__c += income.Novidea_HPC__Commission_Amount__c;
			}
			sums.Total_Premium__c = 0.0;
			for(Novidea_HPC__Collection_From_Carrier__c  carrier : sums.Collection_From_Carrier__r) {
				if(carrier.Novidea_HPC__Payment__c!=null)
					sums.Total_Premium__c += carrier.Novidea_HPC__Payment__c;
			}
		}
		
		Database.update(scope);
	}
	            
	global void execute(SchedulableContext ctx)  {
        ID batchprocessid = Database.executeBatch(new SumsCalculationDaily(),100);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
     
}