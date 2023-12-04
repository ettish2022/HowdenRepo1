@RestResource(urlMapping='/ProductionFiling/v1/*')
global with sharing class ProductionFilingService {
    @HttpPost
    global static Map<String, String> fileMultipleProdFiles(String[] filesList, boolean validateOnly){
        Savepoint sp = Database.setSavePoint();
        Map<String, String> retVal = new Map<String, String>();
        if (filesList == null || filesList.size() == 0){
            System.debug('ProductionFiling service received empty files list.');
            return retVal;
        }

        System.debug('ProductionFiling service received ' + filesList.size() + ' files.');

        Map<String, PolicyFile> policyFiles = new Map<String, PolicyFile>();
        List<String> policyNumbersForQuery = new List<String>();
        for(String fileItem: filesList){
            String errorMessage;
            try {
                System.debug('Extracting policy number from file: ' + fileItem);
                PolicyFile currPolicy = getPolicyDetails(fileItem);
                policyFiles.put(fileItem, currPolicy);
                System.debug('Found policy with number: ' + currPolicy.policyNumber);
                policyNumbersForQuery.add(currPolicy.policyNumber);
            } catch (UnsupportFileException de){
                errorMessage = 'Unsupported file.';
            } catch (Exception e){
                errorMessage = e.getMessage();
            }

            if (errorMessage != null)
                retVal.put(fileItem, 'Failed filing the document: ' + errorMessage);
        }

        Map<String, List<Novidea_HPC__Policy__c>> policiesCache = queryAllPolicies(policyNumbersForQuery);

        NFILING__InboundDocument__c[] docList = new List<NFILING__InboundDocument__c>();
        for(String s: policyFiles.keySet()){
            String errorMessage;
            NFILING__InboundDocument__c doc;
            try {
                System.debug('Processing file: ' + s);
                doc = createDocument(policyFiles.get(s), policiesCache);
            } catch (NoPolicyFoundException ne){
                errorMessage = 'No policy found matching the given document';
            } catch (DuplicatePolicyFoundException de){
                errorMessage = 'Multiple policies were found matching the given document';
            } catch (UnsupportFileException de){
                errorMessage = 'Unsupported file.';
            } catch (Exception e){
                errorMessage = e.getMessage();
            }

            if (doc != null){
                retVal.put(s, doc.NFILING__Physical_Path__c);
                docList.add(doc);
            } else {
                retVal.put(s, 'Failed filing the document: ' + errorMessage);
            }
        }

        System.debug('Inserting documents list with ' + docList.size() + ' docs, validateOnly='+validateOnly);
        //InboundDocumentTriggerHelper.isDataLoaderRun = true; //This line is used only by Leaderim
        Database.insert(docList);

        if (validateOnly)
            Database.rollback(sp);

        return retVal;
    }

    private class UnsupportFileException extends Exception {}
    private class NoPolicyFoundException extends Exception {}
    private class DuplicatePolicyFoundException extends Exception {}

    private static Boolean validateId(String idNumber){
        Boolean result;
        String idType = NBU.IdentityUtils.getIsraeliIdType(idNumber);
        if(idType == NBU.IdentityUtils.ISRAELI_TAX_ID){
            result = NBU.IdentityUtils.validateIsraeliTaxNumber(idNumber);
        }else if(idType == NBU.IdentityUtils.ISRAELI_COMPANY_NUMBER){
            result = NBU.IdentityUtils.validateIsraeliCompanyNumber(idNumber);
        }else if(idType == NBU.IdentityUtils.ISRAELI_PESONAL_ID){
            result = NBU.IdentityUtils.validateIsraeliPersonalIdStrict(idNumber);
        }else{
            result = false;
        }

        return result;
    }

    private static PolicyFile getPolicyDetails(String fileName){
        String carrierName;
        String policyNum;

        if (fileName.startsWithIgnoreCase('Polisa-')){
            String ptrn = '(?i)(^Polisa-)(.*)([0-9]{2})([_])(.*)([.]Pdf$)';
            Pattern p = Pattern.compile(ptrn);
            Matcher m = p.matcher(filename);
            if (m.matches()){
                carrierName = 'Clal';
                policyNum = m.group(5) + ((m.group(2).length() == 8) ? '0':'') + m.group(2);
            } else {
                throw new UnsupportFileException();
            }
        } else if(fileName.startsWithIgnoreCase('P') && fileName.length() == 'P1016080299_501800533077000002.pdf'.length() && fileName.countMatches('_') == 1){
            carrierName = 'Harel';
            policyNum = fileName.substring(12, 24);
        //The following code was commented out due of not being in use in Leaderim and no relevant file could be found.
        // } else if (fileName.startsWithIgnoreCase('P') && fileName.length() > 11){
        //     carrierName = 'Phoenix';
        //     Integer startIdx = filename.indexof('_') + 1;
        //     if (startIdx > 0){
        //         policyNum = filename.substring(startIdx, fileName.length() - 10);
        //     }else{
        //         throw new UnsupportFileException();
        //     }
        } else if (fileName.startsWithIgnoreCase('G') && fileName.length() > 8){
            carrierName = 'Phoenix';
            policyNum = fileName.substring(1, fileName.length() - 7);
        } else if ((fileName.startsWithIgnoreCase('025')
                || fileName.startsWithIgnoreCase('180')
                || fileName.startsWithIgnoreCase('150')
                || fileName.startsWithIgnoreCase('125')
                || fileName.startsWithIgnoreCase('034')
                || fileName.startsWithIgnoreCase('650')
                || fileName.startsWithIgnoreCase('0630'))
                && fileName.length() > 20) {
            carrierName = 'Migdal';
            policyNum = fileName.substring(3, fileName.length() - 16);
            // Remove leading zeros
            policyNum = String.valueOf(Long.valueOf(policyNum));
        } else if(fileName.length() == '0034659714181005138488382360189901849911520308.pdf'.length() && validateId(fileName.substring(15, 24))){
            carrierName = 'Menora';
            policyNum = fileName.substring(0, 15);
        } else if(fileName.length() == '620_026221888118_1_320060_18061719302.pdf'.length() && fileName.countMatches('_') == 4){
            carrierName = 'Ayalon';
            policyNum = fileName.substring(4, 16);
        }else{
            throw new UnsupportFileException();
        }

        System.debug('Identified file of carrier ' + carrierName + ' with policy number ' + policyNum);

        return new PolicyFile(carrierName, policyNum, fileName);
    }

    private static NFILING__InboundDocument__c createDocument(PolicyFile policyFile, Map<String, List<Novidea_HPC__Policy__c>> policiesCache){
        Novidea_HPC__Policy__c policy = getPolicyDetails(policyFile.policyNumber, policiesCache);

        NFILING__InboundDocument__c doc;
        if (policy != null){
            doc = new NFILING__InboundDocument__c();
            doc.NFILING__Subject__c = policyFile.fileName;
            doc.NFILING__Date_Received__c = DateTime.now();
            doc.NFILING__Private__c = false;
            doc.NFILING__Type__c = (String)NFILING__Novidea_Document_Management__c.getInstance().NFILING__Production_Document_Type__c;
            doc.NFILING__Physical_Path__c = policyFile.getFilePath();
            doc.NFILING__EntExtId1__c = policy.Novidea_HPC__Client__c;
            doc.NFILING__EntExtId2__c = policy.ID;
        }

        return doc;
    }

    private static Map<String, List<Novidea_HPC__Policy__c>> queryAllPolicies(List<String> policyNumbersForQuery){
        Map<String, List<Novidea_HPC__Policy__c>> policiesCache = new Map<String, List<Novidea_HPC__Policy__c>>();

        for (Novidea_HPC__Policy__c p: [select ID, Novidea_HPC__Client__c, Novidea_HPC__Policy_Number__c from Novidea_HPC__Policy__c where Novidea_HPC__Policy_Number__c in :policyNumbersForQuery]){
            // Policy Number is the key to our cache
            String key = p.Novidea_HPC__Policy_Number__c;

            // First time we meet this policy number, create a list for it
            if (!policiesCache.containsKey(key)){
                policiesCache.put(key, new List<Novidea_HPC__Policy__c>());
            }

            List<Novidea_HPC__Policy__c> curPolList = policiesCache.get(key);
            curPolList.add(p);
        }

        return policiesCache;
    }

    private static Novidea_HPC__Policy__c getPolicyDetails(String policyNumber, Map<String, List<Novidea_HPC__Policy__c>> policiesCache){
        Novidea_HPC__Policy__c[] pol = policiesCache.get(policyNumber);

        if(NOVU.ArrayUtils.IsListNullOrEmpty(pol)){
            throw new NoPolicyFoundException ();
        }

        if (pol.size() > 1){ //TODO: Check if this can ever happen
            throw new DuplicatePolicyFoundException();
        }

        return pol[0];
    }

    class PolicyFile {
        public String policyNumber;
        public String carrierName;
        public String fileName;

        public PolicyFile(String carrierName, String policyNumber, String fileName){
            this.carrierName = carrierName;
            this.policyNumber = policyNumber;
            this.fileName = fileName;
        }

        public String getFilePath(){
            String filePath = (String)NFILING__Novidea_Document_Management__c.getInstance().NFILING__Network_Base_Path__c;
            String datePath = Datetime.now().format('yyyyMMdd');
            String productionFolderName = (String)NFILING__Novidea_Document_Management__c.getInstance().NFILING__Production_Folder_Name__c;
            filePath += '\\' + productionFolderName + '\\' + this.carrierName + '\\' + datePath + '\\' + this.fileName;

            return filePath;
        }
    }
}