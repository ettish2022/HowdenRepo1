@isTest
public class TestDevTestBtachRenew {

     @isTest()
    static void testThis(){
      Test.startTest();
      database.executeBatch(new DevTestBtachRenew());
      Test.stopTest();

    }
    
     @isTest()
    static void testCoverage(){
        DevTestBtachRenew.coverage();
    }
    
}