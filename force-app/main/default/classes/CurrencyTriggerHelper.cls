public with sharing class CurrencyTriggerHelper {
    public static boolean stopTrigger = false;
    public static void updateCurrency(Sobject currencyCustomSettings, Schema.Describesobjectresult objDesc, list<sobject> objs){
        if(stopTrigger)return;
        CurrencyHelper.currencyFieldNamesByTargetField = null;
        CurrencyHelper ch = new CurrencyHelper(currencyCustomSettings,objDesc);
        ch.updateCurrencyFields(objs);
        system.debug(objs);
    }
}