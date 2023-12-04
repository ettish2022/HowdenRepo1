public with sharing virtual class ExchangeRateUpdate {
	private static final String CURRENT_EXCHANGE_RATE_URL = Currency__c.getInstance().Current_Exchange_Rate_Source_URL__c;
	private static final Integer MINUTES_FOR_DAILY_UPDATE_RETRY = Currency__c.getInstance().Minutes_for_Daily_Update_Retry__c.intValue();
	public static final Integer NUMBER_OF_DAILY_UPDATE_RETRIES = Currency__c.getInstance().Number_of_Daily_Update_Retries__c.intValue();
	private static final String CURRENCY_MANAGER_ADMIN_EMAIL = Currency__c.getInstance().Currency_Manager__c;
	private static final String FAILURE_EMAIL_SUBJECT = '';
	protected Integer retryNumber { get; private set; }
	protected Date exchangeRateDate { get; private set; }
	public String retryJobId { get; private set; }

	public ExchangeRateUpdate(Integer retryNumber, Date exchangeRateDate) {
		this();
		this.retryNumber = retryNumber;
		this.exchangeRateDate = exchangeRateDate;
	}

	public ExchangeRateUpdate() {
		this.retryNumber = 0;
		this.exchangeRateDate = Date.today();
	}

	private class MissinigRateDateException extends Exception {
	}

	// kept for history reasons
	public void UpdateExchangeRate() {
		try {
			Dom.Document doc = getDailyRates();
			Dom.XmlNode root = doc.getRootElement();
			Dom.XmlNode[] currencies = root.getChildElements();

			Set<Novidea_HPC__Exchange_Rate__c> ers = new Set<Novidea_HPC__Exchange_Rate__c>();
			List<Novidea_HPC__Exchange_Rate__c> tmpExRates;
			Date updateDate;
			if (root.getChildElement('LAST_UPDATE', null) != null) {
				updateDate = Date.valueOf(root.getChildElement('LAST_UPDATE', null).getText());
			} else {
				throw new MissinigRateDateException();
			}
			Date refDate = exchangeRateDate > updateDate ? exchangeRateDate : updateDate;
			Set<String> codes = new Set<String>();
			String tmpCode;
			Decimal tmpRate, tmpUnits;
			system.debug(
				'exchangeRateDate: ' +
					exchangeRateDate +
					' user: ' +
					UserInfo.getName() +
					' ' +
					UserInfo.getLocale() +
					' ' +
					UserInfo.getUserName() +
					' ' +
					UserInfo.getUserId()
			);
			for (Dom.XmlNode crnc : currencies) {
				if (!crnc.getName().equalsIgnoreCase('CURRENCY')) {
					continue;
				}

				tmpCode = crnc.getChildElement('CURRENCYCODE', null).getText();
				codes.add(tmpCode);
				tmpUnits = Decimal.valueOf(crnc.getChildElement('UNIT', null).getText());
				tmpRate = Decimal.valueOf(crnc.getChildElement('RATE', null).getText());
				if (tmpUnits != null && tmpUnits > 0) {
					tmpRate = tmpRate / tmpUnits;
				}
				ers.addAll(new Set<Novidea_HPC__Exchange_Rate__c>(prepareExchangeRates(tmpCode, refDate, tmpRate)));
			}

			List<Novidea_HPC__Exchange_Rate__c> exchRateToUpd = new List<Novidea_HPC__Exchange_Rate__c>(ers);
			Database.upsert(exchRateToUpd);
		} catch (Exception ex) {
			handleException(ex);
		}
	}

	public void UpdateExchangeRatesJSON() {
		try {
			List<Novidea_HPC__Exchange_Rate__c> exchangeRatesToUpsert = new List<Novidea_HPC__Exchange_Rate__c>();
			String jsonStr = getRawDailyRates();
			List<ExchangeRateUpdate.ExchangeRate> exchRates = getExchangeRates(jsonStr);
			String currentCurrency;
			Decimal currentRate, currentUnit;
			Date currentLastUpdateRateDate;
			for (ExchangeRateUpdate.ExchangeRate exchRate : exchRates) {
				currentCurrency = exchRate.key;
				currentRate = exchRate.currentExchangeRate;
				currentUnit = exchRate.unit;
				if (currentUnit != null && currentUnit > 0) {
					currentRate = currentRate / currentUnit;
				}
				currentLastUpdateRateDate = exchRate.lastUpdate.date();
				Date referenceRateDate = exchangeRateDate > currentLastUpdateRateDate ? exchangeRateDate : currentLastUpdateRateDate;
				exchangeRatesToUpsert.addAll(prepareExchangeRates(currentCurrency, referenceRateDate, currentRate));
			}
			Database.upsert(exchangeRatesToUpsert);
		} catch (Exception exc) {
			handleException(exc);
		}
	}

	protected virtual String getRawDailyRates() {
		Http http = new Http();
		HttpRequest req = getHttpRequest();
		HttpResponse res = http.send(req);
		//this intermediate assignment seems to be necessary in order
		//for the subsequent document load not to crash
		/*String xml = res.getBody();
		 return xml;*/
		return res.getBody();
	}

	protected HttpRequest getHttpRequest() {
		HttpRequest req = new HttpRequest();
		system.debug(CURRENT_EXCHANGE_RATE_URL);
		req.setEndpoint(CURRENT_EXCHANGE_RATE_URL);
		req.setMethod('GET');
		return req;
	}

	private Dom.Document getDailyRates() {
		String xml = getRawDailyRates();
		Dom.Document doc = new Dom.Document();
		doc.load(xml);
		system.debug(xml);
		return doc;
	}

	protected virtual void sendExRateUpdateFailureEmail() {
		if (Test.isRunningTest()) {
			return;
		}
		Messaging.reserveSingleEmailCapacity(1);
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(new List<String>{ CURRENCY_MANAGER_ADMIN_EMAIL });
		EmailTemplate emailtemplate = [SELECT Id, Subject, Body FROM EmailTemplate WHERE DeveloperName = 'Daily_Exchange_Rate_Update_Failure'];
		//Id templateId;
		mail.setSubject(emailtemplate.Subject);
		//mail.setTemplateId(templateId);
		//Id target = [SELECT Id FROM User WHERE Email =: CURRENCY_MANAGER_ADMIN_EMAIL].Id;
		//mail.setTargetObjectId(target);
		//mail.setSaveAsActivity(false);
		mail.setPlainTextBody(emailtemplate.Body.replace('{!Today}', exchangeRateDate.format()));
		Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
	}

	private String rescheduleJob(Integer inRetryNumber) {
		Datetime dt = Datetime.now().addMinutes(MINUTES_FOR_DAILY_UPDATE_RETRY);
		String min = dt.minute() + '';
		String hour = dt.hour() + '';
		String day = dt.day() + '';
		String month = dt.month() + '';
		String year = dt.year() + '';
		//Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
		final String CRON_EXP = '0 ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
		system.debug(CRON_EXP);
		return system.schedule(
			'Update Daily Exchange Rate [' + exchangeRateDate.format() + '] - Retry #' + inRetryNumber,
			CRON_EXP,
			getExchangeRateUpdateScheduleImpl(inRetryNumber)
		);
	}

	protected virtual ExchangeRateUpdateScheduleImpl getExchangeRateUpdateScheduleImpl(Integer inRetryNumber) {
		return new ExchangeRateUpdateScheduleImpl(inRetryNumber, exchangeRateDate);
	}

	private void writeExceptionToLog(Exception ex) {
		system.debug(LoggingLevel.ERROR, ex);
	}
	public void handleException(Exception ex) {
		writeExceptionToLog(ex);
		if (retryNumber >= NUMBER_OF_DAILY_UPDATE_RETRIES) {
			sendExRateUpdateFailureEmail();
		} else {
			retryJobId = rescheduleJob(retryNumber + 1);
		}
	}

	private List<ExchangeRateUpdate.ExchangeRate> getExchangeRates(String jsonStr) {
		List<ExchangeRateUpdate.ExchangeRate> exchRates = new List<ExchangeRateUpdate.ExchangeRate>();
		JSONParser parser = JSON.createParser(jsonStr);
		while (parser.nextToken() != null) {
			if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
				while (parser.nextToken() != null) {
					if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
						ExchangeRateUpdate.ExchangeRate exchRate = (ExchangeRateUpdate.ExchangeRate) parser.readValueAs(
							ExchangeRateUpdate.ExchangeRate.class
						);
						exchRates.add(exchRate);
					}
				}
			}
		}
		return exchRates;
	}

	private List<Novidea_HPC__Exchange_Rate__c> prepareExchangeRates(String currencyCode, Date rateDate, Decimal rate) {
		List<Novidea_HPC__Exchange_Rate__c> exchangeRatesToUpsert = new List<Novidea_HPC__Exchange_Rate__c>();
		Novidea_HPC__Exchange_Rate__c lastExchangeRate, todayExchangeRate, tomorrowExchangeRate;
		// Find existing records in order to update instead of insert...
		List<Novidea_HPC__Exchange_Rate__c> exchangeRatesInDB = [
			SELECT Id, Novidea_HPC__Rate__c, Novidea_HPC__Rate_Date__c, Novidea_HPC__Source_Currency__c, Novidea_HPC__Target_Currency__c
			FROM Novidea_HPC__Exchange_Rate__c
			WHERE
				Novidea_HPC__Target_Currency__c = :currencyCode
				AND Novidea_HPC__Source_Currency__c = 'ILS'
				AND Novidea_HPC__Rate_Date__c > :rateDate.addDays(-10)
			ORDER BY Novidea_HPC__Rate_Date__c DESC
		];
		for (Novidea_HPC__Exchange_Rate__c currentExchRate : exchangeRatesInDB) {
			if (lastExchangeRate == null && currentExchRate.Novidea_HPC__Rate_Date__c < rateDate) {
				lastExchangeRate = currentExchRate;
				break;
			}
			if (currentExchRate.Novidea_HPC__Rate_Date__c == rateDate) {
				todayExchangeRate = currentExchRate;
			}
			if (currentExchRate.Novidea_HPC__Rate_Date__c == rateDate.addDays(1)) {
				tomorrowExchangeRate = currentExchRate;
			}
		}
		exchangeRatesToUpsert.add(
			new Novidea_HPC__Exchange_Rate__c(
				Id = todayExchangeRate?.Id,
				Novidea_HPC__Rate__c = rate,
				Novidea_HPC__Source_Currency__c = 'ILS',
				Novidea_HPC__Target_Currency__c = currencyCode,
				Novidea_HPC__Rate_Date__c = rateDate
			)
		);
		exchangeRatesToUpsert.add(
			new Novidea_HPC__Exchange_Rate__c(
				Id = tomorrowExchangeRate?.Id,
				Novidea_HPC__Rate__c = rate,
				Novidea_HPC__Source_Currency__c = 'ILS',
				Novidea_HPC__Target_Currency__c = currencyCode,
				Novidea_HPC__Rate_Date__c = rateDate.addDays(1)
			)
		);
		// Add missing exchange rates for the last week (missing exchange rates occur because the bank post exchange rates only in work days)
		if (lastExchangeRate != null) {
			Date startingDate = lastExchangeRate.Novidea_HPC__Rate_Date__c;
			if (startingDate.daysBetween(rateDate) > 1) {
				for (Integer daysBetween = 1; daysBetween < startingDate.daysBetween(rateDate); daysBetween++) {
					lastExchangeRate = lastExchangeRate.clone(false, true, false, true);
					lastExchangeRate.Novidea_HPC__Rate_Date__c = startingDate.addDays(daysBetween);
					system.debug('lastExchangeRate: ' + lastExchangeRate);
					exchangeRatesToUpsert.add(lastExchangeRate);
				}
			}
		}
		return exchangeRatesToUpsert;
	}

	public class ExchangeRate {
		public String key;
		public Decimal currentExchangeRate;
		public Decimal currentChange;
		public Decimal unit;
		public DateTime lastUpdate;

		public ExchangeRate(String key, Decimal exchangeRate, Decimal change, Decimal unit, DateTime lastUpdate) {
			this.key = key;
			this.currentExchangeRate = exchangeRate;
			this.currentChange = change;
			this.unit = unit;
			this.lastUpdate = lastUpdate;
		}
	}
}