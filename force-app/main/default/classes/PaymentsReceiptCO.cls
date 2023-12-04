public with sharing class PaymentsReceiptCO {
    public class CollectionWrapper{
        public Novidea_HPC__Collection__c collection{get;set;}
        public boolean selected{get;set;}
        public CollectionWrapper(Novidea_HPC__Collection__c collection, boolean selected){
            this.collection = collection;
            this.selected= selected;
        }
    }    
    Id policyId = Apexpages.currentPage().getParameters().get('id');
    public list<CollectionWrapper> collections{get;set;}
    public String plcName{get;set;}
    public String plcNum{get;set;}
    public String error{get;set;}
    public void init(){
        list<Novidea_HPC__Collection__c> clcts = [SELECT Novidea_HPC__Reimbursement__c, Novidea_HPC__Payment_Target__c, 
                            Novidea_HPC__Collection_Reporter__c, Id, Novidea_HPC__Payment_Currency__c, 
                            Novidea_HPC__Collection_Manager__c,  
                            Novidea_HPC__Negative_Premium_Type__c, Novidea_HPC__Payment_Type__c, Novidea_HPC__Policy__c,  
                            Novidea_HPC__Collection_Date__c,Receipt__c,  
                            Name, Novidea_HPC__Payment__c, Novidea_HPC__Payment_Value_In_ILS__c 
                    FROM Novidea_HPC__Collection__c
                    WHERE Novidea_HPC__Policy__c=:policyId
                    AND Novidea_HPC__Negative_Premium_Type__c=null];
        collections = new list<CollectionWrapper>();
        for(Novidea_HPC__Collection__c collection: clcts){
            collections.add(new CollectionWrapper(collection,false));
        }
        plcName = Apexpages.currentPage().getParameters().get('name');
        plcNum = Apexpages.currentPage().getParameters().get('number');
    }
    
    public class NoSuitableFormFoundException extends Exception{} 
    
    public Pagereference save(){
        Decimal sumILS =0, sumUSD = 0;
        for(CollectionWrapper collection: collections){
            if(collection.selected){
if (collection.collection.Novidea_HPC__Payment_Value_In_ILS__c != null)
                    sumILS += collection.collection.Novidea_HPC__Payment_Value_In_ILS__c;
                if(collection.collection.Novidea_HPC__Payment__c != null && collection.collection.Novidea_HPC__Payment_Currency__c != null)
                    sumUSD += CurrencyHelper.convertValue(collection.collection.Novidea_HPC__Collection_Date__c, 
                                                        collection.collection.Novidea_HPC__Payment__c, 
                                                        collection.collection.Novidea_HPC__Payment_Currency__c, 
                                                        'USD');
            }
        }
        System.SavePOint sp = Database.setSavepoint();
        try{
            Receipt__c receipt = new Receipt__c(Policy__c = policyId, Sum_ILS__c = sumILS, Sum_USD__c = sumUSD);
            Database.insert(receipt);
            
            list<Novidea_HPC__Collection__c> clcts= new list<Novidea_HPC__Collection__c>();
            for(CollectionWrapper collection: collections){
                if(collection.selected){
                    collection.collection.Receipt__c = receipt.Id;
                    clcts.add(collection.collection);
                }
            }
            
            if(!clcts.isEmpty()){
                Database.update(clcts);
                //frmId, receipt.id, Receipt__c
                list<Form_Assignment__c> ls = [SELECT Form__c FROM Form_Assignment__c WHERE Name='Receipt' AND Rows_From__c<=:clcts.size() AND Rows_To__c>=:clcts.size() LIMIT 1];
                if(ls.isEmpty()) throw new NoSuitableFormFoundException('לא נמצאה קבלה בגודל המתאים.');
                Id formId = ls[0].Form__c;
                Pagereference pr = new Pagereference('/apex/NPERFORM__generateForm?sourceObjectDescField=Name&targetId='+formId+'&sourceObjectsType=receipt__c&sourceId='+receipt.id+'&mergeWithPdf=true&lockData=true');
                return pr;
            }
            else{
                Database.rollback(sp);
            }
        }
        catch(Exception ex){
            Database.rollback(sp);
            throw ex;
        }
        return null;
    }
    
    public void cancel(){
        
    }
}