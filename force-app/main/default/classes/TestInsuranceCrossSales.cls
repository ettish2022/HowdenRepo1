@isTest
private class TestInsuranceCrossSales {
	/*
		Test of InsuranceCrossSalesController
	*/
    static testMethod void testInsuranceCrossSalesController001() {
    	
    	Insurance_Cross_Sale__c insuranceCrossSell = new Insurance_Cross_Sale__c();
    	insuranceCrossSell.Name = 'test 001';
    	insert insuranceCrossSell;
    	
    	TestUtils.createProductDef('test 001', null, true);
    	TestUtils.createProductDef('test 002', null, true);
    	TestUtils.createProductDef('test 003', null, true);
    	
    	PageReference pageRef = Page.Insurance_Cross_Sale_Creator;
        Test.setCurrentPage(pageRef);
    	
    	ApexPages.StandardController standCont = new ApexPages.StandardController(insuranceCrossSell); 
    	InsuranceCrossSalesController cont = new InsuranceCrossSalesController(standCont);
    	
    	object a = cont.dummyInsuranceCrossSale;
    	a = cont.theInsuranceCrossSale;
    	a = cont.filterDefs;
    	a = cont.toCreateProdDefList;
    	
    	system.debug('cont.toCreateProdDefList.size = ' + cont.toCreateProdDefList.size());
    	a = cont.createButtonText;
    	a = cont.theCreateLeadStep;
    	a = cont.back();
    	a = cont.create();
    	cont.theCreateLeadStep = 1;
    	a = cont.create();    	
    }
    
    static testMethod void testInsuranceCrossSalesController002() { 
    	Insurance_Cross_Sale__c insuranceCrossSell = new Insurance_Cross_Sale__c();
    	insuranceCrossSell.Name = 'test 001';
    	insert insuranceCrossSell;
    	
    	TestUtils.createProductDef('test 001', null, true);
    	TestUtils.createProductDef('test 002', null, true);
    	TestUtils.createProductDef('test 003', null, true);
    	
    	PageReference pageRef = Page.Insurance_Cross_Sale_Creator;
        Test.setCurrentPage(pageRef);
    	
    	ApexPages.StandardController standCont = new ApexPages.StandardController(insuranceCrossSell); 
    	InsuranceCrossSalesController cont = new InsuranceCrossSalesController(standCont);
    	
    	object a = cont.dummyInsuranceCrossSale;
    	a = cont.theInsuranceCrossSale;
    	a = cont.filterDefs;
    	a = cont.toCreateProdDefList;
    	for(InsuranceCrossSalesController.ProductDefWrapper wr : cont.toCreateProdDefList){
    		wr.selected = true;
    	}
    	system.debug('cont.toCreateProdDefList.size = ' + cont.toCreateProdDefList.size());
    	a = cont.createButtonText;
    	a = cont.theCreateLeadStep;
    	a = cont.back();
    	a = cont.create();
    	cont.theCreateLeadStep = 1;
    	a = cont.create();   
    	
    	
    }
    
    static testMethod void testInsuranceCrossSalesController003() { 
    	Insurance_Cross_Sale__c insuranceCrossSell = new Insurance_Cross_Sale__c();
    	insuranceCrossSell.Name = 'test 001';
    	insert insuranceCrossSell;
    	
    	TestUtils.createProductDef('test 001', null, true);
    	TestUtils.createProductDef('test 002', null, true);
    	TestUtils.createProductDef('test 003', null, true);
    	
    	PageReference pageRef = Page.Insurance_Cross_Sale_Creator;
        Test.setCurrentPage(pageRef);
    	
    	ApexPages.StandardController standCont = new ApexPages.StandardController(insuranceCrossSell); 
    	InsuranceCrossSalesController cont = new InsuranceCrossSalesController(standCont);
    	
    	object a = cont.dummyInsuranceCrossSale;
    	cont.dummyInsuranceCrossSale.OwnerId = Userinfo.getUserId();
    	a = cont.theInsuranceCrossSale;
    	a = cont.filterDefs;
    	
    	for(InsuranceCrossSalesController.ProductDefWrapper wr : cont.filterDefs){
    		wr.selected = true;
    		wr.maxLimit = '1000';
    		wr.minPremium = '0';
    		wr.maxPremium = '1000';
    	}
    	
    	a = cont.toCreateProdDefList;
    	for(InsuranceCrossSalesController.ProductDefWrapper wr : cont.toCreateProdDefList){
    		wr.selected = true;
    	}
    	system.debug('cont.toCreateProdDefList.size = ' + cont.toCreateProdDefList.size());
    	a = cont.createButtonText;
    	a = cont.theCreateLeadStep;
    	a = cont.back();
    	a = cont.create();
    	cont.theCreateLeadStep = 1;
    	a = cont.create();   
    	
    	
    }
    
