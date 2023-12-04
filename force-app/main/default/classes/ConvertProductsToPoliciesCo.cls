public with sharing class ConvertProductsToPoliciesCo {
    private List<Novidea_HPC__Product__c> products;
    private Boolean hasDuplicateProductDefs;
    private String filterId;

    public ConvertProductsToPoliciesCo(ApexPages.StandardSetController controller) {
        products = controller.getSelected();
        filterId = controller.getFilterId();
    }

    public ConvertProductsToPoliciesCo(List<Novidea_HPC__Product__c> products, Boolean hasDuplicateProductDefs) {
        this.products = products;
        this.hasDuplicateProductDefs = hasDuplicateProductDefs;
    }

    public PageReference initRecent() {
        filterId = 'Recent';
        return init();
    }

    public PageReference init() {
        try {
            // missing products
            if (products == null || products.isEmpty()) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ConvertProductsToPolicies_Missing_Products));
                return null;
            }

            List<Novidea_HPC__Product__c> validProducts = [
                SELECT  Novidea_HPC__Proposal__c
                FROM    Novidea_HPC__Product__c
                WHERE   Id IN :products
                AND     Novidea_HPC__Carrier__c != null
                AND     Novidea_HPC__Status__c = 'Accepted'
            ];
            // missing valid products - 1st check
            if (validProducts.isEmpty()) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ConvertProductsToPolicies_Missing_Valid_Products));
                return null;
            }

            validProducts = [
                SELECT  Novidea_HPC__Proposal__c
                FROM    Novidea_HPC__Product__c
                WHERE   (Novidea_HPC__Product__c IN :validProducts OR Novidea_HPC__Product__r.Novidea_HPC__Product__c IN :validProducts)
                AND     Novidea_HPC__Proposal__c != NULL
                AND     Novidea_HPC__Product__r.Novidea_HPC__Product__r.Novidea_HPC__Status__c NOT IN ('Converted', 'Cancelled', 'DECLINED_BY_INSURER', 'DECLINED_BY_CLIENT') 
            ];
            // missing valid products - 2nd check
            if (validProducts.isEmpty()) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ConvertProductsToPolicies_Missing_Valid_Products));
                return null;
            }

            // get product Ids and proposal Ids from valid products
            Set<Id> productIds = new Set<Id>();   
            Set<Id> proposalIds = new Set<Id>();
            for (Novidea_HPC__Product__c prod : validProducts) {
                productIds.add(prod.Id);
                proposalIds.add(prod.Novidea_HPC__Proposal__c);
            }

            // convert with management policy
            Novidea_HPC__General_Switches__c gs = Novidea_HPC__General_Switches__c.getInstance('Default');
            if (true != gs.Novidea_HPC__Disable_Management_Policy__c) {
                String selectCarrierPageLink = '/apex/ApprovedProposals?filterId=' + filterId + '&ui=1&advancedMode=true&proposalCsv=' + String.join(new List<Id>(proposalIds), ',');
                PageReference pageRef = new PageReference(selectCarrierPageLink);
                pageRef.setRedirect(true);
                return pageRef;
            }

            // convert without management policy
            ApprovedProposalsController ctrl = ApprovedProposalsController.createControllerWithoutPage(proposalIds, productIds);
            ctrl.advancedModeVal = true;
            ctrl.uiParam = '1';
            ctrl.filterId = filterId;
            PageReference pr = ctrl.convertToPolicy();

            // show special messages after conversion
            if (this.hasDuplicateProductDefs || ctrl.hasDuplicateProductDefs) {
                Boolean enableSameProductDef = gs.Novidea_HPC__Enable_Same_Product_Def__c == null ? false : gs.Novidea_HPC__Enable_Same_Product_Def__c;
                if (!enableSameProductDef) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Novidea_HPC.Same_ProductDef_Not_Created));
                } else {
                    Boolean enableSameProductDefMsg = gs.Novidea_HPC__Enable_Same_Product_Def_Msg__c == null ? false : gs.Novidea_HPC__Enable_Same_Product_Def_Msg__c;
                    if (enableSameProductDefMsg) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Novidea_HPC.Same_ProductDef_Created));
                    }
                }
            }    
            
            // edit policy if configured
            if (pr != null) {
                Boolean editPolicyAfterConversion = gs.Novidea_HPC__Edit_Policy_After_Conversion__c == null ? false : gs.Novidea_HPC__Edit_Policy_After_Conversion__c;
                if (editPolicyAfterConversion == true) {
                    PageReference pageRef = new PageReference(pr.getUrl());
                    pageRef.setRedirect(true);
                    return pageRef;          
                }
            }

            // regular - success message
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, Label.ConvertProductsToPolicies_Success));   
            return pr;         
        }
        catch (Exception ex) { // general error - alert
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ConvertProductsToPolicies_Error + ex.getMessage()));
            return null;
        }
    }
}