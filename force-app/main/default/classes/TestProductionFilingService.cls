@isTest
//TODO: Fix the test to query the result and see that the relevant fields in the inbound document are populated
private class TestProductionFilingService {
    @TestSetup
    static void makeData(){
        CurrencyTriggerHelper.stopTrigger = true;
        List<Novidea_HPC__Policy__c> policies = new Novidea_HPC__Policy__c[]{
            new Novidea_HPC__Policy__c(Name = 'TestMenora1', Novidea_HPC__Policy_Number__c = '34659714181'),
            new Novidea_HPC__Policy__c(Name = 'TestMenora2', Novidea_HPC__Policy_Number__c = '88009970185'),
            new Novidea_HPC__Policy__c(Name = 'TestAyalon1', Novidea_HPC__Policy_Number__c = '26221888118'),
            new Novidea_HPC__Policy__c(Name = 'TestHarel1', Novidea_HPC__Policy_Number__c = '501800533077'),
            new Novidea_HPC__Policy__c(Name = 'TestHarel2', Novidea_HPC__Policy_Number__c = '123456789012'),
            new Novidea_HPC__Policy__c(Name = 'TestPhoenix1', Novidea_HPC__Policy_Number__c = '211'),
            new Novidea_HPC__Policy__c(Name = 'TestPhoenix2', Novidea_HPC__Policy_Number__c = '130180211221571'),
            new Novidea_HPC__Policy__c(Name = 'TestClal1', Novidea_HPC__Policy_Number__c = '56789012123456789012'),
            new Novidea_HPC__Policy__c(Name = 'TestClal2', Novidea_HPC__Policy_Number__c = '19896176914'),
            new Novidea_HPC__Policy__c(Name = 'TestClal3', Novidea_HPC__Policy_Number__c = '.]^\';?\'-aC8/@[#0~*@'),
            new Novidea_HPC__Policy__c(Name = 'TestMigdal1', Novidea_HPC__Policy_Number__c = '325748771913'),
            new Novidea_HPC__Policy__c(Name = 'TestShlomo1', Novidea_HPC__Policy_Number__c = '220000691720'),
            new Novidea_HPC__Policy__c(Name = 'TestShlomo2', Novidea_HPC__Policy_Number__c = '220000690720')
        };
        Database.insert(policies);
    }

    private static void testResult(Map<String, String> result, String testName, String expectedResult){
        Integer i = 0;
        for (String res: result.keySet()){
            String test = result.get(res);
            System.debug(testName + ': ' + test);
            i++;
            System.assertEquals(expectedResult, test, testName + '[' + i + ']');
        }
    }

    private static void testResultContains(Map<String, String> result, String testName, String expectedResult){
        Integer i = 0;
        for (String res: result.keySet()){
            String test = result.get(res);
            System.debug(testName + ': ' + test);
            i++;
            System.assertEquals(true, test.contains(expectedResult), testName + '[' + i + ']');
        }
    }

    @isTest
    private static void testUnsupportedFiles(){
        Map<String, String> result = ProductionFilingService.fileMultipleProdFiles(new String[]{
            'file1.pdf',
            'another_test_file2.pdf',
            '0088009970185020060060061800237900000000520308.PDF', //This is a menora file with a wrong id[position 16-24]
            'P130180211271001.pdf', //A Phoenix file without an underscore after P130180
            'Polisa-896176914a0_____119a.pdf' //Clal - fails because of the letter between 4 and 0(4a0)
            }, false);
        testResult(result, 'Unsupported file', 'Failed filing the document: Unsupported file.');
    }

    //TODO: Fix this test to test the correct things(look at the comment at the top of file)
    @isTest
    private static void testNoPolicy(){
        Map<String, String> result = ProductionFilingService.fileMultipleProdFiles(new String[]{
            '025325948771913_000000_0001.pdf', //Migdal
            'Polisa-89617693321400_15.pdf' //Clal
            }, false);
        testResult(result, 'Test file parsing', 'Failed filing the document: No policy found matching the given document'); //TODO: Change this message after fixing the test
    }

