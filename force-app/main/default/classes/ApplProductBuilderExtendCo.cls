global with sharing virtual class ApplProductBuilderExtendCo {
    //this class is used for profit center setting by transfer data to client (used in javascript only)

    global class SelectOptionSerializable {
        private String value { get; set; }
        private String label { get; set; }
        private Boolean selected { get; set; }

        global SelectOptionSerializable(String value, String label, Boolean selected) {
            this.value = value;
            this.label = label;
            this.selected = selected;
        }
        //for test
        global String getValue() {
            return value;
        }
    }

    // DIANA #902
    public class ProductWrapper {
        public Novidea_HPC__Product__c product {
            get {
                if (product.Novidea_HPC__Status__c == null)
                    product.Novidea_HPC__Status__c = 'Active';
                return product;
            }
            set;
        }
        public Integer id { get; set; }
        public String productDefName { get; set; }
        public String carrierName { get; set; }
        public String appId { get; set; }
        public Boolean isSelected { get; set; }
        public String cancellationReason { get; set; }
        public String lossCauseText { get; set; }
        public Boolean shouldShowModal { get; set; }
        public Boolean isResetExpectedData { get; set; }
        public Boolean isNew {
            get {
                return this.product.Id == null;
            }
        }
        public Boolean isAccepted {
            get {
                return ACCEPTED.equalsIgnoreCase(this.product.Novidea_HPC__Status__c);
            }
        }
        public Boolean isActive {
            get {
                return ACTIVE.equalsIgnoreCase(this.product.Novidea_HPC__Status__c);
            }
        }
        public Boolean isConverted {
            get {
                return CONVERTED.equalsIgnoreCase(this.product.Novidea_HPC__Status__c);
            }
        }
        public Boolean isCancelled {
            get {
                return isStatusCancelled(this.product.Novidea_HPC__Status__c);
            }
        }
        public Boolean isReadOnly {
            get {
                if (isReadOnly == null)
                    return !isNew && (isConverted || isAccepted || isCancelled);
                else
                    return isReadOnly; // Diana #1022
            }
            set;
        }
        public Boolean isSelectable {
            get {
                return (!isConverted && !isLost);
            }
        }
        public Boolean isDeletable {
            get {
                return (!isConverted && !isCancelled && !isAccepted);
            }
        }
        public Boolean isLost {
            get {
                return this.product.Novidea_HPC__Is_Lost__c;
            }
        }
        public Boolean hasRequiredType {
            get {
                return String.isNotBlank(this.product.Novidea_HPC__Required_Policy_Type__c);
            }
        }
        public String fieldSetStorage { get; private set; }
        public String requiredPolicyTypeLabel { get; private set; }

        public String profitCenter {
            get {
                if (String.isBlank(profitCenter) && fieldSetStorage.contains('Profit_Center_Name__c'))
                    profitCenter = Label.Novidea_HPC.Choose_profit_center;
                return profitCenter;
            }
            set;
        }

        public String productEffDate { //todo
            get {
                if (product != null && product.Novidea_HPC__Effective_Date__c != null)
                    return product.Novidea_HPC__Effective_Date__c.format();
                return null;
            }
            set {
                if (String.isNotBlank(value))
                    product.Novidea_HPC__Effective_Date__c = date.parse(value);
            }
        }

        public String productExpirationDate { //todo
            get {
                if (product != null && product.Novidea_HPC__Expiration_Date__c != null)
                    return product.Novidea_HPC__Expiration_Date__c.format();
                return null;
            }
            set {
                if (String.isNotBlank(value))
                    product.Novidea_HPC__Expiration_Date__c = date.parse(value);
            }
        }

        public ProductWrapper(Novidea_HPC__Product__c product, Integer id, String appId, String fieldSetStorage) {
            this.product = product;
            this.productDefName = product.Novidea_HPC__Product_Definition__r.Name;
            this.carrierName = product.Novidea_HPC__Carrier__r.Name;
            this.appId = appId;
            this.id = id;
            this.fieldSetStorage = fieldSetStorage;
            this.requiredPolicyTypeLabel = APP_REQ_POL_TYPE_VALUES_TO_LABELS.get(product.Novidea_HPC__Required_Policy_Type__c);
            this.isResetExpectedData = true;
            this.shouldShowModal = true;
        }

        //Diana #1227 03/02/2015
        public ProductWrapper(
            String existProductDefName,
            Novidea_HPC__Product__c clonedProduct,
            Integer id,
            String appId,
            String fieldSetStorage
        ) {
            this.product = clonedProduct;
            this.productDefName = existProductDefName;
            this.appId = appId;
            this.id = id;
            this.fieldSetStorage = fieldSetStorage;
            this.requiredPolicyTypeLabel = APP_REQ_POL_TYPE_VALUES_TO_LABELS.get(product.Novidea_HPC__Required_Policy_Type__c);
            this.isResetExpectedData = true;
            this.shouldShowModal = true;
        }
    }

    public static Boolean isStatusCancelled(String status) {
        if (
            String.isNotBlank(status) &&
            (status.equalsIgnoreCase(CANCELLED) ||
            status.equalsIgnoreCase(DECLINED_BY_INSURER) ||
            status.equalsIgnoreCase(DECLINED_BY_CLIENT))
        ) {
            return true;
        }
        return false;
    }

    @testvisible
    private static Novidea_HPC__General_Switches__c gs = Novidea_HPC__General_Switches__c.getInstance('Default');

    private static final JSONAutoLossCause applPBSettings {
        get {
            if (applPBSettings == null) {
                List<NOVU__General_Purpose__mdt> generalPurposeMTD = [
                    SELECT id, NOVU__General_Subscriber_Controlled__c
                    FROM NOVU__General_Purpose__mdt
                    WHERE DeveloperName = 'Application_Product_Builder_Setting'
                ];
                if (
                    !NOVU.ArrayUtils.isListNullOrEmpty(generalPurposeMTD) &&
                    String.isNotBlank(generalPurposeMTD[0].NOVU__General_Subscriber_Controlled__c)
                ) {
                    try {
                        applPBSettings = (JSONAutoLossCause) System.JSON.deserialize(
                            (String) generalPurposeMTD[0].NOVU__General_Subscriber_Controlled__c,
                            JSONAutoLossCause.class
                        );
                    } catch (Exception ex) {
                        System.debug(
                            'Missing JSON in Field NOVU__General_Subscriber_Controlled__c Under General Purpose Metadata - Application_Product_Builder_Setting\n' +
                            ex.getMessage()
                        );
                        applPBSettings = new JSONAutoLossCause();
                    }
                } else {
                    applPBSettings = new JSONAutoLossCause();
                }
            }
            return applPBSettings;
        }
        set;
    }

    private Boolean lossCauseReportingBehaviour {
        get {
            return gs.Novidea_HPC__Loss_Cause_Reporting_Behaviour__c == null ? false : gs.Novidea_HPC__Loss_Cause_Reporting_Behaviour__c;
        }
    }

    public Boolean ShowContent {
        get {
            if (ShowContent == null)
                return true;
            else
                return ShowContent;
        }
        set;
    }
    private static final String PREMIUM_CURRENCY_DEF;
    private static final String AGENCY_FEE_CURRENCY_DEF;
    private static final String LIABILITY_LIMIT_CURRENCY_DEF;
    public final static map<String, Schema.FieldSet> fsmap = Schema.SObjectType.Novidea_HPC__Product__c.fieldSets.getMap();
    public final static map<String, Schema.DescribeFieldResult> FIELDSPATH_NS = gs != null &&
        (gs.Novidea_HPC__Copy_Application_Product_To_RFP_Product__c == true ||
        gs.Novidea_HPC__Copy_RFP_Product_To_Proposal_Product__c == true)
        ? NOVU.FlatModelHelper.getFieldsDescribeWithNameSpace('novidea_hpc__product__c')
        : null;
    public final static map<String, Schema.DescribeFieldResult> FIELDSPATH_NO_NS = gs != null &&
        gs.Novidea_HPC__Copy_Application_Product_To_RFP_Product__c == true &&
        gs.Novidea_HPC__Copy_RFP_Product_To_Proposal_Product__c == true
        ? null
        : NOVU.FlatModelHelper.getFieldsDescribeByFilter('Novidea_HPC__Product__c', null);
    public final static map<String, String> APP_REQ_POL_TYPE_VALUES_TO_LABELS = NOVU.ArrayUtils.getPicklistValues(
        'novidea_hpc__required_policy_type__c',
        Novidea_HPC__Application__c.sObjectType
    );
    /**
     * Holds the financlial fields that need computations binary-wise with the following legend
     * 1=exp. premium; 2=exp. premium net;4=exp. fees, 8= exp. commission amount; 16= commission(%)
     */
    private final static Integer financialFieldsDisplayIndicator = getFinancialFieldsDisplayed();

    //product status values
    public static final String ACTIVE = 'Active';
    public static final String SEND = 'Send';
    public static final String RECEIVED = 'Received';
    public static final String CANCELLED = 'Cancelled'; // used also as RFP status
    public static final String PRODUCT_SENT_TO_CLIENT = 'בוצעה פניה ללקוח';

    public static final String DECLINED_BY_INSURER = 'DECLINED_BY_INSURER';
    public static final String DECLINED_BY_CLIENT = 'DECLINED_BY_CLIENT';

    public static final String SENT_TO_CLIENT = 'SENT_TO_CLIENT';

    public static final String ACCEPTED = 'Accepted';
    public static final String CONVERTED = 'Converted';

    //RFP status values
    public static final String SENT_TO_CARRIER = 'Sent To Carrier';
    public static final String RECEIVED_BY_CARRIER = 'Received By Carrier';
    public static final String PROPOSAL_RECEIVED = 'Proposal Received';
    public static final String CLOSED = 'Closed';

    //Proposal status values
    public static final String Rejected = 'Rejected';
    public static final String Coverage_Confirmation = 'Coverage Confirmation';

    public static map<String, String> prodRfpStatusRelationMap;
    public static map<String, String> prodProposalStatusRelationMap;
    public static map<String, Set<String>> statusDependencyMap;

    private static final Map<String, String> APLICATION_CANCELLATION_REASON_PICKLIST_VALUES = NOVU.ArrayUtils.getPicklistValues(
        'Novidea_HPC__Cancellation_Reason__c',
        Novidea_HPC__Application__c.sobjectType
    );
    public static String requiredNotesForLossCauseStatus {
        get {
            if (requiredNotesForLossCauseStatus == null) {
                requiredNotesForLossCauseStatus = applPBSettings.requiredNotesForLossCauseStatus == null
                    ? '[]'
                    : JSON.serialize(applPBSettings.requiredNotesForLossCauseStatus);
            }
            return requiredNotesForLossCauseStatus;
        }
        set;
    }
    public static String invalidStatusesAsLossCause {
        get {
            if (invalidStatusesAsLossCause == null) {
                invalidStatusesAsLossCause = applPBSettings.invalidStatusesAsLossCause == null
                    ? '[]'
                    : JSON.serialize(applPBSettings.invalidStatusesAsLossCause);
            }
            return invalidStatusesAsLossCause;
        }
        set;
    }

    public Id applicationId { get; set; }
    public String error { get; set; }
    public String lossReportPageLink { get; set; }
    public String selectCarrierPageLink { get; set; }
    public Boolean applicationStatusChanged { get; set; }
    public String policyEditUrl { get; set; }

    public list<productWrapper> products { get; set; }
    public Integer lineToRemove { get; set; }
    public Boolean atleastOneConverted { get; set; }
    public Boolean reInit = false;

    public Boolean enableSameProductDef {
        get {
            return gs.Novidea_HPC__Enable_Same_Product_Def__c == null ? false : gs.Novidea_HPC__Enable_Same_Product_Def__c;
        }
    }

    public Boolean enableSameProductDefMsg {
        get {
            return gs.Novidea_HPC__Enable_Same_Product_Def_Msg__c == null ? false : gs.Novidea_HPC__Enable_Same_Product_Def_Msg__c;
        }
    }

    public Novidea_HPC__Application__c theApplication {
        get {
            if (null == theApplication)
                theApplication = getApplicationById(applicationId);
            return theApplication;
        }
        set;
    }
    private static list<Schema.PicklistEntry> pickListTypeValues {
        get {
            if (null == pickListTypeValues) {
                Schema.DescribeFieldResult fieldResult = Novidea_HPC__Product__c.Novidea_HPC__Status__c.getDescribe();
                pickListTypeValues = fieldResult.getPicklistValues();
            }
            return pickListTypeValues;
        }
        set;
    }
    public map<String, list<SelectOption>> statusListMap {
        get {
            if (null == statusListMap) {
                statusListMap = new Map<String, list<SelectOption>>();
                for (String status : statusDependencyMap.keySet())
                    statusListMap.put(status, getProdStatusList(status));
            }
            return statusListMap;
        }
        set;
    }
    private Boolean editPolicyAfterConversion {
        get {
            return gs.Novidea_HPC__Edit_Policy_After_Conversion__c == null ? false : gs.Novidea_HPC__Edit_Policy_After_Conversion__c;
        }
    }

    //GLZ #1497
    public Boolean searchByGivenField {
        get {
            return gs.Novidea_HPC__Autocomplete_Search_By_Field__c == null ? false : gs.Novidea_HPC__Autocomplete_Search_By_Field__c;
        }
    }
    //GLZ #1280
    public Boolean popConvertionMsg {
        get {
            return gs.Novidea_HPC__Pop_Conversion_To_Policy_Msg__c == null ? false : gs.Novidea_HPC__Pop_Conversion_To_Policy_Msg__c;
        }
    }
    //GLZ #1251
    public Boolean autoPageRefresh {
        get {
            return gs.Novidea_HPC__Auto_Refresh_In_Application__c == null ? false : gs.Novidea_HPC__Auto_Refresh_In_Application__c;
        }
    }
    public Boolean refreshPageOnProductStatusChange {
        get {
            return gs.Novidea_HPC__Refresh_Upon_Each_Product_Status_Change__c == null
                ? false
                : gs.Novidea_HPC__Refresh_Upon_Each_Product_Status_Change__c;
        }
    }
    public Boolean productStatusChanged {
        get {
            if (productStatusChanged == null)
                return false;
            return productStatusChanged;
        }
        set;
    }
    //#1251 end

    public Boolean sendExceptionsEmails {
        get {
            return (null == gs || gs.Novidea_HPC__SendExceptionEmails__c == null) ? false : gs.Novidea_HPC__SendExceptionEmails__c;
        }
    }
    //static initialization code
    static {
        PREMIUM_CURRENCY_DEF = ConstructorPoliciesUtils.defaultPicklistValue('Novidea_HPC__Product__c', 'Novidea_HPC__Premium_Currency__c')
            .getValue();
        AGENCY_FEE_CURRENCY_DEF = ConstructorPoliciesUtils.defaultPicklistValue('Novidea_HPC__Product__c', 'Novidea_HPC__Agency_Fee_Currency__c')
            .getValue();
        LIABILITY_LIMIT_CURRENCY_DEF = ConstructorPoliciesUtils.defaultPicklistValue(
                'Novidea_HPC__Product__c',
                'Novidea_HPC__Liability_Limit_Currency__c'
            )
            .getValue();

        prodRfpStatusRelationMap = new Map<String, String>{
            SEND => SENT_TO_CARRIER,
            RECEIVED => PROPOSAL_RECEIVED,
            CANCELLED => CANCELLED,
            DECLINED_BY_INSURER => CANCELLED,
            DECLINED_BY_CLIENT => CANCELLED,
            ACCEPTED => PROPOSAL_RECEIVED
        };

        prodProposalStatusRelationMap = new Map<String, String>{
            RECEIVED => RECEIVED,
            CANCELLED => REJECTED,
            DECLINED_BY_INSURER => REJECTED,
            DECLINED_BY_CLIENT => REJECTED,
            ACCEPTED => RECEIVED
        };
        // Used by the page to define what status to show in the drop-list option according to the current status
        // Code Review: this is not a redundent solution.  The user can manually change the status of the product which in
        //		turn will corrupt the information when the page will do the action.
        statusDependencyMap = new Map<String, Set<String>>{
            ACTIVE => new Set<String>{ ACTIVE, SEND, PRODUCT_SENT_TO_CLIENT, CANCELLED, ACCEPTED, DECLINED_BY_CLIENT },
            SEND => new Set<String>{ SEND, RECEIVED, PRODUCT_SENT_TO_CLIENT, CANCELLED, DECLINED_BY_INSURER, DECLINED_BY_CLIENT },
            PRODUCT_SENT_TO_CLIENT => new Set<String>{
                PRODUCT_SENT_TO_CLIENT,
                RECEIVED,
                CANCELLED,
                ACCEPTED,
                DECLINED_BY_CLIENT,
                SENT_TO_CLIENT
            },
            RECEIVED => new Set<String>{ RECEIVED, CANCELLED, ACCEPTED, DECLINED_BY_CLIENT, SENT_TO_CLIENT },
            SENT_TO_CLIENT => new Set<String>{ SENT_TO_CLIENT, CANCELLED, ACCEPTED, DECLINED_BY_CLIENT },
            CANCELLED => new Set<String>{ CANCELLED },
            DECLINED_BY_INSURER => new Set<String>{ DECLINED_BY_INSURER },
            DECLINED_BY_CLIENT => new Set<String>{ DECLINED_BY_CLIENT },
            ACCEPTED => new Set<String>{ ACCEPTED }
        };
    }

    public List<Schema.FieldSetMember> getSelectedFields() {
        return ApplProductBuilderExtendCO.getTableExtensionFields();
    }

    private static List<Schema.FieldSetMember> getTableExtensionFields() {
        return fsmap.get('Novidea_HPC__ApplicationProductBuilderExtension').getFields();
    }
    private static List<Schema.FieldSetMember> getTableBaseFields() {
        Schema.FieldSet fs = Schema.SObjectType.Novidea_HPC__Product__c.fieldSets.getMap().get(getToGuiFieldShowFieldSet());
        if (null != fs)
            return fs.getFields();
        return new List<Schema.FieldSetMember>();
    }

    /**
        this assums that the actual fields of premium, commission_amount, fees will not be selected for the table since 
        the logic of conversion assumes values should be taken from expected fields. 
    */
    private static Integer getFinancialFieldsDisplayed() {
        Integer financialFieldsDisplay = 0;
        map<String, Integer> fieldNameToBitwiseValue = new Map<String, Integer>{
            'novidea_hpc__expected_premium__c' => 1,
            'novidea_hpc__expected_premium_net__c' => 2,
            'novidea_hpc__expected_fees__c' => 4,
            'novidea_hpc__expected_commission_amount__c' => 8,
            'novidea_hpc__commission__c' => 16
        };
        //assuming currently that novidea_hpc__expected_premium_net__c, novidea_hpc__expected_fees__c, novidea_hpc__commission__c
        //cannot be utilized becasue the page does not support it, therefore they are not checked within the base FS
        for (Schema.FieldSetMember field : getTableBaseFields()) {
            if (
                'novidea_hpc__expected_premium__c'.equalsIgnoreCase(field.getFieldPath()) ||
                'novidea_hpc__expected_commission_amount__c'.equalsIgnoreCase(field.getFieldPath())
            ) {
                financialFieldsDisplay |= getBitwiseMarker(fieldNameToBitwiseValue, field);
            }
        }
        for (Schema.FieldSetMember field : getTableExtensionFields()) {
            financialFieldsDisplay |= getBitwiseMarker(fieldNameToBitwiseValue, field);
        }
        return financialFieldsDisplay;
    }

    private static Integer getBitwiseMarker(map<String, Integer> fieldNameToBitwiseValue, Schema.FieldSetMember field) {
        Integer val = fieldNameToBitwiseValue.get(field.getFieldPath().toLowerCase());
        if (val == null)
            val = 0;
        return val;
    }

    public Boolean getErrorsPresent() {
        // Diana #1022
        return ApexPages.hasMessages(ApexPages.Severity.ERROR);
    }
    private static list<SelectOption> getProdStatusList(String currentStatus) {
        list<SelectOption> options = new List<SelectOption>();
        Set<String> possibleStatusList = statusDependencyMap.get(currentStatus);
        for (Schema.PicklistEntry picklistEntry : pickListTypeValues) {
            if (
                possibleStatusList.contains(picklistEntry.getValue()) // DIANA 15/01/2014 avoid hard codded statuses, add statuses that not do actions
            )
                options.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
        }
        return options;
    }

    public ApplProductBuilderExtendCo(ApexPages.StandardController controller) {
        applicationId = controller.getId();
    }

    public Boolean getHasAcceptedProducts() {
        Boolean hasAcceptedProducts = false;
        for (ProductWrapper cw : products)
            hasAcceptedProducts = hasAcceptedProducts || cw.isAccepted;
        return hasAcceptedProducts;
    }

    public Boolean getHasLostProducts() {
        Boolean hasLostProducts = false;
        for (ProductWrapper cw : products)
            hasLostProducts = hasLostProducts || cw.isCancelled;
        return hasLostProducts;
    }

    private list<Novidea_HPC__Product__c> productsForDeletion;
    public Integer getMaxIdVal() {
        Integer max = -1;
        if (products == null)
            return max;
        for (productWrapper cw : products) {
            if (cw.id > max)
                max = cw.Id;
        }
        return max;
    }

    private static String getToGuiFieldShowFieldSet() {
        if (null != gs && String.isNotBlank(gs.Novidea_HPC__Field_Set_to_Application_Product_Builder__c))
            return gs.Novidea_HPC__Field_Set_to_Application_Product_Builder__c;
        return 'Novidea_HPC__Application_Product_Builder_Page';
    }

    public Boolean getShowAddLineButton() {
        return gs.Novidea_HPC__Show_Add_Line_In_Application__c;
    }
    public Boolean getShowCloneButton() {
        return gs.Novidea_HPC__Show_Clone_In_Application__c;
    }
    public Boolean getMakeReadOnlyProductDef() {
        return gs.Novidea_HPC__Make_Product_Def_ReadOnly_In_Application__c;
    }

    public void init() {
        //for India when no product existing
        products = new List<productWrapper>();
        if (String.isBlank(applicationId))
            return;

        Set<ID> appProductIds = new Set<ID>();

        list<Novidea_HPC__Product__c> appProductList = getExistProdListByApplicationId(applicationId);
        for (Novidea_HPC__Product__c product : appProductList) {
            appProductIds.add(product.Id);
        }

        list<Novidea_HPC__Product__c> proposalProductList = getProposalProdForProfitCenterList(appProductIds);
        map<ID, String> appProd2ProfitCenter = new Map<ID, String>();
        for (Novidea_HPC__Product__c proposalProd : proposalProductList) {
            if (proposalProd.Novidea_HPC__Broker_In_Carrier__r.Name != null)
                appProd2ProfitCenter.put(
                    proposalProd.Novidea_HPC__Product__r.Novidea_HPC__Product__c,
                    proposalProd.Novidea_HPC__Broker_In_Carrier__r.Name
                ); //todo: name agency ?
        }
        for (Novidea_HPC__Product__c prod : appProductList) {
            ProductWrapper wrapper = new ProductWrapper(prod, getMaxIdVal() + 1, applicationId, fieldSetStorage);
            if (appProd2ProfitCenter.containsKey(prod.Id))
                wrapper.profitCenter = appProd2ProfitCenter.get(prod.Id);

            for (InnerLossCause innerLossCause : applPBSettings.jsonAutoLossCauseStatus) {
                if (isMatchAutoLossCause(prod, innerLossCause)) {
                    wrapper.shouldShowModal = false;
                    break;
                }
            }
            products.add(wrapper);
        }

        applicationStatusChanged = false;
        if (products.size() == 0) {
            if (!getShowAddLineButton() && getShowCloneButton() && getMakeReadOnlyProductDef()) {
                ShowContent = false;
                ApexPages.Message myMsg = new ApexPages.Message(
                    ApexPages.Severity.INFO,
                    Label.Novidea_HPC.No_Product_Were_Selected_For_Application
                );
                ApexPages.addMessage(myMsg);
            } else
                addLine();
        }
    }

    public void addLine() {
        applicationStatusChanged = false;
        Boolean currencyFound = false;
        String requeredPolicyType = '';
        requeredPolicyType = theApplication.Novidea_HPC__Required_Policy_Type__c;
        Novidea_HPC__Product__c productData = new Novidea_HPC__Product__c(
            Novidea_HPC__Required_Policy_Type__c = theApplication.Novidea_HPC__Required_Policy_Type__c,
            Novidea_HPC__Application__c = applicationId,
            Novidea_HPC__Liability_Limit_Currency__c = LIABILITY_LIMIT_CURRENCY_DEF,
            Novidea_HPC__Premium_Currency__c = PREMIUM_CURRENCY_DEF,
            Novidea_HPC__Agency_Fee_Currency__c = AGENCY_FEE_CURRENCY_DEF,
            Novidea_HPC__Target_Agency_Fee__c = 0,
            Novidea_HPC__Status__c = ACTIVE,
            Novidea_HPC__Product__c = null,
            Policy_Type__c = 'OnGoing'
        );

        products.add(new productWrapper(productData, getMaxIdVal() + 1, applicationId, fieldSetStorage));
    }

    public void cloneProduct() {
        // #1227
        applicationStatusChanged = false;
        String requeredPolicyType = '';
        requeredPolicyType = theApplication.Novidea_HPC__Required_Policy_Type__c;
        list<productWrapper> clonedProducts = new List<productWrapper>();
        clonedProducts.addAll(products);
        for (productWrapper cw : clonedProducts) {
            if (true == cw.isSelected) {
                cw.isSelected = false;
                Novidea_HPC__Product__c clonedProduct = new Novidea_HPC__Product__c(
                    Novidea_HPC__Required_Policy_Type__c = theApplication.Novidea_HPC__Required_Policy_Type__c,
                    Novidea_HPC__Status__c = ACTIVE,
                    Novidea_HPC__Application__c = applicationId
                );
                for (Schema.FieldSetMember productField : fsmap.get('Novidea_HPC__Application_Clone').getFields()) {
                    clonedProduct.put(productField.getFieldPath(), cw.product.get(productField.getFieldPath()));
                }
                products.add(new productWrapper(cw.productDefName, clonedProduct, getMaxIdVal() + 1, applicationId, fieldSetStorage));
            }
        }
    }

    // Delete only products that have no database instance
    public Pagereference deleteProducts() {
        try {
            applicationStatusChanged = false;
            Integer toDeleteProductCounter = 0, existProductCounter = 0;
            list<ProductWrapper> renewProdlist = new List<ProductWrapper>();

            for (Integer index = 0; index < this.products.size(); index++) {
                ProductWrapper cw = this.products[index];
                if (true == cw.isSelected) {
                    if (cw.product.Id == null || String.isBlank(cw.product.Novidea_HPC__Carrier__c)) {
                        ++toDeleteProductCounter;
                        if (cw.product.Id != null && String.isBlank(cw.product.Novidea_HPC__Carrier__c)) {
                            if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly('CheckCRUDDelete')) {
                                NOVU.SecurityUtils.checkObjects(new List<String>{ 'Novidea_HPC__Product__c' }, NOVU.SecurityUtils.CRUD.DLT);
                            }
                            Database.delete(cw.product);
                        }
                    } else
                        throw new ConstructorPoliciesUtils.ApplicationException(Label.Novidea_HPC.not_deletable_products);
                } else {
                    renewProdlist.add(cw);
                }
            }

            if (toDeleteProductCounter == 0) {
                throw new ConstructorPoliciesUtils.ApplicationException(Label.Novidea_HPC.Choose_products);
            }
            this.products = renewProdlist;
        } catch (Exception e) {
            ConstructorPoliciesUtils.performException(e);
        }
        return null;
    }

    class ApplicationRelatedSize {
        public Integer productSize;
        public Integer proposalSize;
        public Integer policySize;
        public Integer rfpSize;

        public ApplicationRelatedSize(Integer productSize, Integer proposalSize, Integer policySize, Integer rfpSize) {
            this.productSize = productSize;
            this.proposalSize = proposalSize;
            this.policySize = policySize;
            this.rfpSize = rfpSize;
        }
    }

    // GZL: #1251
    private void setApplicationRelatedListsSizes(ApplicationRelatedSize sizes) {
        Novidea_HPC__Application__c application = [
            SELECT
                (SELECT Id FROM Novidea_HPC__Request_for_Proposals__r),
                (SELECT Id FROM Novidea_HPC__Proposals__r),
                (SELECT Id FROM Novidea_HPC__Policies__r),
                (SELECT Id FROM Novidea_HPC__Products__r)
            FROM Novidea_HPC__Application__c
            WHERE Id = :applicationId
        ];
        sizes.productSize = application.Novidea_HPC__Products__r.size();
        sizes.proposalSize = application.Novidea_HPC__Proposals__r.size();
        sizes.policySize = application.Novidea_HPC__Policies__r.size();
        sizes.rfpSize = application.Novidea_HPC__Request_for_Proposals__r.size();
    }

    public PageReference save() {
        ApplicationRelatedSize sizesBefore = new ApplicationRelatedSize(0, 0, 0, 0);
        SavePoint sp;
        try {
            sp = Database.setSavepoint();
            List<Novidea_HPC__Product__c> saveList = new List<Novidea_HPC__Product__c>();
            List<Novidea_HPC__Product__c> toStatusChangeList = new List<Novidea_HPC__Product__c>();
            Integer selectedForMassUpdate = (String.isNotBlank(selectedFieldName) && null != massUpdateDummyObject) ? 0 : -1;

            if (refreshPageOnProductStatusChange)
                setApplicationRelatedListsSizes(sizesBefore);

            Id randomBrokerId = [
                SELECT  Id 
                FROM    Novidea_HPC__Broker_Number__c 
                WHERE   Novidea_HPC__Profit_Center__c != null 
                LIMIT   1
            ].Id;
            for (ProductWrapper cw : this.products) {
                //for aplication status calculation
                toStatusChangeList.add(cw.product);
                if (!cw.isSelectable)
                    continue;

                if (cw.product.Id == null && cw.product.Name == null)
                    cw.product.Name = cw.productDefName;
                //mass update
                if (false == cw.isReadOnly && true == cw.isSelected && selectedForMassUpdate != null && selectedForMassUpdate >= 0) {
                    cw.product.put(selectedFieldName, massUpdateDummyObject.get(selectedFieldName));
                    ++selectedForMassUpdate;
                }
                if (cw.product.Novidea_HPC__Status__c == CANCELLED) {
                    if (String.isBlank(cw.cancellationReason) || cw.cancellationReason == Label.Select_Cancellation_Reason) {
                        for (InnerLossCause innerLossCause : applPBSettings.jsonAutoLossCauseStatus) {
                            if (isMatchAutoLossCause(cw.product, innerLossCause)) {
                                cw.cancellationReason = innerLossCause.Status;
                                break;
                            }
                        }
                    }
                    if (String.isNotBlank(cw.cancellationReason)) {
                        cw.product.Novidea_HPC__Loss_Cause_Reporting__c =
                            selectOptionTranslation(cw.cancellationReason) +
                            '\n' +
                            cw.lossCauseText;
                        cw.product.Novidea_HPC__Is_Lost__c = true;
                    }
                }
                if (cw.product.Novidea_HPC__Required_Policy_Type__c != null) {
                    if (cw.product.Novidea_HPC__Effective_Date__c != null && cw.product.Novidea_HPC__Expiration_Date__c == null)
                        cw.product.Novidea_HPC__Expiration_Date__c = cw.product.Novidea_HPC__Effective_Date__c.addYears(1).addDays(-1);
                    calcPremiumValues(cw.product);
                    calcCommissionValues(cw.product);
                    cw.product.Novidea_HPC__Broker_In_Carrier__c = randomBrokerId;
                    saveList.add(cw.product);
                }
            }
            if (selectedForMassUpdate == 0)
                throw new ConstructorPoliciesUtils.ApplicationException(Label.Novidea_HPC.select_mass_update);

            for (ProductWrapper cw : this.products) {
                if (String.isBlank(cw.product.Novidea_HPC__Product_Definition__c))
                    throw new ConstructorPoliciesUtils.ApplicationException(Label.Novidea_HPC.Select_Prod_Def);
                if (String.isBlank(cw.product.Novidea_HPC__Carrier__c))
                    throw new ConstructorPoliciesUtils.ApplicationException(Label.Novidea_HPC.Choose_carrier);
            }

            String newAppStatus = '';
            String oldAppStatus = '';

            if (!saveList.isEmpty()) {
                if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSUPDATE + '')) {
                    NOVU.SecurityUtils.checkFields(
                        'Novidea_HPC__Product__c',
                        new Set<String>{ 'Name', 'Novidea_HPC__expiration_Date__c' },
                        new List<NOVU.SecurityUtils.FLS>{ NOVU.SecurityUtils.FLS.CREATE, NOVU.SecurityUtils.FLS.UPDT }
                    );
                }
                Database.upsert(saveList);

                map<String, list<Novidea_HPC__Product__c>> status2productMap = new Map<String, list<Novidea_HPC__Product__c>>();
                for (Novidea_HPC__Product__c prod : saveList) {
                    list<Novidea_HPC__Product__c> prodList = status2ProductMap.get(prod.Novidea_HPC__Status__c);
                    if (null == prodList)
                        prodList = new List<Novidea_HPC__Product__c>();
                    prodList.add(prod);
                    status2productMap.put(prod.Novidea_HPC__Status__c, prodList);
                }

                Boolean hasAtLeastOneCancelStatus = false;
                Boolean currentIsStatusCancelled;

                for (String prodStatus : status2productMap.keySet()) {
                    //to do status
                    if (SEND == prodStatus) {
                        createRfp(status2productMap.get(prodStatus), prodRfpStatusRelationMap.get(prodStatus), prodStatus);
                    } else {
                        currentIsStatusCancelled = isStatusCancelled(prodStatus);
                        if (currentIsStatusCancelled)
                            hasAtLeastOneCancelStatus = true;
                        if (RECEIVED == prodStatus || currentIsStatusCancelled || ACCEPTED == prodStatus) {
                            createRfp(status2productMap.get(prodStatus), prodRfpStatusRelationMap.get(prodStatus), prodStatus);
                            createProposal(status2productMap.get(prodStatus), prodProposalStatusRelationMap.get(prodStatus), prodStatus);
                        }
                    }
                }

                // see LossCauseReportingCO documentation for details
                if (lossCauseReportingBehaviour && hasAtLeastOneCancelStatus)
                    ApexPages.addMessage(
                        new ApexPages.Message(ApexPages.Severity.INFO, Label.Novidea_HPC.Should_Report_Lost_To_Canceled_Products)
                    );

                //change application status
                newAppStatus = ProductHelper.calculateApplStatusFromProds(this.theApplication.Novidea_HPC__Status__c, toStatusChangeList);
                oldAppStatus = theApplication.Novidea_HPC__Status__c;
                if (!newAppStatus.equalsIgnoreCase(theApplication.Novidea_HPC__Status__c)) {
                    theApplication.Novidea_HPC__Status__c = newAppStatus;

                    if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSUPDATE + '')) {
                        NOVU.SecurityUtils.checkFields(
                            'Novidea_HPC__Application__c',
                            new Set<String>{ 'Novidea_HPC__Status__c', 'Novidea_HPC__Required_Policy_Type__c' },
                            NOVU.SecurityUtils.FLS.UPDT
                        );
                    }

                    Database.update(theApplication);
                }
            }
            this.reInit = true;
            init();
            this.reInit = false;
            if (refreshPageOnProductStatusChange) {
                ApplicationRelatedSize sizesAfter = new ApplicationRelatedSize(0, 0, 0, 0);
                setApplicationRelatedListsSizes(sizesAfter);
                if (
                    sizesAfter.productSize > sizesBefore.productSize ||
                    sizesAfter.proposalSize > sizesBefore.proposalSize ||
                    sizesAfter.policySize > sizesBefore.policySize ||
                    sizesAfter.rfpSize > sizesBefore.rfpSize
                )
                    productStatusChanged = true;
                else
                    productStatusChanged = false;
            }
            if (oldAppStatus != newAppStatus && newAppStatus != '' && !getErrorsPresent()) {
                applicationStatusChanged = true;
                oldAppStatus = newAppStatus;
            }
        } catch (DmlException exp) {
            System.debug(LoggingLevel.ERROR, exp);
            System.debug(LoggingLevel.ERROR, exp.getStackTraceString());
            NOVU.ForceUtils.emailException('ApplProductBuilderExtendCo DMLException', exp, theApplication.Id);
            if (sp != null)
                Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.None_Saved));

            System.debug(LoggingLevel.ERROR, exp.getMessage());
            for (Integer i = 0; i < exp.getNumDml(); i++) {
                System.debug(LoggingLevel.ERROR, exp.getDmlMessage(i));
                if (exp.getDmlType(i) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, exp.getDmlMessage(i)));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, exp.getMessage()));
            }

            productStatusChanged = false;
            applicationStatusChanged = false;
        } catch (Exception exp) {
            System.debug(LoggingLevel.ERROR, exp);
            System.debug(LoggingLevel.ERROR, exp.getStackTraceString());
            NOVU.ForceUtils.emailException('ApplProductBuilderExtendCo Exception', exp, theApplication.Id);
            if (sp != null)
                Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.None_Saved));
            System.debug(LoggingLevel.ERROR, exp.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, exp.getMessage()));
            productStatusChanged = false;
            applicationStatusChanged = false;
        } finally {
            if (sendExceptionsEmails) {
                NOVU.ForceUtils.sendPendingEmails();
            }
            resetMassUpdateDummyObject();
        }

        return null;
    }

    /**input parameters :
     *	@applicationProducts:	list of selected products by user form current application.
     *	@rfpStatus:				new status for RFP
     *	@prodStatus : 			pass prod status to rfp
     *	function search exisiting RFPs and if RFPs don't exist will create this. After creating of RFRs will be created needed products.
     * 	when app product changed status the child product must be updated!
     **/
    public void createRfp(list<Novidea_HPC__Product__c> applicationProducts, String rfpStatus, String prodStatus) {
        //search RFP
        map<id, Novidea_HPC__Product__c> productAppMap = new Map<id, Novidea_HPC__Product__c>();
        list<Novidea_HPC__Product__c> prod4createRfp = new List<Novidea_HPC__Product__c>();

        for (Novidea_HPC__Product__c appProduct : applicationProducts) {
            productAppMap.put(appProduct.Id, appProduct);
        }

        list<Novidea_HPC__Product__c> rfpProdList = [
            SELECT
                Novidea_HPC__Product__c,
                Novidea_HPC__Status__c,
                Novidea_HPC__Request_for_Proposal__c,
                Novidea_HPC__Request_for_Proposal__r.Novidea_HPC__Status__c,
                Novidea_HPC__Application__c
            FROM Novidea_HPC__Product__c
            WHERE
                Novidea_HPC__Product__c IN :productAppMap.keySet() //instead of parentProdIds // Diana 08/02/2015
                AND Novidea_HPC__Request_for_Proposal__c != NULL
                AND Novidea_HPC__Application__c = NULL
        ]; // diana 08/09/14
        // Diana 08/09/2014
        // if the app product changed status the child product must be updated!
        list<Novidea_HPC__Product__c> rfpProduct4Change = new List<Novidea_HPC__Product__c>();

        Novidea_HPC__Product__c rfpProductToUpdate;
        Map<String, Schema.FieldSetMember> ignoreList = getNotSelectedFields();
        Map<String, Schema.DescribeFieldResult> productFields = FIELDSPATH_NO_NS;
        String ns = '';
        if (gs != null && gs.Novidea_HPC__Copy_Application_Product_To_RFP_Product__c == true) {
            productFields = FIELDSPATH_NS;
            ns = 'Novidea_HPC__';
        }

        for (Novidea_HPC__Product__c pro : rfpProdList) {
            rfpProductToUpdate = pro.clone(true, true, false, false);

            for (String fieldName : productFields.keySet()) {
                if (
                    productFields.get(fieldName).isUpdateable() &&
                    !fieldName.equalsIgnoreCase(ns + 'Novidea_HPC__Application__c') &&
                    !fieldName.equalsIgnoreCase(ns + 'Novidea_HPC__Request_For_Proposal__c') &&
                    !fieldName.equalsIgnoreCase(ns + 'Novidea_HPC__Product__c') &&
                    !ignoreList.keySet().contains(productFields.get(fieldName).getName()) //TODO: India fix with custom setting
                ) {
                    rfpProductToUpdate.put(fieldName, productAppMap.get(pro.Novidea_HPC__Product__c).get(fieldName));
                }
            }
            rfpProduct4Change.add(rfpProductToUpdate);
        }
        map<Id, Novidea_HPC__Request_for_Proposal__c> toUpdateExistRfpList = new Map<Id, Novidea_HPC__Request_for_Proposal__c>();
        Set<Id> idOfProductsAlreadyHavingRFP = new Set<Id>();
        for (Novidea_HPC__Product__c prod : rfpProdList) {
            if (!rfpStatus.equalsIgnoreCase(prod.Novidea_HPC__Request_for_Proposal__r.Novidea_HPC__Status__c)) {
                toUpdateExistRfpList.put(
                    prod.Novidea_HPC__Request_for_Proposal__c,
                    new Novidea_HPC__Request_for_Proposal__c(Id = prod.Novidea_HPC__Request_for_Proposal__c, Novidea_HPC__Status__c = rfpStatus)
                );
            }
            idOfProductsAlreadyHavingRFP.add(prod.Novidea_HPC__Product__c);
        }
        for (Novidea_HPC__Product__c appProduct : applicationProducts) {
            if (!idOfProductsAlreadyHavingRFP.contains(appProduct.Id))
                prod4createRfp.add(appProduct);
        }

        //create RFP
        map<Id, list<Novidea_HPC__Product__c>> carrier2ProdListMap = new Map<Id, list<Novidea_HPC__Product__c>>();
        for (Novidea_HPC__Product__c product : prod4createRfp) {
            list<Novidea_HPC__Product__c> prodList = carrier2ProdListMap.get(product.Novidea_HPC__Carrier__c);
            if (NOVU.ArrayUtils.isListNullOrEmpty(prodList))
                prodList = new List<Novidea_HPC__Product__c>();
            prodList.add(product);
            carrier2ProdListMap.put(product.Novidea_HPC__Carrier__c, prodList);
        }

        map<Id, Novidea_HPC__Request_for_Proposal__c> carrierId2Rpf = new Map<Id, Novidea_HPC__Request_for_Proposal__c>();
        for (Id carrierId : carrier2ProdListMap.keySet()) {
            Novidea_HPC__Request_for_Proposal__c rfp = new Novidea_HPC__Request_for_Proposal__c();
            rfp.Name = Label.RFP + Date.today().format();
            rfp.Novidea_HPC__Carrier__c = carrierId;
            rfp.Novidea_HPC__Application__c = this.applicationId;
            rfp.Novidea_HPC__Status__c = rfpStatus;
            carrierId2Rpf.put(carrierId, rfp);
        }
        //todo update change sattus
        list<Novidea_HPC__Request_for_Proposal__c> toUpdateRFPs = new List<Novidea_HPC__Request_for_Proposal__c>();
        if (!toUpdateExistRfpList.isEmpty())
            toUpdateRFPs.addAll(toUpdateExistRfpList.values());
        if (!carrierId2Rpf.isEmpty())
            toUpdateRFPs.addAll(carrierId2Rpf.values());
        if (!toUpdateRFPs.isEmpty()) {
            if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSCREATE + '')) {
                NOVU.SecurityUtils.checkFields(
                    'Novidea_HPC__Request_for_Proposal__c',
                    new Set<String>{ 'Novidea_HPC__Carrier__c', 'Novidea_HPC__Application__c', 'Name', 'Novidea_HPC__Status__c' },
                    new List<NOVU.SecurityUtils.FLS>{ NOVU.SecurityUtils.FLS.CREATE, NOVU.SecurityUtils.FLS.UPDT }
                );
            }
            Database.upsert(toUpdateRFPs);
        }
        //create products for rfp
        list<Novidea_HPC__Product__c> product4RfpList = new List<Novidea_HPC__Product__c>();
        for (Id carrierId : carrier2ProdListMap.keySet()) {
            list<Novidea_HPC__Product__c> prodList = carrier2ProdListMap.get(carrierId);
            for (Novidea_HPC__Product__c prod : prodList) {
                Novidea_HPC__Product__c product4Rfp = prod.clone(false, true, false, false);
                product4Rfp.Novidea_HPC__Product__c = prod.Id;
                product4Rfp.Novidea_HPC__Carrier__c = carrierId;
                product4Rfp.Novidea_HPC__Request_for_Proposal__c = carrierId2Rpf.get(carrierId).Id;
                product4Rfp.Novidea_HPC__Lead__c = null;
                product4Rfp.Novidea_HPC__Policy__c = null;
                product4Rfp.Novidea_HPC__Proposal__c = null;
                product4Rfp.Novidea_HPC__Application__c = null;
                product4Rfp.Novidea_HPC__Previous_Policy__c = null;
                product4RfpList.add(product4Rfp);
            }
        }
        product4RfpList.addAll(rfpProduct4Change);
        if (!product4RfpList.isEmpty()) {
            if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSUPDATE + '')) {
                NOVU.SecurityUtils.checkFields(
                    'Novidea_HPC__Product__c',
                    new Set<String>{
                        'Name',
                        'Novidea_HPC__expiration_Date__c',
                        'Novidea_HPC__Application__c',
                        'Novidea_HPC__Carrier__c',
                        'Novidea_HPC__Lead__c',
                        'Novidea_HPC__Policy__c',
                        'Novidea_HPC__Previous_Policy__c',
                        'Novidea_HPC__Product__c',
                        'Novidea_HPC__Proposal__c',
                        'Novidea_HPC__Request_for_Proposal__c'
                    },
                    new List<NOVU.SecurityUtils.FLS>{ NOVU.SecurityUtils.FLS.CREATE, NOVU.SecurityUtils.FLS.UPDT }
                );
            }
            Database.upsert(product4RfpList);
        }
    }

    /**
     * Calculates the expected premium values for the proposal product
     * prior to passing them to product helper. Each computed value is based upon
     * two other values.
     */
    private void calcPremiumValues(Novidea_HPC__Product__c product) {
        //get only premiums indicators;
        Integer localIndicator = financialFieldsDisplayIndicator & 7;
        //if all "ingredients" displayed then do nothing
        Decimal fees = product.Novidea_HPC__Expected_Fees__c == null ? 0 : product.Novidea_HPC__Expected_Fees__c,
            premium = product.Novidea_HPC__Expected_Premium__c == null ? 0 : product.Novidea_HPC__Expected_Premium__c,
            netPremium = product.Novidea_HPC__Expected_Premium_Net__c == null ? 0 : product.Novidea_HPC__Expected_Premium_Net__c;
        //only premium or only premium and fees
        if ((localIndicator ^ 1) == 0 || (localIndicator ^ 5) == 0) {
            product.Novidea_HPC__Expected_Premium_Net__c = premium - fees;
        } else if ((localIndicator | 6) > 0) {
            //only net premium or only fees or both
            product.Novidea_HPC__Expected_Premium__c = netPremium + fees;
        } else if ((localIndicator ^ 3) == 0) {
            //only premium and net premium
            product.Novidea_HPC__Expected_Fees__c = premium - netPremium;
        }
    }

    /**
     * Calculates the expected commission values for the proposal product
     * prior to passing them to product helper. Each computed value is based upon
     * other values.
     */
    private void calcCommissionValues(Novidea_HPC__Product__c product) {
        Decimal commissionAmount = product.Novidea_HPC__Expected_Commission_Amount__c == null
                ? 0
                : product.Novidea_HPC__Expected_Commission_Amount__c,
            commission = product.Novidea_HPC__Commission__c == null ? 0 : product.Novidea_HPC__Commission__c,
            netPremium = product.Novidea_HPC__Expected_Premium_Net__c == null ? 0 : product.Novidea_HPC__Expected_Premium_Net__c;
        //only exp. commission amount
        if (
            (financialFieldsDisplayIndicator & 8) > 0 &&
            (financialFieldsDisplayIndicator & 16) == 0 &&
            netPremium != 0 &&
            Math.abs(commissionAmount / netPremium) <= 1
        ) {
            product.Novidea_HPC__Commission__c = commissionAmount / netPremium * 100;
        } else if ((financialFieldsDisplayIndicator & 16) > 0 && (financialFieldsDisplayIndicator & 8) == 0) {
            //only commission pct
            product.Novidea_HPC__Expected_Commission_Amount__c = commission * netPremium / 100;
        }
    }

    /**
     *	input parameters
     *	@param applicationProducts: list of selected products by user form current application.
     *	@param proposalStatus: new status for object 'Proposal' if the app product changed status the proposal status is changed accordingly
     *	@param prodStatus: pass product status to proposal
     * 	@description function search exisiting Proposals and if Proposals don't exist will create it. After creating of RFRs will be created needed products.
     **/
    public void createProposal(list<Novidea_HPC__Product__c> applicationProducts, String proposalStatus, String prodStatus) {
        list<Id> prod4createProposal = new List<Id>();

        map<Id, Novidea_HPC__Product__c> appProductMap = new Map<Id, Novidea_HPC__Product__c>(applicationProducts);

        list<Novidea_HPC__Product__c> proposalProdList = [
            SELECT
                Novidea_HPC__Product__c,
                Novidea_HPC__Status__c,
                Novidea_HPC__Proposal__c,
                Novidea_HPC__Product__r.Novidea_HPC__Product__c,
                Novidea_HPC__Proposal__r.Novidea_HPC__Status__c
            FROM Novidea_HPC__Product__c
            WHERE
                Novidea_HPC__Product__r.Novidea_HPC__Product__c IN :appProductMap.keySet() // instead of "parentProdIds" // Diana 08/02/2015
                AND Novidea_HPC__Proposal__c != NULL
        ]; //diana 08/09/14

        // Set of ids of application products (parent product) that already have rfp
        Set<Id> idOfProductsAlreadyHavingProposal = new Set<Id>();
        //the change here takes place because there can be two products or more in the same RFP
        //and in that case a proposal will be added twice and fail in the update
        map<Id, Novidea_HPC__Proposal__c> toUpdateExistProposaMap = new Map<Id, Novidea_HPC__Proposal__c>();
        for (Novidea_HPC__Product__c prod : proposalProdList) {
            if (
                !proposalStatus.equalsIgnoreCase(prod.Novidea_HPC__Proposal__r.Novidea_HPC__Status__c) &&
                !toUpdateExistProposaMap.containsKey(prod.Novidea_HPC__Proposal__c)
            ) {
                toUpdateExistProposaMap.put(
                    prod.Novidea_HPC__Proposal__c,
                    new Novidea_HPC__Proposal__c(Id = prod.Novidea_HPC__Proposal__c, Novidea_HPC__Status__c = proposalStatus)
                );
            }
            idOfProductsAlreadyHavingProposal.add(prod.Novidea_HPC__Product__r.Novidea_HPC__Product__c);
        }
        //update for new status
        if (!toUpdateExistProposaMap.isEmpty()) {
            if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSUPDATE + '')) {
                NOVU.SecurityUtils.checkFields(
                    'Novidea_HPC__Proposal__c',
                    new Set<String>{ 'Novidea_HPC__Status__c' },
                    NOVU.SecurityUtils.FLS.UPDT
                );
            }
            Database.update(toUpdateExistProposaMap.values());
        }
        //create proposal

        for (Novidea_HPC__Product__c appProduct : applicationProducts) {
            if (!idOfProductsAlreadyHavingProposal.contains(appProduct.Id) && !isStatusCancelled(appProduct.Novidea_HPC__Status__c))
                prod4createProposal.add(appProduct.Id);
        }

        list<Novidea_HPC__Product__c> proposalProductsToUpdate = new List<Novidea_HPC__Product__c>();

        Novidea_HPC__Product__c proposalProductToUpdate, tmpProd;
        for (Novidea_HPC__Product__c pro : proposalProdList) {
            proposalProductToUpdate = pro.clone(true, true, false, false);
            tmpProd = appProductMap.get(pro.Novidea_HPC__Product__r.Novidea_HPC__Product__c);

            Map<String, Schema.DescribeFieldResult> productFields = FIELDSPATH_NO_NS;
            String ns = '';
            if (gs != null && gs.Novidea_HPC__Copy_RFP_Product_To_Proposal_Product__c == true) {
                productFields = FIELDSPATH_NS;
                ns = 'Novidea_HPC__';
            }

            for (String fieldName : productFields.keySet()) {
                if (
                    productFields.get(fieldName).isUpdateable() &&
                    !fieldName.equalsIgnoreCase(ns + 'Novidea_HPC__Application__c') &&
                    !fieldName.equalsIgnoreCase(ns + 'Novidea_HPC__Proposal__c') &&
                    !fieldName.equalsIgnoreCase(ns + 'Novidea_HPC__Product__c') &&
                    //#4183 we do not needto copy Novidea_HPC__Broker_In_Carrier__c (profit center) because its set only on the proposal product by ajax
                    !fieldName.equalsIgnoreCase(ns + 'Novidea_HPC__Broker_In_Carrier__c') &&
                    //#4854
                    !fieldName.equalsIgnoreCase(ns + 'Novidea_HPC__Previous_Policy__c')
                ) {
                    proposalProductToUpdate.put(fieldName, tmpProd.get(fieldName));
                }
            }

            ProductHelper.updateProductActualByExpected(tmpProd, proposalProductToUpdate, true, true);
            proposalProductsToUpdate.add(proposalProductToUpdate);
        }
        if (!proposalProductsToUpdate.isEmpty()) {
            if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSCREATE + '')) {
                NOVU.SecurityUtils.checkFields(
                    'Novidea_HPC__Product__c',
                    new Set<String>{
                        'Name',
                        'Novidea_HPC__expiration_Date__c',
                        'Novidea_HPC__Application__c',
                        'Novidea_HPC__Carrier__c',
                        'Novidea_HPC__Lead__c',
                        'Novidea_HPC__Policy__c',
                        'Novidea_HPC__Previous_Policy__c',
                        'Novidea_HPC__Product__c',
                        'Novidea_HPC__Proposal__c',
                        'Novidea_HPC__Request_for_Proposal__c'
                    },
                    NOVU.SecurityUtils.FLS.UPDT
                );
            }
            Database.update(proposalProductsToUpdate);
        }
        if (!prod4createProposal.isEmpty()) {
            RFPTableCo rfpTableController = new RFPTableCo(new ApexPages.StandardController(this.theApplication));
            rfpTableController.init();
            list<Id> proposalList = rfpTableController.massCreateProposalList(prod4createProposal);
        }
    }

    public PageReference convert() {
        SavePoint sp;
        try {
            applicationStatusChanged = false;
            list<Id> acceptedProducts = new List<Id>();
            map<Id, list<Novidea_HPC__Product__c>> carrier2ProdListMap = new Map<Id, list<Novidea_HPC__Product__c>>();

            for (ProductWrapper cw : products) {
                if (!cw.isSelectable)
                    continue;
                if (!cw.isSelected)
                    continue;
                if (cw.product.Novidea_HPC__Carrier__c == null)
                    throw new ConstructorPoliciesUtils.ApplicationException(Label.Novidea_HPC.Choose_carrier);
                if (cw.isCancelled)
                    throw new ConstructorPoliciesUtils.ApplicationException(Label.Status_Not_Suitable);
                //this is a test based on string. if a profit center has been selected its already populated on the product in DB
                if (!cw.isAccepted) {
                    throw new ConstructorPoliciesUtils.ApplicationException(Label.Novidea_HPC.Product_not_fit);
                }
                acceptedProducts.add(cw.product.Id);
            }
            if (acceptedProducts.isEmpty())
                throw new ConstructorPoliciesUtils.ApplicationException(Label.Novidea_HPC.Choose_products);

            if (gs.Novidea_HPC__Limit_To_One_Policy_Conversion__c == true && acceptedProducts.size() > 1)
                throw new ConstructorPoliciesUtils.ApplicationException(Label.Novidea_HPC.Limit_To_One_Policy_Conversion);
            Set<Id> proposalIds = new Set<Id>();
            list<Novidea_HPC__Product__c> proposalProdList = [
                SELECT Novidea_HPC__Proposal__c
                FROM Novidea_HPC__Product__c
                WHERE
                    (Novidea_HPC__Product__c IN :acceptedProducts //todo need ?
                    OR Novidea_HPC__Product__r.Novidea_HPC__Product__c IN :acceptedProducts)
                    AND Novidea_HPC__Proposal__c != NULL
                    AND Novidea_HPC__Product__r.Novidea_HPC__Product__r.Novidea_HPC__Status__c != :CONVERTED
                    AND Novidea_HPC__Product__r.Novidea_HPC__Product__r.Novidea_HPC__Status__c != :CANCELLED
                    AND Novidea_HPC__Product__r.Novidea_HPC__Product__r.Novidea_HPC__Status__c != :DECLINED_BY_INSURER
                    AND Novidea_HPC__Product__r.Novidea_HPC__Product__r.Novidea_HPC__Status__c != :DECLINED_BY_CLIENT
            ];
            for (Novidea_HPC__Product__c prod : proposalProdList)
                proposalIds.add(prod.Novidea_HPC__Proposal__c);

            if (!proposalIds.isEmpty()) {
                if (true != gs.Novidea_HPC__Disable_Management_Policy__c) {
                    selectCarrierPageLink =
                        '/apex/ApprovedProposals?ui=1&advancedMode=true&proposalCsv=' + String.join(new List<Id>(proposalIds), ',');
                } else {
                    ApprovedProposalsController ctrl = ApprovedProposalsController.createControllerWithoutPage(
                        proposalIds,
                        new Map<Id, Novidea_HPC__Product__c>(proposalProdList).keySet()
                    );
                    ctrl.advancedModeVal = true;
                    ctrl.uiParam = '1';
                    PageReference pr = ctrl.convertToPolicy();

                    if (ctrl.hasDuplicateProductDefs) {
                        if (!enableSameProductDef) {
                            ApexPages.Message myMsg = new ApexPages.Message(
                                ApexPages.Severity.INFO,
                                Label.Novidea_HPC.Same_ProductDef_Not_Created
                            );
                            ApexPages.addMessage(myMsg);
                        } else if (enableSameProductDefMsg) {
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, Label.Novidea_HPC.Same_ProductDef_Created);
                            ApexPages.addMessage(myMsg);
                        }
                    }

                    atleastOneConverted = true;
                    selectCarrierPageLink = null;

                    policyEditUrl = null;
                    if (editPolicyAfterConversion == true && pr != null)
                        policyEditUrl = pr.getUrl();
                }
            } else {
                selectCarrierPageLink = null;
                throw new ConstructorPoliciesUtils.ApplicationException(Label.Novidea_HPC.No_proposals_selected_for_conversion);
            }
        } catch (Exception exp) {
            if (null != sp)
                Database.rollback(sp);
            ConstructorPoliciesUtils.performException(exp);
        }
        return null;
    }

    public PageReference lossReport() {
        try {
            applicationStatusChanged = false;
            list<Id> lossProdIds = new List<Id>();
            for (ProductWrapper cw : products) {
                if (true != cw.isSelected)
                    continue;

                if (cw.isCancelled) {
                    lossProdIds.add(cw.product.Id);
                } else
                    throw new ConstructorPoliciesUtils.ApplicationException(Label.Novidea_HPC.Product_not_fit);
            }
            if (lossProdIds.isEmpty())
                throw new ConstructorPoliciesUtils.ApplicationException(Label.Novidea_HPC.Choose_products);

            lossReportPageLink = '/apex/Novidea_HPC__LossCauseReporting?appId=' + applicationId + '&prodids=' + String.join(lossProdIds, '%2C');
            return null;
        } catch (Exception exp) {
            ConstructorPoliciesUtils.performException(exp);
            selectCarrierPageLink = null;
            lossReportPageLink = null;
        }
        return null;
    }
    public PageReference cancel() {
        return null;
    }

    public String fieldSetStorage {
        get {
            if (String.isNotBlank(fieldSetStorage))
                return fieldSetStorage;
            Schema.FieldSet fs = Schema.SObjectType.Novidea_HPC__Product__c.fieldSets.getMap().get(getToGuiFieldShowFieldSet());

            if (null == fs)
                fieldSetStorage = null;
            else {
                fieldSetStorage = '';
                list<Schema.FieldSetMember> fieldSetMemberList = fs.getFields();
                for (Schema.FieldSetMember member : fieldSetMemberList) {
                    fieldSetStorage += member.getFieldPath() + ',';
                }
            }
            return fieldSetStorage;
        }
        private set;
    }

    public String selectedFieldName { get; set; }
    public sObject massUpdateDummyObject {
        get {
            if (null == massUpdateDummyObject)
                massUpdateDummyObject = new Novidea_HPC__Product__c();
            return massUpdateDummyObject;
        }
        set;
    }

    private void resetMassUpdateDummyObject() {
        massUpdateDummyObject = new Novidea_HPC__Product__c();
        selectedFieldName = null;
    }

    public Pagereference changeField() {
        if (String.isNotBlank(selectedFieldName))
            massUpdateDummyObject.put(selectedFieldName, null);
        return null;
    }

    private String fieldSetForMassUpdate {
        get {
            return null != gs && String.IsNotBlank(gs.Novidea_HPC__Field_Set_to_Mass_Update__c)
                ? gs.Novidea_HPC__Field_Set_to_Mass_Update__c
                : 'Application_Product_Builder_Page';
        }
    }

    public list<Schema.FieldSetMember> fieldSetMembers {
        get {
            if (null == fieldSetMembers)
                fieldSetMembers = readFieldSet('Novidea_HPC__Product__c', fieldSetForMassUpdate);
            return fieldSetMembers;
        }
        set;
    }

    public list<SelectOption> getFieldSetItems() {
        list<SelectOption> fieldSetItems = new List<SelectOption>{ new SelectOption('', '-- ' + Label.Novidea_HPC.None + ' --') };
        for (Schema.FieldSetMember member : fieldSetMembers)
            fieldSetItems.add(new SelectOption(member.getFieldPath(), member.getLabel()));
        return fieldSetItems;
    }

    /*
        DAL
    */
    public void deleteProductRfpAndProposal(list<Id> productIds) {
        list<Novidea_HPC__Product__c> rfpOrPropProducts = getProductRfpAndProposal(productIds);
        if (!rfpOrPropProducts.isEmpty()) {
            if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly('CheckCRUDDelete')) {
                NOVU.SecurityUtils.checkObjects(new List<String>{ 'Novidea_HPC__Product__c' }, NOVU.SecurityUtils.CRUD.DLT);
            }
            Database.delete(rfpOrPropProducts);
        }
    }
    public static Novidea_HPC__Application__c getApplicationById(Id appId) {
        if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
            NOVU.SecurityUtils.checkFields(
                'Novidea_HPC__Application__c',
                new Set<String>{ 'Novidea_HPC__Status__c', 'Novidea_HPC__Required_Policy_Type__c' },
                NOVU.SecurityUtils.FLS.ACCESS
            );
        }
        return [SELECT Novidea_HPC__Status__c, Novidea_HPC__Required_Policy_Type__c FROM Novidea_HPC__Application__c WHERE Id = :appId LIMIT 1];
    }

    public static list<Novidea_HPC__Product__c> getProductRfpAndProposal(list<Id> productIds) {
        if (Novidea_HPC.TriggerUtils.isTriggerEnabledCSOnly(NOVU.SecurityUtils.STOP_START_CHECK.CHECKFLSACCESS + '')) {
            NOVU.SecurityUtils.checkFields(
                'Novidea_HPC__Product__c',
                new Set<String>{ 'Novidea_HPC__Product__c', 'Novidea_HPC__Proposal__c' },
                NOVU.SecurityUtils.FLS.ACCESS
            );
        }
        return [
            SELECT Novidea_HPC__Product__c, Novidea_HPC__Product__r.Novidea_HPC__Product__c, Novidea_HPC__Proposal__c
            FROM Novidea_HPC__Product__c
            WHERE Novidea_HPC__Product__c IN :productIds OR Novidea_HPC__Product__r.Novidea_HPC__Product__c IN :productIds
        ];
    }

    public list<Novidea_HPC__Product__c> getExistProdListByApplicationId(Id applicationId) {
        Boolean isFullProdToBeSelected = FIELDSPATH_NS != null;
        String fromPart = 'Novidea_HPC__Product__c';
        String whereClause = 'Novidea_HPC__Application__c = \'' + applicationId + '\'';
        if (isFullProdToBeSelected) {
            NOVU.SecurityUtils.SecureDynamicQuery sdq = new NOVU.SecurityUtils.SecureDynamicQuery();
            sdq.selectFields = new Set<String>(FIELDSPATH_NS.keySet());
            sdq.selectFields.add('Novidea_HPC__Product_Definition__r.Name');
            sdq.selectFields.add('Novidea_HPC__Carrier__r.Name');
            sdq.fromObject = fromPart;
            sdq.whereClause = whereClause;
            sdq.subQueries = new List<NOVU.SecurityUtils.SecureDynamicQuery>{};
            return NOVU.FieldUtils.executeQuery(sdq);
        } else {
            String[] dynamicFieldsNames = new List<String>(FIELDSPATH_NO_NS.keySet());
            String query = 'SELECT Novidea_HPC__Product_Definition__r.Name, Novidea_HPC__Carrier__r.Name, ';
            query += String.join(dynamicFieldsNames, ',') + '\n';
            query += 'FROM ' + fromPart + '\n' + 'WHERE ' + whereClause;
            return Database.query(query);
        }
    }
    public static list<Novidea_HPC__Product__c> getProposalProdForProfitCenterList(Set<ID> acceptedProductIds) {
        return [
            SELECT
                Novidea_HPC__Proposal__c,
                Novidea_HPC__Status__c,
                Novidea_HPC__Broker_In_Carrier__c,
                Novidea_HPC__Broker_In_Carrier__r.Name,
                Novidea_HPC__Broker_In_Carrier__r.Novidea_HPC__Agency__c,
                Novidea_HPC__Broker_In_Carrier__r.Novidea_HPC__Agency__r.Name,
                Novidea_HPC__Proposal__r.Novidea_HPC__Carrier__c,
                Novidea_HPC__Product__r.Novidea_HPC__Product__c
            FROM Novidea_HPC__Product__c
            WHERE Novidea_HPC__Proposal__c != NULL AND Novidea_HPC__Product__r.Novidea_HPC__Product__c IN :acceptedProductIds
        ];
    }

    public static list<Schema.FieldSetMember> readFieldSet(String ObjectName, String fieldSetName) {
        try {
            Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
            Schema.SObjectType SObjectTypeObj = globalDescribeMap.get(ObjectName);
            Schema.DescribeSObjectResult describeSObjectResultObj = SObjectTypeObj.getDescribe();
            Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
            return fieldSetObj.getFields();
        } catch (system.NullPointerException exp) {
            ApexPages.Message myMsg = new ApexPages.Message(
                ApexPages.Severity.Error,
                'Not set the FieldSet for mass update for object ' + ObjectName
            );
            ApexPages.addMessage(myMsg);
            return new List<Schema.FieldSetMember>();
        }
    }

    public static Map<String, Schema.FieldSetMember> getNotSelectedFields() {
        if (fsmap.get('Novidea_HPC__Excluded_Fields_From_Clone') != null) {
            Map<String, Schema.FieldSetMember> fieldSetsOfProductExt = new Map<String, Schema.FieldSetMember>();
            for (Schema.FieldSetMember f : fsmap.get('Novidea_HPC__Excluded_Fields_From_Clone').getFields()) {
                fieldSetsOfProductExt.put(f.getFieldPath(), f);
            }
            return fieldSetsOfProductExt;
        } else
            return new Map<String, Schema.FieldSetMember>();
    }

    public List<SelectOption> getCancellationReasonOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Label.Select_Cancellation_Reason, Label.Select_Cancellation_Reason));
        for (String pickListValue : APLICATION_CANCELLATION_REASON_PICKLIST_VALUES.keySet()) {
            options.add((new SelectOption(pickListValue, APLICATION_CANCELLATION_REASON_PICKLIST_VALUES.get(pickListValue))));
        }
        return options;
    }

    public String selectOptionTranslation(string selectedValue) {
        Map<String, String> selectOptionMap = new Map<String, String>();
        return APLICATION_CANCELLATION_REASON_PICKLIST_VALUES.get(selectedValue);
    }

    public class JSONAutoLossCause {
        public List<InnerLossCause> jsonAutoLossCauseStatus { get; set; }
        public List<String> requiredNotesForLossCauseStatus { get; set; }
        public List<String> invalidStatusesAsLossCause { get; set; }

        public JSONAutoLossCause() {
            invalidStatusesAsLossCause = new List<String>();
            jsonAutoLossCauseStatus = new List<InnerLossCause>();
            requiredNotesForLossCauseStatus = new List<String>();
        }
    }

    public class InnerLossCause {
        public String Status { get; set; }
        public String ProductDefId { get; set; }
        public String PolicyType { get; set; }
    }

    private Boolean isMatchAutoLossCause(Novidea_HPC__Product__c product, innerLossCause autoLossCause) {
        return (product.Policy_Type__c == autoLossCause.PolicyType &&
            autoLossCause.ProductDefId == null) ||
            (product.Novidea_HPC__Product_Definition__c == autoLossCause.ProductDefId &&
            autoLossCause.PolicyType == null) ||
            (product.Policy_Type__c == autoLossCause.PolicyType &&
            product.Novidea_HPC__Product_Definition__c == autoLossCause.ProductDefId);
    }
}