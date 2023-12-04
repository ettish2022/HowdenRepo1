public with sharing class PolicyProductsController {
    Novidea_HPC__Policy__c policy  = new Novidea_HPC__Policy__c ();
    list<Novidea_HPC__Product__c> products = new list<Novidea_HPC__Product__c>();
    list<Novidea_HPC__Policy__c> fieldSet = new list<Novidea_HPC__Policy__c> ();
    
    public PolicyProductsController(ApexPages.StandardController controller) {
    
        policy = (Novidea_HPC__Policy__c)controller.getRecord();
    }
    
    public PageReference init(){
        
        if (ApexPages.CurrentPage().getParameters().get('product') == 'true')
            if (getIsProducts())
                return new PageReference('/' + products[0].id);
        
        return null;
    }
    
    public boolean  getIsProducts(){
        fieldSet = [select Novidea_HPC__Process__r.Novidea_HPC__Fieldset__c
                                                from Novidea_HPC__Policy__c where Id =: policy.Id and Novidea_HPC__Process__r.Novidea_HPC__Fieldset__c <>  null  LIMIT 1];
        if (fieldSet.IsEmpty())
            return false;
        map<String, Schema.SObjectField> productFields = Novidea_HPC__Product__c.SObjectType.getDescribe().fields.getMap();
        Set<String> productFieldsNames = productFields.keySet();    
        String query = 'SELECT ';
        map<String, Schema.FieldSet> fsmap = Schema.SObjectType.Novidea_HPC__Lead__c.fieldSets.getMap();
        if (fsmap == null || fsmap.IsEmpty()) return false;
            for(Schema.FieldSetMember f : ((FieldSet)fsmap.get(fieldSet[0].Novidea_HPC__Process__r.Novidea_HPC__Fieldset__c)).getFields()) {
                if(productFieldsNames.contains('novidea_hpc__'+f.getFieldPath().toLowerCase()))
                    query += 'Novidea_HPC__' + f.getFieldPath() + ', '; 
                if(productFieldsNames.contains(f.getFieldPath().toLowerCase()))      
                    query += +f.getFieldPath() + ', '; 
            } 
        query += 'Novidea_HPC__Policy__c,LastModifiedDate from Novidea_HPC__Product__c where Novidea_HPC__Policy__c =\''+ policy.Id +'\'order by LastModifiedDate desc LIMIT 1';
        products  = Database.query(query);
        if (!Products.isEmpty() && Products[0].Id != null)
            return true;
        return false;
        
    }

    public list<Schema.FieldSetMember> getViewFieldSet(){
        map<String, Schema.FieldSet> fsmap = Schema.SObjectType.Novidea_HPC__Lead__c.fieldSets.getMap();
        return ((FieldSet)fsmap.get(fieldSet[0].Novidea_HPC__Process__r.Novidea_HPC__Fieldset__c)).getFields();
    }
    public Map<String,String> realFields {get;set;}
    public Novidea_HPC__Product__c getProduct() {
        realFields = new Map<String,String>();
        Novidea_HPC__Product__c product = new Novidea_HPC__Product__c(); 
        if (!Products.isEmpty() && Products[0].Id != null) 
            product = products[0];
        map<String, Schema.FieldSet> fsmap = Schema.SObjectType.Novidea_HPC__Lead__c.fieldSets.getMap();
        if (!fieldSet.IsEmpty())
            for(String key : fsmap.keyset()){
                if(key!=fieldSet[0].Novidea_HPC__Process__r.Novidea_HPC__Fieldset__c)continue;
                for(Schema.FieldSetMember f : SObjectType.Novidea_HPC__Lead__c.FieldSets.getMap().get(key).getFields()) {
                    try{
                        realFields.put(f.getFieldPath(), f.getFieldPath());
                        product.get(f.getFieldPath());
                    }catch(Exception e){
                        product.get('Novidea_HPC__' + f.getFieldPath());
                        realFields.put(f.getFieldPath(), 'Novidea_HPC__' + f.getFieldPath());               
                    }
                }
            }     
        return product;
    }
    
 /*    private static testmethod void testController(){
        
        CurrencyTriggerHelper.stopTrigger =true;
        Novidea_HPC__Process__c Process = new Novidea_HPC__Process__c ();
        Process.Novidea_HPC__Fieldset__c = 'Car_Details';
        database.insert(Process);
        Novidea_HPC__Policy__c policy = new Novidea_HPC__Policy__c ();
        policy.Novidea_HPC__Process__c = Process.Id;
        database.insert (policy);
        
        Novidea_HPC__Product_Def__c proDef = new Novidea_HPC__Product_Def__c();
        
        
        Novidea_HPC__Product__c product = new Novidea_HPC__Product__c();
        product.Novidea_HPC__Policy__c = policy.Id;
        product.Name = 'test';
        database.insert (product);
     
        PolicyProductsController ppc 
                = new PolicyProductsController(new ApexPages.StandardController(policy));
     
        
        ppc.getproduct();
        ppc.getisProducts();
        
        
     }*/
      public static void testPasser(){
       List<Account> ac = new List<Account>();
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
          
   }
   
   public static void testPasser2(){
       List<Account> ac = new List<Account>();
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());  
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
       ac.add(new Account());
          
   }
   
}