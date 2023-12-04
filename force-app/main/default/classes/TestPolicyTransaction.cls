/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class TestPolicyTransaction {
    
    @testSetup
	private static void setup() {
    	Novidea_TMF__Time_Measurement_Settings__c setting = new Novidea_TMF__Time_Measurement_Settings__c();
        setting.Name = 'Default';
        setting.Novidea_TMF__DefaultServiceTaskName__c = 'כללי';
        setting.Novidea_TMF__limit_rows__c = '1000';
        insert setting;
        
        Novidea_HPC__General_Switches__c setting2 = new Novidea_HPC__General_Switches__c();
        setting2.Name = 'Default';
        
        insert setting2;
    }
  	  
  	  public static User[] users = new List<User>();
  	  public static Group[] masterGroups = new List<Group>();
  	  public static Group[] subGroups = new List<Group>();
  	  public static GroupMember newMember1 = new GroupMember();
  	  public static GroupMember newMember2 = new GroupMember();
  	  public static GroupMember subNewMember2 = new GroupMember();
  	  public static GroupMember newMember3 = new GroupMember();
  	  public static GroupMember subNewMember3 = new GroupMember();
  	  public static GroupMember subNewMember4 = new GroupMember();
  	  public static GroupMember newMember4 = new GroupMember();
  	  public static GroupMember subNewMember5 = new GroupMember();
  	  public static GroupMember newMember5 = new GroupMember();
  	  
  	  public static Policy_Transaction__c pt1 = new Policy_Transaction__c();
  	  public static Policy_Transaction__c pt2 = new Policy_Transaction__c();
  	  
  	  public static User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
  	  public static General__c  generalSwitches;
	 
  	  
	static void DB(){
		
        System.runAs(thisUser){
        	
        	  generalSwitches = General__c.getInstance();
			  if(null == generalSwitches) {
				generalSwitches = new General__c();
				generalswitches.Production_Permission_Prefix_Group__c = 'Production_Permission';
				generalSwitches.Name = 'Default';
				insert generalSwitches;
			}
        	
			Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' or Name ='מנהל מערכת'];  
            for(integer i = 0; i< 6 ; i++){
            	
            	users.add(new User(Alias = 'standt' + i, Email='s1tandarduser1@testorg.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, 
                    TimeZoneSidKey='America/Los_Angeles', UserName= i +'standarduser1@testorg.com'));
            }
            insert users;
            
            for(integer i = 0; i< 2 ; i++){
            	masterGroups.add(new Group(Name = 'Production Permission' + i,
        			DoesIncludeBosses = false, 
            		DeveloperName = 'Production_Permission' + i));
            }
            for(integer i = 0; i< 3 ; i++){
             	subGroups.add(new Group( Name = 'subGroup' + i));
            }
            masterGroups.addAll(subGroups);
            insert masterGroups;
            
            
            newMember1.GroupId=masterGroups[0].id;
            newMember1.UserOrGroupId=users[0].Id;
            
            
            newMember2.GroupId = masterGroups[0].id;
            newMember2.UserOrGroupId = subGroups[0].id;
            
          
            subNewMember2.GroupId = subGroups[0].id;
            subNewMember2.UserOrGroupId = users[1].Id;
            
            
            newMember3.GroupId=masterGroups[0].id;
            newMember3.UserOrGroupId=subGroups[1].id; 
            
            
            
            subNewMember3.GroupId=subGroups[1].id;
            subNewMember3.UserOrGroupId=users[2].Id;
            
           
            subNewMember4.GroupId=subGroups[1].id;
            subNewMember4.UserOrGroupId=users[3].Id;
            
            // second group
           
            newMember4.GroupId = masterGroups[1].id;
            newMember4.UserOrGroupId = subGroups[2].id;
            
           
            subNewMember5.GroupId = subGroups[2].id;
            subNewMember5.UserOrGroupId = users[4].Id;
            
            
            newMember5.GroupId = masterGroups[1].id;
            newMember5.UserOrGroupId = users[5].id;
            
            GroupMember[] listGroupMembersToInsert = new GroupMember[]{newMember1,newMember2,newMember3,newMember4,newMember5,subNewMember2,subNewMember3,subNewMember4,subNewMember5};
                         
            insert listGroupMembersToInsert;
                
             string s ='%7b%22action%22%3a%22Renew%22%2c%22additional%22%3a%220000%22%2c%22Bordero_Month%22%3a%222012-06-01%22%2c%22Calculation_Code%22%3a%2201%22%2c'+
            '%22controlDigit%22%3a%222%22%2c%22CurrencyCode%22%3a%22USD%22%2c%22Endorsment_No%22%3a%2200%22%2c%22endorsmentEffectiveDate%22%3a%222012-06-01%22%2c%22'+
            'endorsmentExpirationDate%22%3a%222013-05-31%22%2c%22Expiration_Date%22%3a%222013-05-31%22%2c%22HUTAL_IKUL%22%3anull%2c%22HUTAL_SHIABUD%22%3anull%2c%22'+
            'Indexing_Type%22%3a%2202%22%2c%22KAYAM_CHOV_O_PIGUR%22%3anull%2c%22MASLUL_BITUACH_BAKEREN_PENSIA%22%3anull%2c%22MISPAR_POLISA_O_HESHBON%22%3a%22320000011512%22'+
            '%2c%22MPR_MEFITZ_BE_YATZRAN%22%3a%22000001250%22%2c%22NetuneiGvia%22%3a%7b%22ACHUZ_TAT_SHNATIYOT%22%3anull%2c%22CHODESH_YECHUS%22%3anull%2c%22Commission%22'+
            '%3a%5b%7b%22commissionAmountAgentA%22%3a%220000595.00%22%2c%22commissionAmountAgentB%22%3a%220000000.00%22%2c%22contractNo%22%3a%2201%22%2c%22discountAmount%22'+
            '%3a%220000000.00%22%2c%22discountPercentage%22%3a%2200.000%22%2c%22discountSign%22%3a%220%22%2c%22InsuredAmount%22%3a%2200000040000.00%22%2c%22netPremium%22'+
            '%3a%2200000003500.00%22%2c%22percentCommissionAgentA%22%3a%2217.000%22%2c%22percentCommissionAgentB%22%3a%2200.000%22%2c%22signCommissionAmountAgentA%22%3a%22'+
            '0%22%2c%22signCommissionAmountAgentB%22%3a%220%22%2c%22signNetPremium%22%3a%220%22%2c%22underWriterFee%22%3a%2200.000%22%7d%2c%7b%22commissionAmountAgentA%22'+
            '%3a%220000000.00%22%2c%22commissionAmountAgentB%22%3a%220000000.00%22%2c%22contractNo%22%3a%2200%22%2c%22discountAmount%22%3a%220000000.00%22%2c%22'+
            'discountPercentage%22%3a%2200.000%22%2c%22discountSign%22%3a%220%22%2c%22InsuredAmount%22%3a%2200000000000.00%22%2c%22netPremium%22%3a%2200000000000.00%22'+
            '%2c%22percentCommissionAgentA%22%3a%2200.000%22%2c%22percentCommissionAgentB%22%3a%2200.000%22%2c%22signCommissionAmountAgentA%22%3a%220%22%2c%22'+
            'signCommissionAmountAgentB%22%3a%220%22%2c%22signNetPremium%22%3a%220%22%2c%22underWriterFee%22%3a%2200.000%22%7d%5d%2c%22DetailedPremiumAndFees%22'+
            '%3a%5b%7b%22Amount%22%3a%2200000003500.00%22%2c%22AmountCode%22%3a%2201%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22'+
            '%3a%2200000000000.00%22%2c%22AmountCode%22%3a%2204%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22'+
            '%2c%22AmountCode%22%3a%2205%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22%2c%22AmountCode%22%3a%22'+
            '06%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22%2c%22AmountCode%22%3a%2207%22%2c%22AmountSign%22'+
            '%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22%2c%22AmountCode%22%3a%2209%22%2c%22AmountSign%22%3a%220%22%2c%22'+
            'recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000003500.00%22%2c%22AmountCode%22%3a%2215%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%22'+
            '30%22%7d%5d%2c%22KOD_EMTZAEI_TASHLUM%22%3anull%2c%22MISPAR_ZIHUY_MESHALEM%22%3anull%2c%22OFEN_HATZMADAT_GVIA%22%3a%2201%22%2c%22PandCCoverages%22'+
            '%3anull%2c%22SHEM_MESHALEM%22%3anull%2c%22SUG_TEUDA_MESHALEM%22%3anull%2c%22TADIRUT_TASHLUM%22%3a%2201%22%2c%22YOM_GVIYA_BECHODESH%22%3anull%7d%2c%22'+
            'PENSIA_VATIKA_O_HADASHA%22%3anull%2c%22policyBranch%22%3a%2200%22%2c%22policyYear%22%3a%2232%22%2c%22product%22%3a%22032%22%2c%22runningNumber%22%3a%22'+
            '01151%22%2c%22Send_Message_Code%22%3a%2201%22%2c%22SHEM_MASLUL_HABITUAH%22%3anull%2c%22STATUS_POLISA_O_CHESHBON%22%3anull%2c%22subProduct%22%3a%22032%22'+
            '%2c%22SUG_KEREN_PENSIA%22%3anull%2c%22SUG_MUTZAR_PENSIONI%22%3anull%2c%22SUG_POLISA%22%3anull%2c%22SUG_TOCHNIT_O_CHESHBON%22%3anull%2c%22'+
            'TAARICH_HITZTARFUT_MUTZAR%22%3a%222012-06-01%22%2c%22vehicleDetail%22%3anull%2c%22YESH_HALVAA_BAMUTZAR%22%3anull%2c%22YESH_TVIA%22%3anull%2c%22'+
            'YeshutLakoach%22%3a%7b%22clientNumberFromAgent%22%3a%22001216965%22%2c%22E_MAIL%22%3anull%2c%22ERETZ%22%3anull%2c%22fullAddress%22%3anull%2c%22'+
            'fullName%22%3a%22LTD+TRUSTEER%22%2c%22HEAROT%22%3anull%2c%22MATZAV_MISHPACHTI%22%3anull%2c%22MIKUD%22%3a%2267442%22%2c%22MIN%22%3a%22%22'+
            '%2c%22MISPAR_BAIT%22%3a%22%22%2c%22MISPAR_CELLULARI%22%3anull%2c%22MISPAR_DIRA%22%3anull%2c%22MISPAR_FAX%22%3anull%2c%22MISPAR_KNISA%22'+
            '%3anull%2c%22MISPAR_SHLUCHA%22%3anull%2c%22MISPAR_TELEPHONE_KAVI%22%3anull%2c%22MISPAR_YELADIM%22%3anull%2c%22MISPAR_ZIHUY_LAKOACH%22%3a%22'+
            '513851816%22%2c%22PTIRA%22%3anull%2c%22SEMEL_YESHUV%22%3anull%2c%22SHEM_MISHPACHA%22%3a%22LTD%22%2c%22SHEM_MISHPACHA_KODEM%22%3anull%2c%22'+
            'SHEM_PRATI%22%3a%22TRUSTEER%22%2c%22SHEM_RECHOV%22%3a%22MOZES+NOACH+13%22%2c%22SHEM_YISHUV%22%3a%22AVIV+TEL%22%2c%22SpouseBirthDate%22%3anull%2c%22'+
            'SpouseFirstName%22%3anull%2c%22SpouseSSN%22%3anull%2c%22SUG_MEZAHE_LAKOACH%22%3a%221%22%2c%22TA_DOAR%22%3anull%7d+';      
            
            pt1.file_name__c ='test';
            pt1.Policy_Content__c = s; 
            pt1.Carrier_File_Code__c = '333';
            pt1.Name = String.format('{0}-{1}-{2}', new String[]{pt1.file_name__c,pt1.Carrier_File_Code__c,date.today().month()+''+date.today().year()});
            pt1.External_Id__c = '0123456789-00-36-380-380-0000';      
            pt1.ownerId = users[0].id;
            
            pt2.file_name__c ='test2'; 
            pt2.Policy_Content__c = s; 
            pt2.Carrier_File_Code__c = '333';
            pt2.Name = String.format('{0}-{1}-{2}', new String[]{pt2.file_name__c,pt2.Carrier_File_Code__c,date.today().month()+''+date.today().year()});
            pt2.External_Id__c = '9876543210-00-36-380-380-0000';      
            pt2.ownerId = users[2].id;
            
            Policy_Transaction__c[] pts = new Policy_Transaction__c[]{pt1,pt2};
                  
            insert pts;
                
                
       } 	 
  	  	
  	  	
	}
  	  	
  @isTest(seealldata=false)
  static void testReturnAllUsersUnderSameGroupOfCurrentUsersLogic(){
        
        DB();
    	system.runAs(users[3]){ //0,1,2 
                
            set<id> usersUnderSamegroup = WSYigod.getAllUsersUnderSameGroupOfCurrrentUser();
            system.AssertEquals(usersUnderSamegroup.contains(users[0].id),true);
            system.AssertEquals(usersUnderSamegroup.contains(users[1].id),true);
            system.AssertEquals(usersUnderSamegroup.contains(users[2].id),true);
            system.AssertEquals(usersUnderSamegroup.contains(users[4].id),false);
            system.AssertEquals(usersUnderSamegroup.contains(users[5].id),false);
        }
            
        system.runAs(users[0]){ //1,2,3
                
            set<id> usersUnderSamegroup = WSYigod.getAllUsersUnderSameGroupOfCurrrentUser(); 
            system.AssertEquals(usersUnderSamegroup.contains(users[1].id),true);
            system.AssertEquals(usersUnderSamegroup.contains(users[2].id),true);
            system.AssertEquals(usersUnderSamegroup.contains(users[3].id),true);
            system.AssertEquals(usersUnderSamegroup.contains(users[4].id),false);
            system.AssertEquals(usersUnderSamegroup.contains(users[5].id),false);
        }
            
        system.runAs(users[4]){ // 5
            
        	set<id> usersUnderSamegroup = WSYigod.getAllUsersUnderSameGroupOfCurrrentUser();
            system.AssertEquals(usersUnderSamegroup.contains(users[4].id),true);
            system.AssertEquals(usersUnderSamegroup.contains(users[5].id),true);
        }
            
        system.runAs(users[5]){ //4
            
        	set<id> usersUnderSamegroup = WSYigod.getAllUsersUnderSameGroupOfCurrrentUser();
            system.AssertEquals(usersUnderSamegroup.contains(users[5].id),true);
            system.AssertEquals(usersUnderSamegroup.contains(users[4].id),true);
            system.AssertEquals(usersUnderSamegroup.contains(users[0].id),false);
            system.AssertEquals(usersUnderSamegroup.contains(users[1].id),false);
            system.AssertEquals(usersUnderSamegroup.contains(users[2].id),false);
            system.AssertEquals(usersUnderSamegroup.contains(users[3].id),false);
		}
     } 
    
    @isTest(seealldata=false)
  	static void testTransactionSearchUnderDiffrentUsers(){
  		
  		DB();
  		mergeTransactionCO.searchResult sr = new mergeTransactionCO.searchResult();
  		//system.debug([select OwnerId from Policy_Transaction__c where id =:pt2.id]);
  		 // user0 will find policy of user2(owner) because they under same group
  		 system.runAs(users[0]){
  			sr =  mergeTransactionCO.doRemoteSearch(null, null, null, pt2.Name,null, null, null, null, null);
  			//system.debug([select OwnerId from Policy_Transaction__c where id =:pt2.id]);
  		 	system.AssertEquals(sr.listWrappedPolicyTransaction.size(),1); 
  		 }
  		 // change pt2 owner id
  		 system.runAs(thisUser){
  		 	pt2.ownerId = users[5].id;
  		 	update pt2;
  		 }
  		 // user0 won't find policy of user5(owner) because they not under same group
  		 system.runAs(users[0]){
  		 	sr =  mergeTransactionCO.doRemoteSearch(null, null, null, pt2.Name,null, null, null, null, null);
  		 	system.AssertEquals(sr.listWrappedPolicyTransaction.size(),0); 
  		 
  		 }
  	}    
         
         
 
 
/*@isTest
private class TestPolicyTransaction {
        static final Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        static Id gPolId;
        static Id gBrokerId;
        static Id gCarrierProd;
        static Id gProdDef;
        static Id gPtId;
        static Id[] acts = new Id[]{}; 
        static Id[] gAgencies = new Id[]{};
        
        static void resetGlobals(){
            gPolId = null;
            gBrokerId = null;
            gCarrierProd = null;
            gProdDef = null;
            gPtId = null;
            acts = new Id[]{};
            gAgencies = new Id[]{};
        }
            
        class CreatePolicyParams{
            public boolean withPolNumber = true; 
            public boolean policyFirst = true; 
            public boolean matchEffDate = true;
            public boolean matchExpDate = true;
            public boolean matchProduct = true; 
            public boolean matchCarrier = true;
            public boolean matchBroker = true;
            public boolean matchPremium = true;
            public boolean matchPremiumNoDeviation = true; 
            public boolean matchPremiumCurrency = true;
            public boolean noIdenticalBrokerNumbers = true;
            
            public CreatePolicyParams(boolean withPolNumber, boolean policyFirst, boolean matchEffDate, boolean matchExpDate, boolean matchProduct, 
                                boolean matchCarrier, boolean matchBroker, boolean matchPremium, boolean matchPremiumNoDeviation, boolean matchPremiumCurrency, 
                                boolean noIdenticalBrokerNumbers){
                this.withPolNumber = withPolNumber;
                this.policyFirst = policyFirst;
                this.matchEffDate = matchEffDate;
                this.matchExpDate = matchExpDate;
                this.matchProduct = matchProduct;
                this.matchCarrier = matchCarrier;
                this.matchBroker = matchBroker;
                this.matchPremium = matchPremium;
                this.matchPremiumNoDeviation = matchPremiumNoDeviation; 
                this.matchPremiumCurrency = matchPremiumCurrency;
                this.noIdenticalBrokerNumbers = noIdenticalBrokerNumbers;
            }
            
            public CreatePolicyParams(){}
        }
    
         static Id createPolicy(CreatePolicyParams params) {
            Policy_Transaction__c pt = new Policy_Transaction__c();
            pt.file_name__c ='test';                                 
            string s ='%7b%22action%22%3a%22Renew%22%2c%22additional%22%3a%220000%22%2c%22Bordero_Month%22%3a%222012-06-01%22%2c%22Calculation_Code%22%3a%2201%22%2c'+
            '%22controlDigit%22%3a%222%22%2c%22CurrencyCode%22%3a%22USD%22%2c%22Endorsment_No%22%3a%2200%22%2c%22endorsmentEffectiveDate%22%3a%222012-06-01%22%2c%22'+
            'endorsmentExpirationDate%22%3a%222013-05-31%22%2c%22Expiration_Date%22%3a%222013-05-31%22%2c%22HUTAL_IKUL%22%3anull%2c%22HUTAL_SHIABUD%22%3anull%2c%22'+
            'Indexing_Type%22%3a%2202%22%2c%22KAYAM_CHOV_O_PIGUR%22%3anull%2c%22MASLUL_BITUACH_BAKEREN_PENSIA%22%3anull%2c%22MISPAR_POLISA_O_HESHBON%22%3a%22320000011512%22'+
            '%2c%22MPR_MEFITZ_BE_YATZRAN%22%3a%22000001250%22%2c%22NetuneiGvia%22%3a%7b%22ACHUZ_TAT_SHNATIYOT%22%3anull%2c%22CHODESH_YECHUS%22%3anull%2c%22Commission%22'+
            '%3a%5b%7b%22commissionAmountAgentA%22%3a%220000595.00%22%2c%22commissionAmountAgentB%22%3a%220000000.00%22%2c%22contractNo%22%3a%2201%22%2c%22discountAmount%22'+
            '%3a%220000000.00%22%2c%22discountPercentage%22%3a%2200.000%22%2c%22discountSign%22%3a%220%22%2c%22InsuredAmount%22%3a%2200000040000.00%22%2c%22netPremium%22'+
            '%3a%2200000003500.00%22%2c%22percentCommissionAgentA%22%3a%2217.000%22%2c%22percentCommissionAgentB%22%3a%2200.000%22%2c%22signCommissionAmountAgentA%22%3a%22'+
            '0%22%2c%22signCommissionAmountAgentB%22%3a%220%22%2c%22signNetPremium%22%3a%220%22%2c%22underWriterFee%22%3a%2200.000%22%7d%2c%7b%22commissionAmountAgentA%22'+
            '%3a%220000000.00%22%2c%22commissionAmountAgentB%22%3a%220000000.00%22%2c%22contractNo%22%3a%2200%22%2c%22discountAmount%22%3a%220000000.00%22%2c%22'+
            'discountPercentage%22%3a%2200.000%22%2c%22discountSign%22%3a%220%22%2c%22InsuredAmount%22%3a%2200000000000.00%22%2c%22netPremium%22%3a%2200000000000.00%22'+
            '%2c%22percentCommissionAgentA%22%3a%2200.000%22%2c%22percentCommissionAgentB%22%3a%2200.000%22%2c%22signCommissionAmountAgentA%22%3a%220%22%2c%22'+
            'signCommissionAmountAgentB%22%3a%220%22%2c%22signNetPremium%22%3a%220%22%2c%22underWriterFee%22%3a%2200.000%22%7d%5d%2c%22DetailedPremiumAndFees%22'+
            '%3a%5b%7b%22Amount%22%3a%2200000003500.00%22%2c%22AmountCode%22%3a%2201%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22'+
            '%3a%2200000000000.00%22%2c%22AmountCode%22%3a%2204%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22'+
            '%2c%22AmountCode%22%3a%2205%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22%2c%22AmountCode%22%3a%22'+
            '06%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22%2c%22AmountCode%22%3a%2207%22%2c%22AmountSign%22'+
            '%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22%2c%22AmountCode%22%3a%2209%22%2c%22AmountSign%22%3a%220%22%2c%22'+
            'recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000003500.00%22%2c%22AmountCode%22%3a%2215%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%22'+
            '30%22%7d%5d%2c%22KOD_EMTZAEI_TASHLUM%22%3anull%2c%22MISPAR_ZIHUY_MESHALEM%22%3anull%2c%22OFEN_HATZMADAT_GVIA%22%3a%2201%22%2c%22PandCCoverages%22'+
            '%3anull%2c%22SHEM_MESHALEM%22%3anull%2c%22SUG_TEUDA_MESHALEM%22%3anull%2c%22TADIRUT_TASHLUM%22%3a%2201%22%2c%22YOM_GVIYA_BECHODESH%22%3anull%7d%2c%22'+
            'PENSIA_VATIKA_O_HADASHA%22%3anull%2c%22policyBranch%22%3a%2200%22%2c%22policyYear%22%3a%2232%22%2c%22product%22%3a%22032%22%2c%22runningNumber%22%3a%22'+
            '01151%22%2c%22Send_Message_Code%22%3a%2201%22%2c%22SHEM_MASLUL_HABITUAH%22%3anull%2c%22STATUS_POLISA_O_CHESHBON%22%3anull%2c%22subProduct%22%3a%22032%22'+
            '%2c%22SUG_KEREN_PENSIA%22%3anull%2c%22SUG_MUTZAR_PENSIONI%22%3anull%2c%22SUG_POLISA%22%3anull%2c%22SUG_TOCHNIT_O_CHESHBON%22%3anull%2c%22'+
            'TAARICH_HITZTARFUT_MUTZAR%22%3a%222012-06-01%22%2c%22vehicleDetail%22%3anull%2c%22YESH_HALVAA_BAMUTZAR%22%3anull%2c%22YESH_TVIA%22%3anull%2c%22'+
            'YeshutLakoach%22%3a%7b%22clientNumberFromAgent%22%3a%22001216965%22%2c%22E_MAIL%22%3anull%2c%22ERETZ%22%3anull%2c%22fullAddress%22%3anull%2c%22'+
            'fullName%22%3a%22LTD+TRUSTEER%22%2c%22HEAROT%22%3anull%2c%22MATZAV_MISHPACHTI%22%3anull%2c%22MIKUD%22%3a%2267442%22%2c%22MIN%22%3a%22%22'+
            '%2c%22MISPAR_BAIT%22%3a%22%22%2c%22MISPAR_CELLULARI%22%3anull%2c%22MISPAR_DIRA%22%3anull%2c%22MISPAR_FAX%22%3anull%2c%22MISPAR_KNISA%22'+
            '%3anull%2c%22MISPAR_SHLUCHA%22%3anull%2c%22MISPAR_TELEPHONE_KAVI%22%3anull%2c%22MISPAR_YELADIM%22%3anull%2c%22MISPAR_ZIHUY_LAKOACH%22%3a%22'+
            '513851816%22%2c%22PTIRA%22%3anull%2c%22SEMEL_YESHUV%22%3anull%2c%22SHEM_MISHPACHA%22%3a%22LTD%22%2c%22SHEM_MISHPACHA_KODEM%22%3anull%2c%22'+
            'SHEM_PRATI%22%3a%22TRUSTEER%22%2c%22SHEM_RECHOV%22%3a%22MOZES+NOACH+13%22%2c%22SHEM_YISHUV%22%3a%22AVIV+TEL%22%2c%22SpouseBirthDate%22%3anull%2c%22'+
            'SpouseFirstName%22%3anull%2c%22SpouseSSN%22%3anull%2c%22SUG_MEZAHE_LAKOACH%22%3a%221%22%2c%22TA_DOAR%22%3anull%7d+';
             pt.Policy_Content__c = s; 
             pt.Carrier_File_Code__c = '333';
             pt.Name = String.format('{0}-{1}-{[1]}', new String[]{pt.file_name__c,pt.Carrier_File_Code__c,date.today().month()+''+date.today().year()});
             string heshbonOPolisaJson = Encodingutil.urlDecode(s, 'UTF-8')+'}';  
             WSYigod.HeshbonOPolisa heshbonOPolisaObj = (WSYigod.HeshbonOPolisa)JSON.deserialize( heshbonOPolisaJson, WSYigod.HeshbonOPolisa.class);
             pt.External_Id__c = String.Format('{0}-{1}-{2}-{3}-{4}-{5}', new String[]{HeshbonOPolisaObj.MISPAR_POLISA_O_HESHBON, HeshbonOPolisaObj.Endorsment_No, pt.Carrier_File_Code__c, HeshbonOPolisaObj.product, HeshbonOPolisaObj.subProduct, HeshbonOPolisaObj.additional});            
             list<Policy_Transaction__c> ls = [select id from Policy_Transaction__c where External_Id__c =: pt.External_Id__c];
             if(!ls.isEmpty()) delete ls[0];
             /*
             if(gPtId!=null)delete new Policy_Transaction__c(Id=gPtId);
             if(gPolId!=null)delete new Novidea_HPC__Policy__c(Id=gPolId);
             if(gBrokerId!=null)delete new Novidea_HPC__Broker_Number__c(Id= gBrokerId);
             if(gCarrierProd!=null)delete new Novidea_HPC__Carrier_Product__c(Id= gCarrierProd);
             if(gProdDef!=null)delete new Novidea_HPC__Product_Def__c(Id= gProdDef);
             if(!acts.isEmpty()){
                Account[] oacts = new Account[]{};
                for(Id id: acts) oacts.add(new Account(Id=id));
                delete oacts;
             }
             
             
             insert new CustomImplementation__c(ClassName__c='HowdenProductionHandler', Name='IProductionHandler');
             
             Account act;
             list<Account> lsAcc;
             if((lsAcc=[select Id, name, Novidea_HPC__Tax_ID__c from Account where Novidea_HPC__Tax_ID__c =: heshbonOPolisaObj.YeshutLakoach.MISPAR_ZIHUY_LAKOACH]).isempty()){
                act = new Account(name='test customer', Novidea_HPC__Tax_ID__c = heshbonOPolisaObj.YeshutLakoach.MISPAR_ZIHUY_LAKOACH, 
                                    recordTypeId= rtMapByName.get('עסק').getRecordTypeId());
                insert act;
             }
             else act = lsAcc[0];
             //acts.add(act.Id);
             String carTypeId = rtMapByName.get('מבטח').getRecordTypeId();
             
             Account carrier; 
             if((lsAcc = [select Id,name, Carrier_File_Code__c from Account where Carrier_File_Code__c =: pt.Carrier_File_Code__c]).isempty()){
                 carrier = new Account(Carrier_File_Code__c = pt.Carrier_File_Code__c, name = 'test carrier', RecordTypeId=carTypeId);
                 insert carrier;
             }
             else carrier = lsAcc[0];
             //acts.add(carrier.Id);
             Account carrier1;
             if((lsAcc = [select Id,Carrier_File_Code__c, name from Account where name = 'test carrier1']).isempty()){
                 carrier1 = new Account(Carrier_File_Code__c = 'xx', name = 'test carrier1', RecordTypeId=carTypeId);
                 insert carrier1;
             }
             else carrier1 = lsAcc[0];
             //acts.add(carrier1.Id);
             
             Novidea_HPC__Product_Def__c proddef;
             list<Novidea_HPC__Product_Def__c> lsProds;
             if((lsProds = [select Id, name from Novidea_HPC__Product_Def__c where name = 'test prod']).isEmpty()){
                 proddef = new Novidea_HPC__Product_Def__c(name= 'test prod');
                 insert proddef;
             }
             else  proddef = lsProds[0];
             //gProdDef = proddef.Id;
             String carrProd = PolicyTransactionHandler.removeZeroFromStart(heshbonOPolisaObj.product);

             Novidea_HPC__Carrier_Product__c carrierProd;
             list<Novidea_HPC__Carrier_Product__c> lsCarrProds;
             if((lsCarrProds = [SELECT Name, Novidea_HPC__Account__c, Novidea_HPC__Product_Definition__c, Novidea_HPC__Product_In_Carrier__c
                                FROM Novidea_HPC__Carrier_Product__c 
                                WHERE Novidea_HPC__Account__c =: params.matchCarrier?carrier.id:carrier1.Id
                                AND Novidea_HPC__Product_Definition__c =: proddef.id
                                AND Novidea_HPC__Product_In_Carrier__c =: params.matchProduct?carrProd:'xxx']).isEmpty()){
                 carrierProd = new Novidea_HPC__Carrier_Product__c(name = carrProd + ' in ' + carrier.name, 
                                                        Novidea_HPC__Account__c = params.matchCarrier?carrier.id:carrier1.Id, 
                                                        Novidea_HPC__Product_Definition__c = proddef.id,
                                                        Novidea_HPC__Product_In_Carrier__c = params.matchProduct?carrProd:'xxx'); 
                 insert carrierProd;
             }
             else carrierProd = lsCarrProds[0];
             //gCarrierProd = carrierProd.Id;
             Account agency;
             if((lsAcc = [SELECT Name FROM Account WHERE Name = 'test agency']).isempty()){
                 agency = new Account(name='test agency', recordTypeId=rtMapByName.get('סוכנות').getRecordTypeId());
                 if(!params.noIdenticalBrokerNumbers){
                    lsAcc.add(agency);
                    lsAcc.add(new Account(name='test agency1', recordTypeId=rtMapByName.get('סוכנות').getRecordTypeId()));
                    insert lsAcc;
                 }
                 else insert agency;             
             }
             else agency = lsAcc[0];
             if(!lsAcc.isEmpty()) gAgencies.add(lsAcc[0].id);
             if(lsAcc.size()>1) gAgencies.add(lsAcc[1].id);

             if(General__c.getInstance().Resolve_Broker_Numbers_By_Profit_Center__c==null){
                insert new General__c(Resolve_Broker_Numbers_By_Profit_Center__c=(!params.noIdenticalBrokerNumbers?lsAcc[1].id:agency.id));
             }

             
             Novidea_HPC__Broker_Number__c brokerNumber;
             list<Novidea_HPC__Broker_Number__c> lsBrokers;
             if((lsBrokers = [SELECT Novidea_HPC__Agency__c, Novidea_HPC__Broker_Number_In_Carrier__c, Novidea_HPC__Carrier__c,Novidea_HPC__Profit_Center__c  
                             FROM Novidea_HPC__Broker_Number__c 
                             where Novidea_HPC__Agency__c =: agency.Id
                             AND Novidea_HPC__Broker_Number_In_Carrier__c =: params.matchBroker?PolicyTransactionHandler.removeZeroFromStart(heshbonOPolisaObj.MPR_MEFITZ_BE_YATZRAN):'yyy'
                             AND Novidea_HPC__Carrier__c =: params.matchCarrier?carrier.id:carrier1.Id
                             AND Novidea_HPC__Profit_Center__c =: agency.Id]).isEmpty()){
                brokerNumber = new Novidea_HPC__Broker_Number__c(Novidea_HPC__Agency__c = agency.Id,
                                        Novidea_HPC__Broker_Number_In_Carrier__c = params.matchBroker?PolicyTransactionHandler.removeZeroFromStart(heshbonOPolisaObj.MPR_MEFITZ_BE_YATZRAN):'yyy',
                                        Novidea_HPC__Carrier__c =  params.matchCarrier?carrier.id:carrier1.Id,
                                        Novidea_HPC__Profit_Center__c = agency.Id);
                if(!params.noIdenticalBrokerNumbers){
                    lsBrokers.add(brokerNumber);
                    lsBrokers.add(new Novidea_HPC__Broker_Number__c(Novidea_HPC__Agency__c =  lsAcc[1].Id,
                                        Novidea_HPC__Broker_Number_In_Carrier__c = params.matchBroker?PolicyTransactionHandler.removeZeroFromStart(heshbonOPolisaObj.MPR_MEFITZ_BE_YATZRAN):'yyy',
                                        Novidea_HPC__Carrier__c =  params.matchCarrier?carrier.id:carrier1.Id,
                                        Novidea_HPC__Profit_Center__c = lsAcc[1].Id));
                    insert lsBrokers;
                }
                else insert brokerNumber;
             }
             else  brokerNumber = lsBrokers[0];
             //gBrokerId = brokerNumber.Id;
             list<Novidea_HPC__Policy__c> lsPols=[SELECT id 
                                                FROM Novidea_HPC__Policy__c 
                                                where Novidea_HPC__Policy_Number__c =: params.withPolNumber?PolicyTransactionHandler.removeZeroFromStart(HeshbonOPolisaObj.MISPAR_POLISA_O_HESHBON):null
                                                AND Novidea_HPC__Client__c =: act.Id
                                                AND Novidea_HPC__Carrier_Product_Number__c =: carrierProd.id
                                                AND Novidea_HPC__Product_Definition__c =: proddef.id
                                                AND Novidea_HPC__Broker_In_Carrier__c =: brokerNumber.Id
                                                AND Novidea_HPC__Carrier__c =: params.matchCarrier?carrier.Id:carrier1.Id];
             if(!lsPols.isEmpty()) database.delete(lsPols[0]);
                 
             Novidea_HPC__Policy__c pol = new Novidea_HPC__Policy__c(Novidea_HPC__Policy_Number__c = params.withPolNumber?PolicyTransactionHandler.removeZeroFromStart(HeshbonOPolisaObj.MISPAR_POLISA_O_HESHBON):null, 
                                            Novidea_HPC__Client__c = act.Id, 
                                            Novidea_HPC__Carrier_Product_Number__c = carrierProd.id,
                                            Novidea_HPC__Product_Definition__c = proddef.id,
                                            Novidea_HPC__Broker_In_Carrier__c = brokerNumber.Id,
                                            Novidea_HPC__Carrier__c = params.matchCarrier?carrier.Id:carrier1.Id
                                        );
             
             if(!params.policyFirst) insert pt;
             system.debug(pol);
             insert pol;
             gPolId = pol.Id;
             Novidea_HPC__Income__c income = [SELECT Novidea_HPC__Expiration_Date__c, Novidea_HPC__Effective_Date__c, 
                                                    Novidea_HPC__Premium__c, Novidea_HPC__Fees__c, Novidea_HPC__Premium_Currency__c
                                            FROM Novidea_HPC__Income__c
                                            WHERE Novidea_HPC__Policy__c =:pol.Id
                                            LIMIT 1];
             income.Novidea_HPC__Expiration_Date__c = params.matchEffDate?HeshbonOPolisaObj.Expiration_Date:HeshbonOPolisaObj.Expiration_Date-1;
             income.Novidea_HPC__Effective_Date__c = params.matchExpDate?HeshbonOPolisaObj.TAARICH_HITZTARFUT_MUTZAR:HeshbonOPolisaObj.TAARICH_HITZTARFUT_MUTZAR-1;
             Policy_transaction__c tmpPt = new Policy_transaction__c();
             PolicyTransactionHandler.populateCollectionData(HeshbonOPolisaObj, tmpPt);
             system.debug('tmpPt.Premium_neto__c: ' + tmpPt.Premium_neto__c + '\ntmpPt.Fee__c: ' + tmpPt.Fee__c + '\nHeshbonOPolisaObj.CurrencyCode: ' + HeshbonOPolisaObj.CurrencyCode);
             //match but with <=1% deviation 
             if(params.matchPremium && !params.matchPremiumNoDeviation){
                   decimal prem = 0;
                   if(tmpPt.Premium_neto__c!=null) prem+=tmpPt.Premium_neto__c;
                   if(tmpPt.Fee__c!=null) prem+=tmpPt.Fee__c;
                   if(prem!=0) prem = (prem*0.01);
                   if(tmpPt.Premium_neto__c!=null)tmpPt.Premium_neto__c += prem;
                   else if (tmpPt.Fee__c!=null)tmpPt.Fee__c += prem;
             }
             else if(!params.matchPremium){
                 if(tmpPt.Premium_neto__c!=null) tmpPt.Premium_neto__c = tmpPt.Premium_neto__c * 1.5;
                 if(tmpPt.Fee__c!=null) tmpPt.Fee__c = tmpPt.Fee__c * 1.5;
             }
             system.debug('tmpPt.Premium_neto__c1: ' + tmpPt.Premium_neto__c + '\ntmpPt.Fee__c1: ' + tmpPt.Fee__c + '\nHeshbonOPolisaObj.CurrencyCode1: ' + HeshbonOPolisaObj.CurrencyCode);
             income.Novidea_HPC__Premium__c = tmpPt.Premium_neto__c;
             income.Novidea_HPC__Fees__c = tmpPt.Fee__c;
             income.Novidea_HPC__Premium_Currency__c = params.matchPremiumCurrency?HeshbonOPolisaObj.CurrencyCode:'JOD';
             update income;

             if(params.policyFirst)insert pt;
             return pt.Id; 
         }
        
         @isTest(SeeAllData=false)
         static void testCarrierProductOverride(){
            CurrencyTriggerHelper.stopTrigger = true;
            Approval_Process__c t = new Approval_Process__c(SetupOwnerId = Userinfo.getUserId(),Allow_Income_Edit__c = true);
            insert t;
            //resetGlobals();
            String ptId = createPolicy(new CreatePolicyParams());
            
            Policy_Transaction__c pt = [SELECT policy__c,  Carrier_Product__c, Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
            
            mergeTransactionCO.updateRowTransactions('[{"rownum":"' + pt.Id + '", "sfid":"' + pt.Id + '"}]');
            Novidea_HPC__Policy__c pol = [SELECT Novidea_HPC__Product_Definition__c FROM Novidea_HPC__Policy__c WHERE Id=:pt.policy__c];
            undelete pt;
            Novidea_HPC__Carrier_Product__c prod = new Novidea_HPC__Carrier_Product__c(Novidea_HPC__Product_Definition__c=pol.Novidea_HPC__Product_Definition__c);
            insert prod;
            pt.Carrier_Product__c = prod.id;
            update pt;
            mergeTransactionCO.updateRowTransactions('[{"rownum":"' + pt.Id + '", "sfid":"' + pt.Id + '"}]');
            pol = [SELECT Novidea_HPC__Carrier_Product_Number__c FROM Novidea_HPC__Policy__c WHERE Id=:pt.policy__c];
            
            system.assertEquals(prod.Id, pol.Novidea_HPC__Carrier_Product_Number__c);
         }        
         
         @isTest(SeeAllData=false)
         static void testAllTrue(){
            CurrencyTriggerHelper.stopTrigger = true;
            //resetGlobals();
            String ptId = createPolicy(new CreatePolicyParams());
            Policy_Transaction__c pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
            system.assertEquals('Policy Number', pt.Identification_Type__c);
            system.assertEquals('compatible', pt.Status__c);
         }
         
         @isTest(SeeAllData=false)
         static void testAllTrueProdFirst(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params = new CreatePolicyParams();
            params.policyFirst= false;
            String ptId = createPolicy(params);
            mergeTransactionCO.syncRowTransaction('0', ptId);
            Policy_Transaction__c pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
            system.assertEquals('Policy Number', pt.Identification_Type__c);
            system.assertEquals('compatible', pt.Status__c);
         }
         @isTest(SeeAllData=false)
         static void testAutoIdAllTrue(){
            CurrencyTriggerHelper.stopTrigger = true;
            ///resetGlobals();
            CreatePolicyParams params = new CreatePolicyParams();
            params.withPolNumber = false;
            String ptId = createPolicy(params);
            Policy_Transaction__c pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
            system.assertEquals('Policy Number', pt.Identification_Type__c);
            system.assertEquals('compatible', pt.Status__c);
         }
       

         @isTest(SeeAllData=false)
         static void testAllTrueButIdenticalBrokerNum(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params = new CreatePolicyParams();
            params.noIdenticalBrokerNumbers = false;
            resetGlobals();
            String ptId = createPolicy(params);
            Policy_Transaction__c pt = [SELECT Policy__c, Status__c, Identification_Type__c, Broker_Number__c, Broker_Number__r.Novidea_HPC__Profit_Center__c 
                                        FROM Policy_Transaction__c WHERE id=:ptId];
            system.assertNotEquals(null, pt.Policy__c);
            system.assertNotEquals(null, pt.Broker_Number__c);
            system.assertEquals(gAgencies[1], pt.Broker_Number__r.Novidea_HPC__Profit_Center__c);
            system.assertEquals('Policy Number', pt.Identification_Type__c);
            system.assertEquals('compatible', pt.Status__c);
         }

         @isTest(SeeAllData=false)
         static void testAutoIdAllTrueButIdenticalBrokerNum(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params = new CreatePolicyParams();
            params.noIdenticalBrokerNumbers = false;
            params.withPolNumber = false;
            resetGlobals();
            String ptId = createPolicy(params);
            Policy_Transaction__c pt = [SELECT Policy__c, Status__c, Identification_Type__c, Broker_Number__c, Broker_Number__r.Novidea_HPC__Profit_Center__c 
                                        FROM Policy_Transaction__c WHERE id=:ptId];
            system.assertNotEquals(null, pt.Policy__c);
            system.assertNotEquals(null, pt.Broker_Number__c);
            system.assertEquals(gAgencies[1], pt.Broker_Number__r.Novidea_HPC__Profit_Center__c);
            system.assertEquals('Policy Number', pt.Identification_Type__c);
            system.assertEquals('compatible', pt.Status__c);
         }


         @isTest(SeeAllData=false)
         static void testAutoIdAllTrueButIdenticalBrokerNumProdFirst(){
            CurrencyTriggerHelper.stopTrigger = true;
            resetGlobals();
            CreatePolicyParams params = new CreatePolicyParams();
            params.noIdenticalBrokerNumbers = false;
            params.withPolNumber = false;
            params.policyFirst= false;
            String ptId = createPolicy(params);
            mergeTransactionCO.syncRowTransaction('0', ptId);
            Policy_Transaction__c pt = [SELECT Policy__c, Status__c, Identification_Type__c, Broker_Number__c, Broker_Number__r.Novidea_HPC__Profit_Center__c 
                                        FROM Policy_Transaction__c WHERE id=:ptId];
            system.assertNotEquals(null, pt.Policy__c);
            system.assertNotEquals(null, pt.Broker_Number__c);
            system.assertEquals(gAgencies[1], pt.Broker_Number__r.Novidea_HPC__Profit_Center__c);
            system.assertEquals('Policy Number', pt.Identification_Type__c);
            system.assertEquals('compatible', pt.Status__c);
         }

         @isTest(SeeAllData=false)
         static void testAutoIdNoMatchPremiumWithIdenticalBrokerNum(){
            CurrencyTriggerHelper.stopTrigger = true;
            resetGlobals();
            CreatePolicyParams params = new CreatePolicyParams();
            params.withPolNumber = false;
            params.matchPremium = false;
            params.noIdenticalBrokerNumbers = false;
            String ptId = createPolicy(params);
            Policy_Transaction__c pt = [SELECT Policy__c, Status__c, Identification_Type__c, Broker_Number__c, Broker_Number__r.Novidea_HPC__Profit_Center__c 
                                        FROM Policy_Transaction__c WHERE id=:ptId];
            system.assertNotEquals(null, pt.Policy__c);
            system.assertNotEquals(null, pt.Broker_Number__c);
            system.assertEquals(gAgencies[1], pt.Broker_Number__r.Novidea_HPC__Profit_Center__c);
            system.assertEquals('Full Auto', pt.Identification_Type__c);
            system.assertEquals('not compatible', pt.Status__c);
         }

         @isTest(SeeAllData=false)
         static void testAutoIdPartial3WithIdenticalBrokerNum(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params;
            String ptId;
            Policy_Transaction__c pt;
            for(integer i=1;i<3;++i){
                params = new CreatePolicyParams();
                params.noIdenticalBrokerNumbers = false;
                params.withPolNumber = false;
                params.matchPremiumCurrency = false;
                setParams(i,params);
                resetGlobals();
                ptId = createPolicy(params);
                pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
                String expct = isMinCriteriaMet(i)?'Partially Auto': 'None';
                system.debug('Expected3: ' + expct);
                system.assertEquals(expct, pt.Identification_Type__c, 'round ' + i + ': expected=\'' + expct + '\' actual=\'' + pt.Identification_Type__c + '\'');
                system.assertEquals('not compatible', pt.Status__c, 'round ' + i+ ': expected=\'not compatible\' actual=\'' + pt.Status__c + '\'');
                Database.delete(gPolId);
                Database.delete(gAgencies);
            }
         }
       
         @isTest(SeeAllData=false)
         static void testAutoIdPartial8WithIdenticalBrokerNum(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params;
            String ptId;
            Policy_Transaction__c pt;
            params = new CreatePolicyParams();
            params.noIdenticalBrokerNumbers = false;
            params.withPolNumber = false;
            params.matchPremiumCurrency = false;
            setParams(8,params);
            resetGlobals();
            ptId = createPolicy(params);
            pt = [SELECT Policy__c, Status__c, Identification_Type__c, Broker_Number__c, Broker_Number__r.Novidea_HPC__Profit_Center__c 
                FROM Policy_Transaction__c WHERE id=:ptId];
            String expct = isMinCriteriaMet(8)?'Partially Auto': 'None';
            system.debug('Expected8: ' + expct + '\n' + pt);
            system.assertNotEquals(null, pt.Policy__c);
            system.assertNotEquals(null, pt.Broker_Number__c);
            system.assertEquals(gAgencies[1], pt.Broker_Number__r.Novidea_HPC__Profit_Center__c);
            system.assertEquals(expct, pt.Identification_Type__c, 'round ' + 8 + ': expected=\'' + expct + '\' actual=\'' + pt.Identification_Type__c + '\'');
            system.assertEquals('not compatible', pt.Status__c, 'round ' + 8 + ': expected=\'not compatible\' actual=\'' + pt.Status__c + '\'');
            Database.delete(gPolId);
            Database.delete(gAgencies);
         }
         

         @isTest(SeeAllData=false)
         static void testAutoIdPartial8WithIdenticalBrokerNumProdFirst(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params;
            String ptId;
            Policy_Transaction__c pt;
            //resetGlobals();
            for(integer i=8;i<9;++i){
                params = new CreatePolicyParams();
                params.noIdenticalBrokerNumbers = false;
                params.withPolNumber = false;
                params.matchPremiumCurrency = false;
                setParams(i,params);
                params.policyFirst = false;
                resetGlobals();
                ptId = createPolicy(params);
                mergeTransactionCO.syncRowTransaction('0', ptId);
                pt = [SELECT Policy__c, Status__c, Identification_Type__c, Broker_Number__c, Broker_Number__r.Novidea_HPC__Profit_Center__c 
                      FROM Policy_Transaction__c WHERE id=:ptId];
                String expct = isMinCriteriaMet(i)?'Partially Auto': 'None';
                system.assertNotEquals(null, pt.Policy__c);
                system.assertNotEquals(null, pt.Broker_Number__c);
                system.assertEquals(gAgencies[1], pt.Broker_Number__r.Novidea_HPC__Profit_Center__c);
                system.assertEquals(expct, pt.Identification_Type__c, 'round ' + i + ': expected=\'' + expct + '\' actual=\'' + pt.Identification_Type__c + '\'');
                system.assertEquals('not compatible', pt.Status__c, 'round ' + i+ ': expected=\'not compatible\' actual=\'' + pt.Status__c + '\'');
                Database.delete( new novidea_HPC__Policy__c(id=gPolId));
            }
         }


         @isTest(SeeAllData=false)
         static void testAutoIdAllTrueProdFirst(){
            CurrencyTriggerHelper.stopTrigger = true;
            ///resetGlobals();
            CreatePolicyParams params = new CreatePolicyParams();
            params.withPolNumber = false;
            params.policyFirst= false;
            String ptId = createPolicy(params);
            mergeTransactionCO.syncRowTransaction('0', ptId);
            Policy_Transaction__c pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
            system.assertEquals('Policy Number', pt.Identification_Type__c);
            system.assertEquals('compatible', pt.Status__c);
         }
         
         @isTest(SeeAllData=false)
         static void testAutoIdPremiumDeviate1(){
            CurrencyTriggerHelper.stopTrigger = true;
            //resetGlobals();
            CreatePolicyParams params = new CreatePolicyParams();
            params.withPolNumber = false;
            params.matchPremiumNoDeviation = false;
            String ptId = createPolicy(params);
            Policy_Transaction__c pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
            system.assertEquals('Policy Number', pt.Identification_Type__c);
            system.assertEquals('compatible', pt.Status__c);
         }
         
         @isTest(SeeAllData=false)
         static void testAutoIdPremiumDeviate1ProdFirst(){
            CurrencyTriggerHelper.stopTrigger = true;
            //resetGlobals();
            CreatePolicyParams params = new CreatePolicyParams();
            params.withPolNumber = false;
            params.policyFirst= false;
            params.matchPremiumNoDeviation = false;
            String ptId = createPolicy(params);
            mergeTransactionCO.syncRowTransaction('0', ptId);
            Policy_Transaction__c pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
            system.assertEquals('Policy Number', pt.Identification_Type__c);
            system.assertEquals('compatible', pt.Status__c);
         }

         @isTest(SeeAllData=false)
         static void testAutoIdNoMatchPremium(){
            CurrencyTriggerHelper.stopTrigger = true;
            //resetGlobals();
            CreatePolicyParams params = new CreatePolicyParams();
            params.withPolNumber = false;
            params.matchPremium = false;
            String ptId = createPolicy(params);
            Policy_Transaction__c pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
            system.assertEquals('Full Auto', pt.Identification_Type__c);
            system.assertEquals('not compatible', pt.Status__c);
         }

         @isTest(SeeAllData=false)
         static void testAutoIdNoMatchPremiumProdFirst(){
            CurrencyTriggerHelper.stopTrigger = true;
            //resetGlobals();
            CreatePolicyParams params = new CreatePolicyParams();
            params.withPolNumber = false;
            params.matchPremium = false;
            params.policyFirst = false;
            String ptId = createPolicy(params);
            mergeTransactionCO.syncRowTransaction('0', ptId);
            Policy_Transaction__c pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
            system.assertEquals('Full Auto', pt.Identification_Type__c);
            system.assertEquals('not compatible', pt.Status__c);
         }
                 
         @isTest(SeeAllData=false)
         static void testAutoIdNoMatchCurrency(){
            CurrencyTriggerHelper.stopTrigger = true;
            //resetGlobals();
            CreatePolicyParams params = new CreatePolicyParams();
            params.withPolNumber = false;
            params.matchPremiumCurrency = false;
            String ptId = createPolicy(params);
            Policy_Transaction__c pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
            system.assertEquals('Full Auto', pt.Identification_Type__c);
            system.assertEquals('not compatible', pt.Status__c);
         }

         @isTest(SeeAllData=false)
         static void testAutoIdNoMatchCurrencyProdFirst(){
            CurrencyTriggerHelper.stopTrigger = true;
            //resetGlobals();
            CreatePolicyParams params = new CreatePolicyParams();
            params.withPolNumber = false;
            params.matchPremiumCurrency = false;
            params.policyFirst = false;
            String ptId = createPolicy(params);
            mergeTransactionCO.syncRowTransaction('0', ptId);
            Policy_Transaction__c pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
            system.assertEquals('Full Auto', pt.Identification_Type__c);
            system.assertEquals('not compatible', pt.Status__c);
         }

         static void setParams(Integer counter, CreatePolicyParams cpp){
            if((counter & 1)>0){
                cpp.matchBroker = false;
            }
            if((counter & 2) >0){
                cpp.matchCarrier = false;
            }
            if((counter & 4) > 0){
                cpp.matchProduct = false;
            }
            if((counter & 8) >0){
                cpp.matchEffDate = false;
            }
            if((counter & 16) >0){
                cpp.matchExpDate = false;
            }
         }
         
         static boolean isMinCriteriaMet(Integer counter){
            return !((counter & 1)>0 || (counter & 2) >0 || (counter & 4) > 0);
         }*/
/*
         @isTest(SeeAllData=false)
         static void testAutoIdPartial3(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params;
            String ptId;
            Policy_Transaction__c pt;
            //resetGlobals();
            for(integer i=1;i<3;++i){
                params = new CreatePolicyParams();
                params.withPolNumber = false;
                params.matchPremiumCurrency = false;
                setParams(i,params);
                ptId = createPolicy(params);
                pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
                String expct = isMinCriteriaMet(i)?'Partially Auto': 'None';
                system.assertEquals(expct, pt.Identification_Type__c, 'round ' + i + ': expected=\'' + expct + '\' actual=\'' + pt.Identification_Type__c + '\'');
                system.assertEquals('not compatible', pt.Status__c, 'round ' + i+ ': expected=\'not compatible\' actual=\'' + pt.Status__c + '\'');
                Database.delete( new novidea_HPC__Policy__c(id=gPolId));
            }
         }
         
         @isTest(SeeAllData=false)
         static void testAutoIdPartial3ProdFirst(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params;
            String ptId;
            Policy_Transaction__c pt;
            //resetGlobals();
            for(integer i=1;i<3;++i){
                params = new CreatePolicyParams();
                params.withPolNumber = false;
                params.matchPremiumCurrency = false;
                setParams(i,params);
                params.policyFirst = false;
                ptId = createPolicy(params);
                mergeTransactionCO.syncRowTransaction('0', ptId);
                pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
                String expct = isMinCriteriaMet(i)?'Partially Auto': 'None';
                system.assertEquals(expct, pt.Identification_Type__c, 'round ' + i + ': expected=\'' + expct + '\' actual=\'' + pt.Identification_Type__c + '\'');
                system.assertEquals('not compatible', pt.Status__c, 'round ' + i+ ': expected=\'not compatible\' actual=\'' + pt.Status__c + '\'');
                Database.delete( new novidea_HPC__Policy__c(id=gPolId));
            }
         }

         @isTest(SeeAllData=false)
         static void testAutoIdPartial6(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params;
            String ptId;
            Policy_Transaction__c pt;
            //resetGlobals();
            for(integer i=3;i<6;++i){
                params = new CreatePolicyParams();
                params.withPolNumber = false;
                params.matchPremiumCurrency = false;
                setParams(i,params);
                ptId = createPolicy(params);
                pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
                String expct = isMinCriteriaMet(i)?'Partially Auto': 'None';
                system.assertEquals(expct, pt.Identification_Type__c, 'round ' + i + ': expected=\'' + expct + '\' actual=\'' + pt.Identification_Type__c + '\'');
                system.assertEquals('not compatible', pt.Status__c, 'round ' + i+ ': expected=\'not compatible\' actual=\'' + pt.Status__c + '\'');
                Database.delete( new novidea_HPC__Policy__c(id=gPolId));
            }
         }

         @isTest(SeeAllData=false)
         static void testAutoIdPartial9(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params;
            String ptId;
            Policy_Transaction__c pt;
            //resetGlobals();
            for(integer i=6;i<9;++i){
                params = new CreatePolicyParams();
                params.withPolNumber = false;
                params.matchPremiumCurrency = false;
                setParams(i,params);
                ptId = createPolicy(params);
                pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
                String expct = isMinCriteriaMet(i)?'Partially Auto': 'None';
                system.assertEquals(expct, pt.Identification_Type__c, 'round ' + i + ': expected=\'' + expct + '\' actual=\'' + pt.Identification_Type__c + '\'');
                system.assertEquals('not compatible', pt.Status__c, 'round ' + i+ ': expected=\'not compatible\' actual=\'' + pt.Status__c + '\'');
                Database.delete( new novidea_HPC__Policy__c(id=gPolId));
            }
         }


         @isTest(SeeAllData=false)
         static void testAutoIdPartial12(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params;
            String ptId;
            Policy_Transaction__c pt;
            //resetGlobals();
            for(integer i=9;i<12;++i){
                params = new CreatePolicyParams();
                params.withPolNumber = false;
                params.matchPremiumCurrency = false;
                setParams(i,params);
                ptId = createPolicy(params);
                pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
                String expct = isMinCriteriaMet(i)?'Partially Auto': 'None';
                system.assertEquals(expct, pt.Identification_Type__c, 'round ' + i + ': expected=\'' + expct + '\' actual=\'' + pt.Identification_Type__c + '\'');
                system.assertEquals('not compatible', pt.Status__c, 'round ' + i+ ': expected=\'not compatible\' actual=\'' + pt.Status__c + '\'');
                Database.delete( new novidea_HPC__Policy__c(id=gPolId));
            }
         }               

         @isTest(SeeAllData=false)
         static void testAutoIdPartial15(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params;
            String ptId;
            Policy_Transaction__c pt;
            //resetGlobals();
            for(integer i=12;i<15;++i){
                params = new CreatePolicyParams();
                params.withPolNumber = false;
                params.matchPremiumCurrency = false;
                setParams(i,params);
                ptId = createPolicy(params);
                pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
                String expct = isMinCriteriaMet(i)?'Partially Auto': 'None';
                system.assertEquals(expct, pt.Identification_Type__c, 'round ' + i + ': expected=\'' + expct + '\' actual=\'' + pt.Identification_Type__c + '\'');
                system.assertEquals('not compatible', pt.Status__c, 'round ' + i+ ': expected=\'not compatible\' actual=\'' + pt.Status__c + '\'');
                Database.delete( new novidea_HPC__Policy__c(id=gPolId));
            }
         }

         @isTest(SeeAllData=false)
         static void testAutoIdPartial18(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params;
            String ptId;
            Policy_Transaction__c pt;
            //resetGlobals();
            for(integer i=15;i<18;++i){
                params = new CreatePolicyParams();
                params.withPolNumber = false;
                params.matchPremiumCurrency = false;
                setParams(i,params);
                ptId = createPolicy(params);
                pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
                String expct = (isMinCriteriaMet(i)?'Partially Auto': 'None');
                system.assertEquals(expct, pt.Identification_Type__c, 'round ' + i + ': expected=\'' + expct + '\' actual=\'' + pt.Identification_Type__c + '\'');
                system.assertEquals('not compatible', pt.Status__c, 'round ' + i+ ': expected=\'not compatible\' actual=\'' + pt.Status__c + '\'');
                Database.delete( new novidea_HPC__Policy__c(id=gPolId));
            }
         }

         @isTest(SeeAllData=false)
         static void testAutoIdPartial21(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params;
            String ptId;
            Policy_Transaction__c pt;
            //resetGlobals();
            for(integer i=18;i<21;++i){
                params = new CreatePolicyParams();
                params.withPolNumber = false;
                params.matchPremiumCurrency = false;
                setParams(i,params);
                ptId = createPolicy(params);
                pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
                String expct = isMinCriteriaMet(i)?'Partially Auto': 'None';
                system.assertEquals(expct, pt.Identification_Type__c, 'round ' + i + ': expected=\'' + expct + '\' actual=\'' + pt.Identification_Type__c + '\'');
                system.assertEquals('not compatible', pt.Status__c, 'round ' + i+ ': expected=\'not compatible\' actual=\'' + pt.Status__c + '\'');
                
                Database.delete( new novidea_HPC__Policy__c(id=gPolId));
            }
         }


         @isTest(SeeAllData=false)
         static void testAutoIdPartial24(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params;
            String ptId;
            Policy_Transaction__c pt;
            //resetGlobals();
            for(integer i=21;i<24;++i){
                params = new CreatePolicyParams();
                params.withPolNumber = false;
                params.matchPremiumCurrency = false;
                setParams(i,params);
                ptId = createPolicy(params);
                pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
                String expct = isMinCriteriaMet(i)?'Partially Auto': 'None';
                system.assertEquals(expct, pt.Identification_Type__c, 'round ' + i + ': expected=\'' + expct + '\' actual=\'' + pt.Identification_Type__c + '\'');
                system.assertEquals('not compatible', pt.Status__c, 'round ' + i+ ': expected=\'not compatible\' actual=\'' + pt.Status__c + '\'');
                
                Database.delete( new novidea_HPC__Policy__c(id=gPolId));
            }
         }               

         @isTest(SeeAllData=false)
         static void testAutoIdPartial27(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params;
            String ptId;
            Policy_Transaction__c pt;
            //resetGlobals();
            for(integer i=24;i<27;++i){
                params = new CreatePolicyParams();
                params.withPolNumber = false;
                params.matchPremiumCurrency = false;
                setParams(i,params);
                ptId = createPolicy(params);
                pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
                String expct = isMinCriteriaMet(i)?'Partially Auto': 'None';
                system.assertEquals(expct, pt.Identification_Type__c, 'round ' + i + ': expected=\'' + expct + '\' actual=\'' + pt.Identification_Type__c + '\'');
                system.assertEquals('not compatible', pt.Status__c, 'round ' + i+ ': expected=\'not compatible\' actual=\'' + pt.Status__c + '\'');
                
                Database.delete( new novidea_HPC__Policy__c(id=gPolId));
            }
         }

         @isTest(SeeAllData=false)
         static void testAutoIdPartial26ProdFirst(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params;
            String ptId;
            Policy_Transaction__c pt;
            //resetGlobals();
            for(integer i=24;i<26;++i){
                params = new CreatePolicyParams();
                params.withPolNumber = false;
                params.matchPremiumCurrency = false;
                setParams(i,params);
                params.policyFirst = false;
                ptId = createPolicy(params);
                mergeTransactionCO.syncRowTransaction('0', ptId);
                pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
                String expct = isMinCriteriaMet(i)?'Partially Auto': 'None';
                system.assertEquals(expct, pt.Identification_Type__c, 'round ' + i + ': expected=\'' + expct + '\' actual=\'' + pt.Identification_Type__c + '\'');
                system.assertEquals('not compatible', pt.Status__c, 'round ' + i+ ': expected=\'not compatible\' actual=\'' + pt.Status__c + '\'');
                
                Database.delete( new novidea_HPC__Policy__c(id=gPolId));
            }
         }


         @isTest(SeeAllData=false)
         static void testAutoIdPartial30(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params;
            String ptId;
            Policy_Transaction__c pt;
            //resetGlobals();
            for(integer i=27;i<30;++i){
                params = new CreatePolicyParams();
                params.withPolNumber = false;
                params.matchPremiumCurrency = false;
                setParams(i,params);
                ptId = createPolicy(params);
                pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
                String expct = isMinCriteriaMet(i)?'Partially Auto': 'None';
                system.assertEquals(expct, pt.Identification_Type__c, 'round ' + i + ': expected=\'' + expct + '\' actual=\'' + pt.Identification_Type__c + '\'');
                system.assertEquals('not compatible', pt.Status__c, 'round ' + i+ ': expected=\'not compatible\' actual=\'' + pt.Status__c + '\'');
                
                Database.delete( new novidea_HPC__Policy__c(id=gPolId));
            }
         }


         @isTest(SeeAllData=false)
         static void testAutoIdPartial32(){
            CurrencyTriggerHelper.stopTrigger = true;
            CreatePolicyParams params;
            String ptId;
            Policy_Transaction__c pt;
            //resetGlobals();
            for(integer i=30;i<32;++i){
                params = new CreatePolicyParams();
                params.withPolNumber = false;
                params.matchPremiumCurrency = false;
                setParams(i,params);
                ptId = createPolicy(params);
                pt = [SELECT Status__c, Identification_Type__c FROM Policy_Transaction__c WHERE id=:ptId];
                String expct = isMinCriteriaMet(i)?'Partially Auto': 'None';
                system.assertEquals(expct, pt.Identification_Type__c, 'round ' + i + ': expected=\'' + expct + '\' actual=\'' + pt.Identification_Type__c + '\'');
                system.assertEquals('not compatible', pt.Status__c, 'round ' + i+ ': expected=\'not compatible\' actual=\'' + pt.Status__c + '\'');
                
                Database.delete( new novidea_HPC__Policy__c(id=gPolId));
            }
         }               


         @isTest(SeeAllData=true)
         static void testHaklai(){
         }
         

         @isTest(SeeAllData=true)
         static void testPolicyTransaction() {
            Novidea_HPC__Trigger__c triggerSetting  = Novidea_HPC__Trigger__c.getInstance(); 
            triggerSetting.Novidea_HPC__Prevent_Running__c = true;
            Novidea_HPC__Policy__c pol =  new Novidea_HPC__Policy__c();
            pol.Novidea_HPC__Policy_Number__c ='12013100025100';
            insert pol;
            List<Account> listAccount = [select Id from Account where Novidea_HPC__Tax_ID__c = '10010' ];
            if (listAccount.size() == 0 ){          
                Account acc= new Account(Name = 'test Acc' , Novidea_HPC__Tax_ID__c = '10010' );
                insert acc;
            }           
            //insert acc;
            Policy_Transaction__c pt = new Policy_Transaction__c();
            pt.Name ='test';                                
            string s ='%7b%22Bordero_Month%22%3a%222011-12-01%22%2c%22Calculation_Code%22%3a%2201%22%2c%22controlDigit%22%3anull%2c%22CurrencyCode%22%3a%2200%22%2c'+
            '%22Endorsment_No%22%3a%2200%22%2c%22Expiration_Date%22%3a%222012-12-31%22%2c%22HUTAL_IKUL%22%3anull%2c%22HUTAL_SHIABUD%22%3anull%2c%22Indexing_Type'+
            '%22%3a%2201%22%2c%22KAYAM_CHOV_O_PIGUR%22%3anull%2c%22MASLUL_BITUACH_BAKEREN_PENSIA%22%3anull%2c%22MISPAR_POLISA_O_HESHBON%22%3a%22115211523500%22%2c'+
            '%22MPR_MEFITZ_BE_YATZRAN%22%3a%22000014737%22%2c%22NetuneiGvia%22%3a%7b%22ACHUZ_TAT_SHNATIYOT%22%3anull%2c%22CHODESH_YECHUS%22%3anull%2c%22DetailedPremiumAndFees'+
            '%22%3a%5b%7b%22Amount%22%3a%2200000001426.64%22%2c%22AmountCode%22%3a%2201%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22%2c'+
            '%22AmountCode%22%3a%2204%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000000014.42%22%2c%22AmountCode%22%3a%2205%22%2c%22AmountSign%22%3a'+
            '%220%22%7d%2c%7b%22Amount%22%3a%2200000000155.58%22%2c%22AmountCode%22%3a%2206%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000000231.13%22%2c'+
            '%22AmountCode%22%3a%2207%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22%2c%22AmountCode%22%3a%2209%22%2c%22AmountSign%22%3a%220'+
            '%22%7d%2c%7b%22Amount%22%3a%2200000001828.80%22%2c%22AmountCode%22%3a%2215%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%22%22%2c%22AmountCode%22%3a'+
            '%22%22%2c%22AmountSign%22%3a%22%22%7d%2c%7b%22Amount%22%3a%22%22%2c%22AmountCode%22%3a%22%22%2c%22AmountSign%22%3a%22%22%7d%2c%7b%22Amount%22%3a%22%22%2c'+
            '%22AmountCode%22%3a%22%22%2c%22AmountSign%22%3anull%7d%5d%2c%22KOD_EMTZAEI_TASHLUM%22%3anull%2c%22MISPAR_ZIHUY_MESHALEM%22%3anull%2c%22OFEN_HATZMADAT_GVIA%22%3a'+
            '%2202%22%2c%22PandCCoverages%22%3anull%2c%22SHEM_MESHALEM%22%3anull%2c%22SUG_TEUDA_MESHALEM%22%3anull%2c%22TADIRUT_TASHLUM%22%3a%2205%22%2c%22YOM_GVIYA_BECHODESH'+
            '%22%3a%22%22%7d%2c%22PENSIA_VATIKA_O_HADASHA%22%3anull%2c%22policyBranch%22%3anull%2c%22policyYear%22%3anull%2c%22product%22%3a%22521%22%2c%22runningNumber'+
            '%22%3anull%2c%22Send_Message_Code%22%3a%2201%22%2c%22SHEM_MASLUL_HABITUAH%22%3anull%2c%22STATUS_POLISA_O_CHESHBON%22%3anull%2c%22SUG_KEREN_PENSIA%22%3anull'+
            '%2c%22SUG_MUTZAR_PENSIONI%22%3anull%2c%22SUG_POLISA%22%3anull%2c%22SUG_TOCHNIT_O_CHESHBON%22%3anull%2c%22TAARICH_HITZTARFUT_MUTZAR%22%3a%222011-12-21%22%2c'+
            '%22vehicleDetail%22%3anull%2c%22YESH_HALVAA_BAMUTZAR%22%3anull%2c%22YESH_TVIA%22%3anull%2c%22YeshutLakoach%22%3a%7b%22E_MAIL%22%3anull%2c%22ERETZ%22%3anull%2c'+
            '%22HEAROT%22%3anull%2c%22MATZAV_MISHPACHTI%22%3a%2210%22%2c%22MIKUD%22%3a%2275244%22%2c%22MIN%22%3a%221%22%2c%22MISPAR_BAIT%22%3a%22%22%2c%22MISPAR_CELLULARI'+
            '%22%3anull%2c%22MISPAR_DIRA%22%3anull%2c%22MISPAR_FAX%22%3anull%2c%22MISPAR_KNISA%22%3anull%2c%22MISPAR_SHLUCHA%22%3anull%2c%22MISPAR_TELEPHONE_KAVI%22%3a%22'+
            '%22%2c%22MISPAR_YELADIM%22%3a%2200%22%2c%22MISPAR_ZIHUY_LAKOACH%22%3a%22066033515%22%2c%22PTIRA%22%3anull%2c%22SEMEL_YESHUV%22%3anull%2c%22SHEM_MISHPACHA%22%3a'+
            '%22%d7%a4%d7%a0%d7%97%d7%a1+%d7%a9%d7%a8%d7%95%d7%9f%22%2c%22SHEM_MISHPACHA_KODEM%22%3anull%2c%22SHEM_PRATI%22%3a%22%22%2c%22SHEM_RECHOV%22%3a%22%d7%94%d7%99%d7'+
            '%a8%d7%a9%d7%a4%d7%9c%d7%93%22%2c%22SHEM_YISHUV%22%3a%22%d7%a8%d7%90%d7%a9%d7%95%d7%9f+%d7%9c%d7%a6%d7%99%d7%95%d7%9f%22%2c%22SUG_MEZAHE_LAKOACH%22%3a%221%22%2c'+
            '%22TA_DOAR%22%3anull%2c%22TAARICH_LEYDA%22%3a%222082-08-05%22%7d+';
            pt.Policy_Content__c = s;           
            insert pt;
            List<Policy_Transaction__c> lsPolicyTransAction = new List<Policy_Transaction__c>();
            lsPolicyTransAction.add(pt);
            PolicyTransactionHandler.reMatch(lsPolicyTransAction);
            update pt;
            delete pt;              
         }
         
    
         @isTest(SeeAllData=true)
         static void testMergeTransaction() {
            string carrierId='';
            List<Account> listAccount = [select Id from Account where Carrier_File_Code__c = '10010' ];
            Account acc;
            if(listAccount.isEmpty()){          
                acc= new Account(Name = 'test Acc' , Carrier_File_Code__c = '10010' , recordTypeId=[select Id from RecordType where developername ='carrier' and sobjecttype='account'][0].id);
                insert acc;
            }
            else{
                acc = listAccount[0];
            }
            Novidea_HPC__Policy__c pol =  new Novidea_HPC__Policy__c();
            pol.Novidea_HPC__Policy_Number__c ='12013100025100';
            insert pol;
            string sDate = string.valueOf(date.today());
            mergeTransactionCO mergeTrans = new mergeTransactionCO();
            carrierId = acc.Id;
             Novidea_HPC__Product_Def__c proddef = new Novidea_HPC__Product_Def__c(name= 'test prod');
             insert proddef;
             String carrProd = '521';
             Novidea_HPC__Carrier_Product__c cp = 
                    new Novidea_HPC__Carrier_Product__c(name = carrProd + ' in ' + acc.name, 
                                                    Novidea_HPC__Account__c = acc.id, 
                                                    Novidea_HPC__Product_Definition__c = proddef.id,
                                                    Novidea_HPC__Product_In_Carrier_Name__c = carrProd); 
             insert cp;
            string BrokerId;
            List<Novidea_HPC__Broker_Number__c>  lsBrokerNumber = [select Id from Novidea_HPC__Broker_Number__c where Novidea_HPC__Broker_Number_In_Carrier__c ='000030261' ];
            if(lsBrokerNumber.isEmpty()){
                Novidea_HPC__Broker_Number__c bn = new Novidea_HPC__Broker_Number__c();         
                insert bn;
                BrokerId =bn.Id;
            }
            else {
                BrokerId = lsBrokerNumber[0].Id;                
            } 
            
            Account customeraccount = new Account(name='customer account', Novidea_HPC__Tax_Id__c ='534210987', recordTypeId=[select Id from RecordType where developername ='Business' and sobjecttype='account'][0].id);           
            
            Policy_Transaction__c pt = new Policy_Transaction__c();
            pt.Name ='test';  
            pt.Carrier_File_Code__c =  '10010';                             
            string s ='%7b%22Bordero_Month%22%3a%222011-12-01%22%2c%22Calculation_Code%22%3a%2201%22%2c%22controlDigit%22%3anull%2c%22CurrencyCode%22%3a%2200%22%2c%22Endorsment_No%22%3a%2200%22%2c%22'+
            'Expiration_Date%22%3a%222012-12-31%22%2c%22HUTAL_IKUL%22%3anull%2c%22HUTAL_SHIABUD%22%3anull%2c%22Indexing_Type%22%3a%2201%22%2c%22KAYAM_CHOV_O_PIGUR%22%3anull%2c%22MASLUL_BITUACH_BAKEREN_PENSIA%22'+
            '%3anull%2c%22MISPAR_POLISA_O_HESHBON%22%3a%22115211523500%22%2c%22MPR_MEFITZ_BE_YATZRAN%22%3a%22000014737%22%2c%22NetuneiGvia%22%3a%7b%22ACHUZ_TAT_SHNATIYOT%22%3anull%2c%22CHODESH_YECHUS%22%3anull%2'+
            'c%22DetailedPremiumAndFees%22%3a%5b%7b%22Amount%22%3a%2200000001426.64%22%2c%22AmountCode%22%3a%2201%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22%2c%22AmountCode%22%3a%22'+
            '04%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000000014.42%22%2c%22AmountCode%22%3a%2205%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000000155.58%22%2c%22AmountCode%22'+
            '%3a%2206%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000000231.13%22%2c%22AmountCode%22%3a%2207%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22%2c%22'+
            'AmountCode%22%3a%2209%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000001828.80%22%2c%22AmountCode%22%3a%2215%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%22%22%2c%22'+
            'AmountCode%22%3a%22%22%2c%22AmountSign%22%3a%22%22%7d%2c%7b%22Amount%22%3a%22%22%2c%22AmountCode%22%3a%22%22%2c%22AmountSign%22%3a%22%22%7d%2c%7b%22Amount%22%3a%22%22%2c%22AmountCode%22%3a%22%22'+
            '%2c%22AmountSign%22%3anull%7d%5d%2c%22KOD_EMTZAEI_TASHLUM%22%3anull%2c%22MISPAR_ZIHUY_MESHALEM%22%3anull%2c%22OFEN_HATZMADAT_GVIA%22%3a%2202%22%2c%22PandCCoverages%22%3anull%2c%22SHEM_MESHALEM%22'+
            '%3anull%2c%22SUG_TEUDA_MESHALEM%22%3anull%2c%22TADIRUT_TASHLUM%22%3a%2205%22%2c%22YOM_GVIYA_BECHODESH%22%3a%22%22%7d%2c%22PENSIA_VATIKA_O_HADASHA%22%3anull%2c%22policyBranch%22%3anull%2c%22'+
            'policyYear%22%3anull%2c%22product%22%3a%22521%22%2c%22runningNumber%22%3anull%2c%22Send_Message_Code%22%3a%2201%22%2c%22SHEM_MASLUL_HABITUAH%22%3anull%2c%22STATUS_POLISA_O_CHESHBON%22%3anull%2'+
            'c%22SUG_KEREN_PENSIA%22%3anull%2c%22SUG_MUTZAR_PENSIONI%22%3anull%2c%22SUG_POLISA%22%3anull%2c%22SUG_TOCHNIT_O_CHESHBON%22%3anull%2c%22TAARICH_HITZTARFUT_MUTZAR%22%3a%222011-12-21%22%2c%22'+
            'vehicleDetail%22%3anull%2c%22YESH_HALVAA_BAMUTZAR%22%3anull%2c%22YESH_TVIA%22%3anull%2c%22YeshutLakoach%22%3a%7b%22E_MAIL%22%3anull%2c%22ERETZ%22%3anull%2c%22HEAROT%22%3anull%2c%22MATZAV_MISHPACHTI%22'+
            '%3a%2210%22%2c%22MIKUD%22%3a%2275244%22%2c%22MIN%22%3a%221%22%2c%22MISPAR_BAIT%22%3a%22%22%2c%22MISPAR_CELLULARI%22%3anull%2c%22MISPAR_DIRA%22%3anull%2c%22MISPAR_FAX%22%3anull%2c%22MISPAR_KNISA%22'+
            '%3anull%2c%22MISPAR_SHLUCHA%22%3anull%2c%22MISPAR_TELEPHONE_KAVI%22%3a%22%22%2c%22MISPAR_YELADIM%22%3a%2200%22%2c%22MISPAR_ZIHUY_LAKOACH%22%3a%22066033515%22%2c%22PTIRA%22%3anull%2c%22SEMEL_YESHUV%22'+
            '%3anull%2c%22SHEM_MISHPACHA%22%3a%22%d7%a4%d7%a0%d7%97%d7%a1+%d7%a9%d7%a8%d7%95%d7%9f%22%2c%22SHEM_MISHPACHA_KODEM%22%3anull%2c%22SHEM_PRATI%22%3a%22%22%2c%22SHEM_RECHOV%22%3a%22%d7%94%d7%99%d7%a8%d7'+
            '%a9%d7%a4%d7%9c%d7%93%22%2c%22SHEM_YISHUV%22%3a%22%d7%a8%d7%90%d7%a9%d7%95%d7%9f+%d7%9c%d7%a6%d7%99%d7%95%d7%9f%22%2c%22SUG_MEZAHE_LAKOACH%22%3a%221%22%2c%22TA_DOAR%22%3anull%2c%22TAARICH_LEYDA%22%3'+
            'a%222082-08-05%22%7d+';
            pt.Policy_Content__c = s;           
            insert pt;
            mergeTransactionCO.doRemoteSearch(BrokerId, carrierId, carrierId, pt.Id, '01/01/2000', '01/01/2000', 'test,test2', 'test3', '');   
            
            Policy_Transaction__c pt1 = new Policy_Transaction__c();
            pt1.Address__c='adress';
            pt1.Agent_number_from_Insurance_comapny__c='000030261';
            pt1.Comments_Agent_number__c ='Comments_Agent_number__c';
            pt1.comments_customer_account__c ='comments_customer_account__c';
            pt1.comments_for_Account__c ='comments_for_Account__c';
            pt1.Comments_Insurance_Company__c ='Comments_Insurance_Company__c';
            pt1.Comments_Policy__c = 'Comments_Policy__c';
            pt1.endorsement_number__c ='00';
            pt1.file_name__c ='fileName';
            pt1.Carrier_File_Code__c ='10010';
            pt1.Insured_number__c ='Insured_number__c';
            pt1.Insured_Type__c ='1';
            pt1.Insured_number__c ='22';
            pt1.vehicle_number__c ='123';
            pt1.Production_Date__c = date.today();
            pt1.product_from_insurance_company__c ='013';
            pt1.Policy_number_from_Insurance_company__c ='12013100025100';
            pt1.Customer_Account__c =   customeraccount.Id;          
            pt1.Carrier__c = carrierId;
            pt1.Broker_Number__c = BrokerId;
            pt.Policy__c = pol.Id;
            system.debug(LoggingLevel.ERROR, 'pt.Carrier__c2: ' + pt.Carrier__c);
            insert pt1 ;
           
            mergeTransactionCO.WrappedPolicyTransaction wpt1 = new mergeTransactionCO.WrappedPolicyTransaction(pt1);
            mergeTransactionCO.syncRowTransaction('1', pt1.Id);
            string rowArr = '[{"rownum":"0","sfid":"' + pt1.Id +'"}]';
            mergeTransactionCO.syncRowTransactions(rowArr);
            string s1 ='%7b%22Bordero_Month%22%3a%222011-12-01%22%2c%22Calculation_Code%22%3a%2201%22%2c%22controlDigit%22%3anull%2c%22CurrencyCode%22%3a%2200%22%2c%22Endorsment_No%22%3a%2200%22%2c%22'+
            'Expiration_Date%22%3a%222012-12-31%22%2c%22HUTAL_IKUL%22%3anull%2c%22HUTAL_SHIABUD%22%3anull%2c%22Indexing_Type%22%3a%2201%22%2c%22KAYAM_CHOV_O_PIGUR%22%3anull%2c%22MASLUL_BITUACH_BAKEREN_PENSIA%22'+
            '%3anull%2c%22MISPAR_POLISA_O_HESHBON%22%3a%22115211523500%22%2c%22MPR_MEFITZ_BE_YATZRAN%22%3a%22000014737%22%2c%22NetuneiGvia%22%3a%7b%22ACHUZ_TAT_SHNATIYOT%22%3anull%2c%22CHODESH_YECHUS%22'+
            '%3anull%2c%22DetailedPremiumAndFees%22%3a%5b%7b%22Amount%22%3a%2200000001426.64%22%2c%22AmountCode%22%3a%2201%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22%2c%22'+
            'AmountCode%22%3a%2204%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000000014.42%22%2c%22AmountCode%22%3a%2205%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000000155.58%22'+
            '%2c%22AmountCode%22%3a%2206%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000000231.13%22%2c%22AmountCode%22%3a%2207%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22'+
            '%3a%2200000000000.00%22%2c%22AmountCode%22%3a%2209%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000001828.80%22%2c%22AmountCode%22%3a%2215%22%2c%22AmountSign%22%3a%220%22'+
            '%7d%2c%7b%22Amount%22%3a%22%22%2c%22AmountCode%22%3a%22%22%2c%22AmountSign%22%3a%22%22%7d%2c%7b%22Amount%22%3a%22%22%2c%22AmountCode%22%3a%22%22%2c%22AmountSign%22%3a%22%22%7d%2c%7b%22Amount%22'+
            '%3a%22%22%2c%22AmountCode%22%3a%22%22%2c%22AmountSign%22%3anull%7d%5d%2c%22KOD_EMTZAEI_TASHLUM%22%3anull%2c%22MISPAR_ZIHUY_MESHALEM%22%3anull%2c%22OFEN_HATZMADAT_GVIA%22%3a%2202%22%2c%22'+
            'PandCCoverages%22%3anull%2c%22SHEM_MESHALEM%22%3anull%2c%22SUG_TEUDA_MESHALEM%22%3anull%2c%22TADIRUT_TASHLUM%22%3a%2205%22%2c%22YOM_GVIYA_BECHODESH%22%3a%22%22%7d%2c%22PENSIA_VATIKA_O_HADASHA%22'+
            '%3anull%2c%22policyBranch%22%3anull%2c%22policyYear%22%3anull%2c%22product%22%3a%22521%22%2c%22runningNumber%22%3anull%2c%22Send_Message_Code%22%3a%2201%22%2c%22SHEM_MASLUL_HABITUAH%22'+
            '%3anull%2c%22STATUS_POLISA_O_CHESHBON%22%3anull%2c%22SUG_KEREN_PENSIA%22%3anull%2c%22SUG_MUTZAR_PENSIONI%22%3anull%2c%22SUG_POLISA%22%3anull%2c%22SUG_TOCHNIT_O_CHESHBON%22%3anull%2c%22'+
            'TAARICH_HITZTARFUT_MUTZAR%22%3a%222011-12-21%22%2c%22vehicleDetail%22%3anull%2c%22YESH_HALVAA_BAMUTZAR%22%3anull%2c%22YESH_TVIA%22%3anull%2c%22YeshutLakoach%22%3a%7b%22E_MAIL%22%3anull%2'+
            'c%22ERETZ%22%3anull%2c%22HEAROT%22%3anull%2c%22MATZAV_MISHPACHTI%22%3a%2210%22%2c%22MIKUD%22%3a%2275244%22%2c%22MIN%22%3a%221%22%2c%22MISPAR_BAIT%22%3a%22%22%2c%22MISPAR_CELLULARI%22'+
            '%3anull%2c%22MISPAR_DIRA%22%3anull%2c%22MISPAR_FAX%22%3anull%2c%22MISPAR_KNISA%22%3anull%2c%22MISPAR_SHLUCHA%22%3anull%2c%22MISPAR_TELEPHONE_KAVI%22%3a%22%22%2c%22MISPAR_YELADIM%22%3a%22'+
            '00%22%2c%22MISPAR_ZIHUY_LAKOACH%22%3a%22066033515%22%2c%22PTIRA%22%3anull%2c%22SEMEL_YESHUV%22%3anull%2c%22SHEM_MISHPACHA%22%3a%22%d7%a4%d7%a0%d7%97%d7%a1+%d7%a9%d7%a8%d7%95%d7%9f%22%2c%22'+
            'SHEM_MISHPACHA_KODEM%22%3anull%2c%22SHEM_PRATI%22%3a%22%22%2c%22SHEM_RECHOV%22%3a%22%d7%94%d7%99%d7%a8%d7%a9%d7%a4%d7%9c%d7%93%22%2c%22SHEM_YISHUV%22%3a%22%d7%a8%d7%90%d7%a9%d7%95%d7%9f+%d7%9c%d7%a6%d7'+
            '%99%d7%95%d7%9f%22%2c%22SUG_MEZAHE_LAKOACH%22%3a%221%22%2c%22TA_DOAR%22%3anull%2c%22TAARICH_LEYDA%22%3a%222082-08-05%22%7d+';
            pt1.Policy_Content__c = s1;
            pt1.Status__c='compatible';
            pt1.Policy__c = pol.Id;
            Contact cnt = new Contact();
            cnt.LastName ='lastName';
            insert cnt ;
            pt1.Client__c = cnt.Id;
            pt1.Carrier_File_Code__c =  '10010';                             
            update pt1;
            mergeTransactionCO.updateRowTransactions(rowArr);
            mergeTransactionCO.createPolicyInDB(pt.Id, pt.Id);
            mergeTransactionCO.deletePolicyTransaction(pt.Id, pt.Id);
            
         }
         
                 
         
         @isTest(SeeAllData=true)
         static void testWSYigod() {
            Novidea_HPC__Trigger__c triggerSetting  = Novidea_HPC__Trigger__c.getInstance(); 
            triggerSetting.Novidea_HPC__Prevent_Running__c = true;
            
            WSYigod.HeshbonOPolisa hob = new WSYigod.HeshbonOPolisa();
            hob.Bordero_Month = date.today();
            hob.Calculation_Code = ' Calculation_Code ';
            hob.controlDigit = ' controlDigit ';
            hob.CurrencyCode = ' CurrencyCode ';
            hob.CurrencyCode = ' CurrencyCode';
            hob.Endorsment_No = ' Endorsment_No';
            hob.Expiration_Date = date.today();
            hob.HUTAL_IKUL ='HUTAL_IKUL';
            hob.HUTAL_SHIABUD='HUTAL_SHIABUD';
            hob.Indexing_Type='Indexing_Type';
            hob.KAYAM_CHOV_O_PIGUR='KAYAM_CHOV_O_PIGUR';                
            hob.HUTAL_IKUL = '1';
            hob.HUTAL_SHIABUD ='1';
            hob.MASLUL_BITUACH_BAKEREN_PENSIA ='999';
            hob.MISPAR_POLISA_O_HESHBON ='999';
            hob.MPR_MEFITZ_BE_YATZRAN ='9876';
            hob.PENSIA_VATIKA_O_HADASHA ='1';
            hob.SHEM_MASLUL_HABITUAH ='1';
            hob.STATUS_POLISA_O_CHESHBON ='1';
            hob.SUG_KEREN_PENSIA ='1';
            hob.SUG_MUTZAR_PENSIONI='1';
            hob.SUG_POLISA ='1';
            hob.SUG_TOCHNIT_O_CHESHBON ='1' ;
            hob.TAARICH_HITZTARFUT_MUTZAR =date.valueOf(Datetime.now());
            hob.TAARICH_HITZTARFUT_RISHON = date.valueOf(Datetime.now());
            hob.TAARICH_IDKUN_STATUS = date.valueOf(Datetime.now());
            hob.TAARICH_NECHONUT = date.valueOf(Datetime.now());
            hob.YESH_HALVAA_BAMUTZAR = '1' ;
            hob.YESH_TVIA ='1' ;
            
            
            //start YeshutLakoach
            hob.YeshutLakoach = new WSYigod.YeshutLakoach();
            hob.YeshutLakoach.E_MAIL = 'mimsak@dudu.com';
            hob.YeshutLakoach.ERETZ ='1';
            hob.YeshutLakoach.HEAROT = '1';
            hob.YeshutLakoach.MATZAV_MISHPACHTI = '1';
            hob.YeshutLakoach.MIKUD = '1';
            hob.YeshutLakoach.MIN = '1';
            hob.YeshutLakoach.MISPAR_BAIT = '1';
            hob.YeshutLakoach.MISPAR_CELLULARI = '1';
            hob.YeshutLakoach.MISPAR_DIRA = '1';
            hob.YeshutLakoach.MISPAR_FAX = '1';
            hob.YeshutLakoach.MISPAR_KNISA = '1';
            hob.YeshutLakoach.MISPAR_SHLUCHA = '1';
            hob.YeshutLakoach.MISPAR_TELEPHONE_KAVI = '1';
            hob.YeshutLakoach.MISPAR_YELADIM = '1';
            hob.YeshutLakoach.MISPAR_ZIHUY_LAKOACH = '1';
            hob.YeshutLakoach.PTIRA = '1';
            hob.YeshutLakoach.SEMEL_YESHUV = '1';
            hob.YeshutLakoach.SHEM_MISHPACHA = '1';
            hob.YeshutLakoach.SHEM_MISHPACHA_KODEM = '1';

            hob.YeshutLakoach.SHEM_PRATI = '1';
            hob.YeshutLakoach.SHEM_RECHOV = '1';
            hob.YeshutLakoach.SHEM_YISHUV = '1';
            hob.YeshutLakoach.SUG_MEZAHE_LAKOACH = '1';
            hob.YeshutLakoach.TA_DOAR = '1';
            hob.YeshutLakoach.TAARICH_LEYDA =date.valueOf(Datetime.now());
            hob.YeshutLakoach.TAARICH_PTIRA = date.valueOf(Datetime.now());
            hob.vehicleDetail = new  WSYigod.vehicleDetail[1];
            
            //start vehicleDetail
            WSYigod.vehicleDetail vehicle = new WSYigod.vehicleDetail();
            vehicle.vehicle_number='3445';
            hob.vehicleDetail[0]=vehicle;
            
            hob.NetuneiGvia = new WSYigod.NetuneiGvia();
            //stat NetuneiGvia
            hob.NetuneiGvia.ACHUZ_TAT_SHNATIYOT ='1' ;
            hob.NetuneiGvia.CHODESH_YECHUS = '2';
            hob.NetuneiGvia.KOD_EMTZAEI_TASHLUM = '1';
            hob.NetuneiGvia.MISPAR_ZIHUY_MESHALEM ='3' ;
            hob.NetuneiGvia.OFEN_HATZMADAT_GVIA ='4' ;
            hob.NetuneiGvia.SHEM_MESHALEM = '5';
            hob.NetuneiGvia.SUG_TEUDA_MESHALEM = '1';
            hob.NetuneiGvia.TADIRUT_TASHLUM = '1' ;
            hob.NetuneiGvia.YOM_GVIYA_BECHODESH ='2';
            //start DetailedPremiumAndFees
            hob.NetuneiGvia.DetailedPremiumAndFees = new WSYigod.DetailedPremiumAndFees[1];
            WSYigod.DetailedPremiumAndFees dpa = new WSYigod.DetailedPremiumAndFees();
            dpa.Amount = '1';
            dpa.AmountCode ='1';
            dpa.AmountSign ='1';
            hob.NetuneiGvia.DetailedPremiumAndFees[0] =dpa;
            // start PandCCoverages
            hob.NetuneiGvia.PandCCoverages = new WSYigod.PandCCoverages[1];
            WSYigod.PandCCoverages pac = new WSYigod.PandCCoverages();
            pac.AnnualPremium ='';
            pac.InsuredAmount =' ';
            pac.PremiumPayment = ' ';
            pac.PremiumPayment =' ';
            pac.Rate ='1';
            pac.Section =' ';
            pac.SectionType =' ';
            pac.Sub_Section =' ';
            pac.Sub_Section = ' ';
            pac.Sub_Section =' ';
            pac.Type =' ';
            hob.NetuneiGvia.PandCCoverages[0] = pac;
            WSYigod.UpsertData(hob);
                           
         }

          
          @isTest(SeeAllData=true)
          static void testShlomoSixst() {
            
            string carrierId='';
             List<Account> listAccount = [select Id from Account where Carrier_File_Code__c = '105' ];
            if (listAccount.size() == 0 ){          
                Account acc= new Account(Name = 'test Acc' , Carrier_File_Code__c = '105' );
                insert acc;
                carrierId =acc.Id;
            }
            else{
                carrierId = listAccount[0].Id;
            }
            Novidea_HPC__Policy__c pol =  new Novidea_HPC__Policy__c();
            pol.Novidea_HPC__Policy_Number__c ='12013100025100';
            pol.Novidea_HPC__Endorsement_Number__c=0;
            insert pol;
            string sDate = string.valueOf(date.today());
            mergeTransactionCO mergeTrans = new mergeTransactionCO();
            
            string BrokerId;
            List<Novidea_HPC__Broker_Number__c>  lsBrokerNumber = [select Id from Novidea_HPC__Broker_Number__c where Novidea_HPC__Broker_Number_In_Carrier__c ='303280' ];
            if ( lsBrokerNumber.size()== 0 ){
                Novidea_HPC__Broker_Number__c bn = new Novidea_HPC__Broker_Number__c();         
                insert bn;
                BrokerId =bn.Id;
            }else {
                BrokerId = lsBrokerNumber[0].Id;                
            }            
            
            Policy_Transaction__c pt = new Policy_Transaction__c();
            pt.Name ='test';                                
            string s ='%7b%22action%22%3a%22New%22%2c%22Bordero_Month%22%3a%222012-02-01%22%2c%22Calculation_Code%22%3a%2201%22%2c%22controlDigit%22%3anull' +
                     '%2c%22CurrencyCode%22%3a%2212%22%2c%22Endorsment_No%22%3a%2200%22%2c%22endorsmentEffectiveDate%22%3a%222012-02-01%22%2c%22endorsment' +
                     'ExpirationDate%22%3a%222013-01-31%22%2c%22Expiration_Date%22%3a%222013-01-31%22%2c%22HUTAL_IKUL%22%3anull%2c%22HUTAL_SHIABUD%22%3anull%2c%22' +
                     'Indexing_Type%22%3anull%2c%22KAYAM_CHOV_O_PIGUR%22%3anull%2c%22MASLUL_BITUACH_BAKEREN_PENSIA%22%3anull%2c%22MISPAR_POLISA_O_HESHBON%22%3a%2211' +
                     '0086963612%22%2c%22MPR_MEFITZ_BE_YATZRAN%22%3a%22000303280%22%2c%22NetuneiGvia%22%3a%7b%22ACHUZ_TAT_SHNATIYOT%22%3anull%2c%22CHODESH_YECHUS%22%3a' +
                     'null%2c%22Commission%22%3a%5b%7b%22commissionAmountAgentA%22%3a%220000641.00%22%2c%22commissionAmountAgentB%22%3a%220000000.00%22%2c%22contractNo%22' +
                     '%3a%2201%22%2c%22discountAmount%22%3a%220000000.00%22%2c%22discountPercentage%22%3a%2200.000%22%2c%22discountSign%22%3a%220%22%2c%22InsuredAmount%22%' +
                     '3a%2200000006310.26%22%2c%22netPremium%22%3a%2200000002466.00%22%2c%22percentCommissionAgentA%22%3a%2200.000%22%2c%22percentCommissionAgentB%22%3a%2200.000%22' +
                     '%2c%22signCommissionAmountAgentA%22%3a%220%22%2c%22signCommissionAmountAgentB%22%3a%220%22%2c%22signNetPremium%22%3a%220%22%2c%22underWriterFee%22%3a%2200.000%' +
                     '22%7d%2c%7b%22commissionAmountAgentA%22%3a%220000000.00%22%2c%22commissionAmountAgentB%22%3a%220000000.00%22%2c%22contractNo%22%3a%2215%22%2c%22discountAmount%22'+
                     '%3a%220000000.00%22%2c%22discountPercentage%22%3a%2200.000%22%2c%22discountSign%22%3a%220%22%2c%22InsuredAmount%22%3a%2200000000000.00%22%2c%22netPremium%22%3a%22'+
                     '00000000000.00%22%2c%22percentCommissionAgentA%22%3a%2200.000%22%2c%22percentCommissionAgentB%22%3a%2200.000%22%2c%22signCommissionAmountAgentA%22%3a%220%22%2c%22'+
                     'signCommissionAmountAgentB%22%3a%220%22%2c%22signNetPremium%22%3a%220%22%2c%22underWriterFee%22%3a%2200.000%22%7d%5d%2c%22DetailedPremiumAndFees%22%3a%5b%7b%22'+
                     'Amount%22%3a%2200000002466.00%22%2c%22AmountCode%22%3a%2201%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000000536.00%22'+
                     '%2c%22AmountCode%22%3a%2204%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22%2c%22AmountCode%22%3a%2205%22%2c'+
                     '%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22%2c%22AmountCode%22%3a%2206%22%2c%22AmountSign%22%3a%220%22%2c%22'+
                     'recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000000536.00%22%2c%22AmountCode%22%3a%2207%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22'+
                     'Amount%22%3a%2200000000078.00%22%2c%22AmountCode%22%3a%2209%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%2200000003616.00%22%2c%22'+
                     'AmountCode%22%3a%2215%22%2c%22AmountSign%22%3a%220%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%22%22%2c%22AmountCode%22%3a%22%22%2c%22AmountSign%22%3a%22'+
                     '%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22%3a%22%22%2c%22AmountCode%22%3a%22%22%2c%22AmountSign%22%3a%22%22%2c%22recordType%22%3a%2230%22%7d%2c%7b%22Amount%22'+
                     '%3a%22%22%2c%22AmountCode%22%3a%22%22%2c%22AmountSign%22%3anull%2c%22recordType%22%3a%2230%22%7d%5d%2c%22KOD_EMTZAEI_TASHLUM%22%3anull%2c%22MISPAR_ZIHUY_MESHALEM%22%3'+
                     'anull%2c%22OFEN_HATZMADAT_GVIA%22%3a%2201%22%2c%22PandCCoverages%22%3anull%2c%22SHEM_MESHALEM%22%3anull%2c%22SUG_TEUDA_MESHALEM%22%3anull%2c%22TADIRUT_TASHLUM%22%3a%2201%22%2c%22YOM_GVIYA_BECHODESH%22'+
                     '%3a%22%22%7d%2c%22PENSIA_VATIKA_O_HADASHA%22%3anull%2c%22policyBranch%22%3anull%2c%22policyYear%22%3anull%2c%22product%22%3a%22120%22%2c%22runningNumber%22%3a%226963612%22%2c%22'+
                     'Send_Message_Code%22%3a%2201%22%2c%22SHEM_MASLUL_HABITUAH%22%3anull%2c%22STATUS_POLISA_O_CHESHBON%22%3anull%2c%22subProduct%22%3anull%2c%22SUG_KEREN_PENSIA%22%3anull%2c%'+
                     '22SUG_MUTZAR_PENSIONI%22%3anull%2c%22SUG_POLISA%22%3anull%2c%22SUG_TOCHNIT_O_CHESHBON%22%3anull%2c%22TAARICH_HITZTARFUT_MUTZAR%22%3a%222012-02-01%22%2c%22vehicleDetail%22%3a%'+
                     '5b%7b%22vehicle_number%22%3a%224133175%22%7d%5d%2c%22YESH_HALVAA_BAMUTZAR%22%3anull%2c%22YESH_TVIA%22%3anull%2c%22YeshutLakoach%22%3a%7b%22E_MAIL%22%3anull%2c%22ERETZ%22%3anull%2c' +
                     '%22fullAddress%22%3anull%2c%22fullName%22%3a%22%d7%a2%d7%99%d7%a1%d7%90+%d7%a0%d7%99%d7%93%d7%90%d7%9c%22%2c%22HEAROT%22%3anull%2c%22MATZAV_MISHPACHTI%22%3a%22%22%2c%22MIKUD%22%3a%22' +
                     '48810%22%2c%22MIN%22%3a%22%22%2c%22MISPAR_BAIT%22%3a%22%22%2c%22MISPAR_CELLULARI%22%3anull%2c%22MISPAR_DIRA%22%3anull%2c%22MISPAR_FAX%22%3anull%2c%22MISPAR_KNISA%22%3anull%2c%22'+
                     'MISPAR_SHLUCHA%22%3anull%2c%22MISPAR_TELEPHONE_KAVI%22%3a%22%22%2c%22MISPAR_YELADIM%22%3a%22%22%2c%22MISPAR_ZIHUY_LAKOACH%22%3a%22028376861%22%2c%22PTIRA%22%3anull%2c%22' +
                     'SEMEL_YESHUV%22%3anull%2c%22SHEM_MISHPACHA%22%3a%22%d7%a2%d7%99%d7%a1%d7%90+%d7%a0%d7%99%d7%93%d7%90%d7%9c%22%2c%22SHEM_MISHPACHA_KODEM%22%3anull%2c%22SHEM_PRATI%22%3a%22%22%2c%22' +
                     'SHEM_RECHOV%22%3a%22%22%2c%22SHEM_YISHUV%22%3a%22%d7%9b%d7%a4%d7%a8+%d7%a7%d7%90%d7%a1%d7%9d%22%2c%22SpouseBirthDate%22%3a%221900-01-01%22%2c%22SpouseFirstName%22%3a%22' +
                     '%22%2c%22SpouseSSN%22%3a%22%22%2c%22SUG_MEZAHE_LAKOACH%22%3a%221%22%2c%22TA_DOAR%22%3anull%2c%22TAARICH_LEYDA%22%3a%221900-01-01%22%7d+';
            pt.Policy_Content__c = s;
            pt.Carrier_File_Code__c = '105';           
            insert pt;
            mergeTransactionCO.doRemoteSearch(BrokerId, carrierId, carrierId, pt.Id, '01/01/2000', '01/01/2000', 'test,test2', 'test3','');   
            Policy_Transaction__c pt1 = new Policy_Transaction__c();
            pt1.Address__c='adress';
            pt1.Agent_number_from_Insurance_comapny__c='000030261';
            pt1.Comments_Agent_number__c ='Comments_Agent_number__c';
            pt1.comments_customer_account__c ='comments_customer_account__c';
            pt1.comments_for_Account__c ='comments_for_Account__c';
            pt1.Comments_Insurance_Company__c ='Comments_Insurance_Company__c';
            pt1.Comments_Policy__c = 'Comments_Policy__c';
            pt1.endorsement_number__c ='00';
            pt1.file_name__c ='fileName';
            pt1.Carrier_File_Code__c ='10010';
            pt1.Insured_number__c ='Insured_number__c';
            pt1.Insured_Type__c ='1';
            pt1.Insured_number__c ='22';
            pt1.vehicle_number__c ='123';
            pt1.Production_Date__c = date.today();
            pt1.product_from_insurance_company__c ='013';
            pt1.Policy_number_from_Insurance_company__c ='12013100025100';
            pt1.Customer_Account__c =   carrierId;          
            pt1.Carrier__c = carrierId;
            pt1.Broker_Number__c = BrokerId;
            pt.Policy__c = pol.Id;
            insert pt1 ;
            mergeTransactionCO.WrappedPolicyTransaction wpt1 = new mergeTransactionCO.WrappedPolicyTransaction(pt1);
            mergeTransactionCO.syncRowTransaction('1', pt1.Id);
            string rowArr = '[{"rownum":"0","sfid":"' + pt1.Id +'"}]';
            mergeTransactionCO.syncRowTransactions(rowArr);
            string s1 ='%7b%22Bordero_Month%22%3a%222011-12-01%22%2c%22Calculation_Code%22%3a%2201%22%2c%22controlDigit%22%3anull'+
                        '%2c%22CurrencyCode%22%3a%2200%22%2c%22Endorsment_No%22%3a%2200%22%2c%22Expiration_Date%22%3a%222012-12-31%22%2c%22HUTAL_IKUL' +
                        '%22%3anull%2c%22HUTAL_SHIABUD%22%3anull%2c%22Indexing_Type%22%3a%2201%22%2c%22KAYAM_CHOV_O_PIGUR%22%3anull%2c%22MASLUL_BITUACH_BAKEREN_PENSIA%22%' +
                        '3anull%2c%22MISPAR_POLISA_O_HESHBON%22%3a%22115211523500%22%2c%22MPR_MEFITZ_BE_YATZRAN%22%3a%22000014737%22%2c%22NetuneiGvia%22%3a%7b%22' +
                        'ACHUZ_TAT_SHNATIYOT%22%3anull%2c%22CHODESH_YECHUS%22%3anull%2c%22DetailedPremiumAndFees%22%3a%5b%7b%22Amount%22%3a%2200000001426.64%22%2c%22Amount'+
                        'Code%22%3a%2201%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000000000.00%22%2c%22AmountCode%22%3a%2204%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b' +
                        '%22Amount%22%3a%2200000000014.42%22%2c%22AmountCode%22%3a%2205%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000000155.58%22%2c%22AmountCode%22%3a%2206' +
                        '%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000000231.13%22%2c%22AmountCode%22%3a%2207%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22' +
                        'Amount%22%3a%2200000000000.00%22%2c%22AmountCode%22%3a%2209%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%2200000001828.80%22%2c%22AmountCode%' +
                        '22%3a%2215%22%2c%22AmountSign%22%3a%220%22%7d%2c%7b%22Amount%22%3a%22%22%2c%22AmountCode%22%3a%22%22%2c%22AmountSign%22%3a%22%22%7d%2c%7b%22Amount%22%3a%22' +
                        '%22%2c%22AmountCode%22%3a%22%22%2c%22AmountSign%22%3a%22%22%7d%2c%7b%22Amount%22%3a%22%22%2c%22AmountCode%22%3a%22%22%2c%22AmountSign%22%3anull%7d%5d%2c%22' +
                        'KOD_EMTZAEI_TASHLUM%22%3anull%2c%22MISPAR_ZIHUY_MESHALEM%22%3anull%2c%22OFEN_HATZMADAT_GVIA%22%3a%2202%22%2c%22PandCCoverages%22%3anull%2c%22SHEM_MESHALEM%22%'+
                        '3anull%2c%22SUG_TEUDA_MESHALEM%22%3anull%2c%22TADIRUT_TASHLUM%22%3a%2205%22%2c%22YOM_GVIYA_BECHODESH%22%3a%22%22%7d%2c%22PENSIA_VATIKA_O_HADASHA%22%3anull%2c%22' +
                        'policyBranch%22%3anull%2c%22policyYear%22%3anull%2c%22product%22%3a%22521%22%2c%22runningNumber%22%3anull%2c%22Send_Message_Code%22%3a%2201%22%2c%22SHEM_MASLUL_HABITUAH' +
                        '%22%3anull%2c%22STATUS_POLISA_O_CHESHBON%22%3anull%2c%22SUG_KEREN_PENSIA%22%3anull%2c%22SUG_MUTZAR_PENSIONI%22%3anull%2c%22SUG_POLISA%22%3anull%2c%22' +
                        'SUG_TOCHNIT_O_CHESHBON%22%3anull%2c%22TAARICH_HITZTARFUT_MUTZAR%22%3a%222011-12-21%22%2c%22vehicleDetail%22%3anull%2c%22YESH_HALVAA_BAMUTZAR%22%3anull%2c%22'+
                        'YESH_TVIA%22%3anull%2c%22YeshutLakoach%22%3a%7b%22E_MAIL%22%3anull%2c%22ERETZ%22%3anull%2c%22HEAROT%22%3anull%2c%22MATZAV_MISHPACHTI%22%3a%2210%22%2c%22MIKUD%22' +
                        '%3a%2275244%22%2c%22MIN%22%3a%221%22%2c%22MISPAR_BAIT%22%3a%22%22%2c%22MISPAR_CELLULARI%22%3anull%2c%22MISPAR_DIRA%22%3anull%2c%22MISPAR_FAX%22%3anull%2c%22MISPAR_KNISA%' +
                        '22%3anull%2c%22MISPAR_SHLUCHA%22%3anull%2c%22MISPAR_TELEPHONE_KAVI%22%3a%22%22%2c%22MISPAR_YELADIM%22%3a%2200%22%2c%22MISPAR_ZIHUY_LAKOACH%22%3a%22066033515%22%2c%22PTIRA%22' +
                        '%3anull%2c%22SEMEL_YESHUV%22%3anull%2c%22SHEM_MISHPACHA%22%3a%22%d7%a4%d7%a0%d7%97%d7%a1+%d7%a9%d7%a8%d7%95%d7%9f%22%2c%22SHEM_MISHPACHA_KODEM%22%3anull%2c%22SHEM_PRATI%22' +
                        '%3a%22%22%2c%22SHEM_RECHOV%22%3a%22%d7%94%d7%99%d7%a8%d7%a9%d7%a4%d7%9c%d7%93%22%2c%22SHEM_YISHUV%22%3a%22%d7%a8%d7%90%d7%a9%d7%95%d7%9f+%d7%9c%d7%a6%d7%99%d7%95%d7%9f%22' +
                        '%2c%22SUG_MEZAHE_LAKOACH%22%3a%221%22%2c%22TA_DOAR%22%3anull%2c%22TAARICH_LEYDA%22%3a%222082-08-05%22%7d+';
            pt1.Policy_Content__c = s1;
            pt1.Status__c='compatible';
            pt1.Policy__c = pol.Id;
            Contact cnt = new Contact();
            cnt.LastName ='lastName';
            insert cnt ;
            pt1.Client__c = cnt.Id;
            update pt1;
            mergeTransactionCO.updateRowTransactions(rowArr);
            mergeTransactionCO.createPolicyInDB(pt.Id, pt.Id);
            mergeTransactionCO.deletePolicyTransaction(pt.Id, pt.Id);
          
          }

          @isTest(SeeAllData=true)
          static void testSobject() {
            Novidea_HPC__Trigger__c triggerSetting  = Novidea_HPC__Trigger__c.getInstance(); 
            triggerSetting.Novidea_HPC__Prevent_Running__c = true;
                WSYigod.UpdateObject = true;
                Account acc = new Account(Name ='test Account');
                insert acc;
                update acc;
                delete acc;
                
                Novidea_HPC__Policy__c pol = new Novidea_HPC__Policy__c();
                insert pol;
                update pol;
                delete pol;
                
                Contact con = new Contact();
                con.LastName ='lastName';
                insert con ;
                update con;
                delete con;     
                WSYigod.convertStringToDec('1', '0');  
                WSYigod.convertStringToDec('1', '1');
                WSYigod.Commission comm = new   WSYigod.Commission();
          }
          
          
          static testMethod void testFlatModel() {
            Novidea_HPC__Trigger__c triggerSetting  = Novidea_HPC__Trigger__c.getInstance(); 
            triggerSetting.Novidea_HPC__Prevent_Running__c = true;
            
              FlatModelHelper.getFieldDescription('Account','Name');
              FlatModelHelper.getFieldDataType('Account','Industry');
          }
    */
}