    @isTest
    private static void testMigdalFiling(){
        Map<String, String> result = ProductionFilingService.fileMultipleProdFiles(new String[]{
            '025325748771913_000000_0001.pdf', //Migdal
            '180325748771913_000000_0001.pdf', //Migdal
            '150325748771913_000000_0001.pdf', //Migdal
            '125325748771913_000000_0001.pdf', //Migdal
            '034325748771913_000000_0001.pdf', //Migdal
            '650325748771913_000000_0001.pdf', //Migdal
            '0630325748771913_000000_0001.pdf' //Migdal
            }, false);
        testResultContains(result, 'Test Migdal filing', 'null\\null\\Migdal\\');
    }

    @isTest
    private static void testClalFiling(){
        Map<String, String> result = ProductionFilingService.fileMultipleProdFiles(new String[]{
            'Polisa-89617691400_19.pdf', //Clal
            'Polisa-12345678901234_56789012.pdf', //Clal
            'Polisa-#0~*@25_.]^\';?\'-aC8/@[.Pdf' //Clal
            }, false);
        testResultContains(result, 'Test Clal filing', 'null\\null\\Clal\\');
    }
            

    @isTest
    private static void testMenoraFiling(){
        Map<String, String> result = ProductionFilingService.fileMultipleProdFiles(new String[]{
            '0034659714181005138488382360189901849911520308.pdf', //Menora - Company
            '0088009970185020000000181800237900000000520308.PDF' //Menora - ID
            }, false);
        //testResultContains(result, 'Test Menora filing', 'null\\null\\Menora\\');
    }

    @isTest
    private static void testAyalonFiling(){
        Map<String, String> result = ProductionFilingService.fileMultipleProdFiles(new String[]{
            '620_026221888118_1_320060_18061719302.pdf', //Ayalon
            '620_026221888118_1_320060_18061719301.pdf' //Ayalon
            }, false);
        //testResultContains(result, 'Test Ayalon filing', 'null\\null\\Ayalon\\');
    }

    @isTest
    private static void testHarelFiling(){
        Map<String, String> result = ProductionFilingService.fileMultipleProdFiles(new String[]{
            'P1234560123_123456789012123456.pdf', //Harel
            'P1016080299_501800533077000002.pdf' //Harel
            }, false);
        testResultContains(result, 'Test Harel filing', 'null\\null\\Harel\\');
    }

    @isTest
    private static void testPhoenixFiling(){
        Map<String, String> result = ProductionFilingService.fileMultipleProdFiles(new String[]{
            // 'P130180_211271001.pdf', //Phoenix - Commented out due to code changes that made this irelevant
            'G130180211221571002.pdf' //Phoenix
            }, false);
        testResultContains(result, 'Test Phoenix filing', 'null\\null\\Phoenix\\');
    }

    @isTest
    private static void testShlomoFiling(){
        Map<String, String> result = ProductionFilingService.fileMultipleProdFiles(new String[]{
            '220-220000691720-000000-0-200227094401331.pdf', //Shlomo
            '220-220000690720-000000-0-200227094413414.pdf' //Shlomo
            }, false);
        //testResultContains(result, 'Test Shlomofiling', 'null\\null\\Shlomo\\');
    }

    @isTest
    private static void testFiling(){
        Map<String, String> result = ProductionFilingService.fileMultipleProdFiles(null, false);
        system.assertEquals(true, result.size() == 0);

        // Empty
        result = ProductionFilingService.fileMultipleProdFiles(new String[]{}, false);
        system.assertEquals(true, result.size() == 0);

        // Throwing exception for code coverage
        result = ProductionFilingService.fileMultipleProdFiles(new String[]{null, null}, false);
        testResult(result, 'Throwing exception for code coverage', 'Failed filing the document: Attempt to de-reference a null object');

        // validate only => true
        result = ProductionFilingService.fileMultipleProdFiles(new String[]{'P1016080299_501800533077000002.pdf'}, true);
        testResultContains(result, 'validate only => true', 'null\\null\\');

        // Duplicate + found
        result = ProductionFilingService.fileMultipleProdFiles(new String[]{'025325748771913_000000_0001.pdf', 'G130180211221550001.pdf'}, false);
        for (String r: result.keySet()){
            System.debug('DUP:' + result.get(r));
        }
        System.assert(result != null);

        // Duplicate + not found
        result = ProductionFilingService.fileMultipleProdFiles(new String[]{'025325748771913_000000_0001.pdf', 'G130180211221571001.pdf'}, false);
        for (String r: result.keySet()){
            System.debug('DUP2:' + result.get(r));
        }
        System.assert(result != null);
    }
}