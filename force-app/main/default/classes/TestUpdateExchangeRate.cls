@isTest(seeAllData=false)
public with sharing class TestUpdateExchangeRate extends ExchangeRateUpdate {
	public String rawData;

	protected override String getRawDailyRates() {
		return rawData;
	}

	public override void sendExRateUpdateFailureEmail() {
		super.sendExRateUpdateFailureEmail();
	}

	public override ExchangeRateUpdateScheduleImpl getExchangeRateUpdateScheduleImpl(Integer inRetryNumber) {
		return new TestExchangeRateUpdateScheduleImpl(inRetryNumber, exchangeRateDate);
	}

	public ExchangeRateUpdateScheduleImpl testGetExchangeRateUpdateScheduleImpl() {
		return super.getExchangeRateUpdateScheduleImpl(0);
	}
	public TestUpdateExchangeRate() {
		super();
	}

	public TestUpdateExchangeRate(Integer retryNumber, Date exchangeRateDate) {
		super(retryNumber, exchangeRateDate);
	}

	public void TestGetHttpRequest() {
		this.getHttpRequest();
	}

	private static void setCurrencyManagerAddress() {
		Currency__c crncy = Currency__c.getInstance();
		if (!String.isNotEmpty(crncy.Currency_Manager__c)) {
			crncy.Currency_Manager__c = 'test@test.com';
			upsert crncy;
		}
	}

	@istest(seealldata=true)
	private static void testUpdateExchangeRateFillEmptyDays() {
		database.insert(
			new Novidea_HPC__Exchange_Rate__c(
				Novidea_HPC__Rate__c = 21.32,
				Novidea_HPC__Source_Currency__c = 'ILS',
				Novidea_HPC__Target_Currency__c = 'USD',
				Novidea_HPC__Rate_Date__c = Date.valueOf('2055-12-12')
			)
		);
		TestUpdateExchangeRate eru = new TestUpdateExchangeRate(0, Date.valueOf('2055-12-16'));
		String adate = '2055-12-15';
		eru.rawData =
			'<CURRENCIES><LAST_UPDATE>' +
			adate +
			'</LAST_UPDATE><CURRENCY><NAME>Dollar</NAME><UNIT>1</UNIT><CURRENCYCODE>USD</CURRENCYCODE><COUNTRY>USA</COUNTRY><RATE>3.745</RATE><CHANGE>0.591</CHANGE></CURRENCY><CURRENCY><NAME>Pound</NAME><UNIT>1</UNIT><CURRENCYCODE>GBP</CURRENCYCODE><COUNTRY>Great Britain</COUNTRY><RATE>5.9424</RATE><CHANGE>-0.344</CHANGE></CURRENCY><CURRENCY><NAME>Yen</NAME><UNIT>100</UNIT><CURRENCYCODE>JPY</CURRENCYCODE><COUNTRY>Japan</COUNTRY><RATE>4.5482</RATE><CHANGE>0.236</CHANGE></CURRENCY><CURRENCY><NAME>Euro</NAME><UNIT>1</UNIT><CURRENCYCODE>EUR</CURRENCYCODE><COUNTRY>EMU</COUNTRY><RATE>4.9243</RATE><CHANGE>-0.88</CHANGE></CURRENCY><CURRENCY><NAME>Dollar</NAME><UNIT>1</UNIT><CURRENCYCODE>AUD</CURRENCYCODE><COUNTRY>Australia</COUNTRY><RATE>3.8465</RATE><CHANGE>-0.404</CHANGE></CURRENCY><CURRENCY><NAME>Dollar</NAME><UNIT>1</UNIT><CURRENCYCODE>CAD</CURRENCYCODE><COUNTRY>Canada</COUNTRY><RATE>3.7627</RATE><CHANGE>0.237</CHANGE></CURRENCY><CURRENCY><NAME>krone</NAME><UNIT>1</UNIT><CURRENCYCODE>DKK</CURRENCYCODE><COUNTRY>Denmark</COUNTRY><RATE>0.6619</RATE><CHANGE>-0.869</CHANGE></CURRENCY><CURRENCY><NAME>Krone</NAME><UNIT>1</UNIT><CURRENCYCODE>NOK</CURRENCYCODE><COUNTRY>Norway</COUNTRY><RATE>0.6503</RATE><CHANGE>-0.884</CHANGE></CURRENCY><CURRENCY><NAME>Rand</NAME><UNIT>1</UNIT><CURRENCYCODE>ZAR</CURRENCYCODE><COUNTRY>South Africa</COUNTRY><RATE>0.4795</RATE><CHANGE>-1.114</CHANGE></CURRENCY><CURRENCY><NAME>Krona</NAME><UNIT>1</UNIT><CURRENCYCODE>SEK</CURRENCYCODE><COUNTRY>Sweden</COUNTRY><RATE>0.5589</RATE><CHANGE>-1.097</CHANGE></CURRENCY><CURRENCY><NAME>Franc</NAME><UNIT>1</UNIT><CURRENCYCODE>CHF</CURRENCYCODE><COUNTRY>Switzerland</COUNTRY><RATE>4.0916</RATE><CHANGE>-0.87</CHANGE></CURRENCY><CURRENCY><NAME>Dinar</NAME><UNIT>1</UNIT><CURRENCYCODE>JOD</CURRENCYCODE><COUNTRY>Jordan</COUNTRY><RATE>5.2806</RATE><CHANGE>0.562</CHANGE></CURRENCY><CURRENCY><NAME>Pound</NAME><UNIT>10</UNIT><CURRENCYCODE>LBP</CURRENCYCODE><COUNTRY>Lebanon</COUNTRY><RATE>0.0249</RATE><CHANGE>0.81</CHANGE></CURRENCY><CURRENCY><NAME>Pound</NAME><UNIT>1</UNIT><CURRENCYCODE>EGP</CURRENCYCODE><COUNTRY>Egypt</COUNTRY><RATE>0.6201</RATE><CHANGE>0.568</CHANGE></CURRENCY></CURRENCIES>';
		eru.UpdateExchangeRate();
		system.assertEquals(
			4,
			(Decimal) [
					SELECT count(id) cnt
					FROM Novidea_HPC__Exchange_Rate__c
					WHERE Novidea_HPC__Rate_Date__c >= 2055-12-12 AND Novidea_HPC__Rate__c = 21.32 AND Novidea_HPC__Target_Currency__c = 'USD'
				][0]
				.get('cnt')
		);

		system.assertEquals(
			2,
			(Decimal) [
					SELECT count(id) cnt
					FROM Novidea_HPC__Exchange_Rate__c
					WHERE Novidea_HPC__Rate_Date__c >= 2055-12-16 AND Novidea_HPC__Rate__c = 3.745 AND Novidea_HPC__Target_Currency__c = 'USD'
				][0]
				.get('cnt')
		);
	}

	@istest(seealldata=false)
	private static void testUpdateExchangeRate() {
		insert new Currency__c(
			Current_Exchange_Rate_Source_URL__c = 'ssss',
			Minutes_for_Daily_Update_Retry__c = 60,
			Number_of_Daily_Update_Retries__c = 10,
			Currency_Manager__c = 'ss@yy.com'
		);
		String adate = date.today().addDays(-2).year() + '-' + date.today().addDays(-2).month() + '-' + date.today().addDays(-2).day();
		list<Novidea_HPC__Exchange_Rate__c> ers = new List<Novidea_HPC__Exchange_Rate__c>();
		list<String> targets = new List<String>{
			'USD',
			'GBP',
			'JPY',
			'EUR',
			'AUD',
			'CAD',
			'DKK',
			'NOK',
			'ZAR',
			'SEK',
			'CHF',
			'JOD',
			'LBP',
			'EGP'
		};
		for (String target : targets) {
			ers.add(
				new Novidea_HPC__Exchange_Rate__c(
					Novidea_HPC__Rate_Date__c = Date.valueOf(adate),
					Novidea_HPC__Rate__c = Math.random(),
					Novidea_HPC__Target_Currency__c = target,
					Novidea_HPC__Source_Currency__c = 'ILS'
				)
			);
		}
		insert ers;
		TestUpdateExchangeRate eru = new TestUpdateExchangeRate();
		eru.TestGetHttpRequest();
		//replace for another test
		eru.rawData =
			'<CURRENCIES><LAST_UPDATE>' +
			adate +
			'</LAST_UPDATE><CURRENCY><NAME>Dollar</NAME><UNIT>1</UNIT><CURRENCYCODE>USD</CURRENCYCODE><COUNTRY>USA</COUNTRY><RATE>3.745</RATE><CHANGE>0.591</CHANGE></CURRENCY><CURRENCY><NAME>Pound</NAME><UNIT>1</UNIT><CURRENCYCODE>GBP</CURRENCYCODE><COUNTRY>Great Britain</COUNTRY><RATE>5.9424</RATE><CHANGE>-0.344</CHANGE></CURRENCY><CURRENCY><NAME>Yen</NAME><UNIT>100</UNIT><CURRENCYCODE>JPY</CURRENCYCODE><COUNTRY>Japan</COUNTRY><RATE>4.5482</RATE><CHANGE>0.236</CHANGE></CURRENCY><CURRENCY><NAME>Euro</NAME><UNIT>1</UNIT><CURRENCYCODE>EUR</CURRENCYCODE><COUNTRY>EMU</COUNTRY><RATE>4.9243</RATE><CHANGE>-0.88</CHANGE></CURRENCY><CURRENCY><NAME>Dollar</NAME><UNIT>1</UNIT><CURRENCYCODE>AUD</CURRENCYCODE><COUNTRY>Australia</COUNTRY><RATE>3.8465</RATE><CHANGE>-0.404</CHANGE></CURRENCY><CURRENCY><NAME>Dollar</NAME><UNIT>1</UNIT><CURRENCYCODE>CAD</CURRENCYCODE><COUNTRY>Canada</COUNTRY><RATE>3.7627</RATE><CHANGE>0.237</CHANGE></CURRENCY><CURRENCY><NAME>krone</NAME><UNIT>1</UNIT><CURRENCYCODE>DKK</CURRENCYCODE><COUNTRY>Denmark</COUNTRY><RATE>0.6619</RATE><CHANGE>-0.869</CHANGE></CURRENCY><CURRENCY><NAME>Krone</NAME><UNIT>1</UNIT><CURRENCYCODE>NOK</CURRENCYCODE><COUNTRY>Norway</COUNTRY><RATE>0.6503</RATE><CHANGE>-0.884</CHANGE></CURRENCY><CURRENCY><NAME>Rand</NAME><UNIT>1</UNIT><CURRENCYCODE>ZAR</CURRENCYCODE><COUNTRY>South Africa</COUNTRY><RATE>0.4795</RATE><CHANGE>-1.114</CHANGE></CURRENCY><CURRENCY><NAME>Krona</NAME><UNIT>1</UNIT><CURRENCYCODE>SEK</CURRENCYCODE><COUNTRY>Sweden</COUNTRY><RATE>0.5589</RATE><CHANGE>-1.097</CHANGE></CURRENCY><CURRENCY><NAME>Franc</NAME><UNIT>1</UNIT><CURRENCYCODE>CHF</CURRENCYCODE><COUNTRY>Switzerland</COUNTRY><RATE>4.0916</RATE><CHANGE>-0.87</CHANGE></CURRENCY><CURRENCY><NAME>Dinar</NAME><UNIT>1</UNIT><CURRENCYCODE>JOD</CURRENCYCODE><COUNTRY>Jordan</COUNTRY><RATE>5.2806</RATE><CHANGE>0.562</CHANGE></CURRENCY><CURRENCY><NAME>Pound</NAME><UNIT>10</UNIT><CURRENCYCODE>LBP</CURRENCYCODE><COUNTRY>Lebanon</COUNTRY><RATE>0.0249</RATE><CHANGE>0.81</CHANGE></CURRENCY><CURRENCY><NAME>Pound</NAME><UNIT>1</UNIT><CURRENCYCODE>EGP</CURRENCYCODE><COUNTRY>Egypt</COUNTRY><RATE>0.6201</RATE><CHANGE>0.568</CHANGE></CURRENCY></CURRENCIES>';
		eru.UpdateExchangeRate();
		Decimal total = (Decimal) ([
				SELECT count(id) total
				FROM Novidea_HPC__Exchange_Rate__c
				WHERE Novidea_HPC__Rate_Date__c = :Date.valueOf(adate).adddays(1)
			][0]
			.get('total'));
		system.debug(total);
		system.assertEquals(targets.size(), total);
		total = (Decimal) ([
				SELECT count(id) total
				FROM Novidea_HPC__Exchange_Rate__c
				WHERE Novidea_HPC__Rate_Date__c IN :(new List<Date>{ Date.valueOf(adate).adddays(2), Date.valueOf(adate).adddays(3) })
			][0]
			.get('total'));
		system.debug(total);
		system.assertEquals(targets.size() * 2, total);
	}

	@istest(seealldata=true)
	private static void testHandleExceptionCreateReschedule() {
		TestUpdateExchangeRate tuer = new TestUpdateExchangeRate(0, system.Today());
		tuer.rawData = '<CURRENCIES><LAST_UPDATE>2012-0404</LAST_UPDATE><CURRENCY><NAME>Dollar</NAME><UNIT>1</UNIT><CURRENCYCODE>USD</CURRENCYCODE><COUNTRY>USA</COUNTRY><RATE>3.745</RATE><CHANGE>0.591</CHANGE></CURRENCY></CURRENCIES>';
		Exception extest;
		tuer.UpdateExchangeRate();
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :tuer.retryJobId];
		system.assertNotEquals(null, ct);
		//ct.CronExpression
	}

	@istest(seealldata=true)
	private static void testHandleExceptionSendMail() {
		setCurrencyManagerAddress();
		TestUpdateExchangeRate tuer = new TestUpdateExchangeRate(ExchangeRateUpdate.NUMBER_OF_DAILY_UPDATE_RETRIES, system.Today());
		tuer.testGetExchangeRateUpdateScheduleImpl();
		tuer.rawData = '<CURRENCIES><LAST_UPDATE>2012-0404</LAST_UPDATE><CURRENCY><NAME>Dollar</NAME><UNIT>1</UNIT><CURRENCYCODE>USD</CURRENCYCODE><COUNTRY>USA</COUNTRY><RATE>3.745</RATE><CHANGE>0.591</CHANGE></CURRENCY></CURRENCIES>';
		Exception extest;
		tuer.UpdateExchangeRate();
	}

	@istest(seealldata=true)
	private static void testSendFailureEmail() {
		setCurrencyManagerAddress();
		TestUpdateExchangeRate tuer = new TestUpdateExchangeRate();
		tuer.sendExRateUpdateFailureEmail();
	}

	@istest(seealldata=false)
	private static void testUpdateExchangeRateJson() {
		Database.insert(
			new Currency__c(
				Current_Exchange_Rate_Source_URL__c = 'ssss',
				Minutes_for_Daily_Update_Retry__c = 60,
				Number_of_Daily_Update_Retries__c = 10,
				Currency_Manager__c = 'ss@yy.com'
			)
		);
		TestUpdateExchangeRate tuer = new TestUpdateExchangeRate();
		tuer.rawData =
			'{' +
			'\"exchangeRates\": [' +
			'{' +
			'\"key\": \"USD\",' +
			'\"currentExchangeRate\": 3.477,' +
			'\"currentChange\": 0.23061400980109543,' +
			'\"unit\": 1,' +
			'\"lastUpdate\": \"2022-12-21T13:23:04.1919991Z\"' +
			'},' +
			'{' +
			'\"key\": \"GBP\",' +
			'\"currentExchangeRate\": 4.2126,' +
			'\"currentChange\": 0.35973793924955335,' +
			'\"unit\": 1,' +
			'\"lastUpdate\": \"2022-12-21T13:23:04.1919991Z\"' +
			'}' +
			']' +
			'}';
		tuer.UpdateExchangeRatesJSON();
		Decimal total = (Decimal) ([SELECT count(id) total FROM Novidea_HPC__Exchange_Rate__c][0].get('total'));
		system.assertEquals(4, total);
	}
}