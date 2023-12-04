public class GenerateFormHelper {
     
    public static  string getPerFormGeneratePR(String formId, String sobjId){
        return '/apex/NPERFORM__generateForm?sourceObjectDescField=Name&targetId='+formId+'&sourceObjectsType=quote&sourceId='+sobjId+'&mergeWithPdf=true&lockData=true';
    }
    public static  ID getFormByClaimItemsCount(String formName, Integer rowCount){
        try {
            ID formId = [select Form__r.Id
                        from    Form_Assignment__c
                        where   Name = :formName
                        and     Rows_From__c <= :rowCount 
                        and     Rows_To__c >= :rowCount LIMIT 1][0].Form__r.Id;
            
            return formId;
        } catch (Exception e){
            return null;
        }
    }
      
       public static void  callGenerateForm(string sid) {
             
           string baseUrl = Url.getSalesforceBaseUrl().toExternalForm();
           baseUrl = baseUrl+  getPerFormGeneratePR('a0jD0000001Rx3YIAS','a0ED000000BnxPX');//+'&sid='+sid;  
           baseUrl = 'https://eu1.salesforce.com/visualforce/session?url=https%3A%2F%2Fc.eu1.visual.force.com%2Fapex%2FNPERFORM__generateForm%3FsourceObjectDescField%3DName%26targetId%3Da0jD0000001Rx3YIAS%26sourceObjectsType%3Dquote%26sourceId%3Da0ED000000BnxPX%26mergeWithPdf%3Dtrue%26lockData%3Dtrue';
        // Instantiate a new http object            
            Http h = new Http();        
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint 
            
            HttpRequest req = new HttpRequest();
            system.debug('duduav is printing baseUrl' + baseUrl);
            req.setEndpoint(baseUrl);
            req.setMethod('GET');       
        // Send the request, and return a response          
            HttpResponse res = h.send(req);
            
            system.debug('duduav is printing  +   res.getStatus()' +  res.getStatus() );
            system.debug('duduav is printing +   res.getBody()' +  res.getBody() );
       }
    

}