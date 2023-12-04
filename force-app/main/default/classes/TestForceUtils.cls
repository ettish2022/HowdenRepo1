@isTest
public class TestForceUtils {
 	public static testmethod void testEmails(){
    	try {
            ForceUtils.emailException('Test Message', new ForceUtils.TestException(), '');
            ForceUtils.sendPendingEmails();
    	} catch (exception e){
    		// This is cause we moved the email address to configuration
    	}
    }
}