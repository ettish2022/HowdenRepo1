global with sharing class DocumentSearchParams {
	public List<CustomEntityFilter> acts{get; set;}
	public Id act{get;set;}
	public Id cnt{get;set;}
	public Id tsk{get;set;}
	public Id owner{get;set;}

	public String actname{get;set;}
	public String cntname{get;set;}
	public String ownername{get;set;}
	public String tskname{get;set;}

	public Map<String, CustomEntityFilter> customEnts {get; set;}
	  
	public String startDate{get;set;}
	public String endDate{get;set;}
	public String[] doctype{get;set;}
	public String freeText {get;set;}
	public Integer queryLimit {get;set;}

	public DocumentSearchOrderByParam[] orderby{get;set;}
	//marks whether we need to first display ordered created docs and only later ordered imported docs from shavit 
	public boolean splitQueryByImportedVSCreated{get;set;}

	public boolean removeOrderByElement(String fieldName) {
	    integer i=0;
	    for(DocumentSearchOrderByParam ds: orderby){
	        if(ds!=null && ds.fieldName!=null && ds.fieldName.equalsIgnoreCase(fieldName)){
	        	orderby.remove(i);
	        	return true;
	        }
	        ++i;
	    }
	    return false;       	
	}
      
    public boolean isOrderByFieldSet(String fieldName){
		for(DocumentSearchOrderByParam ds: orderby){
			if(ds!=null && ds.fieldName!=null && ds.fieldName.equalsIgnoreCase(fieldName))return true;
		}
		return false;   
    }
      
	public String getJson(){
		return Json.serialize(this);
	}

	public class CustomEntityFilter {
		public String idStr {get; set;}
		public String name {get; set;}
	}
	    
	global class DocumentSearchOrderByParam{
		public String fieldName {get;set;}
		public String sortdir{get;set;}
		//true if nulls first false if last, null for nothing
		public boolean nullsFirst{get;set;}
		public DocumentSearchOrderByParam(String fieldName, String sortdir){
			this.fieldName = fieldName;
			this.sortdir = sortdir;
		}
	}
}