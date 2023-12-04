@istest
public class TestDocumentSearchController {
	 @isTest(SeeAllData=true)
    private static void testcoverage(){
        list<sObject> ls = new list<sObject>();
        Account acc = new Account(name='test account');
        database.insert(acc);
        //contatc with account
        Contact cnt = new Contact(firstname='first', lastname = 'last', Email='craig@allianceproductions.com');
        database.insert(cnt);
        //contact without account
        Contact cnt1 = new Contact(firstname='first1', lastname = 'last1');
        database.insert(cnt1);
        
        // TODO: Rolan - Implement test like this for the 
        //Novidea_HPC__Associated_person__c ap = new Novidea_HPC__Associated_person__c(Novidea_HPC__Contact__c=cnt.Id,Novidea_HPC__Account__c=acc.Id);
        //database.insert(ap);
        //Novidea_HPC__Application__c app; Novidea_HPC__Policy__c plc; Novidea_HPC__Claim__c clm; Novidea_HPC__Lead__c ptl;
        //database.insert(app=new Novidea_HPC__Application__c(name='test name',Novidea_HPC__Account__c=acc.id));
        //database.insert(plc=new Novidea_HPC__Policy__c(name='test name',Novidea_HPC__Client__c=acc.id));
        //database.insert(clm=new Novidea_HPC__Claim__c(Novidea_HPC__Client__c=acc.id));
        //database.insert(ptl=new Novidea_HPC__Lead__c(name='test name', Novidea_HPC__Client__c=acc.id));
        //ls.add(app);
        //ls.add(plc);
        //ls.add(clm);
        //ls.add(ptl);
        InboundDocument__c doc = new InboundDocument__c(EntId1__c = acc.Id, EntId2__c = cnt.Id, 
                                        Subject__c='Subject', Attachments__c='{"name":"sss.ddd","size":22222222}', Has_Attachment__c=true, 
                                        Comments__c='comments',Date_Received__c=Datetime.Now(),
                                        Email_Preview__c='dfasnbondsnosdanonnfosndonfona noindfonaosdnofnosadno o;no;inofnsad oinoindsosd', 
                                        Sender__c='daf adfsfA', Sender_Email__c='dsaf@dsf.com', Physical_Path__c='M:/'+ acc.name + ' A' + acc.Id +'/' + Date.Today().Year()+Date.Today().Month() + '/Subject ' + Datetime.Now() + '.msg');
        database.insert(doc);
        DocumentSearchParams oParams = new DocumentSearchParams();
        oParams.act = acc.id;
        oParams.cnt = cnt.id;
        oParams.owner = Userinfo.getUserId();
        try{
            Date.parse('20/03/2012');
            oParams.startDate = '20/03/2012';
            oParams.endDate = '21/03/2012';
        }
        catch(Exception ex){
            oParams.startDate = '03/20/2012';
            oParams.endDate = '03/21/2012';
        }
        oParams.doctype = new String[]{'נתון'};
        oParams.orderby = new DocumentSearchParams.DocumentSearchOrderByParam[]{new DocumentSearchParams.DocumentSearchOrderByParam('lastmodifieddate','DESC')};
        DocumentSearchController.doRemoteSearch(oParams);
        oParams.splitQueryByImportedVSCreated = true;
        DocumentSearchController.doRemoteSearch(oParams);
        DocumentSearchController cont = new DocumentSearchController();
        cont.bDisplayFilter = true;
        cont.init();
        oParams = new DocumentSearchParams();
        oParams.act = acc.id;
        //DocumentSearchFacade.doRemoteSearch(Json.serialize(oParams));
        /*database.query('SELECT Type__c, Subject__c, LastModifiedDate, Owner.Name, Date_Received__c, Physical_Path__c, Email_Preview__c, Attachments__c ' + 
        'FROM InboundDocument__c ' +
        'ORDER BY lastmodifieddate DESC ' +
        'LIMIT 4000');*/
    }
    
    @istest(SeeAllData=true)
    public static void test2(){
        DocumentSearchController cont = new DocumentSearchController();
        cont.getCalculatedColspan();
        DocumentSearchController.getSoslSearchFreeTextTerm('for test');
        DocumentSearchController.markObject([select id from account limit 1].id, 'account');
        DocumentSearchController.markObject([select id from contact limit 1].id, 'contact');
        cont.getPicklistValues('InboundDocument__c', 'Type__c');
    }
}