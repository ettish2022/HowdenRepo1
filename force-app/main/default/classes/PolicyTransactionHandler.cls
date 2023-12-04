//TODO: set handling to only one carrier by eliminating the carrier set and changing to single var, or extend to several carrier properly
public with sharing class PolicyTransactionHandler {
       
        //TBD need to change this Vvalues to Tax Id (currently i am using the Id of Howden "atid" DB)
        public static final string FNX ='17';
        public static final string MENORA ='22';
        public static final string CLAL ='18';
        public static final string MIGDAL ='21';
        public static final string SHLOMO = '105';  
        public static final string AYALON = '36';
        public static final string HAKLAI = '6';
        private static final Integer LEN_OF_CLIENT_ID = 9;
        private static General__c generalSetting = General__c.getInstance(); 
        private static final set<Id> matchByNumAndProdCats = getMatchByNumAndProdCatsCsv();
       
        // ביטוח ימי
        public static final Map<String, Set<String>> CargoInsuranceNumbers = new Map<String,Set<String>> { 
            MIGDAL => new Set<String> {'271', '272'}
        };
                
        private static set<Id> getSettingCsv(String fieldName){
            set<Id> retset = new set<Id>();
            if(generalSetting!=null && !String.isBlank((String)generalSetting.get(fieldName))){
                for(Id id : ((String)generalSetting.get(fieldName)).split(',')){
                    retset.add(Id);
                }
            }
            return retset;          
        }
        
        private static set<Id> getMatchByNumAndProdCatsCsv(){
            return getSettingCsv('Match_By_Num_And_Prod_Cats_Csv__c');
        }        
        
        private static set<Id> getVehicleCategories(){
            return getSettingCsv('Vehicle_Production_Merge_Categories_Csv__c');
        }
        
        public static string removeZeroFromStart(string str){
            string newString;
            try{
                newString = str.replaceFirst('^0+(?!$)','');
                return newString;
            }catch(exception e){}
            return str;
        }
        
        public static String leftPadZeros(String str){
            if(null==str)return '';
            String retval = '';
            for(integer toprepend=LEN_OF_CLIENT_ID-str.length(); toprepend>0; toprepend--) {
                retval += '0';
            }
            retval+=str;
            return retval;
        }
        
        
        public static void populateCollectionData(WSYigod.HeshbonOPolisa heshbonOPolisaObj, Policy_Transaction__c policyTransaction){
            decimal fees = 0;
            decimal credit = 0;
            decimal prem = 0;
            policyTransaction.Other_Commissions__c =0 ;
            policyTransaction.Commission_Written_In_Carrier__c = 0 ;
            policyTransaction.Agent_Discount_Written_In_Carrier__c = 0;
            policyTransaction.Premium_neto__c = 0;
            if (heshbonOPolisaObj.NetuneiGvia.DetailedPremiumAndFees != null){
                for (WSYigod.DetailedPremiumAndFees dpaf : heshbonOPolisaObj.NetuneiGvia.DetailedPremiumAndFees){
                    if (dpaf.recordType =='30' ){   
                        if (dpaf.AmountCode =='04' || dpaf.AmountCode =='05' || dpaf.AmountCode =='06' || dpaf.AmountCode =='07' || dpaf.AmountCode =='08' ){
                            fees += WSYigod.convertStringToDec(dpaf.Amount,dpaf.AmountSign);                        
                        }
                        else if(dpaf.AmountCode =='09'){
                            credit += WSYigod.convertStringToDec(dpaf.Amount,dpaf.AmountSign);                  
                        }
                        //bruto premium
                        else if(dpaf.AmountCode =='15'){
                             prem += WSYigod.convertStringToDec(dpaf.Amount,dpaf.AmountSign);
                        }
                        else if(dpaf.AmountCode =='21'){
                            policyTransaction.Agent_Discount_Written_In_Carrier__c += WSYigod.convertStringToDec(dpaf.Amount,dpaf.AmountSign);
                        }
                        else if(dpaf.AmountCode =='20'){
                            policyTransaction.Commission_Written_In_Carrier__c += WSYigod.convertStringToDec(dpaf.Amount,dpaf.AmountSign);
                        }
                        else if(dpaf.AmountCode =='01' ||  dpaf.AmountCode =='02' ||  dpaf.AmountCode =='03' ||  dpaf.AmountCode =='24'||  dpaf.AmountCode =='25'||  dpaf.AmountCode =='26'||   dpaf.AmountCode =='27' ||   dpaf.AmountCode =='28' ||   dpaf.AmountCode =='29' ){
                            policyTransaction.Premium_neto__c += WSYigod.convertStringToDec(dpaf.Amount,dpaf.AmountSign);
                        }
                        else if(dpaf.AmountCode =='10' ||  dpaf.AmountCode =='11'){
                            policyTransaction.Other_Commissions__c += WSYigod.convertStringToDec(dpaf.Amount,dpaf.AmountSign);
                        }
                    }
                }
                policyTransaction.Fee__c = fees ;
                policyTransaction.Credit_Fee__c = credit;
                policyTransaction.premium__c = string.valueOf(policyTransaction.Premium_neto__c);//string.valueOf(prem);//TODO: Raniz - TempFix 09/07/2012
            
            }
        }
        
        // this function will run before insert of PolicyTransaction object and will create the lookup fields
        public static void readPolicyContent(list<Policy_Transaction__c> listTransaction){

            // in evrey bulk of the Trigger there is one insureance Comapny
            string companyId ='';
            list<Account> listInsuranceCompany = new list<Account>();
            try{
                if(listTransaction[0].Carrier_File_Code__c !=null)
                    listInsuranceCompany = [SELECT id FROM Account WHERE Carrier_File_Code__c =: listTransaction[0].Carrier_File_Code__c];
            }
            catch(exception e){}
            if (listInsuranceCompany.size()>0){
                companyId=listInsuranceCompany[0].Id;
            }
            set<string> setlineProduct = new set<string>();
            
            set<string> setClientId = new set<string>();
            
            set<string> setClientNumberFromAgent = new set<string>();   
            
            set<string> setBrokerId = new set<string>();
            
            set<String> policyIdSet = new set<String>(); 
            set<Id> setCarrierId = new set<Id>();
            
            set<String> carModelCodeSet = new set<String>();
            //raniz change 09/09/2012: changed from set to list for order keeping purposes. 
            //In any case not many numbers can fit so no chance of too many duplicates, and also duplicates policy number don't logicaly matter
            map<string, list<String>> thisYearToLastYearPolicyNumbersMap = new map<string, list<String>>();
            Set<String> lastYearPolicyNumbers = new Set<String>();
            Integer lastYear = math.mod(Date.today().year(),100) - 1; 
            
            // run on all the Transaction and read the policy Content 
            for (Policy_Transaction__c policyTransaction : listTransaction){
                if (policyTransaction.Policy_Content__c != null ){
                    //raniz 15/07/2012: logic for the name part moved to .Net in order to be able to override existing name of same tx
                    //TODO: need to remove this its a duplicated logic (dup with the .Net comp)!!
                    if (policyTransaction.file_name__c != null ){
                        policyTransaction.Name = String.format('{0}-{1}-{2}', new String[]{policyTransaction.file_name__c,listTransaction[0].Carrier_File_Code__c,date.today().month()+''+date.today().year()});
                    }
                    
                    string heshbonOPolisaJson = Encodingutil.urlDecode(policyTransaction.Policy_Content__c, 'UTF-8')+'}';
                    WSYigod.HeshbonOPolisa heshbonOPolisaObj = (WSYigod.HeshbonOPolisa)JSON.deserialize( heshbonOPolisaJson, WSYigod.HeshbonOPolisa.class);
                    if (companyId != null && companyId != ''){
                        policyTransaction.Carrier__c=companyId;
                        setCarrierId.add(companyId);
                    }
                    if (heshbonOPolisaObj != null){
                        if(heshbonOPolisaObj.vehicleDetail != null){
                            if (heshbonOPolisaObj.vehicleDetail.size()>0){
                                if (heshbonOPolisaObj.vehicleDetail[0].vehicle_number != null)
                                    policyTransaction.vehicle_number__c = heshbonOPolisaObj.vehicleDetail[0].vehicle_number;
                            }
                        }
                        if(heshbonOPolisaObj.NetuneiGvia != null)
                        {
                            populateCollectionData(heshbonOPolisaObj, policyTransaction);
                                
                            if(heshbonOPolisaObj.NetuneiGvia.Commission != null){
                                 
                                if(policyTransaction.Commission_Written_In_Carrier__c == null)
                                    policyTransaction.Commission_Written_In_Carrier__c=0;
                                
                                if(policyTransaction.Agent_Discount_Written_In_Carrier__c == null )   
                                    policyTransaction.Agent_Discount_Written_In_Carrier__c=0;
                                
                                if(policyTransaction.Premium_neto__c == null)
                                    policyTransaction.Premium_neto__c =0;
                                
                                Boolean countPremiumNeto =false;
                                
                                if (policyTransaction.Premium_neto__c == 0) countPremiumNeto=true;
                                    
                                policyTransaction.Commission_Agent_A__c = 0;
                                policyTransaction.Commission_Agent_B__c = 0 ;
                                
                                 
                                for(WSYigod.Commission com : heshbonOPolisaObj.NetuneiGvia.Commission){
                                     if(com.netPremium != null && com.signNetPremium != null && countPremiumNeto){
                                        policyTransaction.Premium_neto__c +=  WSYigod.convertStringToDec(com.netPremium,com.signNetPremium); 
                                     }
                                     
                                     if (com.commissionAmountAgentA != null && com.signCommissionAmountAgentA != null){
                                         decimal percentCommissionAgentA =0;
                                         try{
                                               percentCommissionAgentA = decimal.valueOf(com.percentCommissionAgentA);
                                         }
                                         catch(exception e){}
                                         if (percentCommissionAgentA >0 ||  policyTransaction.Carrier_File_Code__c == SHLOMO)
                                              policyTransaction.Commission_Agent_A__c +=  WSYigod.convertStringToDec(com.commissionAmountAgentA, com.signCommissionAmountAgentA);
                                     }
                                     if (com.commissionAmountAgentB != null && com.signCommissionAmountAgentB != null){
                                        decimal percentCommissionAgentB =0;
                                         try{
                                               percentCommissionAgentB = decimal.valueOf(com.percentCommissionAgentb);
                                          }
                                          catch(exception e){}
                                          if (percentCommissionAgentB >0 || policyTransaction.Carrier_File_Code__c == SHLOMO)
                                             policyTransaction.Commission_Agent_B__c +=WSYigod.convertStringToDec(com.commissionAmountAgentB, com.signCommissionAmountAgentB);
                                     }
                          
                                     if (com.discountPercentage != null){
                                         try{   
                                            policyTransaction.Agent_Discount_Written_In_Carrier__c += WSYigod.convertStringToDec(com.discountAmount, com.discountSign);
                                         }
                                         catch(exception e){}
                                     }
                                }
                                policyTransaction.Commission_Written_In_Carrier__c = policyTransaction.Commission_Agent_A__c + policyTransaction.Commission_Agent_B__c;
                                //rz comment 09/09/2012: Agent_Discount_Written_In_Carrier__c comes into the calculation in display formulas
                                //policyTransaction.Commission_Written_In_Carrier__c =  policyTransaction.Commission_Written_In_Carrier__c - policyTransaction.Agent_Discount_Written_In_Carrier__c;
                            }
                        }
                        if(string.isNotEmpty(heshbonOPolisaObj.CurrencyCode)){
                            policyTransaction.Premium_Currency__c = heshbonOPolisaObj.CurrencyCode;
                        }
                        if (heshbonOPolisaObj.MPR_MEFITZ_BE_YATZRAN != null){
                            policyTransaction.Agent_number_from_Insurance_comapny__c =removeZeroFromStart(heshbonOPolisaObj.MPR_MEFITZ_BE_YATZRAN);
                            setBrokerId.add(policyTransaction.Agent_number_from_Insurance_comapny__c);
                        }
                        if (heshbonOPolisaObj.YeshutLakoach != null)
                        {
                            if (heshbonOPolisaObj.YeshutLakoach.MISPAR_ZIHUY_LAKOACH != null){
                                policyTransaction.Insured_number__c = removeZeroFromStart(heshbonOPolisaObj.YeshutLakoach.MISPAR_ZIHUY_LAKOACH);
                                //rz add condition 29/8/2012: when '0' is added accounts can be identified by related contact SSN = '0'
                                if(!'0'.equals(policyTransaction.Insured_number__c))
                                    setClientId.add(policyTransaction.Insured_number__c);
                                setClientId.add(heshbonOPolisaObj.YeshutLakoach.MISPAR_ZIHUY_LAKOACH);
                                //setClientStrId.add(heshbonOPolisaObj.YeshutLakoach.MISPAR_ZIHUY_LAKOACH);
                            }
                            if (heshbonOPolisaObj.YeshutLakoach.clientNumberFromAgent != null){
                                // Raniz 17/05/2012 change:  handle clientnumber *with* zeros
                                policyTransaction.client_Number_From_Agent__c = heshbonOPolisaObj.YeshutLakoach.clientNumberFromAgent;
                                if(removeZeroFromStart(policyTransaction.client_Number_From_Agent__c) != '0'){
                                    //changed By raniz 11/05/2012
                                    setClientNumberFromAgent.add(policyTransaction.client_Number_From_Agent__c  + ',' + companyId + ',' + policyTransaction.Agent_number_from_Insurance_comapny__c);
                                }
                            }
                            if (heshbonOPolisaObj.YeshutLakoach.SUG_MEZAHE_LAKOACH != null)
                            {
                                policyTransaction.Insured_Type__c =heshbonOPolisaObj.YeshutLakoach.SUG_MEZAHE_LAKOACH;
                            }
                            string fullAdress= '';
                            if (heshbonOPolisaObj.YeshutLakoach.SHEM_RECHOV != null){
                                
                                fullAdress += ' ' + heshbonOPolisaObj.YeshutLakoach.SHEM_RECHOV;
                            }
                            if (heshbonOPolisaObj.YeshutLakoach.fullName != null ) {
                                policyTransaction.customer_full_name__c = heshbonOPolisaObj.YeshutLakoach.fullName;
                            }
                            if (heshbonOPolisaObj.YeshutLakoach.MISPAR_BAIT != null){
                                fullAdress += ' ' + heshbonOPolisaObj.YeshutLakoach.MISPAR_BAIT;
                            }
                            if (heshbonOPolisaObj.YeshutLakoach.SHEM_YISHUV != null){
                                fullAdress += ' ' + heshbonOPolisaObj.YeshutLakoach.SHEM_YISHUV;
                            }
                            if (heshbonOPolisaObj.YeshutLakoach.MIKUD != null){
                                fullAdress += ' ' + heshbonOPolisaObj.YeshutLakoach.MIKUD;
                            }
                            policyTransaction.Address__c = fullAdress;
                        }
                        
                        if(heshbonOPolisaObj.MISPAR_POLISA_O_HESHBON != null){
                            string endorsment = '';
                            String addition = removeZeroFromStart(heshbonOPolisaObj.additional);
                            if (MIGDAL.equals(policyTransaction.Carrier_File_Code__c) && 
                                    CargoInsuranceNumbers.get(policyTransaction.Carrier_File_Code__c).contains(heshbonOPolisaObj.product) &&
                                    addition != null && addition != '') {
                                endorsment = addition;
                                policyTransaction.endorsement_number__c =addition;
                            } else if(heshbonOPolisaObj.Endorsment_No != null){
                                endorsment =heshbonOPolisaObj.Endorsment_No;
                                policyTransaction.endorsement_number__c =removeZeroFromStart(heshbonOPolisaObj.Endorsment_No); 
                            }
                            else{
                                policyTransaction.endorsement_number__c='0';
                            }
                            // in case the company is FNX we need to bulid the policy number :
                            String previousYearPolicyNumber, previousYearPolicyNumberOptionTwo;
                            if (FNX.equals(policyTransaction.Carrier_File_Code__c)){
                                policyTransaction.Policy_number_from_Insurance_company__c='';
                                policyTransaction.Policy_number_from_Insurance_company__c+=heshbonOPolisaObj.policyBranch;
                                policyTransaction.Policy_number_from_Insurance_company__c+=heshbonOPolisaObj.product;
                                policyTransaction.Policy_number_from_Insurance_company__c+=heshbonOPolisaObj.runningNumber;
                                policyTransaction.Policy_number_from_Insurance_company__c+=heshbonOPolisaObj.controlDigit;

                                previousYearPolicyNumber = lastYear + policyTransaction.Policy_number_from_Insurance_company__c;
                                previousYearPolicyNumberOptionTwo = (lastYear-1) + policyTransaction.Policy_number_from_Insurance_company__c;
                                policyTransaction.Policy_number_from_Insurance_company__c=
                                        heshbonOPolisaObj.policyYear + policyTransaction.Policy_number_from_Insurance_company__c;
                            } 
                            else{
                                 policyTransaction.Policy_number_from_Insurance_company__c = removeZeroFromStart(heshbonOPolisaObj.MISPAR_POLISA_O_HESHBON); 
                                if(MENORA.equals(policyTransaction.Carrier_File_Code__c)){
                                    previousYearPolicyNumber=heshbonOPolisaObj.policyBranch;
                                    previousYearPolicyNumber+=heshbonOPolisaObj.product;
                                    previousYearPolicyNumber+=heshbonOPolisaObj.runningNumber;
                                    previousYearPolicyNumberOptionTwo = previousYearPolicyNumber;
                                    previousYearPolicyNumber += lastYear + heshbonOPolisaObj.controlDigit;
                                    previousYearPolicyNumberOptionTwo += (lastYear-1) + heshbonOPolisaObj.controlDigit;
                                }
                                // TBD - SHEM_MASLUL_HABITUAH should have been מס_פוליסה_קודמת__מס_פוליסה
                                else if(CLAL.equals(policyTransaction.Carrier_File_Code__c)){
                                    String previousPolicyBody = removeZeroFromStart(heshbonOPolisaObj.SHEM_MASLUL_HABITUAH);
                                    if (previousPolicyBody != '' && previousPolicyBody != null) {
                                        previousYearPolicyNumberOptionTwo=previousYearPolicyNumber=heshbonOPolisaObj.product;
                                        previousYearPolicyNumber+=math.mod(lastYear,10);
                                        previousYearPolicyNumberOptionTwo+=math.mod(lastYear-1,10);
                                        previousYearPolicyNumber+=previousPolicyBody;
                                        previousYearPolicyNumberOptionTwo+=previousPolicyBody;
                                    }
                                } 
                                else {
                                    previousYearPolicyNumber  = 
                                            policyTransaction.Policy_number_from_Insurance_company__c.substring(0, 
                                                    policyTransaction.Policy_number_from_Insurance_company__c.length()-2) + 
                                            lastYear;
                                    previousYearPolicyNumberOptionTwo  = 
                                            policyTransaction.Policy_number_from_Insurance_company__c.substring(0, 
                                                    policyTransaction.Policy_number_from_Insurance_company__c.length()-2) + 
                                            (lastYear-1);
                                }
    
                                if(AYALON.equals(policyTransaction.Carrier_File_Code__c)){
                                   if(addition!=null && !''.equals(addition) && !'0'.equals(addition)){
                                        policyTransaction.Policy_number_from_Insurance_company__c+=addition;
                                        /*Yishay's Fix - reenter after check*/
                                        previousYearPolicyNumber+=addition;
                                        previousYearPolicyNumberOptionTwo+=addition;
                                        /**/
                                   }
                                }
                                
                            }
                            /*Yishay's Fix - reenter after check*/
                            previousYearPolicyNumber = removeZeroFromStart(previousYearPolicyNumber);
                            previousYearPolicyNumberOptionTwo = removeZeroFromStart(previousYearPolicyNumberOptionTwo);
                            if (!thisYearToLastYearPolicyNumbersMap.containsKey(policyTransaction.Policy_number_from_Insurance_company__c))
                                thisYearToLastYearPolicyNumbersMap.put(policyTransaction.Policy_number_from_Insurance_company__c, new list<String>());
                            // TBD - I used SHEM_MASLUL_HABITUAH in order not to add a new field and compile a new version.
                            // add a new field for Previous_Policy_number, change the XMLs, compile the .net with the new WSDL and change this code.
                            String previousPolicyBody = '0';
                            if (heshbonOPolisaObj.SHEM_MASLUL_HABITUAH != null && heshbonOPolisaObj.SHEM_MASLUL_HABITUAH != '')
                                previousPolicyBody = removeZeroFromStart(heshbonOPolisaObj.SHEM_MASLUL_HABITUAH);
                            if (!CLAL.equals(policyTransaction.Carrier_File_Code__c) && 
                                    !MIGDAL.equals(policyTransaction.Carrier_File_Code__c) &&
                                    previousPolicyBody != '0') {
                                thisYearToLastYearPolicyNumbersMap.get(policyTransaction.Policy_number_from_Insurance_company__c).add(previousPolicyBody);
                                lastYearPolicyNumbers.add(previousPolicyBody);
                            } else if (policyTransaction.Carrier_File_Code__c == FNX){
                            
                                String lastYaerRegularNumber = removeZeroFromStart(heshbonOPolisaObj.MISPAR_POLISA_O_HESHBON);
                                lastYaerRegularNumber = lastYaerRegularNumber.substring(0, lastYaerRegularNumber.length()-2) + lastYear; 
                                thisYearToLastYearPolicyNumbersMap.get(policyTransaction.Policy_number_from_Insurance_company__c).add(
                                        lastYaerRegularNumber);
                                lastYearPolicyNumbers.add(lastYaerRegularNumber);
                                
                                String lastYaerRegularNumberOptionTwo = removeZeroFromStart(heshbonOPolisaObj.MISPAR_POLISA_O_HESHBON);
                                lastYaerRegularNumberOptionTwo = lastYaerRegularNumberOptionTwo.substring(0, lastYaerRegularNumberOptionTwo.length()-2) + (lastYear - 1); 
                                thisYearToLastYearPolicyNumbersMap.get(policyTransaction.Policy_number_from_Insurance_company__c).add(
                                        lastYaerRegularNumberOptionTwo);
                                lastYearPolicyNumbers.add(lastYaerRegularNumberOptionTwo);
                            } else {
                                thisYearToLastYearPolicyNumbersMap.get(policyTransaction.Policy_number_from_Insurance_company__c).add(previousYearPolicyNumber);
                                thisYearToLastYearPolicyNumbersMap.get(policyTransaction.Policy_number_from_Insurance_company__c).add(previousYearPolicyNumberOptionTwo);
                                lastYearPolicyNumbers.add(previousYearPolicyNumber);
                                lastYearPolicyNumbers.add(previousYearPolicyNumberOptionTwo);
                            } 
                            
                            /**/
                            string prod = removeZeroFromStart(heshbonOPolisaObj.product);
                            
                            populatePolicyIdSet(policyIdSet, policyTransaction.Carrier_File_Code__c, policyTransaction.Policy_number_from_Insurance_company__c, prod);
                        }

                        if (heshbonOPolisaObj.product != null){
                            String prod = removeZeroFromStart(heshbonOPolisaObj.product);
                            policyTransaction.product_from_insurance_company__c = prod;
                            setlineProduct.add(prod);
                        }
                        
                        extractCarModelCodeAndManufacturer(policyTransaction, heshbonOPolisaObj, carModelCodeSet);
                        //rz add 22/10/12: made in order to work against user exposed fields in the tx to enable correction of incorrect dates
                        setDateFieldsOnTx(policyTransaction, heshbonOPolisaObj);
                                                                                
                    }
                                
                }
            }

            processPolicyTransaction(listTransaction, setClientNumberFromAgent, setClientId, setBrokerId, policyIdSet,  
                    thisYearToLastYearPolicyNumbersMap, lastYearPolicyNumbers, setCarrierId, setlineProduct, carModelCodeSet);
        }

        private static void extractCarModelCodeAndManufacturer(Policy_Transaction__c policyTransaction, WSYigod.HeshbonOPolisa heshbonOPolisaObj, set<String> carModelCodeSet){
            if(heshbonOPolisaObj.vehicleDetail!=null && !heshbonOPolisaObj.vehicleDetail.isEmpty() && heshbonOPolisaObj.vehicleDetail[0]!=null){
                extractCarModelCode(policyTransaction, heshbonOPolisaObj, carModelCodeSet);
                extractManufacturer(policyTransaction, heshbonOPolisaObj);
            }
        }

        private static void extractManufacturer(Policy_Transaction__c policyTransaction, WSYigod.HeshbonOPolisa heshbonOPolisaObj){
            if(heshbonOPolisaObj.vehicleDetail[0].vehicleManufacturer!=null && !''.equals(heshbonOPolisaObj.vehicleDetail[0].vehicleManufacturer)){
                policyTransaction.Vehicle_Manufacturer__c = heshbonOPolisaObj.vehicleDetail[0].vehicleManufacturer;
            }
        }
        
        private static void extractCarModelCode(Policy_Transaction__c policyTransaction, WSYigod.HeshbonOPolisa heshbonOPolisaObj, set<String> carModelCodeSet){
            if(heshbonOPolisaObj.vehicleDetail[0].vehicleModel!=null && !''.equals(heshbonOPolisaObj.vehicleDetail[0].vehicleModel)){
                policyTransaction.Vehicle_Model__c = removeZeroFromStart(heshbonOPolisaObj.vehicleDetail[0].vehicleModel);
                carModelCodeSet.add(policyTransaction.Vehicle_Model__c);
            }
        }

        private static void setDateFieldsOnTx(Policy_Transaction__c policyTransaction, WSYigod.HeshbonOPolisa heshbonOPolisaObj){
            if(heshbonOPolisaObj!=null){
                policyTransaction.Production_Date__c = heshbonOPolisaObj.Bordero_Month;
                policyTransaction.Endorsement_Expiration_Date__c = heshbonOPolisaObj.endorsmentExpirationDate;
                policyTransaction.Endorsement_Effective_Date__c = heshbonOPolisaObj.endorsmentEffectiveDate;
                policyTransaction.Expiration_Date__c = heshbonOPolisaObj.Expiration_Date;
                policyTransaction.Effective_Date__c = heshbonOPolisaObj.TAARICH_HITZTARFUT_MUTZAR;
                policyTransaction.Birthdate__c = heshbonOPolisaObj.YeshutLakoach.TAARICH_LEYDA;
            }
        }



        private static String generatePolicyMapKey(String carrierFileCode, String polNumber, String prodNum){
           if(prodNum==null) return polNumber+'';
           return String.format('{0},{1}',new String[]{polNumber,prodNum});
        }
        
        private static String getProdNumfromPolicyMapKey(String key){
            if(key==null || !key.contains(',')) return ''; 
            return key.split(',')[1];
        }

        public static void processPolicyTransaction(list<Policy_Transaction__c> listTransaction, set<string> setClientNumberFromAgent,
                                                    set<string> setClientId, set <string> setBrokerId, set<string>  policyIdSet,
                                                    map<string, list<String>> thisYearToLastYearPolicyNumbersMap, set<String> lastYearPolicyNumbers,
                                                    set<Id> setCarrier, set<string> setLineProduct, set<String> carModelCodeSet){

            map<Id,Novidea_HPC__Policy__c> mapAllPolicy = new map<Id,Novidea_HPC__Policy__c>();
            map<Id,Novidea_HPC__Policy__c> mapAllPolicyShavit = new map<Id,Novidea_HPC__Policy__c>();
            list<Novidea_HPC__Carrier_Product__c> listCarrierProduct = new list<Novidea_HPC__Carrier_Product__c>();
            list<Novidea_HPC__Broker_Number__c> listCarrierBroker  = new list<Novidea_HPC__Broker_Number__c>();
            map<string,Account> mapAccount = new map<string,Account>(); 
            map<string,Novidea_HPC__Policy__c> mapPolicyByNumAndProd = new map<string,Novidea_HPC__Policy__c>();
            map<String,list<Novidea_HPC__Policy__c>> mapPolicyByNum = new map<string,list<Novidea_HPC__Policy__c>>();
            map<string,Novidea_HPC__Carrier_Product__c> mapLineProduct = new map<string,Novidea_HPC__Carrier_Product__c>();
            map<string,Novidea_HPC__Broker_Number__c> mapCarrierBroker = new map<string,Novidea_HPC__Broker_Number__c>();
            map<String, String> mapClientSpecByPrefixedNumber = null;
            map<String, String> mapClientSpecBy3PrefixedNumber = null;
            
            if (!setBrokerId.isEmpty()){
                listCarrierBroker = [SELECT Novidea_HPC__Carrier__c, Novidea_HPC__Broker_Number_In_Carrier__c, Novidea_HPC__Profit_Center__r.Client_Number_Prefix__c 
                                    FROM  Novidea_HPC__Broker_Number__c 
                                    WHERE Novidea_HPC__Broker_Number_In_Carrier__c IN :setBrokerId 
                                    AND Novidea_HPC__Carrier__c IN : setCarrier ];
                if (!listCarrierBroker.isEmpty()){
                    IProductionHandler helper = (IProductionHandler)ServiceLocator.getService('IProductionHandler');
                    for (Novidea_HPC__Broker_Number__c broker :listCarrierBroker){
                        if(helper==null || helper.isBrokerToBeProcessed(mapCarrierBroker, broker))
                            mapCarrierBroker.put(broker.Novidea_HPC__Carrier__c + broker.Novidea_HPC__Broker_Number_In_Carrier__c, broker);
                    }
                }
            }

            map<string,map<String,Account>> mapAccountNumber = new map<string,map<String,Account>>();
            String[] crumbs = null;
            if (!setClientNumberFromAgent.isEmpty()){
                mapClientSpecByPrefixedNumber = new map<String, String>();
                String prefix = '';
                Novidea_HPC__Broker_Number__c brkr;
                for(String s: setClientNumberFromAgent){
                    crumbs = s.split(',');
                    if((brkr=mapCarrierBroker.get(crumbs[1]+crumbs[2]))!=null){
                        if(brkr.Novidea_HPC__Profit_Center__r.Client_Number_Prefix__c!=null)
                            prefix = brkr.Novidea_HPC__Profit_Center__r.Client_Number_Prefix__c; 
                        mapClientSpecByPrefixedNumber.put(prefix + crumbs[0],s);
                    }
                    prefix='';
                }
                set<String> foundCodes = new set<String>();
                String tempStr;
                for (Account acc : [SELECT AccountNumber FROM Account WHERE AccountNumber IN :mapClientSpecByPrefixedNumber.keyset()]){
                    foundCodes.add(acc.AccountNumber);
                    tempStr = mapClientSpecByPrefixedNumber.get(acc.AccountNumber);
                    crumbs = tempStr.split(',');
                    mapAccountNumber.put(crumbs[0],new map<String,Account>{tempStr=>acc});
                }
                mapClientSpecByPrefixedNumber.keyset().removeAll(foundCodes);
                mapClientSpecBy3PrefixedNumber = new map<String, String>();
                for(String s: mapClientSpecByPrefixedNumber.keyset()){
                    tempStr = s.substring(1);
                    if(tempStr.startsWith('3')){
                        mapClientSpecBy3PrefixedNumber.put(tempStr, mapClientSpecByPrefixedNumber.get(s));
                    }
                }
                
                for (Account acc : [SELECT AccountNumber FROM Account WHERE AccountNumber IN :mapClientSpecBy3PrefixedNumber.keyset()]){
                    tempStr = mapClientSpecBy3PrefixedNumber.get(acc.AccountNumber);
                    crumbs = tempStr.split(',');
                    mapAccountNumber.put(crumbs[0],new map<String,Account>{tempStr=>acc});
                }
            }
            
            //rz change 5/6/13 to cover the case where a contact can be in several accounts
            map<String, list<Novidea_HPC__Associated_Person__c>> mapCntSSNToAssPerson = new map<String, list<Novidea_HPC__Associated_Person__c>>();
            list<Novidea_HPC__Associated_Person__c> tempAPList;
            if (!setClientId.isEmpty()){
                String tempSSN;
                for(Novidea_HPC__Associated_Person__c ap: [SELECT Novidea_HPC__Contact__c, Novidea_HPC__Account__c, 
                                                                    Novidea_HPC__Contact__r.Novidea_HPC__SSN__c
                                                          FROM Novidea_HPC__Associated_Person__c
                                                          WHERE Novidea_HPC__Contact__r.Novidea_HPC__SSN__c IN: setClientId]){
                    tempSSN = removeZeroFromStart(ap.Novidea_HPC__Contact__r.Novidea_HPC__SSN__c);
                    if((tempAPList = mapCntSSNToAssPerson.get(tempSSN))==null)
                        tempAPList  = new list<Novidea_HPC__Associated_Person__c>();
                    tempAPList.add(ap);
                    mapCntSSNToAssPerson.put(tempSSN,tempAPList);
                }
            }

            if(!setClientId.isEmpty()){
                for (Account acc : [SELECT Novidea_HPC__Tax_ID__c FROM Account WHERE Novidea_HPC__Tax_ID__c IN :setClientId]){
                    mapAccount.put(removeZeroFromStart(acc.Novidea_HPC__Tax_ID__c),acc);
                }
            } 
            //TODO: when the carrier is Phoenix it is possible that some policies will come up which do not belong to Phoenix instead of correct policy


            
            if (!setLineProduct.isEmpty())
            {
                listCarrierProduct = getListCarrierProduct(setLineProduct, setCarrier);
                populateLineProduct(mapLineProduct, listCarrierProduct);                    
            }

            
            if(!policyIdSet.isEmpty()){
                mapAllPolicy = getAllPolicies(policyIdSet, mapLineProduct, setCarrier);
                populatePolicyByNumAndProdMap(mapPolicyByNumAndProd, mapPolicyByNum, mapAllPolicy);
            }
			
			/* this class is not relvant anymore(moved to Productsia package), comment this so can delete field Policy_Number_External__c
            //raniz add 16/9/2013: filter by client and carrier . Otherwise query is non selective
            list<Novidea_HPC__Policy__c> lastYearPolicies = [SELECT Novidea_HPC__Policy_Number__c,
                                                                    Novidea_HPC__client__c,Novidea_HPC__Carrier__c,
                                                                    Novidea_HPC__Broker_In_Carrier__c 
                                                            FROM Novidea_HPC__Policy__c 
                                                            WHERE Policy_Number_External__c IN : lastYearPolicyNumbers
                                                            AND Novidea_HPC__Client__c !=null];
            */   
            list<Novidea_HPC__Policy__c> lastYearPolicies;                                           
            map<String, Novidea_HPC__Policy__c> lastYearPoliciesByPolicyNumber = new map<String, Novidea_HPC__Policy__c>();
            for (Novidea_HPC__Policy__c policy:lastYearPolicies)
                lastYearPoliciesByPolicyNumber.put(policy.Novidea_HPC__Policy_Number__c, policy);

            list<Car_Model__c> carmodels;
            map<String,Car_Model__c> carModelsByCode;
            if(!carModelCodeSet.isEmpty()){
                carmodels= [SELECT Name, Code__c FROM Car_Model__c WHERE Code__c IN: carModelCodeSet];
                carModelsByCode = new map<String,Car_Model__c>();
                for(Car_Model__c cm: carmodels){
                    carModelsByCode.put(cm.Code__c, cm);
                }
            }
            carModelCodeSet = null;

            // go over all Transaction
            for(Policy_Transaction__c policyTransaction : listTransaction ){
                if(policyTransaction.Identification_Type__c == 'Partially Auto')
                    policyTransaction.Policy__c = null;

                setProductDef(policyTransaction, mapLineProduct);            
                setPolicyDetails(policyTransaction, mapPolicyByNumAndProd, mapPolicyByNum, mapLineProduct);

                //TBD currently i am using houseHold Lookup need to switch to objectPeson Account
                
                // this variable will indicate if we found the Account acording to client number from agent
                Boolean isAccountFound = false;

                map<String,Account> tmptMap;
                
                if (policyTransaction.client_Number_From_Agent__c != null &&  policyTransaction.client_Number_From_Agent__c != '0'){
                    if ((tmptMap = mapAccountNumber.get(policyTransaction.client_Number_From_Agent__c)) != null){
                        //will only have 1 entry
                        for(String s : tmptMap.keyset()){
                            crumbs = s.split(',');
                            if(crumbs[1].equals(policyTransaction.Carrier__c) && crumbs[2].equals(policyTransaction.Agent_number_from_Insurance_comapny__c)){
                                policyTransaction.Customer_Account__c = tmptMap.get(s).Id;
                                isAccountFound = true;
                                break;
                            }
                        }
                    } 
                }
                
                // Use head-to-toe method
                if (thisYearToLastYearPolicyNumbersMap.containsKey(policyTransaction.Policy_number_from_Insurance_company__c)){
                    for (String lastYearPolicyNumber:thisYearToLastYearPolicyNumbersMap.get(policyTransaction.Policy_number_from_Insurance_company__c)){
                        if(lastYearPoliciesByPolicyNumber.containsKey(lastYearPolicyNumber)) {
                            policyTransaction.Customer_Account__c = lastYearPoliciesByPolicyNumber.get(lastYearPolicyNumber).Novidea_HPC__client__c;
                            isAccountFound = policyTransaction.Is_Customer_Located_By_Head_To_Tail__c = true;
                            break;
                        }
                    }
                }
                
                //raniz change 09/09/2012: do not try to rematch account (when entering from rematch) if customer account has been found by head to tail method
                if (policyTransaction.Insured_number__c != null && !isAccountFound && 
                (policyTransaction.Is_Customer_Located_By_Head_To_Tail__c==null || !policyTransaction.Is_Customer_Located_By_Head_To_Tail__c)){
                                                                              
                    if((tempAPList = mapCntSSNToAssPerson.get(policyTransaction.Insured_number__c))!=null){
                            policyTransaction.Customer_Account__c = tempAPList[0].Novidea_HPC__Account__c;
                            policyTransaction.Client__c = tempAPList[0].Novidea_HPC__Contact__c;
                    }
                    else if (mapAccount.get(policyTransaction.Insured_number__c) != null ){
                        policyTransaction.Customer_Account__c = mapAccount.get(policyTransaction.Insured_number__c).Id;
                    }
                }
                //raniz addition 21/5/2013: insert contact even if account identified, if the contact's account is the one identified
                //raniz change 5/6/13: handle possible multiple instances of AP
                else if(policyTransaction.Insured_number__c != null && isAccountFound && (tempAPList=mapCntSSNToAssPerson.get(policyTransaction.Insured_number__c))!=null){
                    for(Novidea_HPC__Associated_Person__c ap: tempAPList){
                        if(policyTransaction.Customer_Account__c == ap.Novidea_HPC__Account__c){
                            policyTransaction.Client__c = ap.Novidea_HPC__Contact__c;
                            break;
                        }
                    }
                }
                
                if (policyTransaction.Agent_number_from_Insurance_comapny__c != null){
                    if (policyTransaction.Carrier__c!= null)
                    {
                        if (mapCarrierBroker.get(policyTransaction.Carrier__c + policyTransaction.Agent_number_from_Insurance_comapny__c) != null){
                            policyTransaction.Broker_Number__c = mapCarrierBroker.get(policyTransaction.Carrier__c+policyTransaction.Agent_number_from_Insurance_comapny__c).Id;
                        }
                    }
                }
                
                
                setCarManufacturerByCarModel(policyTransaction, carModelsByCode);
                
                processPolicyTransaction(policyTransaction,mapAllPolicy);
            }//end of for 
            
        }
        
        
        private static list<Novidea_HPC__Carrier_Product__c> getListCarrierProduct(set<string> setLineProduct, set<Id> setCarrier){
            //rz change 2/7/13: add query field Novidea_HPC__Product_Definition__r.Calculated_Master_Product_Def__c
            return [SELECT Novidea_HPC__Product_Definition__r.Name, Novidea_HPC__Product_Definition__r.Id, 
                           Novidea_HPC__Product_Definition__r.Calculated_Master_Product_Def__c,
                           Novidea_HPC__Product_Definition__r.Novidea_HPC__Category__c,
                           Novidea_HPC__Product_In_Carrier__c, Novidea_HPC__Account__c
                    FROM Novidea_HPC__Carrier_Product__c 
                    WHERE Novidea_HPC__Account__c IN :setCarrier 
                    AND Novidea_HPC__Product_In_Carrier__c IN : setLineProduct];
        }

        private static void populateLineProduct(map<string,Novidea_HPC__Carrier_Product__c> mapLineProduct, list<Novidea_HPC__Carrier_Product__c> listCarrierProduct){
            if(listCarrierProduct==null || mapLineProduct==null) return;
            for (Novidea_HPC__Carrier_Product__c carrierPro :listCarrierProduct){
                mapLineProduct.put(carrierPro.Novidea_HPC__Account__c + ',' + carrierPro.Novidea_HPC__Product_In_Carrier__c, carrierPro);
            }
        }
        
        private static void setProductDef(Policy_Transaction__c policyTransaction, map<string,Novidea_HPC__Carrier_Product__c> mapLineProduct ){
            if (policyTransaction.product_from_insurance_company__c!= null && policyTransaction.Carrier__c!= null ){
                String key = policyTransaction.Carrier__c + ',' + policyTransaction.product_from_insurance_company__c;
                Novidea_HPC__Carrier_Product__c cp;
                if ((cp=mapLineProduct.get(key)) != null){
                    if(cp.Novidea_HPC__Product_Definition__r!=null){
                        if(cp.Novidea_HPC__Product_Definition__r.Name!=null){ 
                            policyTransaction.Insurance_Type__c = cp.Novidea_HPC__Product_Definition__r.Name;
                        }
                        if(cp.Novidea_HPC__Product_Definition__r.Id!=null){
                            policyTransaction.Product_Def__c = cp.Novidea_HPC__Product_Definition__r.Id;
                        }
                    }
                    policyTransaction.Carrier_Product__c = cp.Id;
                }
            }
        }
        
        /*
            sets the "is policy found" and policy Id on the tx record
        */
        private static void setPolicyDetails(Policy_Transaction__c pt, map<String,Novidea_HPC__Policy__c> mapPolicyByNumAndProd, 
                                            map<String, list<Novidea_HPC__Policy__c>> mapPolicyByNum, 
                                            map<string,Novidea_HPC__Carrier_Product__c> mapLineProduct){
            if (pt.Policy_number_from_Insurance_company__c != null){
                Novidea_HPC__Policy__c tmpPlc;
                list<Novidea_HPC__Policy__c> tmpPlcs;
                Novidea_HPC__Carrier_Product__c tmpCarrierProd;
                //raniz 6/8/13: if matchByNumAndProdCats is not empty and the category of the product def in the tx is in it 
                //or the matchByNumAndProdCats is empty then match by prod and num
                //if the category is not in the non-empty matchByNumAndProdCats then match by number only
                if(pt.Product_Def__c!=null && 
                    ((tmpCarrierProd = mapLineProduct.get(pt.Carrier__c + ',' + pt.product_from_insurance_company__c))!=null &&
                     matchByNumAndProdCats.contains(tmpCarrierProd.Novidea_HPC__Product_Definition__r.Novidea_HPC__Category__c) || 
                     matchByNumAndProdCats.isEmpty() || 
                     pt.Carrier_File_Code__c==HAKLAI
                     ) &&
                    (tmpPlc=mapPolicyByNumAndProd.get(generatePolicyMapKey(pt.Carrier_File_Code__c, 
                                                                        pt.Policy_number_from_Insurance_company__c, 
                                                                        //raniz change 2/7/13
                                                                        ((String)pt.Product_Def__c).substring(0,15)))) != null 
                    || 
                    !matchByNumAndProdCats.isEmpty() && tmpCarrierProd!=null && 
                    !matchByNumAndProdCats.contains(tmpCarrierProd.Novidea_HPC__Product_Definition__r.Novidea_HPC__Category__c) &&
                    (tmpPlcs=mapPolicyByNum.get(generatePolicyMapKey(pt.Carrier_File_Code__c, pt.Policy_number_from_Insurance_company__c, null))) != null && 
                    (tmpPlc = tmpPlcs[0])!=null      
                ){
//                  system.debug('Matched Pt: ' + pt);
                    pt.Policy__c = tmpPlc.Id;
                }
                //rz add 22/10/12: fix #1048
                else if(!'Full Auto'.equalsIgnoreCase(pt.Identification_Type__c)){
                    pt.Policy__c = null;
                    pt.Is_Policy_found__c = false;
                }
            }
        }
        
        
        private static map<Id,Novidea_HPC__Policy__c> getAllPolicies(set<String> policyIdSet, map<string,Novidea_HPC__Carrier_Product__c> mapLineProduct, set<Id> setCarrier){
            set<String> newPolicyIdSet = new set<String>(), prodDefIdSet  = new set<String>(), polNumberSet = new set<String>(), uniquePolicyNumberSet = new set<String>();
            String tempNewKey, tmp;
            string[] crumbs;
            for(Id carrKey: setCarrier){
                for(String key: policyIdSet){
//                  system.debug('key: ' + key);
                    String prod = getProdNumfromPolicyMapKey(key);
//                  system.debug('prod: ' + prod);
                    Novidea_HPC__Carrier_Product__c tmpCp;
//                  system.debug('string.format(\'{0},{1}\',new String[]{carrKey,prod}): ' + string.format('{0},{1}',new String[]{carrKey,prod}));
                    if((tmpCp = mapLineProduct.get(string.format('{0},{1}',new String[]{carrKey,prod})))==null)continue;
//                  system.debug('key.replaceFirst(prod + \'$\' ,tmpCp.Novidea_HPC__Product_Definition__c): ' + key.replaceFirst(prod + '$' ,tmpCp.Novidea_HPC__Product_Definition__c));
                    //raniz change 2/7/2013
                    String calcMasterProd = tmpCp.Novidea_HPC__Product_Definition__r.Calculated_Master_Product_Def__c;
                    tempNewKey = key.replaceFirst(prod + '$' ,calcMasterProd);
                    newPolicyIdSet.add(tempNewKey);
                    crumbs = tempNewKey.split(',');
                    if(crumbs!=null && !crumbs.isempty()){
                        if(crumbs[0]!=null)polNumberSet.add(crumbs[0]);
                        if(crumbs.size()>1 && crumbs[1]!=null) prodDefIdSet.add(crumbs[1]);
                    }
                }
            }
//          system.debug(logginglevel.ERROR,newPolicyIdSet.size() + '\n' + string.join(new list<string>(newPolicyIdSet),'\',\''));
            //raniz change 2/7/2013
            //TODO: possible solution to performance problem is to limit the policy set to those with expiration dates bigeer then 2 or even 1.5 years
            //raniz 5/8/13: if no categories are set in customsetting then match all by pol number & product
            /*this class is not relvant anymore(moved to Productsia package), comment this so can delete field Policy_Number_External__c 
            if(matchByNumAndProdCats.isEmpty()){
            	
                return new map<Id,Novidea_HPC__Policy__c>([SELECT Novidea_HPC__Endorsement_Number__c, Novidea_HPC__Policy_Number__c,
                                                                    Novidea_HPC__client__c, Novidea_HPC__Carrier__c, Policy_Number_Product__c, 
                                                                    Novidea_HPC__Broker_In_Carrier__c, Novidea_HPC__Product_Definition__c
                                                            FROM Novidea_HPC__Policy__c 
                                                            WHERE Policy_Number_External__c IN : polNumberSet
                                                            AND Master_Product_Definition__c IN : prodDefIdSet
                                                            AND Policy_Number_Product__c IN : newPolicyIdSet ]);
               
              
            }
            //raniz 5/8/13: if some categories are set in customsetting then match them by pol number & product and the rest by pol number only 
            else{
//              system.debug(uniquePolicyNumberSet);
                return new map<Id,Novidea_HPC__Policy__c>(
                    [SELECT Novidea_HPC__Endorsement_Number__c, Novidea_HPC__Policy_Number__c,
                            Novidea_HPC__client__c, Novidea_HPC__Carrier__c, Policy_Number_Product__c, 
                            Novidea_HPC__Broker_In_Carrier__c, Novidea_HPC__Product_Definition__c 
                    FROM Novidea_HPC__Policy__c 
                    WHERE Policy_Number_External__c IN : polNumberSet 
                    AND(
                        (Master_Product_Definition__c IN : prodDefIdSet
                        AND Policy_Number_Product__c IN : newPolicyIdSet
                        AND(Novidea_HPC__Product_Definition__r.Novidea_HPC__Category__c IN : matchByNumAndProdCats 
                            OR Novidea_HPC__Carrier__r.Carrier_File_Code__c = : HAKLAI
                            )
                        )
                        OR Novidea_HPC__Product_Definition__r.Novidea_HPC__Category__c NOT IN : matchByNumAndProdCats
                    )]);
            }
            */
            return null;
        }

        //rz change 2/7/13
        private static void populatePolicyByNumAndProdMap(map<String,Novidea_HPC__Policy__c> mapPolicyByNumAndProd, 
                                                            map<String,list<Novidea_HPC__Policy__c>> mapPolicyByNum, 
                                                            map<Id,Novidea_HPC__Policy__c> mapAllPolicy){
            if(mapAllPolicy!=null && !mapAllPolicy.isEmpty()){
                list<Novidea_HPC__Policy__c> tmplist;
                for(Novidea_HPC__Policy__c policy : mapAllPolicy.values()){
                    mapPolicyByNumAndProd.put(policy.Policy_Number_Product__c,policy);
                    if((tmplist=mapPolicyByNum.get(policy.Novidea_HPC__Policy_Number__c))==null)
                        tmplist = new list<Novidea_HPC__Policy__c>();
                    tmplist.add(policy);
                    mapPolicyByNum.put(policy.Novidea_HPC__Policy_Number__c, tmplist);
                }
            }           
        }
        
        private static void setCarManufacturerByCarModel(Policy_Transaction__c policyTransaction, map<String,Car_Model__c> carModelsByCode){
            if(!generalSetting.Policy_Tx_Table_Override_Car_Manufacurer__c) return;
            if(policyTransaction.Vehicle_Model__c!=null && carModelsByCode!=null && !carModelsByCode.isEmpty() && carModelsByCode.containsKey(policyTransaction.Vehicle_Model__c)){
                policyTransaction.Vehicle_Manufacturer__c = carModelsByCode.get(policyTransaction.Vehicle_Model__c).Name;
            }
        }
        
        // this function is for determine the status of the Policy_Transaction__c record
        public static void processPolicyTransaction(Policy_Transaction__c pTransaction ,map<Id,Novidea_HPC__Policy__c> mapAllPolicy){
            Boolean findPolicy = false ;
            Boolean findCustomerAccount = false ;
            Boolean findBroker = false ;
            Boolean fullMatch = false ;
            pTransaction.is_Account_Found__c = false;
            pTransaction.Is_Broker_Found__c =false;
            pTransaction.Is_Policy_found__c =false;
            pTransaction.Is_carrier_Found__c = false;
            if (pTransaction.Policy__c == null){
                pTransaction.Comments_Policy__c =' לא נמצאה פוליסה במערכת, נא צור פוליסה חדשה';
            }
            //TODO: raniz 2/7/2013: THERE IS A BUG HERE: rematch was pressed in a state of fullauto identification. In this state the policy number will be on 
            //transaction and it wil considered as if the policy was located in rematch when in fact nothing in data has changed.
            //this was intended to hapen only on "merge" key press, but erronously it happens also on rematch
            else{
                pTransaction.Comments_Policy__c =' הפוליסה קיימת במערכת';
                findPolicy = true;
                pTransaction.Is_Policy_found__c = true;
            }
            if(pTransaction.Broker_Number__c == null){
                pTransaction.Comments_Agent_number__c =' לא נמצא סוכן במערכת, נא צור את הסוכן';
            }
            else{
                pTransaction.Comments_Agent_number__c = ' הסוכן קיים במערכת';
                findBroker = true;
                pTransaction.Is_Broker_Found__c =true;
            }
            if(pTransaction.Customer_Account__c == null){
                pTransaction.comments_customer_account__c = 'לא נמצא חשבון במערכת, אנא צור חשבון חדש';
            }
            else{
                pTransaction.comments_customer_account__c = 'החשבון קיים במערכת';
                findCustomerAccount = true;
                pTransaction.is_Account_Found__c =true;
            }
            /*
                raniz comment-out 13/06/2012: && findCustomerAccount:
                Need to allow saving updates if policy exits even if account wasn't found
                so the fullmatch flag should be true for that purpose (policy account will remain as is)
            */
            if(findPolicy /*&& findCustomerAccount*/ && findBroker){
                fullMatch = true;
            }
            
            Novidea_HPC__Policy__c pol;
            if(pTransaction.Policy__c != null){
                 if((pol = mapAllPolicy.get(pTransaction.Policy__c)) != null){                    
                    if (pTransaction.Broker_Number__c != null && ((pol.Novidea_HPC__Broker_In_Carrier__c == null) ||
                        (pol.Novidea_HPC__Broker_In_Carrier__c != null && pTransaction.Broker_Number__c != pol.Novidea_HPC__Broker_In_Carrier__c)) ){
//                        system.debug('pTransaction.Broker_Number__c != pol.Novidea_HPC__Broker_In_Carrier__c: ' +  
//                            pTransaction.Broker_Number__c  + ' ' + pol.Novidea_HPC__Broker_In_Carrier__c);  
                        pTransaction.Comments_Agent_number__c = ' נמצא סוכן במערכת, אבל הסוכן לא מופיע בפוליסה הנוכחית  ' ;
                        //fullMatch = false ;
                    }

                    if (pTransaction.Customer_Account__c != null){
                        /*
                            raniz change 13/06/2012: split if condition into 2
                            Need to allow saving updates if policy exits even if account wasn't found or does not match the policy's account
                            so the fullmatch flag should be true for that purpose (account will be updated to the new one)
                            kept the "fullMatch = false" in case pol.Novidea_HPC__client__c == null since in that unprobable case there is no account to copy later
                        */
                        if( pol.Novidea_HPC__client__c == null ||( pol.Novidea_HPC__client__c != null && pTransaction.Customer_Account__c != pol.Novidea_HPC__client__c)){
                            pTransaction.comments_customer_account__c = ' נמצא חשבון במערכת אבל החשבון לא תואם את הפוליסה   ' ;
                            //fullMatch = false ;
                            pTransaction.is_Account_Found__c =false;
                        }                        
                        if(pol.Novidea_HPC__client__c == null){
                            fullMatch = false ;
                        }   
                   }
                    if (pTransaction.Carrier__c != null && ( pol.Novidea_HPC__Carrier__c == null || (pol.Novidea_HPC__Carrier__c != null && pTransaction.Carrier__c != pol.Novidea_HPC__Carrier__c ))){
                        pTransaction.Comments_Insurance_Company__c = ' היצרן לא תואם ליצרן שבפוליסה  ';
                        fullMatch = false ; 
                        pTransaction.Is_carrier_Found__c = false;
                    }
                    else if(pTransaction.Carrier__c != null){
                        pTransaction.Is_carrier_Found__c =true;
                    }
                 }
                
            }
            if (fullMatch){
                pTransaction.Identification_Type__c = 'Policy Number';
                pTransaction.Status__c = 'compatible';
            }
            else{
                pTransaction.Status__c = 'not compatible';
            }
        }

        private static void populatePolicyIdSet(set<String> policyIdSet, String carrierFileCode, String polNumberFromCarrier, String prodNumberFromCarrier){
            String key = generatePolicyMapKey(carrierFileCode, polNumberFromCarrier, prodNumberFromCarrier);
            policyIdSet.add(key);
        }
        
        //this function will run on a list of Policy_Transaction__c and will try to rematch the the lookup 
        public static List<Policy_Transaction__c> reMatch(list<Policy_Transaction__c> listTransaction){
            
            set<string> setCarrierDecId = new set<string>(); 
            for ( Policy_Transaction__c policyTransaction : listTransaction ){
                 if (policyTransaction.Carrier_File_Code__c != null ){
                    try{
                        setCarrierDecId.add(policyTransaction.Carrier_File_Code__c);                       
                    }
                    catch(exception e){}
                 }
            }                       
            list<Account> listInsuranceCompany = [SELECT Carrier_File_Code__c FROM Account WHERE Carrier_File_Code__c IN : setCarrierDecId ];
            map<string,string> mapAccountExternalIdToSFId = new map<string,string>();
            for(Account acc : listInsuranceCompany){
                mapAccountExternalIdToSFId.put(string.valueOf(acc.Carrier_File_Code__c),acc.Id);
            }
            set<string> setlineProduct = new set<string>();
            set<string> setClientId = new set<string>();
            //set<string> setClientStrId = new set<string>();         
            set<string> setBrokerId = new set<string>();
            set<string> policyIdSet = new set<string>();
            set<Id> setCarrierId = new set<Id>(); 
            set<string> setClientNumberFromAgent = new set<string>();
            set<String> carModelCodeSet = new set<String>();
            String tmpVal;
            // run on all the Transaction and read the policy Content 
            for (Policy_Transaction__c policyTransaction : listTransaction){
                
                if(policyTransaction.Carrier_File_Code__c != null ){
                    if ((tmpVal = mapAccountExternalIdToSFId.get(policyTransaction.Carrier_File_Code__c)) != null){
                        policyTransaction.Carrier__c = tmpVal;
                        setCarrierId.add(policyTransaction.Carrier__c);
                    } 
                }                       
                if(policyTransaction.Insured_number__c != null){
                    //rz add condition 29/8/2012: when '0' is added accounts can be identified by related contact SSN = '0'
                    if(!'0'.equals(policyTransaction.Insured_number__c))
                        setClientId.add(policyTransaction.Insured_number__c);
                    setClientId.add(leftPadZeros(policyTransaction.Insured_number__c));
                } 
                
                populatePolicyIdSet(policyIdSet, policyTransaction.Carrier_File_Code__c, policyTransaction.Policy_number_from_Insurance_company__c, policyTransaction.product_from_insurance_company__c);   
                           
                if (policyTransaction.Agent_number_from_Insurance_comapny__c != null){
                    setBrokerId.add(policyTransaction.Agent_number_from_Insurance_comapny__c);
                }
                if (policyTransaction.product_from_insurance_company__c != null){                               
                    setlineProduct.add(policyTransaction.product_from_insurance_company__c);
                }
                if (policyTransaction.client_Number_From_Agent__c != null && policyTransaction.client_Number_From_Agent__c != '0'){
                    //rewriten by raniz 15/5/2012
                    setClientNumberFromAgent.add(policyTransaction.client_Number_From_Agent__c + ',' + policyTransaction.Carrier__c + ',' + policyTransaction.Agent_number_from_Insurance_comapny__c);
                }

            }
             
/*        
            system.debug('listTransaction : ' + listTransaction); 
            system.debug('setClientNumberFromAgent : ' + setClientNumberFromAgent); 
            system.debug('setClientId : ' + setClientId); 
            system.debug('setBrokerId : ' + setBrokerId); 
            system.debug('policyIdSet : ' + policyIdSet); 
            system.debug('setCarrierId : ' + setCarrierId);    
            system.debug('setlineProduct : ' + setlineProduct);                      
*/            
             
            // No need for previous year head-to-toe method in the merge transaction page. 
            map<string, list<String>> thisYearToLastYearPolicyNumbersMap = new map<string, list<String>>(); 
            Set<String> lastYearPolicyNumbers = new Set<String>(); 
            processPolicyTransaction(listTransaction, setClientNumberFromAgent, setClientId, setBrokerId, policyIdSet,
                thisYearToLastYearPolicyNumbersMap, lastYearPolicyNumbers, setCarrierId, setlineProduct, carModelCodeSet);  

            Database.update(listTransaction);
            
            automaticMatching(listTransaction);
            
            return listTransaction;                         
        }
        
    public class PolicyTransactionSummery {
        public String premiumCurrency {
            get {
                if (transactions != null && !transactions.isempty())
                    return transactions[0].Premium_Currency__c;
                return null;
            }
        }
        public String policyNumber {
            get {
                if (transactions != null && !transactions.isempty())
                    return transactions[0].Policy_number_from_Insurance_company__c;
                return null;
            }
        }
        public String clientId {
            get {
                if (transactions != null && !transactions.isempty())
                    return transactions[0].Customer_Account__c;
                return null;
            }
        }
        public Integer premiumBruto {
            get {
                if(premiumBruto == null && transactions != null && !transactions.isempty()) {
                    premiumBruto = 0;
                    for (Policy_Transaction__c policyTransaction:transactions){
                        if(policyTransaction.premium__c != null) premiumBruto += Decimal.valueOf(policyTransaction.premium__c).intValue();
                        //16/7/13 rz change: fixing a bug following the change "TempFix 09/07/2012" that turned 
                        //the premium field to be the net amount, without changing this. it created a bug
                        if(policyTransaction.Fee__c != null) premiumBruto += policyTransaction.Fee__c.intValue();
                    }
                }
                return premiumBruto;
            }
            private set;
        }
        
        public Id productDefCategory{
            get{
                return transactions[0].Carrier_Product__r.Novidea_HPC__Product_Definition__r.Novidea_HPC__Category__c;
            }
        }
        
        public String transactionId {
            get {
                if (transactionId == null && transactions != null && !transactions.isEmpty()) {
                    String[] valArr = new String[]{'','','','','',''};
                    if(transactions[0].Customer_Account__c != null)
                        valArr.set(0,((String)transactions[0].Customer_Account__c).substring(0,15));
                    if (transactions[0].Effective_Date__c != null)
                        valArr.set(1,String.valueOf(transactions[0].Effective_Date__c));
                    if (transactions[0].Expiration_Date__c != null)
                        valArr.set(2,String.valueOf(transactions[0].Expiration_Date__c));
                    if (transactions[0].Master_Product_Definition__c != null)
                        valArr.set(3,((String)transactions[0].Master_Product_Definition__c).substring(0,15));
                    if (transactions[0].Carrier__c != null)
                        valArr.set(4,((String)transactions[0].Carrier__c).substring(0,15));
                    if (transactions[0].Agent_number_from_Insurance_comapny__c != null)
                        valArr.set(5,(transactions[0].Agent_number_from_Insurance_comapny__c));
                   String formatString = '{0}___{1}___{2}___{3}___{4}___{5}';
                   transactionId = string.format(formatString,valArr);
              }
              return transactionId;
            }
            private set;
        }
        
        public String transactionIdForVehicle{
            get {
                if (transactionIdForVehicle == null && transactions != null && !transactions.isEmpty()) {
                    boolean useBroker = generalSetting.Match_vehicle_prod_by_broker_number__c==true;
                    String[] valArr;
                    if(useBroker) valArr= new String[]{'','','','','',''};
                    else valArr= new String[]{'','','','',''};
                    if(transactions[0].Customer_Account__c != null)
                        valArr.set(0,((String)transactions[0].Customer_Account__c).substring(0,15));
                    if (transactions[0].Effective_Date__c != null)
                       valArr.set(1,string.format('{0}-{1}',new String[]{transactions[0].Effective_Date__c.month()+'', transactions[0].Effective_Date__c.year()+''}));
                    if (transactions[0].Master_Product_Definition__c != null)
                        valArr.set(2,((String)transactions[0].Master_Product_Definition__c).substring(0,15));
                    if (transactions[0].Carrier__c != null)
                        valArr.set(3,((String)transactions[0].Carrier__c).substring(0,15));
                    if (transactions[0].Agent_number_from_Insurance_comapny__c != null && useBroker)
                        valArr.set(4,(transactions[0].Agent_number_from_Insurance_comapny__c));
                    if (transactions[0].Vehicle_Number__c != null)
                        valArr.set(useBroker?5:4,transactions[0].Vehicle_Number__c);
                   String formatString;
                   if(useBroker) formatString = '{0}___{1}___{2}___{3}___{4}___{5}';
                   else formatString = '{0}___{1}___{2}___{3}___{4}';
                   transactionIdForVehicle = string.format(formatString,valArr);
                }
                return transactionIdForVehicle;
            }
            private set;
            
        }
        
        public String partialTransactionId{
            get{
                if (partialTransactionId == null && transactions != null && !transactions.isEmpty()) {
                    String[] valArr = new String[]{'','','','',''};
                    if (transactions[0].Customer_Account__c != null)
                        valArr.set(0,((String)transactions[0].Customer_Account__c).substring(0,15));
                    if (transactions[0].Master_Product_Definition__c != null)
                        valArr.set(1,((String)transactions[0].Master_Product_Definition__c).substring(0,15));
                    if (transactions[0].Carrier__c != null)
                        valArr.set(2,((String)transactions[0].Carrier__c).substring(0,15));
                    if (transactions[0].Agent_number_from_Insurance_comapny__c != null)
                       valArr.set(3,(transactions[0].Agent_number_from_Insurance_comapny__c));
                   String formatString = '{0}___{1}___{2}___{3}';
                   partialTransactionId = string.format(formatString,valArr);
                }
                return partialTransactionId;                
            }
            private set;
        }
        
        public Integer identificationLevel {
            get {
                if (identificationLevel == null)
                    identificationLevel = 0;
                return identificationLevel;
            }
            set;
        }
        
        public Novidea_HPC__Policy__c matchingPolicy {
            get;
            set {
                Integer inIdentificationLevel = getIdentificationLevel(value);
//                system.debug('identificationLevel: ' + identificationLevel + ' - ' + matchingPolicy + 
//                            '\ninIdentificationLevel: ' + inIdentificationLevel + ' - ' + value);
                //raniz change 08/08/12: only allow setting matching policy if Identification level >0
                if(value != null && inIdentificationLevel>0 && 
                    (matchingPolicy == null || identificationLevel < inIdentificationLevel ||
                    identificationLevel == inIdentificationLevel && value.Novidea_HPC__Expiration_Date__c > matchingPolicy.Novidea_HPC__Expiration_Date__c
                    /*&& (matchingPolicy.Novidea_HPC__Policy_Number__c == null || matchingPolicy.Novidea_HPC__Policy_Number__c.startsWith('-'))*/ 
                    ) 
                ){
                    matchingPolicy = value;
                    identificationLevel = inIdentificationLevel;
                }  
            }
        }
        
        public Novidea_HPC__Income__c matchingIncome {get;set;}
        
        public list<Policy_Transaction__c> transactions {get;private set;}
        
        public void addTransaction(Policy_Transaction__c policyTransaction){
            premiumBruto = null;
            transactionId = null;
            partialTransactionId = null;
            this.transactions.add(policyTransaction);
        }
        public PolicyTransactionSummery() {
            this.transactions = new list<Policy_Transaction__c>();
        }
        
        public PolicyTransactionSummery(List<Policy_Transaction__c> transactions) {
            this.transactions = transactions;
        }
        
        private Integer getIdentificationLevel(Novidea_HPC__Policy__c policy) {
            //Noga 13/08/2012: minimum match criteria is: broker number, carrier & product in carrier 
            if(policy.Novidea_HPC__Client__c != transactions[0].Customer_Account__c || 
                    policy.Novidea_HPC__Client__c==null && transactions[0].Customer_Account__c==null ||
                    policy.Novidea_HPC__Carrier__c != transactions[0].Carrier__c || 
                    policy.Novidea_HPC__Carrier__c==null && transactions[0].Carrier__c==null ||
                    //policy.Novidea_HPC__Carrier_Product_Number__c != transactions[0].Carrier_Product__c ||
                    //policy.Novidea_HPC__Carrier_Product_Number__c==null && transactions[0].Carrier_Product__c==null ||
                    policy.Master_Product_Definition__c != 
                            transactions[0].Master_Product_Definition__c ||
                    policy.Master_Product_Definition__c==null && transactions[0].Master_Product_Definition__c==null ||
                    policy.Novidea_HPC__Broker_In_Carrier__c!=null && 
                        policy.Novidea_HPC__Broker_In_Carrier__r.Novidea_HPC__Broker_Number_In_Carrier__c != transactions[0].Agent_number_from_Insurance_comapny__c || 
                    (policy.Novidea_HPC__Broker_In_Carrier__r==null || 
                            policy.Novidea_HPC__Broker_In_Carrier__r.Novidea_HPC__Broker_Number_In_Carrier__c==null) && 
                                    transactions[0].Agent_number_from_Insurance_comapny__c==null)
                return 0;
            Integer returnValue = 1;
            if(policy.Novidea_HPC__Effective_Date__c == transactions[0].Effective_Date__c)
                returnValue++;
            if(policy.Novidea_HPC__Expiration_Date__c == transactions[0].Expiration_Date__c)
                returnValue++;
            return returnValue;
        }
        
        public map<String,String> missingFields {
            get {
                map<String,String> returnValue = new map<String,String>();
                if (matchingPolicy.Novidea_HPC__Effective_Date__c != transactions[0].Effective_Date__c)
                    returnValue.put(SObjectType.Novidea_HPC__Policy__c.fields.Novidea_HPC__Effective_Date__c.getLabel(),'');
                if (matchingPolicy.Novidea_HPC__Expiration_Date__c != transactions[0].Expiration_Date__c)
                    returnValue.put(SObjectType.Novidea_HPC__Policy__c.fields.Novidea_HPC__Expiration_Date__c.getLabel(),'');
                //if (matchingPolicy.Novidea_HPC__Carrier_Product_Number__c != transactions[0].Carrier_Product__c)
                    //returnValue.put(SObjectType.Novidea_HPC__Policy__c.fields.Novidea_HPC__Carrier_Product_Number__c.getLabel(),''); 
                if (matchingPolicy.Master_Product_Definition__c != transactions[0].Master_Product_Definition__c)
                    returnValue.put(SObjectType.Novidea_HPC__Policy__c.fields.Novidea_HPC__Carrier_Product_Number__c.getLabel(),''); 
                if (matchingPolicy.Novidea_HPC__Broker_In_Carrier__c==null || matchingPolicy.Novidea_HPC__Broker_In_Carrier__c!=null &&  matchingPolicy.Novidea_HPC__Broker_In_Carrier__r.Novidea_HPC__Broker_Number_In_Carrier__c != transactions[0].Agent_number_from_Insurance_comapny__c)
                    returnValue.put(SObjectType.Novidea_HPC__Policy__c.fields.Novidea_HPC__Broker_In_Carrier__c.getLabel(),'');
                if (matchingPolicy.Novidea_HPC__Carrier__c != transactions[0].Carrier__c)
                    returnValue.put(SObjectType.Novidea_HPC__Policy__c.fields.Novidea_HPC__Carrier__c.getLabel(),'');
                return returnValue;
            }
        }
    }
    
    /*
        this method is activated right after trying to match policies according to number
    */
    public static void automaticMatching(list<Policy_Transaction__c> listTransaction){
        //if (Userinfo.getUserId() != '005D0000001zbHbIAI')
        //  return;
//        if(!listTransaction.isempty()) system.debug('listTransaction[0]: ' + listTransaction[0]);
        //find all txs that ahve no match but have identified customer. The reason for reloading the list is 
        //to make sure that we have all relevant Txs for complete premium comparison.
        list<Policy_Transaction__c> transactionsWithNoMatch = 
            [SELECT Premium__c, Policy__c, Broker_Number__c, Carrier_Product__c, Carrier_Product__r.Novidea_HPC__Product_Definition__c, Carrier__c, 
                    Premium_Currency__c, Policy_number_from_Insurance_company__c, Identification_Type__c, Master_Product_Definition__c,
                    Customer_Account__c, Effective_Date__c, Expiration_Date__c, Agent_number_from_Insurance_comapny__c, product_from_insurance_company__c,
                    Carrier_Product__r.Novidea_HPC__Product_Definition__r.Novidea_HPC__Category__c, Client__c, Vehicle_Number__c
            FROM Policy_Transaction__c
            WHERE Id IN :listTransaction 
            AND Policy__c = null 
            AND Customer_Account__c != null];
    
        map<String, PolicyTransactionSummery> transactionSummeries = new map<String, PolicyTransactionSummery>();
        
        Set<Id> clientIds  = new Set<Id>();
        String key;
        //set identification level to None & build Client Ids set 
        for (Policy_Transaction__c policyTransaction:transactionsWithNoMatch) {
            policyTransaction.Identification_Type__c = 'None';
            clientIds.add(policyTransaction.Customer_Account__c);
            //add the sepecific tx to a map with policy numebr + product key. there can be several txs (endorsements) per policy and PolicyTransactionSummery indeed holds several txs
            //rz change 29/7/2013: differenciate txs by product as well as pol number
            key = generatePolicyMapKey(policyTransaction.Carrier_File_Code__c, policyTransaction.Policy_number_from_Insurance_company__c,policyTransaction.product_from_insurance_company__c);
//            system.debug('key: ' + key + ' policyTransaction.product_from_insurance_company__c: ' + policyTransaction.product_from_insurance_company__c);
            if(!transactionSummeries.containsKey(key))
                transactionSummeries.put(key, new PolicyTransactionSummery());
            transactionSummeries.get(key).addTransaction(policyTransaction);
        }
//        system.debug('automaticMatching 1: transactionSummeries : ' + transactionSummeries);
        //try to fully match policies. Comming out of this operation with either total match (including premium) or full match (only without premium) 
        doFullAutomaticMatching(transactionSummeries, clientIds);
//        system.debug('automaticMatching 2: transactionSummeries : ' + transactionSummeries);
        //see if there is a partial match and analyze which fields did not match
        doSemiAutomaticMatching(transactionSummeries, clientIds);
        
        Database.update(transactionsWithNoMatch);
    }
    
    /**
    * transactionSummeries = all the wanted transactions mapped by their policy number. 
    *     The function alters the data in the map so that each transaction list returns linked to it's representing income. 
    * The function updates only the policies in the database that are fully matched to the transactions.
    * It is required by the user to update the list of transactions after calling this method.  
    **/
    private static void doFullAutomaticMatching(map<String, PolicyTransactionSummery> transactionSummeries, Set<Id> clientIds) {
        map<Id,String> policiesIdsToNumber = new map<Id, String>();
        map<String, PolicyTransactionSummery> transactionByTransactionId = new map<String, PolicyTransactionSummery>();
        map<String, PolicyTransactionSummery> transactionByVehicleTransactionId = new map<String, PolicyTransactionSummery>();

        set<Id> vehicleCats = getVehicleCategories();
//      system.debug('transactionSummeries: ' + transactionSummeries + '\n' + vehicleCats);
        //go through all tx that need a match and orgenize by a tx-Id concatenation for later comparison to income. all txs under each transactionSummery have the same tx-Id
        for(PolicyTransactionSummery transactionSummery:transactionSummeries.values()){
//          system.debug('transactionSummery.productDefCategory ' + transactionSummery.productDefCategory);
            //TODO: Check length and case sensitivity
            if(vehicleCats.contains(transactionSummery.productDefCategory)){
                transactionByVehicleTransactionId.put(transactionSummery.transactionIdForVehicle, transactionSummery);
            }
            else transactionByTransactionId.put(transactionSummery.transactionId, transactionSummery);
        }
        
//        system.debug('transactionByTransactionId: ' + transactionByTransactionId + '\ntransactionByVehicleTransactionId: ' +  transactionByVehicleTransactionId);
        //Novidea_HPC__Policy__r.Novidea_HPC__Insured_Person__c, Novidea_HPC__Policy__r.Novidea_HPC__Car_Number__c, Transaction_Id_For_Vehicle__c, Novidea_HPC__Policy__r.Novidea_HPC__Product_Definition__r.Novidea_HPC__Category__c

        //compare against incomes in order to compar the premium. Incomes are selected if they have the same tx-Id 
        //as in the keyset above and their policy don't have number or with negative number 
        list<Novidea_HPC__Income__c> matchingIncomes = [SELECT Novidea_HPC__Premium_Currency__c, Novidea_HPC__Premium__c, 
                                                                Novidea_HPC__Fees__c, Novidea_HPC__Policy__c, 
                                                                Transaction_Id__c, Transaction_Id_For_Vehicle__c
                FROM Novidea_HPC__Income__c
                WHERE Novidea_HPC__Policy__r.Novidea_HPC__Client__c IN :clientIds 
                AND((Novidea_HPC__Policy__r.Novidea_HPC__Product_Definition__r.Novidea_HPC__Category__c NOT IN : vehicleCats 
                    AND Transaction_Id__c IN :transactionByTransactionId.keySet())
                OR (Novidea_HPC__Policy__r.Novidea_HPC__Product_Definition__r.Novidea_HPC__Category__c IN : vehicleCats 
                    AND Transaction_Id_For_Vehicle__c IN:transactionByVehicleTransactionId.keySet())
                )
                AND (Novidea_HPC__Policy__r.Novidea_HPC__Policy_Number__c = null OR Novidea_HPC__Policy__r.Novidea_HPC__Policy_Number__c Like '-%')];
        
        //compair premiums
        //there can be several loops here because each transactionSummery can be called according to the tx-id several times
        PolicyTransactionSummery transactionSummery;
        for (Novidea_HPC__Income__c income : matchingIncomes) {
            transactionSummery = transactionByVehicleTransactionId.get(income.Transaction_Id_For_Vehicle__c);
            if(transactionSummery==null) transactionSummery = transactionByTransactionId.get(income.Transaction_Id__c);
           
            //added because the query fetches matches that are case-insensitive and we need case sensitivity (the exact Ids that form the transaction ids)
            if (transactionSummery == null) continue;

            if(!vehicleCats.contains(transactionSummery.productDefCategory)){
                Decimal premiumBruto = 0;
                if (income.Novidea_HPC__Premium__c != null)
                    premiumBruto = income.Novidea_HPC__Premium__c;
                if (income.Novidea_HPC__Fees__c != null)
                    premiumBruto += income.Novidea_HPC__Fees__c;
                
                //if premiums match set the policiesIdsToNumber map to mark that a total id level has been reached
                //assuming here that the premiumCurrency is the same in all txs and that premiumBruto is a sum of all txs
                //that should be compared to a single income
                if (transactionSummery.premiumCurrency == income.Novidea_HPC__Premium_Currency__c &&
                        Math.abs((transactionSummery.premiumBruto - premiumBruto  + 0.000001 ) / ( transactionSummery.premiumBruto + 0.00001 )) < 0.01) {
                    policiesIdsToNumber.put(income.Novidea_HPC__Policy__c, transactionSummery.policyNumber);
                    transactionSummery.matchingIncome = income;
                }
                else {
                    if (transactionSummery.matchingIncome == null) {
                        transactionSummery.matchingIncome = income;
                    }
                }
            }
            else{
                policiesIdsToNumber.put(income.Novidea_HPC__Policy__c, transactionSummery.policyNumber);
                transactionSummery.matchingIncome = income;
            }
        }
        
        for (Novidea_HPC__Income__c income : matchingIncomes){
            transactionSummery = transactionByVehicleTransactionId.get(income.Transaction_Id_For_Vehicle__c);
            if(transactionSummery==null) transactionSummery = transactionByTransactionId.get(income.Transaction_Id__c);
            //added because the query fetches matches that are case-insensitive and we need case sensitivity (the exact Ids that form the transaction ids)
            if (transactionSummery == null) continue;
            
            for (Policy_Transaction__c policyTransaction:transactionSummery.transactions) {
                policyTransaction.Policy__c = transactionSummery.matchingIncome.Novidea_HPC__Policy__c;
                if(policiesIdsToNumber.containsKey(transactionSummery.matchingIncome.Novidea_HPC__Policy__c)){
                    policyTransaction.Identification_Type__c = 'Policy Number';
                    policyTransaction.Status__c = 'compatible';
                    policyTransaction.Is_Policy_Found__c = true;
                    policyTransaction.Comments_Policy__c = null;
                }
                else if(!vehicleCats.contains(transactionSummery.productDefCategory)){
                    policyTransaction.Identification_Type__c = 'Full Auto';
                    policyTransaction.Comments_Policy__c = 'יש התאמה מלאה מלבד בפרמיה לפוליסה קיימת במערכת';
                }
            }
        }
        
        list<Novidea_HPC__Policy__c> matchingPolicies = [SELECT Novidea_HPC__Policy_Number__c
                                                        FROM Novidea_HPC__Policy__c
                                                        WHERE Id IN :policiesIdsToNumber.keySet()];
        for (Novidea_HPC__Policy__c policy : matchingPolicies)
            policy.Novidea_HPC__Policy_Number__c = policiesIdsToNumber.get(policy.Id);
        
        Database.update(matchingPolicies);
    }
    
    
    /**
    * transactionSummeries = all the transactions, some of which still need to be matched, mapped by their policy number. 
    *       The function alters the data in the map so that each transaction list returns linked to it's representing income.
    *       The function will alter only transaction summeries that has no income defined.  
    * It is required by the user to update the list of transactions after calling this method.
    **/
    private static void doSemiAutomaticMatching(map<String, PolicyTransactionSummery> transactionSummeries, Set<Id> clientIds) {
        map<String, PolicyTransactionSummery> policyTransactionsByPartialTransactionId = new map<String, PolicyTransactionSummery>();
        set<Id> vehicleCats = getVehicleCategories();
        //map the still unmatched txs according to client Id
        for (PolicyTransactionSummery transactionSummery:transactionSummeries.values()){
            if(transactionSummery.matchingIncome == null && !vehicleCats.contains(transactionSummery.productDefCategory))
                policyTransactionsByPartialTransactionId.put(transactionSummery.partialTransactionId, transactionSummery);
        }
//        system.debug('transactionSummeries : ' + transactionSummeries);
        
         
        //select the policies that match the client Ids (the minimum criteria) and do not have a number or have a negative number
        //raniz add 16/9/2013: filter by client and carrier to be selective - they are part of the partial tx Id so they must be !=null 
        /*this class is not relvant anymore(moved to Productsia package), comment this so can delete field Policy_Number_External__c 
        for (Novidea_HPC__Policy__c policy:[SELECT Novidea_HPC__Broker_In_Carrier__c, Novidea_HPC__Broker_In_Carrier__r.Novidea_HPC__Broker_Number_In_Carrier__c,
                                            Novidea_HPC__Client__c, Novidea_HPC__Effective_Date__c, Novidea_HPC__Expiration_Date__c, 
                                            Novidea_HPC__Carrier__c, Partial_Transaction_Id__c, Master_Product_Definition__c
                                        FROM Novidea_HPC__Policy__c
                                        WHERE Partial_Transaction_Id__c IN :policyTransactionsByPartialTransactionId.keySet()
                                        AND (Policy_Number_External__c = null OR Policy_Number_External__c Like '-%')
                                        AND Novidea_HPC__Client__c!=null
                                        AND Novidea_HPC__Client__c IN : clientIds
                                        AND Novidea_HPC__Carrier__c!=null]) {
            //added becuase query fetches case-insensitive results
            if(!policyTransactionsByPartialTransactionId.containskey(policy.Partial_Transaction_Id__c)) continue;
            //set the macthing policy with the logic in the property
            policyTransactionsByPartialTransactionId.get(policy.Partial_Transaction_Id__c).matchingPolicy = policy;
        }
       */ 
//        system.debug('policyTransactionsByPartialTransactionId: ' + policyTransactionsByPartialTransactionId);
        
        for (PolicyTransactionSummery transactionSummery:transactionSummeries.values()) {
//            system.debug('transactionSummery: ' + transactionSummery);
            if (transactionSummery.matchingPolicy != null) {
                for (Policy_Transaction__c policyTransaction:transactionSummery.transactions) {
                    policyTransaction.Policy__c = transactionSummery.matchingPolicy.Id;
                    policyTransaction.Identification_Type__c = 'Partially Auto';
                    policyTransaction.Comments_Policy__c = 'נמצאה פוליסה ללא מספר פוליסה, שאיננה מתאימה בשדות הבאים: ';
                    for (String fieldName:transactionSummery.missingFields.keySet()) {
                        policyTransaction.Comments_Policy__c += fieldName + ', ';
                    }
                    if(policyTransaction.Comments_Policy__c.endsWith(', '))
                        policyTransaction.Comments_Policy__c = policyTransaction.Comments_Policy__c.substring(0,policyTransaction.Comments_Policy__c.length()-2);
                    policyTransaction.Reason_for_Difference__c = ''; // TBD - is this redundent.
                }
            }
        }
    }       
   
}