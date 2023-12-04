public class StringUtils {
    public static Boolean isNullOrEmpty(String s) {
        //rz change 1/1/13: replaced custom implementation with std. one
        return string.isEmpty(s);
    }
    
    public static String date4Query(Date d) {
    	return d.year() + '-' + d.month() + '-' + d.day();
    }   
    
    public static String dateTime4Query(Date d) {
    	return date4Query(d) + 'T00:00:00Z';
    }
   
    public static String getValIfNull(String value, String altValue){
    	return value==null?altvalue:value;
    }

    public static String getValIfNotNull(String value, String altValue){
    	return value!=null?altvalue:value;
    }
    
    public static String getValIfBlank(String value, String altValue){
    	return string.isBlank(value)?altvalue:value;
    }

    public static String getValIfNotBlank(String value, String altValue){
    	return string.isNotBlank(value)?altvalue:value;
    }

    public static String getValIfEmpty(String value, String altValue){
    	return string.isEmpty(value)?altvalue:value;
    }

    public static String getValIfNotEmpty(String value, String altValue){
    	return string.isNotEmpty(value)?altvalue:value;
    }
    
    
    
   
}