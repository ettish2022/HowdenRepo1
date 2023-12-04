public without sharing class ProductManagements {
    
   	private final String ACTION_FAILED = 'לא ניתן לבצע את הפעולה. סיבת השגיאה:';
   	
    public class ProductWrapper {
        public Novidea_HPC__Product__c product {get;set;}
        public Integer id{get;set;}
        public String productDefId{get;set;}
        
        public ProductWrapper(Novidea_HPC__Product__c product, Integer id ){
            this.product = product;
            this.productDefId = product.Novidea_HPC__Product_Definition__r.Id;
            this.id= id;
        }
    }
   
    public Integer lineToRemove {get;set;}
    public String selectedId{get;set;}
    public String selectedProdDefId{get;set;}
    //public decimal premiumAfterDiscount {get;set;}
    
    private list<Novidea_HPC__Product__c> productsForDeletion;
    
    private Integer getMaxIdVal(){
        Integer max = -1;
        if(products==null) return max;
        for(productWrapper cw:products){
            if(cw.id>max)max = cw.Id;
        }
        return max;
    }
    
    public map<Id,string> carrierIdToName ;
    Novidea_HPC__Lead__c lead;
    ApexPages.StandardController theController ;
    public ProductManagements(ApexPages.StandardController controller) { 
        lead = [select Novidea_HPC__Process__c,Name from Novidea_HPC__Lead__c where id =:((Novidea_HPC__Lead__c)controller.getRecord()).id];
        theController = controller; 
        
         productDefToName  = new map<Id,string>();
        for(Novidea_HPC__Product_Def__c proDef : [select Id, Name from Novidea_HPC__Product_Def__c]){
            productDefToName.put(proDef.Id,proDef.Name);
        }
    }

     public list<productWrapper> products
     {get{
     
        if (products == null){
            products = new list<productWrapper>();
            productsForDeletion = new list<Novidea_HPC__Product__c>();
            String targetWhere = '';
               targetWhere = ' Where Novidea_HPC__Lead__c = ' + '\'' + lead.Id + '\'';
        
            if (targetWhere != '') { 
                for (Novidea_HPC__Product__c product: (List<Novidea_HPC__Product__c>)Database.query(
                        'Select Id, Novidea_HPC__Product_Definition__c ,Novidea_HPC__Previous_Policy__r.Novidea_HPC__Action__c,Novidea_HPC__Previous_Policy__r.Novidea_HPC__Premium_to_Pay__c,Novidea_HPC__Discount__c,Name,Novidea_HPC__Carrier__c,Novidea_HPC__Premium__c,Premium_After_Discount__c,Novidea_HPC__Previous_Policy__r.Name,Car_Protections__c,' +
                        'Novidea_HPC__Product_Definition__r.Name,Novidea_HPC__Previous_Policy__c,Novidea_HPC__Carrier__r.Name,Novidea_HPC__Coverages__c from Novidea_HPC__Product__c ' +targetWhere)) {
                    products.add(new productWrapper(product,getMaxIdVal()+1)); 
                }
            }
        }   
        system.debug(products);
        return products; 
     }
        
        
     set;}
        
    public PageReference addLine(){
    	try {
	        Novidea_HPC__Product__c productData = new Novidea_HPC__Product__c(); 
	        productData.Novidea_HPC__Lead__c = lead.Id;
	        
	        system.debug('selectedProdDefId' + selectedProdDefId);
	        if (!string.isEmpty(selectedProdDefId) && selectedProdDefId != null && selectedProdDefId !=''){
	            productData.Novidea_HPC__Product_Definition__c = selectedProdDefId;
	            productData.Name = productDefToName.get(selectedProdDefId); 
	        }
	        productWrapper wp = new productWrapper(productData, getMaxIdVal()+1); 
	        products.add(wp);
	        Novidea_HPC.TriggerUtils.disableTrigger('blockCopyLeadToProdsOnProdBeforeInsert','ProductManagements.addLine');
	        database.insert(productData);
	        Novidea_HPC.TriggerUtils.enableTrigger('blockCopyLeadToProdsOnProdBeforeInsert','ProductManagements.addLine');
	        
	        PageReference pageRefresh = ApexPages.currentPage();    
	        pageRefresh.setRedirect(false);
	        return pageRefresh; 

        } catch(Exception e) {
        	if (!Apexpages.hasMessages())
				Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ACTION_FAILED + e.getMessage()));   

			return null;
        }
    }
    
    map<Id,string> productDefToName; 
     
    public list<Novidea_HPC__Process_Connection__c> getShowRemaindedProducts(){
       
        set<Id> proDefList = new set<id>();
        for (ProductWrapper pDef: products)
                proDefList.add(pDef.productDefId);
        
        list<Novidea_HPC__Process_Connection__c> procConList = new list<Novidea_HPC__Process_Connection__c>();
        list<Novidea_HPC__Process__c> procObj =[Select (Select Novidea_HPC__Product_Def__r.Name, Novidea_HPC__Product_Def__c 
                                                From Novidea_HPC__Processes_Connection__r
                                                where Novidea_HPC__Product_Def__c NOT IN : proDefList)
                                                From Novidea_HPC__Process__c
                                                where Id =: lead.Novidea_HPC__Process__c]; 
        //TODO: no process defined;
        if (procObj.size() == 0)
            return new list<Novidea_HPC__Process_Connection__c>();                     
                                        
        return  procObj.get(0).Novidea_HPC__Processes_Connection__r ;
    }
    
    public PageReference createProduct(){
    	try {
	        Novidea_HPC__Product__c productData = new Novidea_HPC__Product__c(); 
	        productData.Novidea_HPC__Lead__c = lead.Id; 
	        productData.Novidea_HPC__Product_Definition__c = selectedId;
	        productData.Name = productDefToName.get(selectedId);
	        products.add(new productWrapper(productData, getMaxIdVal()+1)); 

	        Novidea_HPC.TriggerUtils.disableTrigger('blockCopyLeadToProdsOnProdBeforeInsert','ProductManagements.createProduct');
	        database.insert(productData);
	        Novidea_HPC.TriggerUtils.enableTrigger('blockCopyLeadToProdsOnProdBeforeInsert', 'ProductManagements.createProduct');

	        PageReference pageRefresh = ApexPages.currentPage();    
	        pageRefresh.setRedirect(true);
	        return pageRefresh;

        } catch(Exception e) {
			if (!Apexpages.hasMessages())
				Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ACTION_FAILED + e.getMessage()));
				   
			return null;
        }
    }
    
    
   public PageReference removeLine(){ 
        try {
	        Integer productsSize = products.Size();
	        for(Integer productIndex = 0; productIndex < productsSize;productIndex++){
	            ProductWrapper cw = products[productIndex];
	            if(cw.id==lineToRemove){
	                system.debug('lineToRemove: '+lineToRemove);
	                Novidea_HPC__Product__c removedProduct = cw.product;
	                system.debug('products.size()' + products.size());
	                products.remove(productIndex);
	                system.debug('products.size()' + products.size());
	                if (cw.product.Id != null)
	                    productsForDeletion.add(removedProduct);
	                break;
	            }
	        }
	        
	        Database.delete(productsForDeletion);
	        
	        PageReference pageRefresh = ApexPages.currentPage();    
	        pageRefresh.setRedirect(true);
	        return pageRefresh;
        } catch(Exception e) {
        	if (!Apexpages.hasMessages())
				Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ACTION_FAILED + e.getMessage()));
				   
			return null;
        }
    }
    
    
    public PageReference saveChanges(){ 
    	try {
	        list<Novidea_HPC__Product__c> savelist = new list<Novidea_HPC__Product__c>();
	        for(ProductWrapper cw: products){
	            if (cw.product.Novidea_HPC__Carrier__c == null) {
	                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'המוצרים לא ישמרו כל עוד לא נבחרה חברת ביטוח לכל מוצר'));
	                return null;
	            }   
// Removed validation of carrier: Requested by allied, 09.05.2013
// TO DELETE IF NOT USED IN FUTURE
//	            } else if (!IsCarrierSuitableToTheProduct(cw) && carrierIdToName.get(cw.product.Novidea_HPC__Carrier__c) !=null){
//	            	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,carrierIdToName.get(cw.product.Novidea_HPC__Carrier__c) +' ,יתכן ומבטח זה אינו מסוג מבטח או שמוצריו לא תואמים למוצר הנוכחי'));
//	                return null;   
//	            }  
	            savelist.add(cw.product);                 
	        }
	        Database.upsert(savelist);
	        products = null;

			PageReference pageRefresh = ApexPages.currentPage();    
	        pageRefresh.setRedirect(false);
	        return pageRefresh;
        } catch(Exception e) {
        	if (!Apexpages.hasMessages())
				Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ACTION_FAILED + e.getMessage()));   
	
			return null;
        }
    }

    public decimal getNetPremiumSum(){
        decimal sum = 0;
        for(ProductWrapper cw: products){
            if(cw.product.Novidea_HPC__Premium__c == null)
                cw.product.Novidea_HPC__Premium__c = 0;
            sum += cw.product.Novidea_HPC__Premium__c ;
        }
        return sum;
    }
    public decimal getDiscountSum(){
        decimal sum = 0;
        for(ProductWrapper cw: products){
            if (cw.product.Novidea_HPC__Discount__c == null)
                cw.product.Novidea_HPC__Discount__c = 0;
            sum += cw.product.Novidea_HPC__Discount__c ;
        }
        return sum;
    }
  
   public decimal getCalculatedPremiumSum(){
        decimal sum = 0;
        for(ProductWrapper cw: products){
            if (cw.product.Premium_After_Discount__c != null)
                sum += cw.product.Premium_After_Discount__c ;
        }
        return sum;
    }
    
    public void dummy(){
    }

/*
    Removed validation of carrier: By Ada, 09.05.2013
    TO DELETE IF NOT USED IN FUTURE
    
    private boolean IsCarrierSuitableToTheProduct(ProductWrapper cw){
    	carrierIdToName  = new map<Id,string>();
		list<Account> carrier = [select Id ,Name,recordTypeId,
								 (select Novidea_HPC__Product_Definition__c from Novidea_HPC__Carrier_Products1__r)
								 from Account where Id =:cw.product.Novidea_HPC__Carrier__c];
		for(Account account : carrier){
			carrierIdToName.put(account.Id,account.Name);
		}
			
 		if (carrier.size()== 0)
 			return false;
 		for (Novidea_HPC__Carrier_Product__c def: carrier.get(0).Novidea_HPC__Carrier_Products1__r){
 			if(cw.productDefId == def.Novidea_HPC__Product_Definition__c)
 				return true;				 	
	 	}
	 	return false;
    }
*/
}