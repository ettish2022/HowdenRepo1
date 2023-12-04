global with sharing class DocumentSearchFacade {
	global class SearchResult {
		public list<InboundDocument__c> documents {get;set;}
		public Integer maximumSize {get;set;}
	}
    @RemoteAction    
    global static SearchResult doRemoteSearch(String params){
        system.debug(params);
        DocumentSearchParams oParams = (DocumentSearchParams)Json.deserialize(params,DocumentSearchParams.class);
        system.debug(oParams);
        if(oParams==null)oParams = new DocumentSearchParams();
        if(null==oParams.orderby){
            oParams.orderby  = new DocumentSearchParams.DocumentSearchOrderByParam[]{};
        }
        if(!oParams.isOrderByFieldSet('Date_Received__c'))
            oParams.orderby.add(new DocumentSearchParams.DocumentSearchOrderByParam('Date_Received__c','DESC'));
        SearchResult result = new SearchResult();
        result.documents = DocumentSearchController.doRemoteSearch(oParams);
        result.maximumSize = DocumentSearchController.MAX_RECORDS;
        if (!String.isEmpty(oParams.freeText))
        	result.maximumSize = DocumentSearchController.LIMIT_SOSL_QUERY_RECORDS;
        return result;//JSON.serialize(docs);
    }
    
    public DocumentSearchFacade(DocumentSearchController searchController) {}
    public static Integer maxRecords {
    	get {
    		return DocumentSearchController.MAX_RECORDS;
    	}
    	private set;
    }
}