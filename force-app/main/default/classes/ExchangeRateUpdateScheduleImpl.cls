global with sharing virtual class ExchangeRateUpdateScheduleImpl implements Schedulable {
	protected Integer retryNumber = 0;
	protected Date exchangeRateDate = null;

	public ExchangeRateUpdateScheduleImpl() {
	}

	public ExchangeRateUpdateScheduleImpl(Integer retryNumber, Date exchangeRateDate) {
		this.retryNumber = retryNumber;
		this.exchangeRateDate = exchangeRateDate;
	}

	global virtual void execute(SchedulableContext ctx) {
		ExchangeRateUpdateScheduleImpl.execute(retryNumber, exchangeRateDate == null ? Date.today() : exchangeRateDate);
	}

	@future(callout=true)
	public static void execute(Integer retryNumber, Date exchangeRateDate) {
		start(retryNumber, exchangeRateDate);
	}

	public static void start(Integer retryNumber, Date exchangeRateDate) {
		ExchangeRateUpdate eru = new ExchangeRateUpdate(retryNumber, exchangeRateDate);
		// eru.UpdateExchangeRate();
		eru.UpdateExchangeRatesJSON();
	}
}