     static testMethod void testInsuranceCrossSalesController004() { 
    	Insurance_Cross_Sale__c insuranceCrossSell = new Insurance_Cross_Sale__c();
    	insuranceCrossSell.Name = 'test 001';
    	insert insuranceCrossSell;
    	
    	TestUtils.createProductDef('test 001', null, true);
    	TestUtils.createProductDef('test 002', null, true);
    	TestUtils.createProductDef('test 003', null, true);
    	
    	PageReference pageRef = Page.Insurance_Cross_Sale_Creator;
        Test.setCurrentPage(pageRef);
    	
    	ApexPages.StandardController standCont = new ApexPages.StandardController(insuranceCrossSell); 
    	InsuranceCrossSalesController cont = new InsuranceCrossSalesController(standCont);
    	
    	object a = cont.dummyInsuranceCrossSale;
    	cont.dummyInsuranceCrossSale.OwnerId = Userinfo.getUserId();
    	a = cont.theInsuranceCrossSale;
    	a = cont.filterDefs;
    	
    	for(InsuranceCrossSalesController.ProductDefWrapper wr : cont.filterDefs){
    		wr.selected = true;
    		wr.maxLimit = 'bubu';
    		wr.minPremium = 'bubu';
    		wr.maxPremium = 'bubu';
    	}
    	
    	a = cont.toCreateProdDefList;
    	for(InsuranceCrossSalesController.ProductDefWrapper wr : cont.toCreateProdDefList){
    		wr.selected = true;
    	}
    	system.debug('cont.toCreateProdDefList.size = ' + cont.toCreateProdDefList.size());
    	a = cont.createButtonText;
    	a = cont.theCreateLeadStep;
    	a = cont.back();
    	a = cont.create();
    	cont.theCreateLeadStep = 1;
    	a = cont.create();   
    }
    /*
    	Test InsuranceCrossSalesSendEmailController
    */
    static testMethod void  testInsuranceCrossSalesSendEmailController001() {
    	
    	General__c generalSetting = General__c.getInstance();
    	generalSetting.Email_to_reply_Insurance_Cross_Sales__c = 'test@google.com';
    	generalSetting.Email_Template_Insurance_Cross_Sales__c = 'test_template';
    	Database.upsert(generalSetting);
    	/*
    	if(null == generalSetting.Id){
	    	generalSetting.Name = 'test';
	    	generalSetting.SetupOwnerId = Userinfo.getUserId();
	    	Database.insert(generalSetting);
    	}
    	else {
    		generalSetting.Email_to_reply_Insurance_Cross_Sales__c = 'test@google.com';
	    	generalSetting.Email_Template_Insurance_Cross_Sales__c = 'test_template';
    		Database.update(generalSetting);
    	}*/
    	
    	EmailTemplate eTempl = new EmailTemplate();
    	eTempl.Subject = 'test[{0}]';
    	eTempl.FolderId = Userinfo.getUserId();
    	eTempl.IsActive = true;
    	eTempl.DeveloperName = 'test_template';
    	eTempl.Name = 'test_template';
    	eTempl.TemplateType = 'custom';
    	eTempl.HtmlValue = '<meta name="fields" content="Novidea_HPC__Contact_Name__c"><div>Dear {0} test {Dinamy:0} test</div>';
    	
    	Database.insert(eTempl); 
    	
    	Insurance_Cross_Sale__c insuranceCrossSell = new Insurance_Cross_Sale__c();
    	insuranceCrossSell.Name = 'test 001';
    	insert insuranceCrossSell;
    	
    	Novidea_HPC__Product_Def__c pDef1 = TestUtils.createProductDef('test 001', null, false);
    	Novidea_HPC__Product_Def__c pDef2 = TestUtils.createProductDef('test 002', null, false);
    	Novidea_HPC__Product_Def__c pDef3 = TestUtils.createProductDef('test 003', null, false);
    	
    	list<Novidea_HPC__Product_Def__c> prodDefList = new list<Novidea_HPC__Product_Def__c> { pDef1, pDef2, pDef3};
    	Database.insert(prodDefList);
    	
    	Novidea_HPC__Lead__c lead1 = TestUtils.createCustomLead(insuranceCrossSell.Id, 'test 001', false);
    	Novidea_HPC__Lead__c lead2 = TestUtils.createCustomLead(insuranceCrossSell.Id, 'test 002', false);
    	Novidea_HPC__Lead__c lead3 = TestUtils.createCustomLead(insuranceCrossSell.Id, 'test 003', false);
    	list<Novidea_HPC__Lead__c> leadList = new list<Novidea_HPC__Lead__c> { lead1, lead2, lead3};
    	Database.insert(leadList);
    	
    	list<Novidea_HPC__Product__c> prodList = new list<Novidea_HPC__Product__c>(); 
    	for(Integer x=0; x<3; x++)
    		for(Integer t=0; t<3; t++)
    			prodList.add(TestUtils.createProduct('test 001', prodDefList[t].Id, leadList[x].Id, false));
    			 
    	Database.insert(prodList);
    	
    	PageReference pageRef = Page.Insurance_Cross_Sales_Send_Email;
        Test.setCurrentPage(pageRef);
         ApexPages.currentPage().getParameters().put('Id', insuranceCrossSell.Id);
    	
    	ApexPages.StandardController standCont = new ApexPages.StandardController(insuranceCrossSell); 
    	InsuranceCrossSalesSendEmailController cont = new InsuranceCrossSalesSendEmailController(standCont); 
    	cont.sendemails();
    	cont.updateParent();
    	
    }
    /*
    	Test InsuranceCrossSalesAnalysysController
    */
    static testMethod void  testInsuranceCrossSalesAnalysys001() {
    	
    	Insurance_Cross_Sale__c insuranceCrossSell = new Insurance_Cross_Sale__c();
    	insuranceCrossSell.Name = 'test 001';
    	insert insuranceCrossSell;
    	
    	Novidea_HPC__Lead__c lead1 = TestUtils.createCustomLead(insuranceCrossSell.Id, 'test 001', false);
    	Novidea_HPC__Lead__c lead2 = TestUtils.createCustomLead(insuranceCrossSell.Id, 'test 002', false);
    	lead2.Novidea_HPC__Status__c = 'Closed';
    	Novidea_HPC__Lead__c lead3 = TestUtils.createCustomLead(insuranceCrossSell.Id, 'test 003', false);
    	lead3.Novidea_HPC__Status__c = 'Converted';
    	Novidea_HPC__Lead__c lead4 = TestUtils.createCustomLead(insuranceCrossSell.Id, 'test 004', false);
    	lead4.Sent__c = true;
    	lead4.Responded__c = true;
    	list<Novidea_HPC__Lead__c> leadList = new list<Novidea_HPC__Lead__c> { lead1, lead2, lead3, lead4};
    	Database.insert(leadList);
    	
    	PageReference pageRef = Page.Insurance_Cross_Sales_Analysys;
        Test.setCurrentPage(pageRef);
    	ApexPages.StandardController standCont = new ApexPages.StandardController(insuranceCrossSell); 
    	InsuranceCrossSalesAnalysysController cont = new InsuranceCrossSalesAnalysysController(standCont);
    	cont.runanalytics();
    	
    }
    /*
    	Test AnswerToLeadMailPerformer
    */
    static testMethod void  testAnswerToLeadMailPerformer001() {
    	Insurance_Cross_Sale__c insuranceCrossSell = new Insurance_Cross_Sale__c();
    	insuranceCrossSell.Name = 'test 001';
    	insert insuranceCrossSell;
    	
    	Novidea_HPC__Lead__c lead1 = TestUtils.createCustomLead(insuranceCrossSell.Id, 'test 001', true);
    	
    	
    	Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.plainTextBody = 'This should become a note';
        email.fromAddress ='test@test.com';
        String contactEmail = 'jsmith@salesforce.com';
        email.ccAddresses = new String[] {'Jon Smith <' + contactEmail + '>'};
        email.subject = 'test [' + lead1.Id + ']' ;
        
        AnswerToLeadMailPerformer edr = new AnswerToLeadMailPerformer();
        Test.startTest();
        Messaging.InboundEmailResult result = edr.handleInboundEmail(email, env);
        Test.stopTest();
    	
    }
    
