global class WSYigod {
    //this field will be used in policy update trigger to decide whether to turn off the managed_by_production flag
    public static boolean keepManagedByProductionOn = false; 
    public static final String USER_TYPE = Schema.SObjectType.User.getKeyPrefix();
    public static final String GROUP_TYPE = Schema.SObjectType.Group.getKeyPrefix();
    public static General__c generalswitches = General__c.getInstance();
    
    webservice static wsResult checkForTransactionName(String fileName) {
        wsResult result = new wsResult();
        try{
            set<id> groupMembers = getAllUsersUnderSameGroupOfCurrrentUser();            
            result.code =101;
            if (fileName != null){
                list<Policy_Transaction__c> listPolicyTransaction = [select id from Policy_Transaction__c where Name = : fileName and OwnerId IN: groupMembers limit 10000];
                if (listPolicyTransaction.size()>0){
                    result.isFound = true;                  
                }               
             } 
        }catch(exception e){
            result.listFailed.add('ארעה שגיאה אנא נסה לטעון את הקובץ בשנית');
            return result;
        }
        return result;
    }
    
    webservice static wsResult deletePolicyTransactionByFileName(String fileName) {
        wsResult result = new wsResult();
        try{ 
            set<id> groupMembers = getAllUsersUnderSameGroupOfCurrrentUser();              
            result.code = 101;
            if (fileName != null){
                list<Policy_Transaction__c> listPolicyTransaction = [select id from Policy_Transaction__c where Name = : fileName and OwnerId  IN: groupMembers limit 10000];
                if (listPolicyTransaction.size()>0){
                    delete listPolicyTransaction;                   
                }               
             }
        }catch(exception e){
            result.listFailed.add('ארעה שגיאה אנא נסה לטעון את הקובץ בשנית');
            return result;
        }
        return result;
    }
    
     /* DIANA
     *  get all users under same group and under subgroup with current user
     *  if not exist such group return user itself
     */
    
       private static map<id,set<id>> groupToAllUsers(string developerNameOfFirstLayer,String userType, String groupType){  
       
    
        map<id,set<id>> parentGroupToSetUsers = new map<id,set<id>>();
        map<id,id> groupToParentGroup = new map<id,id>();
        set<id> users ;
    
    
        for (Group m : [Select (Select UserOrGroupId,GroupId From GroupMembers) 
                                From Group 
                                Where DeveloperName like: (developerNameOfFirstLayer + '%')] ){
            users = new set<id>();
            for(GroupMember gm : m.GroupMembers){
                if (((String)gm.UserOrGroupId).startsWith(userType)){
                    users.add(gm.UserOrGroupId);
                }
                else if (((String)gm.UserOrGroupId).startsWith(groupType)){
                    groupToParentGroup.put(gm.UserOrGroupId,m.id);
                }
            }
            parentGroupToSetUsers.put(m.id,users);
        }

        for (Group im : [select (Select UserOrGroupId,GroupId From GroupMembers) From Group Where id IN: groupToParentGroup.keySet()]){
            for(GroupMember gm : im.GroupMembers){
                if (((String)gm.UserOrGroupId).startsWith(userType) && im.id != null
                        && groupToParentGroup.get(im.id)!= null
                        && parentGroupToSetUsers.get(groupToParentGroup.get(im.id)) != null){
                    parentGroupToSetUsers.get(groupToParentGroup.get(im.id)).add(gm.UserOrGroupId);
                }
            }
        }
        return parentGroupToSetUsers;
    }
    
    public static set<id> getAllUsersUnderSameGroupOfCurrrentUser(){
        map<id,set<id>> parentGroupToSetUsers = 
                groupToAllUsers(generalswitches.Production_Permission_Prefix_Group__c != null ?generalswitches.Production_Permission_Prefix_Group__c:'Production_Permission',
                USER_TYPE, GROUP_TYPE);
        for(id parentGroup: parentGroupToSetUsers.keySet()){
            set<id>usersUnderParentGroup = parentGroupToSetUsers.get(parentGroup);
            if(usersUnderParentGroup.contains(userInfo.getUserId()))
                return usersUnderParentGroup; 
        }
        return new set<id>{userInfo.getUserId()};
    }
    ///    
    
    public static Boolean UpdateObject = false;
    WebService static wsResult UpsertData(HeshbonOPolisa policyDetail)  
    {       
        wsResult result = new wsResult();
        result.code =101;
        return null;         
    }       
    
    public class MissingPolicyProductException extends Exception{}
   
    public static Novidea_HPC__Product__c updatePolicyProduct(Novidea_HPC__Policy__c policy, Policy_Transaction__c pt, HeshbonOPolisa heshbonOPolisaObj, Novidea_HPC__Policy__c polFromDB){
        boolean hasCarDetails = !string.isBlank(pt.Vehicle_Model__c) || !string.isBlank(pt.Vehicle_Manufacturer__c) || heshbonOPolisaObj.isVehicleDetailsExist();
        system.debug(polFromDB);
        system.debug(polFromDB.novidea_hpc__Products__r);
        system.debug( polFromDB.novidea_hpc__Products__r.isEmpty());
        system.debug(hasCarDetails);
        
        if(polFromDB==null || polFromDB.novidea_hpc__Products__r==null || polFromDB.novidea_hpc__Products__r.isEmpty() && hasCarDetails){ // DIANA 22/04/2015
            throw new MissingPolicyProductException('Policy: ' + policy.Novidea_HPC__Policy_Number__c + ' has no products, Therefore vehicle details cannot be saved.');
        }
        if(hasCarDetails){
            polFromDB.novidea_hpc__Products__r[0].Novidea_HPC__Vehicle_Model_In_Price_List__c = pt.Vehicle_Model__c;
            polFromDB.novidea_hpc__Products__r[0].Novidea_HPC__Vehicle_Model__c =  pt.Vehicle_Manufacturer__c;
            heshbonOPolisaObj.updateVehicleDetails(polFromDB.novidea_hpc__Products__r[0]);
            return polFromDB.Novidea_HPC__Products__r[0];
        }
        return null;
    }

    public static void updatePolicyProduct(PolicyGenerationResultList pgr){
        map<Id,Novidea_HPC__Policy__c> pols = new map<Id,Novidea_HPC__Policy__c>([SELECT (SELECT Novidea_HPC__Vehicle_Year_of_manufacture__c, Novidea_HPC__Vehicle_Model__c,
                                                                                            Novidea_HPC__Vehicle_Registration_Number__c,Novidea_HPC__Vehicle_Manufacturer__c,
                                                                                            Novidea_HPC__Vehicle_Model_In_Price_List__c  
                                                                                        FROM Novidea_HPC__Products__r
                                                                                        LIMIT 1)
                                                                                FROM Novidea_HPC__Policy__c
                                                                                WHERE id IN : pgr.policies]);
        Novidea_HPC__Product__c prod;
        list<Novidea_HPC__Product__c> prods = new list<Novidea_HPC__Product__c>();
        for(Novidea_HPC__Policy__c pol: pgr.policies){
            prod = updatePolicyProduct(pol,  pgr.getTxData(pol.Id).pt, pgr.getTxData(pol.Id).heshbonOPolisaObj, pols.containsKey(pol.Id)?pols.get(pol.Id):pol);
            if(prod!=null)prods.add(prod);
        }
        if(!prods.isEmpty())Database.update(prods);
    }
    
    
    
     public class PolicyGenerationResultList{
        private map<String,PartialPolicyGenerationResult> basemap = new map<String,PartialPolicyGenerationResult>();
        private map<String,Novidea_HPC__Policy__c> policyMap = new  map<String,Novidea_HPC__Policy__c>();
        //translate from PolicyId to the generatedKey
        private map<Id,String> translationMap = new  map<Id,String>();
        public list<Novidea_HPC__Policy__c> policies{get{return policyMap.values();}}
        
        public PartialPolicyGenerationResult getTxData(Id polId){
            return basemap.get(translationMap.get(polId));
        }
        public void add(PolicyGenerationResult pgr){
            //generate key for the maps if no Id yet
            String key = pgr.pol.Id!=null ? (String)pgr.pol.Id : ((basemap.size()+1) + '');
            basemap.put(key, new PartialPolicyGenerationResult(pgr.heshbonOPolisaObj,pgr.pt));
            policyMap.put(key, pgr.pol);
        }
        
        public void dbInsertPolicies(){
            database.insert(policyMap.values());
            for(String key: policyMap.keyset()){
                translationMap.put(policyMap.get(key).id,key);
            }
        }
      }
      
      public class PolicyGenerationResult{
        public Novidea_HPC__Policy__c pol;
        public WSYigod.HeshbonOPolisa heshbonOPolisaObj;
        public Policy_Transaction__c pt;
        public PolicyGenerationResult(Novidea_HPC__Policy__c pol, WSYigod.HeshbonOPolisa heshbonOPolisaObj, Policy_Transaction__c pt){
            this.pol = pol;
            this.heshbonOPolisaObj = heshbonOPolisaObj;
            this.pt = pt;
        }
      }
      
      public class PartialPolicyGenerationResult{
        public WSYigod.HeshbonOPolisa heshbonOPolisaObj;
        public Policy_Transaction__c pt;
        public PartialPolicyGenerationResult(WSYigod.HeshbonOPolisa heshbonOPolisaObj, Policy_Transaction__c pt){
            this.heshbonOPolisaObj = heshbonOPolisaObj;
            this.pt = pt;
        }
        
      }
    
    public static List<Id> processAndUpdateSobjFromPolicyTransaction(list<Policy_Transaction__c> listPolicyTransAction, boolean processNonMatchingAccounts){
//        system.debug('listPolicyTransAction: ' + listPolicyTransAction);
        UpdateObject = true;
        map<Id,Novidea_HPC__Policy__c> mapPolicyToUpsert = new map<Id,Novidea_HPC__Policy__c>();
        map<Id,Contact> mapContactToUpdate = new map<Id,Contact>();
        map<Id,Account> mapAccountToUpdate = new map <Id,Account>(); 
        map<Id,set<Id>> mapPolicyTranctionToSobjIds = new map<Id,set<Id>>();
        set<Id> setPolicyId = new set<Id>();
        for(Policy_Transaction__c pt : listPolicyTransaction){
            if(pt.Policy__c != null)
                setPolicyId.add(pt.Policy__c);
        }
        map<Id,Novidea_HPC__Policy__c> mapAllPolicyWithIncome = new map<Id,Novidea_HPC__Policy__c>();
        if(!setPolicyId.isEmpty()){
            mapAllPolicyWithIncome = new map<Id,Novidea_HPC__Policy__c>(
                                [SELECT Novidea_HPC__Policy_Number__c, Novidea_HPC__Client__c, Novidea_HPC__Carrier_Product_Number__c,  Novidea_HPC__Client__r.Owner.ProfileId, 
                                        Novidea_HPC__Product_Definition__r.Novidea_HPC__Category__r.Policies_Owner__c, 
                                        Novidea_HPC__Product_Definition__r.Novidea_HPC__Category__r.Default_Team_Member_Role__c, 
                                        Novidea_HPC__Client__r.OwnerId,
                                        Novidea_HPC__Status__c, Endorsement_Approved__c, Managed_By_Production__c, OwnerId, Novidea_HPC__Policy_Source__c,
                                        Novidea_HPC__Original_Type__c,
                                    (SELECT Novidea_HPC__Policy__c, Novidea_HPC__Commission_Amount__c, Novidea_HPC__Commission_From_Production__c,
                                            Novidea_HPC__Commission_Percentage__c, Novidea_HPC__Commission_amount_from_Production__c, Novidea_HPC__Credit_Fees_From_Production__c, 
                                            Novidea_HPC__Credit_Fees__c, Novidea_HPC__Effective_Date__c, Novidea_HPC__Endorsement_Number__c, Novidea_HPC__Expiration_Date__c, 
                                            Novidea_HPC__Fees_From_Production__c, Novidea_HPC__Fees__c, Novidea_HPC__Is_Updated_by_Production__c, 
                                            Novidea_HPC__Premium_From_Production__c,Novidea_HPC__Premium__c, Novidea_HPC__Production_Update_Date__c,
                                            Created_By_Policy_Trigger__c
                                    FROM Novidea_HPC__Incomes__r),
                                    (SELECT Novidea_HPC__Vehicle_Year_of_manufacture__c, Novidea_HPC__Vehicle_Model__c,
                                                Novidea_HPC__Vehicle_Registration_Number__c,Novidea_HPC__Vehicle_Manufacturer__c  
                                    FROM Novidea_HPC__Products__r LIMIT 1)
                                 FROM Novidea_HPC__Policy__c 
                                 WHERE Id IN :setPolicyId ]);
        }
        
        list<Novidea_HPC__Income__c> listIncomeUpsert = new list<Novidea_HPC__Income__c>();
        map<Id,Novidea_HPC__Product__c> mapProductUpsert = new map<Id,Novidea_HPC__Product__c>();
        //rz change 4/7/12: part of need to update all matching incomes with bordero + production update date
        boolean incomeFound = false, matchingIncomesUpdated = false;
        list<Novidea_HPC__Income__c> matchingIncomes = new list<Novidea_HPC__Income__c>();
        Novidea_HPC__Policy__c polFromDB = null;
        for(Policy_Transaction__c pt : listPolicyTransAction){
            if (pt.Policy_Content__c != null){
                set<Id> setSobjId = new set<Id>();
                string heshbonOPolisaJson = Encodingutil.urlDecode(pt.Policy_Content__c, 'UTF-8')+'}';  
                WSYigod.HeshbonOPolisa heshbonOPolisaObj = (WSYigod.HeshbonOPolisa)JSON.deserialize( heshbonOPolisaJson, WSYigod.HeshbonOPolisa.class);
                if (heshbonOPolisaObj != null && pt.Status__c == 'compatible' && pt.Policy__c != null && (processNonMatchingAccounts || pt.Customer_Account__c!=null) 
                //raniz add 17/10/2012: #1062  
                && ((polFromDB = mapAllPolicyWithIncome.get(pt.Policy__c))==null || polFromDB.Novidea_HPC__Client__c!=null || pt.Customer_Account__c!=null)){
                    //raniz change 2/2/14: found following issue in updating cancelation status - IC-0100001216
                    Novidea_HPC__Policy__c pol;// = new Novidea_HPC__Policy__c(Id = pt.Policy__c);
                    if((pol=mapPolicyToUpsert.get(pt.Policy__c))==null) pol = new Novidea_HPC__Policy__c(Id = pt.Policy__c);
                    // new logic 23/04
                    string incomeId ='';
                    //raniz 9/7/2012: add indicator to handle same as new income when the income was just created by policy trigger
                    //this will enable updating of premium, fees etc. values 
                    boolean createdByPolicyTrigger = false;
                    
                    if ((polFromDB = mapAllPolicyWithIncome.get(pt.Policy__c)) != null){
                        if(polFromDB.Novidea_HPC__Incomes__r != null && !polFromDB.Novidea_HPC__Incomes__r.isEmpty()){
                            for(Novidea_HPC__Income__c income : polFromDB.Novidea_HPC__Incomes__r){
                                if(income.Novidea_HPC__Endorsement_Number__c != null){
                                    if(String.valueOf(income.Novidea_HPC__Endorsement_Number__c)==pt.endorsement_number__c ||
                                    //rz change 3/7/12: allow update of endorsments with -sign
                                    income.Novidea_HPC__Endorsement_Number__c < 0 && 
                                    String.valueOf(math.abs(income.Novidea_HPC__Endorsement_Number__c)-1)==pt.endorsement_number__c){
                                        //rz change 4/7/12: need to update all matching incomes with bordero + production update date
                                        if(incomeFound!=null && !incomeFound){
                                            incomeId =income.Id;
                                            createdByPolicyTrigger = income.Created_By_Policy_Trigger__c;
                                            incomeFound = true;
                                        }
                                        else{
                                            if(matchingIncomes==null) matchingIncomes = new list<Novidea_HPC__Income__c>();
                                            matchingIncomes.add(new Novidea_HPC__Income__c(Id=income.Id));                                       
                                        }
                                    }
                                }
                            }                       
                        }
                    }
                    //rz change 4/7/12: part of need to update all matching incomes with bordero + production update date
                    incomeFound = false;
                    //end change 4/7/12
                    Novidea_HPC__Income__c incomeToUpsert;
                    
                    if(incomeId !='') incomeToUpsert = new Novidea_HPC__Income__c(id =incomeId);
                    else incomeToUpsert = new Novidea_HPC__Income__c();
                    
                    if(createdByPolicyTrigger) incomeToUpsert.Created_By_Policy_Trigger__c = false;
                    
                    if ( incomeId !='' && !createdByPolicyTrigger){
                        
                        //rz add 3/7/12
                        if (pt.Production_Date__c != null){
                            incomeToUpsert.Novidea_HPC__Bordero_Date__c = pt.Production_Date__c;
                            //rz change 4/7/12: need to update all matching incomes with bordero + production update date
                            if(matchingIncomes!=null && !matchingIncomes.isEmpty()){
                                for(Novidea_HPC__Income__c inc: matchingIncomes){
                                    inc.Novidea_HPC__Bordero_Date__c = pt.Production_Date__c;
                                    inc.Novidea_HPC__Production_Update_Date__c = date.today();
                                }
                                matchingIncomesUpdated = true;
                            }
                        }
                        //rz change 4/7/12: need to update all matching incomes with bordero + production update date
                        if(matchingIncomes!=null && !matchingIncomes.isEmpty() && matchingIncomesUpdated!=null && !matchingIncomesUpdated){
                            for(Novidea_HPC__Income__c inc: matchingIncomes){
                                inc.Novidea_HPC__Production_Update_Date__c = date.today();
                            }
                        } 
                    }
                    else{
                        
                        //rz add 3/7/12
                        if (pt.Production_Date__c != null){
                            incomeToUpsert.Novidea_HPC__Bordero_Date__c = pt.Production_Date__c;
                        }

                        if (pt.endorsement_number__c != null){
                            try{                        
                                incomeToUpsert.Novidea_HPC__Endorsement_Number__c = decimal.valueOf(pt.endorsement_number__c);
                            }
                            catch(exception e){}
                        }
                        if (pt.Policy__c != null && !createdByPolicyTrigger){
                            incomeToUpsert.Novidea_HPC__Policy__c = pt.Policy__c;
                        }
                    }  
                    
                    //raniz change 11/09/2012: moved from inside the above "else". This was a bug since the begining: 
                    //incomes need to update if the poicy is managed by production even if greater then 0 or new
                    if(polFromDB==null || polFromDB.Managed_By_Production__c!=null && polFromDB.Managed_By_Production__c){
                        if (pt.Commission_Written_In_Carrier__c != null){
                            incomeToUpsert.Novidea_HPC__Commission_Amount__c = pt.Commission_Written_In_Carrier__c;
                        }
                        if (pt.Fee__c != null){
                            incomeToUpsert.Novidea_HPC__Fees__c = pt.Fee__c;
                        }
                        
                        if (pt.Credit_Fee__c != null){
                            incomeToUpsert.Novidea_HPC__Credit_Fees__c = pt.Credit_Fee__c;
                        }
                        
                        if (pt.premium__c != null){
                            try{
                                incomeToUpsert.Novidea_HPC__Premium__c = decimal.valueOf(pt.premium__c);
                            }
                            catch(exception e){}
                        }
                        //rz add 09/09/2012
                        if(pt.Agent_Discount_Written_In_Carrier__c!=null){
                            incomeToUpsert.Novidea_HPC__Agent_Discount__c = pt.Agent_Discount_Written_In_Carrier__c;
                        }
                    }
 
                    
                    //raniz change 18/7/2012: common part
                    if (pt.Commission_Written_In_Carrier__c != null){
                        incomeToUpsert.Novidea_HPC__Commission_amount_from_Production__c = pt.Commission_Written_In_Carrier__c;                                             
                    }
                    
                    if (pt.Credit_Fee__c != null){
                        incomeToUpsert.Novidea_HPC__Credit_Fees_From_Production__c =pt.Credit_Fee__c;
                    }

                    if (pt.Fee__c != null){
                        incomeToUpsert.Novidea_HPC__Fees_From_Production__c = pt.Fee__c;
                    }                               
                    if (pt.premium__c != null){
                        try{
                            incomeToUpsert.Novidea_HPC__Premium_From_Production__c = decimal.valueOf(pt.premium__c);
                        }
                        catch(exception e){}
                    } 
                    
                    if(pt.Agent_Discount_Written_In_Carrier__c!=null){
                        incomeToUpsert.Novidea_HPC__Agent_Discount_From_Production__c = pt.Agent_Discount_Written_In_Carrier__c;
                    }
                    
                    if(pt.Carrier__c!=null){
//                        system.debug('enter pt.Carrier__c!=null');
                        incomeToUpsert.Novidea_HPC__Carrier__c = pt.Carrier__c;
                    }
                    else{
//                        system.debug('enter pt.Carrier__c==null');
                    }
                    
                    if(incomeToUpsert.Novidea_HPC__Premium_Currency__c==null && heshbonOPolisaObj.CurrencyCode!=null && !''.equals(heshbonOPolisaObj.CurrencyCode))
                        incomeToUpsert.Novidea_HPC__Premium_Currency__c = heshbonOPolisaObj.CurrencyCode;
                    
                
                
                    //raniz change 05/12/2012: taking  Effective_Date__c & Expiration_Date__c for numer>0 when ther is no Endorsement_Effective_Date__c
                    //e.g. In Clal Novidea_HPC__Effective_Date__c & Novidea_HPC__Expiration_Date__c not always apear when number>0
                    if (pt.Effective_Date__c != null){
                        incomeToUpsert.Novidea_HPC__Effective_Date__c = pt.Effective_Date__c;
                    }
                    if (pt.Expiration_Date__c != null){
                        incomeToUpsert.Novidea_HPC__Expiration_Date__c = pt.Expiration_Date__c;
                    }
                    if(pt.endorsement_number__c != '0'){
                        if (pt.Endorsement_Effective_Date__c != null){
                            incomeToUpsert.Novidea_HPC__Effective_Date__c = pt.Endorsement_Effective_Date__c;
                        }
                        if (pt.Endorsement_Expiration_Date__c != null){
                            incomeToUpsert.Novidea_HPC__Expiration_Date__c = pt.Endorsement_Expiration_Date__c;
                        }
                    }
 

                    incomeToUpsert.Novidea_HPC__Production_Update_Date__c = date.today();
                    incomeToUpsert.Novidea_HPC__Is_Updated_by_Production__c = true; 
   
                    //END raniz change 18/7/2012: common part
                    
                    //raniz add 10/09/2012
                    incomeToUpsert.Production_File_Name__c = pt.File_Name__c;
                    //
                                  
                    listIncomeUpsert.add(incomeToUpsert);
                    
                    createdByPolicyTrigger = false;
                    
                    //rz change 4/7/12: need to update all matching incomes with bordero + production update date
                    if(!matchingIncomes.isempty()) {
                        listIncomeUpsert.addAll(matchingIncomes);
                        matchingIncomes = new list<Novidea_HPC__Income__c>();
                    }                  
                    // start updating field in policy  from the PolicyTransaction object
                    
                    // the broker number will be overide any way
                    if (pt.Broker_Number__c != null ){
                        pol.Novidea_HPC__Broker_In_Carrier__c = pt.Broker_Number__c;
                    }
                    if (pt.Product_Def__c != null ){
                        pol.Novidea_HPC__Product_Definition__c = pt.Product_Def__c;
                    }
                    //raniz change 21/10/2012: issue #1044 - update only when changing
                    if (pt.Carrier_Product__c != null && (polFromDB==null || polFromDB.Novidea_HPC__Carrier_Product_Number__c!=pt.Carrier_Product__c)){
                        pol.Novidea_HPC__Carrier_Product_Number__c = pt.Carrier_Product__c;
                    }
//                    system.debug('pol1: ' + pol + '\npolFromDB: ' + polFromDB + '\npt: ' + pt);
                    //raniz change 3/7/12
                    if(polFromDB==null || !'BOR In Middle period'.equalsIgnoreCase(polFromDB.Novidea_HPC__Status__c)){
                        pol.Novidea_HPC__Status__c = 'Production Updated';
//                        system.debug('enter to update status : ' + pol);
                    }
                    /*
                        raniz change 13/06/2012: Need to allow saving updates if policy exits even if account wasn't found 
                        or does not match the policy's account. The policy's account will be updated to the new one 
                        if there was no account on the exiting policy.
                    */
                    if(polFromDB!=null && pt.Customer_Account__c!=null && polFromDB.Novidea_HPC__Client__c ==null){
                        pol.Novidea_HPC__Client__c = pt.Customer_Account__c;
                    }
                    //rz add 15/7/2012: 
                    if(pt.endorsement_number__c!=null && 
                      (polFromDB!=null && polFromDB.Endorsement_Approved__c!=null && polFromDB.Endorsement_Approved__c<decimal.valueOf(pt.endorsement_number__c) || 
                        polFromDB==null || polFromDB.Endorsement_Approved__c==null
                       )
                    )
                        pol.Endorsement_Approved__c = decimal.valueOf(pt.endorsement_number__c);
                   
//                      system.debug('pol2: ' + pol);
                    /*commented out by raniz 14/4/2013
                    pol.Novidea_HPC__Vehicle_Model__c = pt.Vehicle_Model__c;
                    pol.Novidea_HPC__Vehicle_Manufacturer__c = pt.Vehicle_Manufacturer__c;
                    */
                    pol.Insured_Name__c = pt.Customer_Full_Name__c;
                    
                    if(pt.Client__c!=null) pol.Novidea_HPC__Insured_Person__c = pt.Client__c;
                    
                    heshbonOPolisaObj.updatePolicyField(pol, false, polFromDB);  
//                      system.debug('pol3: ' + pol);
                    //rz add 14/4/13: update the policy product with vehicle details
                    //TODO: unify with other product handling + handle the update to the lead. it happens only here and not in policy creation
                    Novidea_HPC__Product__c prod = updatePolicyProduct(pol,pt,heshbonOPolisaObj, polFromDB);
                    if(prod!=null)mapProductUpsert.put(prod.id,prod);
                                    
                    if(heshbonOPolisaObj.NetuneiGvia != null){
                        heshbonOPolisaObj.NetuneiGvia.updatePolicyField(pol);
                        setSobjId.add(pt.Policy__c);                                        
                    }                   
                    if(pt.Customer_Account__c != null && pt.Client__c == null ){
                        if(heshbonOPolisaObj.YeshutLakoach != null){
                            Account acc = new Account(id = pt.Customer_Account__c);
                            heshbonOPolisaObj.YeshutLakoach.updateAccountField(acc);
                            if(!mapAccountToUpdate.containsKey(acc.Id)) 
                                mapAccountToUpdate.put(acc.Id,acc);
                            setSobjId.add(pt.Customer_Account__c); 
                            //raniz add 11/7/13: create contact
                        }
                    }
                    else if(pt.Client__c != null){
                        if(heshbonOPolisaObj.YeshutLakoach != null ){
                            setSobjId.add(pt.Client__c);
                            Contact con = new Contact(id =pt.Client__c);
                            heshbonOPolisaObj.YeshutLakoach.updateContactField(con);
                            if(!mapContactToUpdate.containsKey(con.Id))
                                mapContactToUpdate.put(con.Id,con);     
                        }
                    }
                        
                        
                    mapPolicyTranctionToSobjIds.put(pt.Id,setSobjId);
                    if(!mapPolicyToUpsert.containsKey(pol.Id)){
                        mapPolicyToUpsert.put(pol.Id,pol);
                        pol.Novidea_HPC__Policy_Number__c = pt.Policy_number_from_Insurance_company__c;
                    }
                }                       
            }
        } 
        
        //start updating record 
        map<Id,List<Database.Error>> mapErrors = new map<Id,List<Database.Error>>();
        system.savepoint sp = database.setSavepoint();
        try{
            if (!listIncomeUpsert.isempty()){
//              system.debug(listIncomeUpsert[0]);
                Database.upsert(listIncomeUpsert);
            }
            if(!mapProductUpsert.isempty()){
                Database.upsert(mapProductUpsert.values());
            }
            
            
            list<Database.Upsertresult> policyResult;
            if (!mapPolicyToUpsert.isEmpty()){
//              system.debug('mapPolicyToUpsert.values()[0]: ' + mapPolicyToUpsert.values()[0]);
                policyResult = database.upsert(mapPolicyToUpsert.values(),false);
                if (policyResult != null){
                    processUpdateResult(policyResult,mapErrors);
                }
            }
//          system.debug('mapErrors: ' + mapErrors);
            List<Database.Upsertresult> contactResult;
            if (!mapContactToUpdate.isEmpty()){
                contactResult = database.upsert(mapContactToUpdate.values(),false);
                if (contactResult != null){
                    processUpdateResult(contactResult,mapErrors);
                }
            }       
            List<Database.Upsertresult> accountResult;
            if (!mapAccountToUpdate.isEmpty()){
                accountResult = database.upsert(mapAccountToUpdate.values(),false);
                if (accountResult != null){
                    processUpdateResult(accountResult,mapErrors);
                }
            }
        }
        catch(exception ex){
            database.rollback(sp);
            throw ex;
        }

        list<Id> listPTId = new list<Id>();
        for(Policy_Transaction__c pt : listPolicyTransAction){
            pt.Errors_while_updating_Sobject__c ='';
            if(mapPolicyTranctionToSobjIds.containsKey(pt.Id)){
                 set<Id> setSobjId = mapPolicyTranctionToSobjIds.get(pt.Id);
                 if(!setSobjId.isEmpty()){
                    for(id sobjId : setSobjId){
                        if(mapErrors.containsKey(sobjId)){
                            List<Database.Error> listErr = mapErrors.get(sobjId);
                            for ( Database.Error err : listErr)
                                pt.Errors_while_updating_Sobject__c =err.getMessage() ; 
                        }
                    }
                 }
                if (pt.Errors_while_updating_Sobject__c == ''){ 
                    listPTId.add(pt.Id);                
                }
            }
        }
        return listPTId;
                
    } 
       
    public static void processUpdateResult(List<Database.Upsertresult> listResult,map<Id,List<Database.Error>> mapErrors){
        for(Database.upsertResult result:listResult) {
            if (!result.isSuccess()){
                mapErrors.put(result.getId(),result.getErrors());
            } 
        }       
    }
    ///////////////////// start global class /////////////////////////////////
    
    
    global class wsResult {
        webservice Integer code;//(101 = success, 102= partial success, 103=failure).
        webservice Boolean isFound; 
        webservice List<string> listFailed;
        public wsResult()
        {
            isFound =false;
            List<string> listFailed = new list<string>();
        }
    }   
    
    
    
     global class HeshbonOPolisa  {
      
        
        //fields from Aigod
        webservice Date Expiration_Date;
        webservice string Calculation_Code;
        webservice Date Bordero_Month;
        webservice string Send_Message_Code;
        webservice string Indexing_Type;
        webservice string CurrencyCode;
        webservice string Endorsment_No;      
        
        //policy Identifiers
        webservice string policyYear;
        webservice string policyBranch;
        webservice string product;
        webservice string subProduct;
        webservice string runningNumber;
        webservice string controlDigit;
        //added by raniz 11/7/2012: cover a problem in Ayalon where the "same" policy number & endorsment acts for different insurees 
        webservice string additional;
        
        webservice string action;
        webservice Date endorsmentEffectiveDate;
        webservice Date endorsmentExpirationDate;
        
        
        webservice vehicleDetail[] vehicleDetail;
     
        
        //kotert Polica
        webservice DateTime TAARICH_BITZUA;
        webservice string SUG_MUTZAR_PENSIONI;
        webservice string MISPAR_POLISA_O_HESHBON;
        webservice string MPR_MEFITZ_BE_YATZRAN; 
        webservice Date TAARICH_NECHONUT;
        webservice Date TAARICH_HITZTARFUT_MUTZAR;
        webservice Date TAARICH_HITZTARFUT_RISHON;
        webservice string SUG_KEREN_PENSIA;
        webservice string PENSIA_VATIKA_O_HADASHA;
        webservice Date TAARICH_IDKUN_STATUS;
        webservice string STATUS_POLISA_O_CHESHBON;
        webservice string SUG_POLISA;
        webservice string SUG_TOCHNIT_O_CHESHBON;       
        webservice string YESH_HALVAA_BAMUTZAR;
        webservice string YESH_TVIA;
        webservice string HUTAL_SHIABUD;
        webservice string HUTAL_IKUL;        
        webservice string MASLUL_BITUACH_BAKEREN_PENSIA;
        webservice string SHEM_MASLUL_HABITUAH;
        webservice string KAYAM_CHOV_O_PIGUR;
              
        //end kotertPolica
        
        webservice YeshutLakoach YeshutLakoach;
        webservice  NetuneiGvia NetuneiGvia;
        
        // TODO charging TYPe and product defention  look up
        public void updatePolicyField(Novidea_HPC__Policy__c policy, boolean isCreate, Novidea_HPC__Policy__c policyFromDB){
            //TODO: Check if we need some exception handling for a case where a date is nulldate
            //in the parsing component this happens in several cases e.g when incomeing date is '0000' or '000000'
            Date nullDate = date.valueOf('1900-01-01');
            //raniz change 7/3/12: no need to update Bordero since it will be updated through income trigger
            //raniz 16/10/2012: more than that - if this value *will* be updated here it might run over the value 
            //from the income summation logic same goes for effective and expiration dates
//            system.debug('Bordero_Month: ' + Bordero_Month);
            /*if(Bordero_Month != null){
                policy.Novidea_HPC__Date_Written__c = Bordero_Month;
            }*/           
//            system.debug('Expiration_Date: ' +Expiration_Date);
            //raniz change 16/5/13: Expiration_Date should be updated on policy in case of 
            //policy creation so the create renewal lead process relying on this will work  
            if (isCreate && Expiration_Date  != null && Expiration_Date!=nullDate){
                policy.Novidea_HPC__Expiration_Date__c = Expiration_Date;
            }          
//            system.debug('action: ' + action);
            //raniz change 18/07/2012
            if (action != null && !''.equals(action) && !'Endorsement By Replaced'.equalsIgnoreCase(action)){
                if(!'Cancelled'.equalsIgnoreCase(action)){
                    //raniz change 28/7/13: issue https://eu2.salesforce.com/a00b0000002l039
                    if(!isCreate && policyFromDB!=null && policyFromDB.Novidea_HPC__Original_Type__c==null || isCreate || policyFromDB==null)
                        policy.Novidea_HPC__Original_Type__c = action;
                }
                else {
                    //raniz comment 17/10/12: this is needed in order to override (run-over) a 
                    //potential "Expired" action entered during package income trigger activation
                    policy.Novidea_HPC__Action__c = action;
                }
            }
            
//            system.debug('CurrencyCode: ' + CurrencyCode);
            if (CurrencyCode!= null){
                policy.Novidea_HPC__Commission_Currency__c = CurrencyCode;
                policy.Novidea_HPC__Fee_Currency__c = CurrencyCode;
                policy.Novidea_HPC__Premium_Amount_Currency__c = CurrencyCode;
            }
            
            //raniz add 25/7/12: document Policy_Number_Components__c
            policy.Policy_Number_Components__c = generatePolicyComponentsJson();
            
            //raniz change 16/5/13: At first all car updates were commented because the place for the vehicle details is 
            //in products. In fact car number should be updated on policy in case of policy creation so the create 
            //renewal lead process relying on this will work. Other details needed also because no trigger does that upon insert
            if(isCreate && vehicleDetail!=null && !vehicleDetail.isEmpty() && vehicleDetail[0]!=null){
                if(vehicleDetail[0].vehicle_number!=null && !''.equals(vehicleDetail[0].vehicle_number))
                    policy.Novidea_HPC__Car_Number__c = vehicleDetail[0].vehicle_number;
                if(vehicleDetail[0].vehicleProductionYear!=null && !''.equals(vehicleDetail[0].vehicleProductionYear)){
                    policy.Novidea_HPC__Vehicle_Production_Year__c = convertTwoDigitsYearToFour(vehicleDetail[0].vehicleProductionYear);
                }
            }
            
        }
        
        public boolean isVehicleDetailsExist(){
            return vehicleDetail!=null && !vehicleDetail.isempty() && vehicleDetail[0]!=null && (!string.isBlank(vehicleDetail[0].vehicle_number) || !string.isBlank(vehicleDetail[0].vehicleProductionYear));
        }
        
        public void updateVehicleDetails(Novidea_HPC__Product__c prod){
            if(vehicleDetail!=null && !vehicleDetail.IsEmpty() && vehicleDetail[0]!=null){
                if(vehicleDetail[0].vehicle_number!=null && !''.equals(vehicleDetail[0].vehicle_number))
                    prod.Novidea_HPC__Vehicle_Registration_Number__c = vehicleDetail[0].vehicle_number;
                if(vehicleDetail[0].vehicleProductionYear!=null && !''.equals(vehicleDetail[0].vehicleProductionYear)){
                    prod.Novidea_HPC__Vehicle_Year_of_manufacture__c = convertTwoDigitsYearToFour(vehicleDetail[0].vehicleProductionYear);
                }
            }
        }
       
        private String convertTwoDigitsYearToFour(String twoDigitYear){
            if(!isStringInteger(twoDigitYear) || twoDigitYear.length()!=2) return '1900';
            String prefix = '19';
            Integer currentYear = integer.valueOf(Datetime.now().format('yy'));
            if(integer.valueOf(twoDigitYear)<=integer.valueOf(Datetime.now().format('yy'))){
                prefix = '20';
            }
            return prefix + twoDigitYear;
        }
        
        public boolean isStringInteger(String str){
            return str!=null && Pattern.matches('[0-9]+', str);
        }
        
        private String generatePolicyComponentsJson(){
//            system.debug('MISPAR_POLISA_O_HESHBON: ' + MISPAR_POLISA_O_HESHBON);
            Jsongenerator jsongen = Json.createGenerator(false);
            jsongen.writeStartObject();
            jsongen.writeFieldName('year');
            if(policyYear!=null) jsongen.writeString(policyYear);
            else jsongen.writeNull();
            jsongen.writeFieldName('branch');
            if(policyBranch!=null) jsongen.writeString(policyBranch);
            else jsongen.writeNull();
            jsongen.writeFieldName('product');
            if(policyBranch!=null) jsongen.writeString(product);
            else jsongen.writeNull();
            jsongen.writeFieldName('runningNumber');
            if(runningNumber!=null) jsongen.writeString(runningNumber);
            else jsongen.writeNull();
            jsongen.writeFieldName('controlDigit');
            if(controlDigit!=null) jsongen.writeString(controlDigit);
            else jsongen.writeNull();
            jsongen.writeFieldName('originalNumber');
            if(MISPAR_POLISA_O_HESHBON!=null) jsongen.writeString(MISPAR_POLISA_O_HESHBON);
            else jsongen.writeNull();
            jsongen.writeEndObject();
            return jsongen.getAsString();
            
        }
    }
    
    global class YeshutLakoach {
        // field that came from yIGod WS
     
        webservice string fullAddress;     
        webservice string fullName;               
        /////////////
        
        webservice string clientNumberFromAgent;
        webservice string SUG_MEZAHE_LAKOACH;
        webservice string MISPAR_ZIHUY_LAKOACH;
        webservice string SHEM_PRATI;
        webservice string SHEM_MISHPACHA_KODEM;
        webservice string SHEM_MISHPACHA;
        webservice string MIN;
        webservice Date TAARICH_LEYDA;
        webservice string PTIRA;
        webservice Date TAARICH_PTIRA;
        webservice string MATZAV_MISHPACHTI;
        webservice string ERETZ;
        webservice string SHEM_YISHUV;
        webservice string SEMEL_YESHUV;
        webservice string SHEM_RECHOV;
        webservice string MISPAR_BAIT;
        webservice string MISPAR_KNISA;
        webservice string MISPAR_DIRA;
        webservice string MIKUD;
        webservice string TA_DOAR;
        webservice string MISPAR_TELEPHONE_KAVI;
        webservice string MISPAR_SHLUCHA;
        webservice string MISPAR_CELLULARI;
        webservice string MISPAR_FAX;
        webservice string E_MAIL;
        webservice string HEAROT;
        webservice string MISPAR_YELADIM;
        webservice string SpouseSSN;
        webservice string SpouseFirstName;
        webservice string SpouseBirthDate;
        
        
        public void updateContactField(Contact contact){
            /* the name + gender logic was canceled after the meeting on 18/03/2012*/
            contact.MailingStreet = '';
            if(!String.isblank(SHEM_RECHOV)) contact.MailingStreet = SHEM_RECHOV;
            if(!String.isblank(MISPAR_BAIT)) contact.MailingStreet += ' ' + MISPAR_BAIT;
            if(!String.isblank(MISPAR_DIRA)) contact.MailingStreet += ' דירה ' + MISPAR_DIRA;
            if(!String.isblank(ERETZ)) contact.MailingCountry = ERETZ;
            if(contact.MailingState==null) contact.MailingState = '';
            if(!String.isblank(SHEM_YISHUV)) contact.MailingCity = SHEM_YISHUV;
            if(!String.isblank(MIKUD)) contact.MailingPostalCode = MIKUD;
        }
        
        public void updateNewContact(Contact contact){
            updateContactField(contact);
            if(!String.isblank(MISPAR_ZIHUY_LAKOACH)) contact.Novidea_HPC__SSN__c = PolicyTransactionHandler.removeZeroFromStart(MISPAR_ZIHUY_LAKOACH); 
            if(!String.isblank(MISPAR_TELEPHONE_KAVI)) contact.phone = MISPAR_TELEPHONE_KAVI; 
            if(!String.isblank(SHEM_PRATI)) contact.FirstName = SHEM_PRATI; 
            if(!String.isblank(SHEM_MISHPACHA)) contact.LastName = SHEM_MISHPACHA;
            
            if(!String.isblank(MIN)) contact.Novidea_HPC__Gender__c = MIN;    
            if(TAARICH_LEYDA!=null && TAARICH_LEYDA>date.newinstance(1900,1,1)){
                try{
                    contact.Birthdate = TAARICH_LEYDA;
                }
                catch(exception e){}   
            }
        }
        
        public void updateAccountField(Account account){
        	account.ShippingStreet = '';
            if(!String.isblank(SHEM_RECHOV)) account.ShippingStreet = SHEM_RECHOV;   
            if(!String.isblank(MISPAR_BAIT)) account.ShippingStreet += ' ' + MISPAR_BAIT;
            if(!String.isblank(MISPAR_DIRA)) account.ShippingStreet += ' דירה ' + MISPAR_DIRA;
            if(!String.isblank(SHEM_YISHUV)) account.ShippingCity = SHEM_YISHUV;
            if(!String.isblank(MIKUD)) account.ShippingPostalCode = MIKUD;
            if(!String.isblank(ERETZ)) account.ShippingCountry = ERETZ;
            if(account.ShippingState==null) account.ShippingState = '';
         }
    }
    
    
    global class vehicleDetail  {
        webservice string vehicle_number;
        webservice string vehicleManufacturer;
        webservice string vehicleModel;
        webservice string vehicleProductionYear;
    }
    
    global class AgentCommison{
        webservice string Producer;
        webservice string commissionRate;
        webservice string agentDiscountRate;
        webservice string otherCommissionRate;
    }
    
    
    global class NetuneiGvia {
        webservice string SHEM_MESHALEM;
        webservice string SUG_TEUDA_MESHALEM;
        webservice string MISPAR_ZIHUY_MESHALEM;
        webservice string KOD_EMTZAEI_TASHLUM;
        webservice string TADIRUT_TASHLUM;
        webservice string CHODESH_YECHUS;
        webservice string YOM_GVIYA_BECHODESH;
        webservice string OFEN_HATZMADAT_GVIA;
        webservice string ACHUZ_TAT_SHNATIYOT;
        webservice date firstPaymentDate;        
        webservice DetailedPremiumAndFees[] DetailedPremiumAndFees;       
        webservice PandCCoverages[] PandCCoverages;
        webservice Commission[] Commission;
        
        public void updatePolicyField(Novidea_HPC__Policy__c policy){
//            system.debug('FirstPaymentDate: ' + firstPaymentDate);
            if (firstPaymentDate != null){
                policy.Novidea_HPC__First_Payment_Date__c = firstPaymentDate;               
            }
//            system.debug('TADIRUT_TASHLUM: ' + TADIRUT_TASHLUM);
            if (TADIRUT_TASHLUM != null){
                try{
                    policy.Novidea_HPC__Payments_Number__c = decimal.valueOf(TADIRUT_TASHLUM);}catch(exception e){}             
            }
            /*
            if (DetailedPremiumAndFees != null){
                decimal fees = 0;
                            
                for (DetailedPremiumAndFees dpaf : DetailedPremiumAndFees ){
                    if (dpaf.AmountCode =='04' || dpaf.AmountCode =='05' || dpaf.AmountCode =='06' || dpaf.AmountCode =='07' || dpaf.AmountCode =='08' ){
                        fees += convertStringToDec(dpaf.Amount,dpaf.AmountSign);                        
                    }else if (dpaf.AmountCode =='09' ){
                        policy.Credit_Fee__c = convertStringToDec(dpaf.Amount,dpaf.AmountSign);                 
                    }else if (dpaf.AmountCode =='15'){
                         policy.Premium_Amount__c = convertStringToDec(dpaf.Amount,dpaf.AmountSign);
                    }
                }
                policy.Fees__c = fees ;
            }*/
                    
        }
        
       
    }   
    
    global class DetailedPremiumAndFees {
        webservice string recordType;
        webservice string AmountCode;
        webservice string Amount;
        webservice string AmountSign;
    } 
    
    global class Commission {
        webservice string contractNo ;
        webservice string netPremium;
        webservice string signNetPremium;
        webservice string InsuredAmount;
        webservice string percentCommissionAgentA;
        webservice string commissionAmountAgentA;
        webservice string signCommissionAmountAgentA;
        webservice string percentCommissionAgentB;
        webservice string commissionAmountAgentB;
        webservice string signCommissionAmountAgentB;
        webservice string discountPercentage;
        webservice string discountAmount;
        webservice string discountSign;
        webservice string underWriterFee;        
    }
       
     global class PandCCoverages {
        webservice string Section;
        webservice string Sub_Section;
        webservice string SectionType; 
        webservice string SectionName;                
        webservice string InsuredAmount;
        webservice string Rate;
        webservice string AnnualPremium; 
        webservice string PremiumPayment;
        webservice string Type;
           
    }
    
    
    /////////////////// end global class  //////////////////////////////////////
    
    public static decimal convertStringToDec(string amount, string sign){
        decimal num =0;
        if ( sign == '0' || sign =='1'  ){
            try{
                num = decimal.valueOf(amount);
                if (  sign =='1' ) {
                    num =num*(-1);
                }
                return num;
            }catch(exception e){}
        }
        return num;
    }
    
    private static String getPolicyNonOwnerCsv(){
        return General__c.getInstance().Policy_Non_Owners_Csv__c;
    }
      
    public static set<String> getPolicyNonOwnerProfilesSet(){
        String profilesCsv = getPolicyNonOwnerCsv();
        String[] listProfilesIds;
        set<String> profilesIds;
        if(String.isNotEmpty(profilesCsv)){
//          system.debug(profilesCsv);
            listProfilesIds = profilesCsv.split(',');
            if(listProfilesIds!=null) profilesIds = new Set<String>(listProfilesIds);
        }
        return profilesIds;
    }
      
    public static Boolean setPolicyOwnerByTeamMemberRole(Novidea_HPC__Policy__c policyToUpdate, Account acc, NoviDea_HPC__Product_Category__c category){
//      system.debug(json.serialize(acc) + '\n' + json.serialize(category));
        if(String.isBlank(category.Default_Team_Member_Role__c) || ArrayUtils.isListNullOrEmpty(acc.AccountTeamMembers))return false;   
        Boolean bOwnerSet = false;
        for(AccountTeamMember atm: acc.AccountTeamMembers){
            if(category.Default_Team_Member_Role__c.equalsIgnoreCase(atm.TeamMemberRole)){
                policyToUpdate.ownerId = atm.UserId;
                bOwnerSet = true;
                break;
            }
        }
        return bOwnerSet;
    }
    
    public static Boolean setPolicyOwnerFromAccount(Novidea_HPC__Policy__c policyToUpdate, Account acc){
        Boolean bOwnerSet = false;
        set<String> profilesIds = getPolicyNonOwnerProfilesSet();
//      system.debug(acc.Owner.ProfileId + ' ' + profilesIds);
        if(acc!=null && (profilesIds==null || profilesIds!=null && !profilesIds.contains(acc.Owner.ProfileId) && !profilesIds.contains(((String)acc.Owner.ProfileId).substring(0,15)))){
            policyToUpdate.ownerId = acc.ownerId;
            bOwnerSet = true;
        }
        return bOwnerSet;
    }

    public static void setPolicyOwnerFromCategory(Novidea_HPC__Policy__c policyToUpdate, NoviDea_HPC__Product_Category__c category){
        if(category!=null && category.Policies_Owner__c!=null) policyToUpdate.OwnerId = category.Policies_Owner__c;
        else setDefaultPolicyOwner(policyToUpdate);
    }

    public static void setDefaultPolicyOwner(Novidea_HPC__Policy__c policyToUpdate){
        if(getDefaultPolicyOwner()!=null) policyToUpdate.OwnerId = getDefaultPolicyOwner();
    } 
    
    public static Id getDefaultPolicyOwner(){
        return General__c.getInstance().Default_Policy_Owner_For_Production__c;     
    }
    
    private void sendEmail(String msg, String subject, string[] emails){
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setCharset('UTF-8');
        mail.setToAddresses(emails);
        mail.setSubject(subject);
        String singleObjDetails = '';
        mail.setPlainTextBody(msg);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}