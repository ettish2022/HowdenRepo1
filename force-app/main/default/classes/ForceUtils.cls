public with sharing class ForceUtils {

    private static Messaging.SingleEmailMessage[] pendingEmails = new List<Messaging.SingleEmailMessage>();
    
    public static void emailException(String msg, Exception e, String subjectId){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {(String)Novidea_Document_Management__c.getInstance().Support_Email__c};
        mail.setToAddresses(toAddresses);
        mail.setReplyTo((String)Novidea_Document_Management__c.getInstance().Support_Email__c);
        mail.setSenderDisplayName(UserInfo.getOrganizationName());
        mail.setSubject(UserInfo.getOrganizationName() + ': ' + msg);
        String linkToSfUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + subjectId;
        String emsg = '';
        if (e != null)
        	emsg = e.getMessage();
        mail.setHtmlBody('<h1>'+ msg+'</h1><br/><h2>'+emsg+'</h2><br/><a href="'+linkToSfUrl+'">Click here to view in salesforce</a>');
        pendingEmails.add(mail);
    }
    
    public static void sendPendingEmails(){
        Messaging.sendEmail(pendingEmails);
    }

    public class TestException extends Exception{}
   
}