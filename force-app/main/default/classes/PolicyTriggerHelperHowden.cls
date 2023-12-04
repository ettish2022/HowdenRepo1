public without sharing class PolicyTriggerHelperHowden {

    public static Boolean inWork = false;
    public static boolean stopTrigger = false;
    //public class customException extends Exception {} 
    
    public static void onBeforeInsert(  
            list<Novidea_HPC__Policy__c> newPolicies){  
        if(stopTrigger) return;
        inWork = true; 
        
        updateLeadSource(newPolicies); 
        CurrencyTriggerHelper.updateCurrency(Policy_Currency__c.getInstance(),Novidea_HPC__Policy__c.sObjectType.getDescribe(),newPolicies);
        inWork = false;
    }
    public static void onBeforeUpdate(list<Novidea_HPC__Policy__c> newPolicies){  
        if(stopTrigger) return;
        inWork = true; 
        CurrencyTriggerHelper.updateCurrency(Policy_Currency__c.getInstance(),Novidea_HPC__Policy__c.sObjectType.getDescribe(),newPolicies);     
        inWork = false;
    }
    ///after///
    public static void onAfterInsert(list<Novidea_HPC__Policy__c> newPolicies){  
        if(stopTrigger) return;
        inWork = true; 
        detectIsActivOrPersonal(newPolicies);
        shareAccounts(newPolicies); 
        sharePolicies(newPolicies);      
        inWork = false;
    }
    public static void onAfterUpdate(list<Novidea_HPC__Policy__c>oldPolicies, map<Id,Novidea_HPC__Policy__c> newPolicies){
          
        if(stopTrigger) return;
        inWork = true;
        detectIsActivOrPersonal(newPolicies.values()); 
        updateAccountsShare(oldPolicies,newPolicies);   
        changeExistPolicyProductDefCategoryType(oldPolicies,newPolicies);    
        inWork = false;
    }
    public static void onAfterDelete(list<Novidea_HPC__Policy__c>oldPolicies){  
        if(stopTrigger) return;
        inWork = true; 
        deletedPolicies(oldPolicies);
        inWork = false;
    }
    
    public static void onBeforeDelete(list<Novidea_HPC__Policy__c>oldPolicies){  
        if(stopTrigger) return;
        inWork = true; 
        deleteValidityManagers(oldPolicies);//AEF    
        inWork = false;
    }
    
    /*
        method which find all users which have personal Product Def Policy
        newPolicys:trigger new
        newPolicysMap: trigger new map
    */
    
    public static void sharePolicies(list <Novidea_HPC__Policy__c> newPolicies){
        list<Novidea_HPC__Policy__c> Policies = new list<Novidea_HPC__Policy__c>();
        for (Novidea_HPC__Policy__c policy : newPolicies)
            if (policy.Policy_Type__c == 'Personal')
                Policies.add(policy);
        
        list<Novidea_HPC__Policy__Share> PoliciesShare = new list<Novidea_HPC__Policy__Share>();        
        for (Novidea_HPC__Policy__c Policy:Policies){
                Novidea_HPC__Policy__Share Policieshare = new Novidea_HPC__Policy__Share();
                Policieshare.ParentId = Policy.Id; // The account that we are trying to grant access to.
                Policieshare.UserOrGroupId = System.label.External_Claim_Department_Group_Id; // The user to which access is being granted
                Policieshare.AccessLevel = 'Read';
                PoliciesShare.add(Policieshare); 
            
        }       
        Database.upsert(PoliciesShare); 
    }
    
    /*
        method which share users when change exist Policy Product Def category to personal and cancel sharing when change exist Policy 
        Product Def category to not personal
        oldPolicies:trigger old
        newPolicies: trigger new map
    */
    
    
    public static void changeExistPolicyProductDefCategoryType(
            list<Novidea_HPC__Policy__c>oldPolicies,
            map<Id,Novidea_HPC__Policy__c> newPolicies){
        list<Novidea_HPC__Policy__c> newPersonalPolicies = new list<Novidea_HPC__Policy__c>(); 
        list<Novidea_HPC__Policy__c> newNonPersonalPolicies = new list<Novidea_HPC__Policy__c>(); 
        for (Novidea_HPC__Policy__c policy : oldPolicies){
            if (newPolicies.get(policy.Id).Policy_Type__c != policy.Policy_Type__c //change Policy to personal
                    && newPolicies.get(policy.Id).Policy_Type__c == 'Personal'){
                newPersonalPolicies.add(newPolicies.get(policy.Id));            
            }
            else if (newPolicies.get(policy.Id).Policy_Type__c != policy.Policy_Type__c //change Policy to unpersonal
                    && policy.Policy_Type__c == 'Personal'){
                newNonPersonalPolicies.add(newPolicies.get(policy.Id));     
            }
                    
        }
        if (newPersonalPolicies != null && newPersonalPolicies.size()!= 0)
            sharePolicies(newPersonalPolicies);         
        if (newNonPersonalPolicies != null && newNonPersonalPolicies.size()!= 0)
            cancelSharePolicy(newNonPersonalPolicies);      
    }
    
    /*
        method which cancel share Policy when product Def category is changed to not personal
        newPolicies: trigger new 
    */
    
    public static void cancelSharePolicy(list <Novidea_HPC__Policy__c> newPolicies){
        list <Novidea_HPC__Policy__Share> PolicieshareDeleteList=[SELECT ParentId,UserOrGroupId 
                FROM Novidea_HPC__Policy__Share WHERE ParentId IN : newPolicies 
                AND UserOrGroupId=:System.label.External_Claim_Department_Group_Id];
        
        database.delete(PolicieshareDeleteList);    
    }
    
            
    /*
        this func perform 2 scenarios: first if policy's product def has change from 'non Personal' type to 'personal' or has no client to has client, it will share it accounts
        second, if type was changed from 'personal' to 'non Personal' or has  client to has no client it will check if account has more personal policies if no, it will cancelled account share
        oldPolicies: policies before change
        newMapPolicies: policies after change
    */
    
    public static void updateAccountsShare(
            list <Novidea_HPC__Policy__c> oldPolicies,
            map <Id,Novidea_HPC__Policy__c> newMapPolicies){
        list<Novidea_HPC__Policy__c> newPoliciesChangedType = new list<Novidea_HPC__Policy__c>();
        set <Id> clientsWithUnPersonalCurrentPolicy = new set<Id>(); 
        set <Id> oldClientbeforePolicyChange = new set<Id>(); 
        list<Novidea_HPC__Policy__c> newClientOfChangedPolicy= new list<Novidea_HPC__Policy__c>(); 
        
        for (Novidea_HPC__Policy__c policy: oldPolicies){
            if(policy.Policy_Type__c == null && newMapPolicies.get(policy.Id).Policy_Type__c == 'Personal' 
                    || policy.Novidea_HPC__Client__c == null && newMapPolicies.get(policy.Id).Novidea_HPC__Client__c != null)
                newPoliciesChangedType.add(newMapPolicies.get(policy.Id));
            else if (policy.Policy_Type__c == 'Personal' && newMapPolicies.get(policy.Id).Policy_Type__c == null
                    || policy.Novidea_HPC__Client__c != null && newMapPolicies.get(policy.Id).Novidea_HPC__Client__c == null ){
                clientsWithUnPersonalCurrentPolicy.add(newMapPolicies.get(policy.Id).Novidea_HPC__Client__c);
            }
            if (newMapPolicies.get(policy.Id).Policy_Type__c == 'Personal' &&  
                    policy.Novidea_HPC__Client__c != newMapPolicies.get(policy.Id).Novidea_HPC__Client__c 
                    && policy.Novidea_HPC__Client__c != null && newMapPolicies.get(policy.Id).Novidea_HPC__Client__c != null  ){
                 oldClientbeforePolicyChange.add(policy.Novidea_HPC__Client__c);
                 newClientOfChangedPolicy.add(newMapPolicies.get(policy.Id));
            }
                                                     
        }
        if(newPoliciesChangedType.size()!=0)
            shareAccounts(newPoliciesChangedType);
        else if(clientsWithUnPersonalCurrentPolicy.size()!=0)
            checkMoreClientPersonalPolicies(clientsWithUnPersonalCurrentPolicy);
        if(newClientOfChangedPolicy.size()!=0 ){ 
            checkMoreClientPersonalPolicies(oldClientbeforePolicyChange);
            shareAccounts(newClientOfChangedPolicy);                
        }                       
    }
    
    /*
        method which find all clients which have personal policy
        newPolicies:trigger new
        newPliciesMap: trigger new map
        return: client map <Id=clientId,value=policy>
    */
    
    public static void shareAccounts(list <Novidea_HPC__Policy__c>newPolicies){
        list<Novidea_HPC__Policy__c> policies = [SELECT  Id,Novidea_HPC__Client__c,Novidea_HPC__Product_Definition__c 
                FROM Novidea_HPC__Policy__c WHERE Novidea_HPC__Product_Definition__r.Novidea_HPC__Category__r.Type__c='Personal'
                AND Id IN : newPolicies ];
        
        list<AccountShare> accountsShare = new list<AccountShare>();        
        for (Novidea_HPC__Policy__c policy:policies){
            if (policy.Novidea_HPC__Client__c != null) {
                AccountShare accountShare = new AccountShare();
                accountShare.AccountId = policy.Novidea_HPC__Client__c; // The account that we are trying to grant access to.
                accountShare.UserOrGroupId = System.label.External_Claim_Department_Group_Id; // The user to which access is being granted
                accountShare.OpportunityAccessLevel = 'Read';
                accountShare.CaseAccessLevel = 'Read';
                accountShare.AccountAccessLevel = 'Read';
                accountsShare.add(accountShare);
            }
        }       
        System.debug(accountsShare);
        Database.upsert(accountsShare); 
    }
    
    /*
    *   check if client has more personal policies 
    *   clientsToCheckPersonalPolicy: set of clients Id, that might not have personl policies, but had before 
    */
    public static void checkMoreClientPersonalPolicies(set <Id> clientsToCheckPersonalPolicy){
        set <Id> clientWithPersonalPolicy = new set <Id> ();
        list <Novidea_HPC__Policy__c> policies = [SELECT Novidea_HPC__Client__c FROM Novidea_HPC__Policy__c 
                WHERE  Novidea_HPC__Client__c IN : clientsToCheckPersonalPolicy AND Policy_Type__c=:'Personal'];
            for (Novidea_HPC__Policy__c policy:policies){
                clientWithPersonalPolicy.add(policy.Novidea_HPC__Client__c);    
            }   
        clientsToCheckPersonalPolicy.removeAll(clientWithPersonalPolicy);
        cancelSharingAccount(clientsToCheckPersonalPolicy);     
    }
    
    /*
    *   delete account share on clients which have no more personal policies for specific role
    *   clientWithoutPersonalPolicy: set of client Ids for cancel account sharing
    */
    public static void cancelSharingAccount (set<Id> clientWithoutPersonalPolicy ){
        if (clientWithoutPersonalPolicy == null || clientWithoutPersonalPolicy.size() == 0)
            return;
        list <AccountShare> AccountShareDeleteList=[SELECT AccountId,UserOrGroupId FROM AccountShare 
                WHERE AccountId IN : clientWithoutPersonalPolicy AND UserOrGroupId=:System.label.External_Claim_Department_Group_Id];
        
        database.delete(AccountShareDeleteList);         
    }
    /*
    *  check if policy which going to be deleted contains clients, if so will check if they have more person policy if not delete account share
    *  oldPolicies: policies before delete
    */  
    public static void deletedPolicies(list <Novidea_HPC__Policy__c> oldPolicies){
        set <Id> clientsWithDeletedPolicy = new set<Id>();
        for (Novidea_HPC__Policy__c policy: oldPolicies)
            if(policy.Novidea_HPC__Client__c !=null)
                clientsWithDeletedPolicy.add(policy.Novidea_HPC__Client__c);
        if(clientsWithDeletedPolicy.size()!=0)
            checkMoreClientPersonalPolicies(clientsWithDeletedPolicy);  
    }
    public static final String PERSONAL = 'Personal';  
    public static final String ACTIVE = 'Active'; 
    public static final String EXPIRED = 'Expired';
  
  
   /**
    * The function has been developed for facilitating the representation of policies in standart AccountView. 
      After criterion following four fields will have value. This helps to present separately policies in standard Account View.
    **/  
  
  public static void detectIsActivOrPersonal(list<Novidea_HPC__Policy__c> policies) {
    if(stopTrigger) return;
    
    set<Id> prodDefIds = new set<Id>();
    set<Id> policyIds = new set<Id>();
    
    for(Novidea_HPC__Policy__c policy : policies) {
        policyIds.add(policy.Id); 
        if(null!=policy.Novidea_HPC__Product_Definition__c){
            prodDefIds.add(policy.Novidea_HPC__Product_Definition__c);
        }
    }
    
    map<Id, Novidea_HPC__Product_Def__c> mapId2ProdDef = new map<Id, Novidea_HPC__Product_Def__c>
                                                            ([SELECT Novidea_HPC__Category__r.Type__c, 
                                                               		Novidea_HPC__Category__c 
                                                             FROM Novidea_HPC__Product_Def__c
                                                             WHERE Id IN : prodDefIds]);
    
    list<Validity_Manager__c> validityManagerList =
                                  [SELECT Name,OwnerId,
                                          Policy__c, 
                                          Client_NotActive_Personal__c, 
                                          Client_NotActive_NotPersonal__c, 
                                          Client_Active_Personal__c, 
                                          Client_Active_NotPersonal__c 
                                    FROM Validity_Manager__c
                                    WHERE Policy__c IN : policyIds];
                                    
    list<Validity_Manager__c> validManager2SaveList = new list<Validity_Manager__c>();
                                     
    map<Id,Validity_Manager__c> policy2validManagerMap = new map<Id,Validity_Manager__c>(); 

    for(Validity_Manager__c validManger : validityManagerList) 
        policy2validManagerMap.put(validManger.Policy__c, validManger);
                                     
    for(Novidea_HPC__Policy__c policy : policies){
      
      if(null == policy.Novidea_HPC__Client__c) continue;
      
      Id pdId = policy.Novidea_HPC__Product_Definition__c;
      Novidea_HPC__Product_Def__c prodDef = String.isNotBlank(pdId) ? mapId2ProdDef.get(pdId) : null;
      
      String catType = (null != prodDef && 
		                null != prodDef.Novidea_HPC__Category__r && 
		                String.isNotBlank(prodDef.Novidea_HPC__Category__r.Type__c)) ? prodDef.Novidea_HPC__Category__r.Type__c : '';
                
      String action = String.isNotBlank(policy.Novidea_HPC__Action__c) ? policy.Novidea_HPC__Action__c : '';

      //update/create manager  
      Validity_Manager__c validManger = policy2validManagerMap.get(policy.Id);

      if(null == validManger)
        validManger = new Validity_Manager__c(Policy__c = policy.Id,OwnerId=policy.OwnerId);
      else     
      	cleanClientIds(validManger);
      
      if(validManger.OwnerId != policy.OwnerId)
         validManger.OwnerId = policy.OwnerId;
                
      if(action.equalsIgnoreCase(ACTIVE) && catType.equalsIgnoreCase(PERSONAL)) {
         validManger.Client_Active_Personal__c = policy.Novidea_HPC__Client__c;
      }
      else if(action.equalsIgnoreCase(ACTIVE) && !catType.equalsIgnoreCase(PERSONAL)) {
        validManger.Client_Active_NotPersonal__c = policy.Novidea_HPC__Client__c;
      }
      else if(!action.equalsIgnoreCase(ACTIVE) && catType.equalsIgnoreCase(PERSONAL)) {
        validManger.Client_NotActive_Personal__c = policy.Novidea_HPC__Client__c;
      }
      else{
        validManger.Client_NotActive_NotPersonal__c = policy.Novidea_HPC__Client__c;
      }
      
      validManager2SaveList.add(validManger);
    }
    
    if(!validManager2SaveList.isEmpty())
        Database.upsert(validManager2SaveList);
              
  }
  
   static void cleanClientIds(sObject instance) {
    instance.put('Client_Active_Personal__c',null);
    instance.put('Client_Active_NotPersonal__c',null);
    instance.put('Client_NotActive_Personal__c',null);
    instance.put('Client_NotActive_NotPersonal__c',null);
  }
  //AEF
  public static void deleteValidityManagers(list<Novidea_HPC__Policy__c> policies) {
    
    set<Id> policyIds = new set<Id>();
    for(Novidea_HPC__Policy__c policy : policies)
        policyIds.add(policy.Id);
        
        
    system.debug('policyIds >> ' + policyIds  );    
        
    Database.delete([SELECT Id
                       FROM Validity_Manager__c
                      WHERE Policy__c IN : policyIds]); 
    
    
  }
  
  public static void updateLeadSource(list<Novidea_HPC__Policy__c> policies){
        if(stopTrigger) return;
        map<Integer,Id> leadIds = new map<Integer,Id>();
        map<Integer,Id> appIds = new map<Integer,Id>();
        set<Integer> skipPoliciesNumber = new set<Integer>();

        Novidea_HPC__Policy__c policy;
        for(integer i =0; i< policies.size();++i) {
            policy = policies[i];
            if(policy.Lead_Source__c!=null || policy.Novidea_HPC__Lead__c==null && policy.Novidea_HPC__Application__c==null){
                skipPoliciesNumber.add(i);
                continue;
            }
            if(policy.Novidea_HPC__Lead__c!=null)leadIds.put(i,policy.Novidea_HPC__Lead__c);
            if(policy.Novidea_HPC__Application__c!=null)appIds.put(i,policy.Novidea_HPC__Application__c);
        }
        if(!leadIds.isEmpty()){
            map<Id,Novidea_HPC__Lead__c> leadmap = new map<Id,Novidea_HPC__Lead__c>([SELECT Novidea_HPC__Lead_Source__c,Novidea_HPC__Source_Desciption__c 
                                                                                      FROM Novidea_HPC__Lead__c 
                                                                                      WHERE Id IN: leadIds.values()]);
            for(integer i =0; i< policies.size();++i) {
                if(skipPoliciesNumber.contains(i) || !leadIds.containsKey(i)){
                    continue;
                }
                policies[i].Lead_Source__c = leadmap.get(policies[i].Novidea_HPC__Lead__c).Novidea_HPC__Lead_Source__c;
                policies[i].Source_Desciption__c = leadmap.get(policies[i].Novidea_HPC__Lead__c).Novidea_HPC__Source_Desciption__c;
                
                skipPoliciesNumber.add(i);
            }
        }
        //found all available lead_sources
        if(appIds.isEmpty() || skipPoliciesNumber.size()==policies.size())return;
        map<Id,Novidea_HPC__Application__c> appmap = new map<Id,Novidea_HPC__Application__c>([SELECT Novidea_HPC__Lead__r.Novidea_HPC__Lead_Source__c ,
                                                                                               		 Novidea_HPC__Lead__r.Novidea_HPC__Source_Desciption__c
                                                                                              FROM Novidea_HPC__Application__c 
                                                                                              WHERE Id IN: appIds.values() 
                                                                                              AND Novidea_HPC__Lead__c!=null]);
        for(integer i =0; i< policies.size();++i) {
            if(skipPoliciesNumber.contains(i) || !appIds.containsKey(i) || !appmap.containsKey(policies[i].Novidea_HPC__Application__c))continue;
            policies[i].Lead_Source__c = appmap.get(policies[i].Novidea_HPC__Application__c).Novidea_HPC__Lead__r.Novidea_HPC__Lead_Source__c;
            policies[i].Source_Desciption__c = appmap.get(policies[i].Novidea_HPC__Application__c).Novidea_HPC__Lead__r.Novidea_HPC__Source_Desciption__c; 
        }
    } 
}