global with sharing class BatchUpdatePoliciesFromTxs implements Database.Batchable<Policy_Transaction__c>, Database.stateful{
    
    private set<String> txIds;
    private Datetime startDatetime;
    private string errorString='';
    private integer batchCounter=0;
    
    public BatchUpdatePoliciesFromTxs(set<String> txIds){
        this.txIds = txIds; 
        startDatetime = Datetime.now();
    }
    
    global Iterable<Policy_Transaction__c> start(Database.BatchableContext BC){
        return [SELECT Policy__c, Carrier__c, client_Number_From_Agent__c, Policy_number_from_Insurance_company__c, Broker_Number__c,
                     Other_Commissions__c, premium__c, Premium_neto__c, endorsement_number__c, Agent_Discount_Written_In_Carrier__c, Commission_Written_In_Carrier__c,
                     Premium_Currency__c, Identification_Type__c, customer_full_name__c, Product_Def__c, Product_Def__r.Novidea_HPC__Category__r.Policies_Owner__c,
                     Errors_while_updating_Sobject__c,Status__c,Client__c, Policy_Content__c, Insured_number__c, Insured_Type__c, Credit_Fee__c, Fee__c, 
                     Customer_Account__c,Customer_Account__r.OwnerId, Customer_Account__r.Owner.ProfileId, Carrier_Product__c, File_Name__c, Vehicle_Manufacturer__c,
                     Vehicle_Model__c, Production_Date__c, Endorsement_Expiration_Date__c,Endorsement_Effective_Date__c,Expiration_Date__c,Effective_Date__c, Birthdate__c
                FROM Policy_Transaction__c
                WHERE Id IN : txIds
                ORDER BY Carrier__c, Policy__c, endorsement_number__c];
    }
    
    global void execute(Database.BatchableContext BC, list<Policy_Transaction__c> scope){
        batchCounter++;
        try{
            executeLogic(scope);
        }
        catch(exception e){
            errorString += String.format('{0} {1} {2}: {3}\r\n',new string[]{'אצווה','' + batchCounter,'הסתיימה עם שגיאה ',e.getmessage()});
            system.debug(errorString + ' ' + batchcounter);
        }
    }

    global void finish(Database.BatchableContext BC){
        String subjectPart = String.format('{0}-{1}',new String[]{'עיבוד התפוקות שהופעל ב',startDatetime.format('d/M/yyyy HH:mm','Asia/Jerusalem')});
        String subject = String.format('{0} {1}',new String[]{'סיום',subjectPart});
        sendEmail(String.format('{0} {1}\r\n{2}\r\n\r\n{3}', new string[]{subjectPart,'הסתיים.','.נא להכנס למסך מיזוג התפוקות או לרענן מסך פתוח', errorString}), subject, new string[]{Userinfo.getUserEmail()});
    } 
    
    private class FailureException extends Exception{}
    
    public void executeLogic(list<Policy_Transaction__c> scope){
        map<Id, list<mergeTransactionCO.RowIdentifier>> jsonTxByCarrier = new map<Id, list<mergeTransactionCO.RowIdentifier>>();
        list<mergeTransactionCO.RowIdentifier> tmpJsonList;
        integer counter = 0;
        for(Policy_Transaction__c pt: scope){
            if((tmpJsonList= jsonTxByCarrier.get(pt.carrier__c))==null){
                tmpJsonList = new list<mergeTransactionCO.RowIdentifier>();
            }
            tmpJsonList.add(new mergeTransactionCO.RowIdentifier(pt.Id,++counter+''));
            jsonTxByCarrier.put(pt.carrier__c, tmpJsonList);
        }
        for(Id key: jsonTxByCarrier.keyset()){
            mergeTransactionCO.updateRowTransactions(JSON.serialize(jsonTxByCarrier.get(key)),General__c.getInstance().Process_Compatible_Tx_Without_Account__c==true);
            //throw new FailureException('Exception in ' +  batchCounter + ' Batch');
        }
    }
    
    private void sendEmail(String msg, String subject, string[] emails){
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setCharset('UTF-8');
        mail.setToAddresses(emails);
        mail.setSubject(subject);
        String singleObjDetails = '';
        mail.setPlainTextBody(msg);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
	public static list<Policy_Transaction__c> createTxs(list<Novidea_HPC__Product_Def__c> prodefs, Account carrier){
        list<Policy_Transaction__c> txs = new list<Policy_Transaction__c>();
        Account acc = new Account(name='חשבון לקוח');
        insert acc;
        Novidea_HPC__Broker_Number__c bn = new Novidea_HPC__Broker_Number__c(
                                                                            Novidea_HPC__Broker_Number_In_Carrier__c = '56561',
                                                                            Novidea_HPC__Carrier__c = carrier.Id
                                                                            );
        insert bn;
		
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123451234',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[0].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123451234',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[1].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123451234',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[2].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        
        
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123456789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[0].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        /*txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123456789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[0].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '1'
        ));
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123456789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[0].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '2'
        ));*/
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123456789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[1].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123456789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[2].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        /*txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = null,
            Policy_Number_From_Insurance_Company__c = '555555555',
            Product_Def__c = prodefs[3].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));*/


        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123956789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[0].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123956789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[1].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123956789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[2].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123956789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[2].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));
        
        txs.add(new Policy_Transaction__c(
            Vehicle_Number__c = '123956789',
            Policy_Number_From_Insurance_Company__c = '987654321',
            Product_Def__c = prodefs[2].id,
            Carrier__c = carrier.Id,
            Customer_Account__c =  acc.id,
            Broker_Number__c = bn.Id,
            Is_Broker_Found__c = true,
            Is_carrier_Found__c = true,
            is_Account_Found__c = true,
            Endorsement_Number__c = '0'
        ));

        insert txs;
        return txs;
    }

    public static list<Novidea_HPC__Product_Def__c> createProductDefs(){
        list<Novidea_HPC__Product_Def__c> prodefs = new list<Novidea_HPC__Product_Def__c>();
        
    	General__c general = [SELECT Personal_Category__c FROM General__c][0];
    	map<string, Novidea_HPC__Product_Category__c> cats = new map<string, Novidea_HPC__Product_Category__c>{
    														'car'=>new Novidea_HPC__Product_Category__c(name='car'),
    														'flat'=>new Novidea_HPC__Product_Category__c(name='flat'),
    														'stam'=>new Novidea_HPC__Product_Category__c(name='stam')
    														};
    	insert cats.Values();
    	general.Personal_Category__c='';
    	for(Novidea_HPC__Product_Category__c cat: cats.values()){
    		general.Personal_Category__c+=cat.Id +',';
    	}
    	general.Personal_Category__c = general.Personal_Category__c.substring(0,general.Personal_Category__c.length()-1);
    	update general;
        prodefs.add(new Novidea_HPC__Product_Def__c(Name='מקיף',Novidea_HPC__Category__c = cats.get('car').Id)); //diana added categoty
        prodefs.add(new Novidea_HPC__Product_Def__c(Name='חובה',Novidea_HPC__Category__c = cats.get('car').Id));
        prodefs.add(new Novidea_HPC__Product_Def__c(Name='ריידר',Novidea_HPC__Category__c = cats.get('car').Id));
        prodefs.add(new Novidea_HPC__Product_Def__c(Name='סתם לא קשור לרכב',Novidea_HPC__Category__c = cats.get('stam').Id));
        prodefs.add(new Novidea_HPC__Product_Def__c(Name='דירה',Novidea_HPC__Category__c = cats.get('flat').Id));
        
        insert prodefs;
        return prodefs;
    }
    
    public static Account createCarrier(){
        Id RecordTypeId = [select Id from recordType where sobjecttype='account' and developername = 'carrier' and 	IsActive = true][0].id;
        Account a  = new Account(RecordTypeId=RecordTypeId, name= 'carrier');
        insert a;
        return a;
    }
}