    static testMethod void  testAnswerToLeadMailPerformer002() {
    	Insurance_Cross_Sale__c insuranceCrossSell = new Insurance_Cross_Sale__c();
    	insuranceCrossSell.Name = 'test 001';
    	insert insuranceCrossSell;
    	
    	Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.plainTextBody = 'This should become a note';
        email.fromAddress ='test@test.com';
        String contactEmail = 'jsmith@salesforce.com';
        email.ccAddresses = new String[] {'Jon Smith <' + contactEmail + '>'};
        email.subject = 'test [666]' ;
        
        AnswerToLeadMailPerformer edr = new AnswerToLeadMailPerformer();
        Test.startTest();
        Messaging.InboundEmailResult result = edr.handleInboundEmail(email, env);
        Test.stopTest();
    	
    }
    
    static testMethod void  testAnswerToLeadMailPerformer003() {
    	Insurance_Cross_Sale__c insuranceCrossSell = new Insurance_Cross_Sale__c();
    	insuranceCrossSell.Name = 'test 001';
    	insert insuranceCrossSell;
    	
    	Novidea_HPC__Lead__c lead1 = TestUtils.createCustomLead(insuranceCrossSell.Id, 'test 001', true);
    	
    	Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.plainTextBody = 'This should become a note';
        email.fromAddress ='test@test.com';
        String contactEmail = 'jsmith@salesforce.com';
        email.ccAddresses = new String[] {'Jon Smith <' + contactEmail + '>'};
        email.subject = 'test [' + lead1.Id + ']' ;
        
        delete lead1;
        
        AnswerToLeadMailPerformer edr = new AnswerToLeadMailPerformer();
        Test.startTest();
        Messaging.InboundEmailResult result = edr.handleInboundEmail(email, env);
        Test.stopTest();
    	
    }
    
    
}