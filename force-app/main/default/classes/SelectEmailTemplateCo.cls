global with sharing class SelectEmailTemplateCo {

        public static list<ObjectsEmailFieldsCollector.EmailRecipient> NameAndEmails {
                get{
                        return ObjectsEmailFieldsCollector.getEmailAddrs( ApexPages.currentPage().getParameters().get('entid'));
                        
                }set;}
    public String getTemplateWindow() {
        //todo: handle parameters
        PageReference selectionPage = new PageReference('/email/author/templateselector.jsp?fcf=' + ApexPages.currentPage().getParameters().get('filterIds') + '&entid=' + ApexPages.currentPage().getParameters().get('entid'));
        return selectionPage.getContent().toString();
    }
    
   public string resultFieldId  {get {return 'resultFieldId';}set;}
    
    global class EmailTemplateData{
        public String subject;
        public String body;
    }
    
    
    @RemoteAction
    global static boolean sendSingleSMS(String smsBody, list<String> phonesList, String senderName,  String entId){
    
        Novidea_Document_Management__c settings = Novidea_Document_Management__c.getInstance();
        
        if (settings == null){
            system.debug('Novidea_Document_Management__c - not found');
            return false;
        }
            
        if (settings.Single_SMS_Impl_Class__c == null || settings.Single_SMS_Impl_Class__c == ''){
            system.debug('Single_SMS_Impl_Class__c - not set');
            return false;
        }             

        Type t = Type.forName(settings.Single_SMS_Impl_Class__c);
        SingleSMSInterface smsSingleImple = (SingleSMSInterface)t.newInstance();

        boolean success = smsSingleImple.sendSMS(smsBody, phonesList, senderName);
        
        createEmailTask('SMS', smsBody, entId, null);
        
        return success;
    
    }
    
    @RemoteAction
    global static String createEmailTask(String subject, String body, String entId, String[] docsIds){
        
                try {
                Task task = new Task();
                task.Subject = Label.Send_Email;
                task.ActivityDate = date.today();
                task.Priority = 'Normal';
                task.Description = subject + '\n' + body;
                task.Status = 'Completed';
                
                if (entId.indexOf('003') == 0)
                  task.WhoId = entId;         
                else
                  task.WhatId = entId; 
                  
                database.insert(task);
                
                system.debug(docs);
                
               if (docsIds != null && docsIds.size() >0)
                    for (ID docId : docsIds){
                        docs = null; //Igall, hack fix for some bug
                        attachFileToTask(task.Id,docId);
                    }    

                return task.id;
                    
                } catch (Exception e){
                        System.debug('Cannot create task or attach to task:' + e.getMessage());
                }
                
                return null;
    }
    
    @RemoteAction
    global static EmailTemplateData getTemplateContent(string templateId, string entId ,string docId) {

       
        EmailTemplateData ed = new EmailTemplateData();
                EmailTemplate eTemplate = new EmailTemplate() ;
                /*Messaging.SingleEmailMessage emailOut = new Messaging.SingleEmailMessage();
                emailOut.setTemplateId(templateId);
                emailOut.setTargetObjectId(entId);*/
                if(templateId != ''){ 
                eTemplate = [select Id,Name from EmailTemplate where id =:templateId];
                        
                ed.subject = getContentSubject(templateId);
                
                ed.body = getContent(templateId);
                }else{
                        ed.subject = '';
                ed.body = ''; 
                }
                           
        return ed;    
   }
    @RemoteAction
    private static InboundDocument__c[] docs;
    @RemoteAction
    public static  InboundDocument__c[] getDocuments(id taskId ,id docId){
        if (docs == null){
                        String docQuery = 'select Id, Name, Attachments__c, Comments__c, Date_Received__c, Department__c,'  
                                                        +'EntId10__c, EntId11__c, EntId12__c, EntId13__c, EntId14__c, EntId15__c, EntId16__c, EntId17__c, EntId18__c, EntId19__c, EntId20__c, EntId2__c, EntId3__c, EntId4__c, EntId5__c, EntId6__c, EntId7__c, EntId8__c, EntId9__c,' 
                                                        +'Private__c, Subject__c, Type__c, account__c ' 
                                        +'from InboundDocument__c where id ='+ '\'' + docId + '\'' +'AND (';
        
                String tempStr = '';
                        String whereClause = '';                
                for(integer i=2; i<=20; ++i){
                    whereClause+= (tempStr + ' EntId' + i + '__c = null');
                    tempStr = ' OR ';
                }
                whereClause+= ') ';
                system.debug(docQuery + whereClause);
                docs = Database.query(docQuery + whereClause); 
        }
        
        return docs;
    }
   @RemoteAction
   public static void attachFileToTask(Id taskId,Id docId ){
                // Add the new document to filing criteria
                boolean refiled = false;
        for(integer i=2; i<=20; ++i){
                String ent = 'EntId' + i + '__c';
                String entValue = (String)getDocuments(taskId,docId)[0].get(ent); 
                if (String.isBlank(entValue)){
                        getDocuments(taskId,docId)[0].put(ent, taskId);
                        update getDocuments(taskId,docId)[0];
                        refiled = true;
                        break; 
                }
        }
        // If there was no free EntId to add the new filing criteria, then send an alert
        if (!refiled){
                ForceUtils.emailException('CreateXFromDocumentTaskController: Failed adding filing criteria to the document: '+getDocuments(taskId,docId)[0].Id + ', needed criteria: ' + taskId, null, getDocuments(taskId,docId)[0].Id);
                ForceUtils.sendPendingEmails();
        }
   }
    
   public static String getContent(ID templateId){
                PageReference pr = new PageReference('/_ui/core/email/author/EmailAuthor?template_id='+templateId);
                String c = pr.getContent().ToString();
                String startStr = 'id="p7"';
                String endStr = '</';
                integer s = c.indexOf(startStr);
                s = c.indexOf('>', s) + 1;
                integer e =  c.indexOf(endStr, s);
                return c.substring(s, e);
   }
    
   public static String getContentSubject(ID templateId){
                PageReference pr = new PageReference('/_ui/core/email/author/EmailAuthor?template_id='+templateId);
                String c = pr.getContent().ToString();
                // TODO: Move to custom label
                String startStr = 'id="p6"';
                String endStr = '"';
                integer s = c.indexOf(startStr);
                s = c.indexOf('value="', s) + 7;
                integer e =  c.indexOf(endStr, s);              
                return c.substring(s, e);
    }
}