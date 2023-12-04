@isTest(seeAllData=false)
public with sharing class ConvertProductsToPoliciesCoTest {
    final static String TEST_CARRIER_NAME = 'test carrier';

    // init data before converting
    @TestSetup
    static void makeData(){
        Database.insert(new Novidea_TMF__Time_Measurement_Settings__c(
            Name = 'Default',
            Novidea_TMF__Stop_AccountTrigger__c = true,
            Novidea_TMF__DefaultServiceTaskName__c = 'כללי',
            Novidea_TMF__limit_rows__c = '1000'
        ));  

        Database.insert(new Novidea_HPC__General_Switches__c(
            Name = 'Default',
            Novidea_HPC__Disable_Management_Policy__c = true,
            Novidea_HPC__Edit_Policy_After_Conversion__c = false,
            Novidea_HPC__Enable_Same_Product_Def__c = false,
            Novidea_HPC__Enable_Same_Product_Def_Msg__c = true
        ));

        Account carrier = new Account(
            Name = TEST_CARRIER_NAME
        );
        Database.insert(carrier);

        Novidea_HPC__Product_Def__c prodDef = new Novidea_HPC__Product_Def__c(
            Name = 'def test'
        );
        Database.insert(prodDef); 

        Novidea_HPC__Product__c parentProduct = new Novidea_HPC__Product__c(
            Novidea_HPC__Product_Definition__c = prodDef.Id,
            Novidea_HPC__Status__c = 'Accepted',
            Novidea_HPC__Carrier__c = carrier.Id
        );
        Database.insert(parentProduct);

        Novidea_HPC__Application__c app = new Novidea_HPC__Application__c(
            Name = 'app test'
        );
        Database.insert(app);

        Novidea_HPC__Proposal__c proposal = new Novidea_HPC__Proposal__c(
            Novidea_HPC__Application__c = app.Id
        );
        Database.insert(proposal);

        Novidea_HPC__Product__c childProduct = new Novidea_HPC__Product__c(
            Novidea_HPC__Product_Definition__c = prodDef.Id,
            Novidea_HPC__Product__c = parentProduct.Id,
            Novidea_HPC__Proposal__c = proposal.Id
        );
        Database.insert(childProduct);       
    }

    // checks recent filter
    @isTest
    private static void TestRecent() {
        PageReference result = new ConvertProductsToPoliciesCo(new List<Novidea_HPC__Product__c> { new Novidea_HPC__Product__c() }, false).initRecent();
    }   

    // checks when converting when there are no products
    @isTest
    private static void TestMissingProducts() {
        PageReference result = new ConvertProductsToPoliciesCo(new List<Novidea_HPC__Product__c>(), false).initRecent();
        System.assertEquals(null, result, 'result should be null, products are missing');
    }

    // checks when converting when all products are invalid
    @isTest
    private static void TestInvalidProductsFirstCheck() {
        PageReference result = new ConvertProductsToPoliciesCo(new List<Novidea_HPC__Product__c> { new Novidea_HPC__Product__c() }, false).initRecent();
        System.assertEquals(null, result, 'result should be null, products are invalid');
    }

    // checks when products are valid, but they don't have children (or their children are invalid)
    @isTest
    private static void TestInvalidProductsSecondCheck() {
        Novidea_HPC__Product__c childProduct = [SELECT Novidea_HPC__Product__c FROM Novidea_HPC__Product__c WHERE Novidea_HPC__Product__c != NULL];
        childProduct.Novidea_HPC__Product__c = null;
        Database.update(childProduct);
        convert();
    }    

    // checks conversion with management policy
    @isTest
    private static void TestConvertManagementPolicy() {
        Novidea_HPC__General_Switches__c gs = [SELECT Novidea_HPC__Disable_Management_Policy__c FROM Novidea_HPC__General_Switches__c WHERE Name = 'Default'];
        gs.Novidea_HPC__Disable_Management_Policy__c = false;
        Database.update(gs);
        convert();
    }    
    
    // checks conversion with edit policy
    @isTest
    private static void TestConvertEditPolicy() {
        Novidea_HPC__General_Switches__c gs = [SELECT Novidea_HPC__Edit_Policy_After_Conversion__c FROM Novidea_HPC__General_Switches__c WHERE Name = 'Default'];
        gs.Novidea_HPC__Edit_Policy_After_Conversion__c = true;
        Database.update(gs);
        convert();
    }    
    
    // checks conversion without policy management or editing
    @isTest
    private static void TestConvertRegular() {
        Novidea_HPC__General_Switches__c gs = [SELECT Novidea_HPC__Enable_Same_Product_Def__c FROM Novidea_HPC__General_Switches__c WHERE Name = 'Default'];
        gs.Novidea_HPC__Enable_Same_Product_Def__c = true;
        Database.update(gs);  
        convert();
    }  
    
    // does the conversion
    private static void convert() {
        List<Novidea_HPC__Product__c> products = [SELECT Id FROM Novidea_HPC__Product__c WHERE Novidea_HPC__Product__c = NULL];
        new ConvertProductsToPoliciesCo(products, true).initRecent();
    }
}