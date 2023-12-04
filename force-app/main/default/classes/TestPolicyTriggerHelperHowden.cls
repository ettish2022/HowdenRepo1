@isTest
public class TestPolicyTriggerHelperHowden {

@isTest(SeeAllData=true)
  static void testInsetUpdatePolicyTrigger() {
    System.debug(Policy_Currency__c.getInstance());
    
    
    Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator' or Name ='מנהל מערכת'];  
        
    User user = new User(Alias = 'standt', Email='s1tandarduser1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName= 'testy@testorg.com');
        
    insert user;
    
    System.runAs(user){
        
        list<sObject> pList = new list<sObject>();
        Account acc =  TestUtils.createAccount('carrier:0003', false);
        //Account client =  TestUtils.createAccount('client:0004', false);
        Novidea_HPC__Product_Category__c cat = TestUtils.createCategory('test:1', PolicyTriggerHelperHowden.PERSONAL, false);
        Novidea_HPC__Product_Category__c cat2 = TestUtils.createCategory('test:2', '', false );
        
        pList.add(acc);
        pList.add(cat);
        pList.add(cat2);
        Database.insert(pList);
                            
        Novidea_HPC__Product_Def__c prodDef = TestUtils.createProductDef('test:01', cat.Id, false);
        Novidea_HPC__Product_Def__c prodDef2 = TestUtils.createProductDef('test:02', cat2.Id, false);
        
        pList.clear();
        pList.add(prodDef);
        pList.add(prodDef2);
        Database.insert(pList);
                    
        list<Novidea_HPC__Policy__c> policies = new Novidea_HPC__Policy__c[] { 
        
             TestUtils.createPolicy('test:001', null, acc.Id, prodDef.Id, PolicyTriggerHelperHowden.ACTIVE, false)
            ,TestUtils.createPolicy('test:002', null, acc.Id, prodDef2.Id, PolicyTriggerHelperHowden.ACTIVE, false)
        
            ,TestUtils.createPolicy('test:003', null, acc.Id, prodDef.Id, PolicyTriggerHelperHowden.EXPIRED, false)
            ,TestUtils.createPolicy('test:004', null, acc.Id, prodDef2.Id, PolicyTriggerHelperHowden.EXPIRED, false)
        
            ,TestUtils.createPolicy('test:005', null, null, null, null, false) 
            ,TestUtils.createPolicy('test:006', null, null, null, null, false)
        };  
        
        Database.insert(policies);
       
        Set<Id> Ids = new Set<Id>();
        for(Integer x=0; x<policies.size(); x++) 
          Ids.add( policies[x].Id );
        
        list<Validity_Manager__c> vmList = [SELECT Id, Policy__c, 
                                            Client_Active_Personal__c, 
                                            Client_Active_NotPersonal__c, 
                                            Client_NotActive_Personal__c, 
                                            Client_NotActive_NotPersonal__c,
                                            OwnerId 
                                            FROM Validity_Manager__c 
                                            WHERE Policy__c IN : Ids];  
        
        map<Id, Validity_Manager__c> vmMap = new map<Id, Validity_Manager__c>();
        for(Validity_Manager__c vm : vmList)
            vmMap.put(vm.Policy__c, vm);
        
        Novidea_HPC__Policy__c selectedPolicy = [SELECT OwnerId FROM Novidea_HPC__Policy__c WHERE Id =: policies[0].Id];
        system.assertEquals(selectedPolicy.OwnerId, vmMap.get(selectedPolicy.id).OwnerId); //#1948
        

        Validity_Manager__c p = vmMap.get(policies[0].Id);
        
        system.assert(p.Client_Active_Personal__c == acc.Id
                && p.Client_Active_NotPersonal__c == null
                && p.Client_NotActive_Personal__c == null
                && p.Client_NotActive_NotPersonal__c == null);
                
          p = vmMap.get(policies[1].Id);
        system.assert(p.Client_Active_Personal__c == null
                && p.Client_Active_NotPersonal__c == acc.Id
                && p.Client_NotActive_Personal__c == null
                && p.Client_NotActive_NotPersonal__c == null);  
                
         p = vmMap.get(policies[2].Id);
         system.assert(p.Client_Active_Personal__c == null
                && p.Client_Active_NotPersonal__c == null
                && p.Client_NotActive_Personal__c == acc.Id
                && p.Client_NotActive_NotPersonal__c == null);  
                
         p = vmMap.get(policies[3].Id);
         system.assert(p.Client_Active_Personal__c == null
                && p.Client_Active_NotPersonal__c == null
                && p.Client_NotActive_Personal__c == null
                && p.Client_NotActive_NotPersonal__c ==  acc.Id);  
                
         p = vmMap.get(policies[4].Id);
         system.assert(p == null);
                
         p = vmMap.get(policies[5].Id);
         system.assert(p == null);
        
        Database.delete(policies);
      }
    
  }
  /*
  @isTest(SeeAllData=false)
  static void testDeleteValidityManagers() {
        Account acc =  TestUtils.createAccount('carrier:0003', false);
        Novidea_HPC__Product_Category__c cat = TestUtils.createCategory('test:1', PERSONAL, false);
        Database.insert(new list<sObject> {acc, cat});
        
        Novidea_HPC__Product_Def__c prodDef = TestUtils.createProductDef('test:01', cat.Id, false);
        
        Database.insert(new list<sObject> {prodDef});
        
        list<Novidea_HPC__Policy__c> policies = new Novidea_HPC__Policy__c[] { 
            TestUtils.createPolicy('test:001', null, acc.Id, prodDef.Id, ACTIVE, false)
        };
        Database.insert(policies);
        Database.delete(policies);
  }*/
  
  @isTest(SeeAllData=false)
  static void testUpdateLeadSource() {
    list<Novidea_HPC__Lead__c> leads = new Novidea_HPC__Lead__c[]{new Novidea_HPC__Lead__c(Novidea_HPC__Lead_Source__c='stam1'), new Novidea_HPC__Lead__c(Novidea_HPC__Lead_Source__c='stam2')};
    insert leads;
    list<Novidea_HPC__Application__c> apps = new Novidea_HPC__Application__c[]{new Novidea_HPC__Application__c(), 
                                          new Novidea_HPC__Application__c(Novidea_HPC__Lead__c = leads[0].Id)};
    insert apps;
    Account acc =  TestUtils.createAccount('carrier:0003', false);
    list<Novidea_HPC__Policy__c> policies = new Novidea_HPC__Policy__c[] {
      new Novidea_HPC__Policy__c(Novidea_HPC__Application__c=apps[0].id, Novidea_HPC__Client__c = acc.Id), 
      new Novidea_HPC__Policy__c(Novidea_HPC__Lead__c=leads[1].Id, Novidea_HPC__Client__c = acc.Id),
      new Novidea_HPC__Policy__c(Novidea_HPC__Application__c=apps[0].id,Novidea_HPC__Lead__c=leads[1].Id, Novidea_HPC__Client__c = acc.Id), 
      new Novidea_HPC__Policy__c(Novidea_HPC__Application__c=apps[1].id,Novidea_HPC__Lead__c=leads[0].Id, Novidea_HPC__Client__c = acc.Id), 
      new Novidea_HPC__Policy__c(Novidea_HPC__Application__c=apps[1].id, Novidea_HPC__Client__c = acc.Id), 
      new Novidea_HPC__Policy__c(Novidea_HPC__Client__c = acc.Id)
      };
    PolicyTriggerHelperHowden.updateLeadSource(policies);
    system.assertEquals(null, policies[0].Lead_Source__c);
    system.assertEquals('stam2', policies[1].Lead_Source__c);
    system.assertEquals('stam2', policies[2].Lead_Source__c);
    system.assertEquals('stam1', policies[3].Lead_Source__c);
    system.assertEquals('stam1', policies[4].Lead_Source__c);
    system.assertEquals(null, policies[5].Lead_Source__c);
  }
  
  @isTest(SeeAllData=true)
  static void testUpdateLeadSourceActualInsert() {
    list<Novidea_HPC__Lead__c> leads = new Novidea_HPC__Lead__c[]{new Novidea_HPC__Lead__c(Novidea_HPC__Lead_Source__c='stam1'), new Novidea_HPC__Lead__c(Novidea_HPC__Lead_Source__c='stam2')};
    insert leads;
    list<Novidea_HPC__Application__c> apps = new Novidea_HPC__Application__c[]{new Novidea_HPC__Application__c(), 
                                          new Novidea_HPC__Application__c(Novidea_HPC__Lead__c = leads[0].Id)};
    insert apps;
    Account acc =  TestUtils.createAccount('carrier:0003', false);
    list<Novidea_HPC__Policy__c> policies = new Novidea_HPC__Policy__c[] {
      new Novidea_HPC__Policy__c(Novidea_HPC__Application__c=apps[0].id, Novidea_HPC__Client__c = acc.Id), 
      new Novidea_HPC__Policy__c(Novidea_HPC__Lead__c=leads[1].Id, Novidea_HPC__Client__c = acc.Id),
      new Novidea_HPC__Policy__c(Novidea_HPC__Application__c=apps[0].id,Novidea_HPC__Lead__c=leads[1].Id, Novidea_HPC__Client__c = acc.Id), 
      new Novidea_HPC__Policy__c(Novidea_HPC__Application__c=apps[1].id,Novidea_HPC__Lead__c=leads[0].Id, Novidea_HPC__Client__c = acc.Id), 
      new Novidea_HPC__Policy__c(Novidea_HPC__Application__c=apps[1].id, Novidea_HPC__Client__c = acc.Id), 
      new Novidea_HPC__Policy__c(Novidea_HPC__Client__c = acc.Id)
      };
    
    insert policies;
    map<Integer,Id> plcNumIdMap = new map<Integer,Id>();
    for(Integer i =0;i<policies.size();++i){
      plcNumIdMap.put(i,policies[i].Id);
    }
    map<Id,Novidea_HPC__Policy__c> plcmap = new map<Id,Novidea_HPC__Policy__c>([SELECT Lead_Source__c FROM Novidea_HPC__Policy__c WHERE Id IN: policies]);
    system.assertEquals(null, plcmap.get(plcNumIdMap.get(0)).Lead_Source__c);
    system.assertEquals('stam2', plcmap.get(plcNumIdMap.get(1)).Lead_Source__c);
    system.assertEquals('stam2', plcmap.get(plcNumIdMap.get(2)).Lead_Source__c);
    system.assertEquals('stam1', plcmap.get(plcNumIdMap.get(3)).Lead_Source__c);
    system.assertEquals('stam1', plcmap.get(plcNumIdMap.get(4)).Lead_Source__c);
    system.assertEquals(null, plcmap.get(plcNumIdMap.get(5)).Lead_Source__c);
    
  } 
}