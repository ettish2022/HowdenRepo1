@isTest(seeAllData=false)
global with sharing class TestExchangeRateUpdateScheduleImpl extends ExchangeRateUpdateScheduleImpl {
	public TestExchangeRateUpdateScheduleImpl() {
		super();
	}

	public TestExchangeRateUpdateScheduleImpl(Integer retryNumber, Date exchangeRateDate) {
		super(retryNumber, exchangeRateDate);
	}

	@TestSetup
	static void makeData() {
		Currency__c currencyData = new Currency__c(
			Current_Exchange_Rate_Source_URL__c = 'http://www.bankisrael.gov.il/currency.xml',
			Minutes_for_Daily_Update_Retry__c = 30,
			Number_of_Daily_Update_Retries__c = 10,
			Currency_Manager__c = ''
		);
		Database.insert(currencyData);
	}

	global override void execute(SchedulableContext ctx) {
		TestExchangeRateUpdateScheduleImpl.executeTest(retryNumber, exchangeRateDate);
	}

	@future(callout=true)
	public static void executeTest(Integer retryNumber, Date exchangeRateDate) {
		start(retryNumber, exchangeRateDate);
	}

	public static void start(Integer retryNumber, Date exchangeRateDate) {
		TestUpdateExchangeRate eru = new TestUpdateExchangeRate(retryNumber, exchangeRateDate);
		eru.rawData = '<CURRENCIES><LAST_UPDATE>2012-0404</LAST_UPDATE><CURRENCY><NAME>Dollar</NAME><UNIT>1</UNIT><CURRENCYCODE>USD</CURRENCYCODE><COUNTRY>USA</COUNTRY><RATE>3.745</RATE><CHANGE>0.591</CHANGE></CURRENCY></CURRENCIES>';
		eru.UpdateExchangeRate();
	}

	private static testMethod void testExchangeRateUpdateScheduleImpl() {
		ExchangeRateUpdateScheduleImpl e = new ExchangeRateUpdateScheduleImpl(0, system.Today());
		e = new ExchangeRateUpdateScheduleImpl();
		ExchangeRateUpdateScheduleImpl.execute(0, system.Today());
	}
}