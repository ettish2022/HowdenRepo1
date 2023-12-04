public with sharing class ServiceLocator {
	public static Object getService(String interfacename){
		CustomImplementation__c cs = CustomImplementation__c.getInstance(interfacename);
		if(cs==null || cs.ClassName__c==null || ''.equals(cs.ClassName__c)) return null;
		Type t = Type.forName(cs.className__c);
		return t.newInstance();
	}
}