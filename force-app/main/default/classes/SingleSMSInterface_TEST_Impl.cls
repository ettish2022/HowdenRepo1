public class SingleSMSInterface_TEST_Impl implements SingleSMSInterface{

    //SMS Center test impl
    //http://www.smscenter.co.il/files/API%20Reference.pdf

    public boolean sendSMS(String smsBody, list<String> phonesList, String senderName){
    
        try{    
            String params = 
                '?UserName=novidea&Password=novidea1&Sender=' + senderName + 
                '&ToPhoneNumber=' + phonesList[0] +
                '&Message=' + smsBody + '&EnableChaining=ENABLECHAINING';

            HttpRequest req = new HttpRequest();
            req.setEndpoint('http://www.smscenter.co.il/pushsms.asp' + params);
            req.setMethod('POST');
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
            
        } catch (Exception e){
            system.debug(e);        
            return false;
        }
        return true;
    }
}