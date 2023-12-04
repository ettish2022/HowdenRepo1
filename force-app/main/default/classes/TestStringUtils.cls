@isTest
public class TestStringUtils {

    static testMethod void  test001() {
        String s = '';
        StringUtils.isNullOrEmpty(s);
        s = null;
        StringUtils.isNullOrEmpty(s);
        
        Date d = Date.today();
        StringUtils.date4Query(d);
        
        StringUtils.dateTime4Query(d);
        StringUtils.getValIfNotEmpty('test1', 'test2');
        StringUtils.getValIfEmpty('test1', 'test2');
        StringUtils.getValIfNotBlank('test1', 'test2');
        StringUtils.getValIfBlank('test1', 'test2');
        StringUtils.getValIfNotNull('test1', 'test2');
        StringUtils.getValIfNull('test1', 'test2');
    }
}