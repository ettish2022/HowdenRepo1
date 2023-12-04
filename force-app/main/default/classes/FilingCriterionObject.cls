public with sharing class FilingCriterionObject {
	private string label;
	public string name {get; set;}
	public string apiName {get; set;}
	public string jsonPrefix {get; set;}
	public Integer valueInTaskConnect {get; set;}
	public String accountFieldName {get; set;}
	public String accountRelationshipName {get; set;}
	public String relationshipToAccountImpClass {get; set;}
	public String jsonBaseFieldName {get; set;}
	public String nameFieldsCsv {get; set;}
	public String idFieldsCsv {get; set;}
	public String relationToAccountFieldName {get; set;} 
	
	public String getJsonPrefixCap() {
		if (jsonPrefix != null)
			return jsonPrefix.capitalize();
		
		return null;
	}
	
	public String getLabel(){
		if (label == null && apiName != null){
			SobjectType objDesc = Schema.getGlobalDescribe().get(apiName);
			if (objDesc != null)
				label = objDesc.getDescribe().getLabel();
			else 
				label = 'Object was not found:' + apiName;
		}

		return label;
	}
	
	public AccountSObjectInterface getInstanceOfRelationshipToAccountImpl(){
		try {
			Type t = Type.forName(relationshipToAccountImpClass);
			return (AccountSObjectInterface)t.newInstance();
		} catch(Exception e) {
			System.debug('getInstanceOfRelationshipToAccountImpl: Failed initiatiating the impl class: ' + e.getMessage());
			return null;
		}
	}
}