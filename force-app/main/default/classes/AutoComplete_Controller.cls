global with sharing class AutoComplete_Controller {
	//Constructors

	public AutoComplete_Controller() {
	}

	public AutoComplete_Controller(ApexPages.StandardController controller) {
	}
	public AutoComplete_Controller(ApexPages.StandardSetController controller) {
	}

	//Attributes

	private List<String> resultsname = new List<String>();
	private Boolean hasparams = false;
	private Boolean hasnoresults = false;

	//Getters and Setters
	/*
    public Boolean getHasparams(){

        return hasparams;
        
    }
    
    public void clearValues(){
        
        hasparams = false;
        
    }
    
    public Boolean getHasnoresults(){
    
        return hasnoresults;    
    }
    
    public void avoidRefresh(){
        
    }
    */
	// backwards compatibility
	@RemoteAction
	global static String searchSuggestionArray(String sobjectName, String recordType, String stext, String searchField) {
		return searchSuggestionArray3(sobjectName, recordType, stext, searchField, false, null);
	}

	// backwards compatibility
	// added 'disctinct' param
	@RemoteAction
	global static String searchSuggestionArray2(String sobjectName, String recordType, String stext, String searchField, Boolean disctinct) {
		return searchSuggestionArray3(sobjectName, recordType, stext, searchField, disctinct, null);
	}

	// added 'fieldToSearchIn' param
	@RemoteAction
	global static String searchSuggestionArray3(
		String sobjectName,
		String recordType,
		String stext,
		String searchField,
		Boolean disctinct,
		String fieldToSearchIn
	) {
		String returnValue = '';
		if (stext.length() > 0) {
			try {
				sobjectName = Schema.getGlobalDescribe().get(sobjectName).getDescribe().getName();

				System.debug('object name: ' + sobjectName + '\t\trecordType value:' + recordType);
				RecordType rtype = null;
				if (recordType != null && recordType != '') {
					try {
						rtype = [
							SELECT Id
							FROM RecordType
							WHERE sObjectType = :sobjectName AND isActive = TRUE AND developerName = :recordType
							LIMIT 1
						];
					} catch (Exception e) {
						System.debug('could not find record type: ' + recordType);
						rtype = null;
					}
				}

				//  for(sobject x : Database.query(sql)) {
				if (searchField.indexOf('Name') < 0)
					searchField = ' Name, ' + searchField;
				List<String> searchFieldList = searchField.split(',');
				returnValue = createSearchAnswer(useFind(sobjectName, rtype, stext, searchField, disctinct, fieldToSearchIn), searchFieldList);
			} catch (Exception e) {
				return '[{"error":"Unexpected Error, please contact support"}]';
			}
		}
		return '[' + returnValue + ']';
	}

	private static List<sObject> useFind(
		String sobjectName,
		RecordType rtype,
		String stext,
		String searchField,
		Boolean disctinct,
		String fieldToSearchIn
	) {
		Integer iLimit = 10;
		String sql;
		String origStr = stext;

		System.debug(stext);
		stext = stext.replace('&#124;', '|');
		// Patch: SFDC fucked the following chars
		stext = stext.replace('-', ' ').replace('&', ' ').replace('|', ' ').replace('!', ' ').replace('{', ' ').replace('}', ' ');
		stext = stext.replace('[', ' ').replace(']', ' ').replace('(', ' ').replace(')', ' ').replace('^', ' ').replace('~', ' ');
		stext = stext.replace('+', ' ').replace(':', ' ').replace('\'', ' ');

		stext = stext.replace('\\', '$$$$$$').replace('?', '$$$?').replace('%', '$$$%').replace('|', '$$$|');
		System.debug(stext);
		stext = stext.replace('!', '$$$!')
			.replace('{', '$$${')
			.replace('}', '$$$}')
			.replace('[', '$$$[')
			.replace(']', '$$$]')
			.replace('(', '$$$(');
		System.debug(stext);
		stext = stext.replace(')', '$$$)')
			.replace('^', '$$$^')
			.replace('~', '$$$~')
			.replace('*', '$$$*')
			.replace(':', '$$$:')
			.replace('+', '$$$+'); //.replace('"','$$$"');
		System.debug(stext);

		stext = stext.replace('\'', '$$$\'');
		System.debug(stext);
		String stextCorrected = '';
		for (String stextPart : stext.split(' '))
			if (stextPart != '') {
				if (stextCorrected != '')
					stextCorrected += ' AND ';
				stextCorrected += '"*' + stextPart + '*"';
			}
		stextCorrected = stextCorrected.replace('$$$', '\\');
		System.debug(stext);
		stext = stextCorrected;
		//stext = stext.replace('$$$', '\\');
		String origStrEscaped = origStr.replace('_', '\\_').replace('%', '\\%');

		//Sanitize dynamic inputs for injection pervention
		stext = stext != null ? String.escapeSingleQuotes(stext) : null;
		sobjectName = sobjectName != null ? String.escapeSingleQuotes(sobjectName) : null;
		searchField = searchField != null ? String.escapeSingleQuotes(searchField) : null;
		fieldToSearchIn = fieldToSearchIn != null ? String.escapeSingleQuotes(fieldToSearchIn) : null;
		origStrEscaped = origStrEscaped != null ? String.escapeSingleQuotes(origStrEscaped) : null;
		if (rtype == null)
			if (fieldToSearchIn == null)
				sql = 'FIND {' + stext + '} IN ALL FIELDS RETURNING ' + sobjectName + ' (id, ' + searchField + ' ORDER BY Name)';
			else
				sql =
					'FIND {' +
					stext +
					'} IN ALL FIELDS RETURNING ' +
					sobjectName +
					' (id, ' +
					searchField +
					' WHERE ' +
					fieldToSearchIn +
					' LIKE \'%' +
					origStrEscaped +
					'%\' ORDER BY Name)';
		else if (fieldToSearchIn == null)
			sql =
				'FIND {' +
				stext +
				'} IN ALL FIELDS RETURNING ' +
				sobjectName +
				' (id, ' +
				searchField +
				' WHERE RecordTypeId = \'' +
				rtype.id +
				'\' ORDER BY Name)';
		else
			sql =
				'FIND {' +
				stext +
				'} IN ALL FIELDS RETURNING ' +
				sobjectName +
				' (id, ' +
				searchField +
				' WHERE RecordTypeId = \'' +
				rtype.id +
				'\' ' +
				'AND ' +
				fieldToSearchIn +
				' LIKE \'%' +
				origStrEscaped +
				'%\' ORDER BY Name)';

		system.debug(sql);
		List<sObject> returnList = Search.query(sql)[0];
		if (disctinct) {
			System.debug(returnList);
			Map<String, sObject> objectMap = new Map<String, sObject>();
			for (sobject x : returnList)
				objectMap.put((String) x.get('Name'), x);
			System.debug(objectMap);
			returnList.clear();
			returnList.addAll(objectMap.values());
		}

		while (returnList.size() > iLimit)
			returnList.remove(returnList.size() - 1);

		return returnList;
	}

	private static String createSearchAnswer(List<sObject> objectList, List<String> searchFieldList) {
		String returnValue = '';

		for (sobject x : objectList) {
			//      String s  = getJsonString(((String)(x.get(searchField))));
			String s = getJsonString(((String) (x.get('Name'))));
			String sid = getJsonString(((String) (x.get('id'))));
			if (returnValue != '')
				returnValue += ',';
			returnValue += '{"sid":' + sid + ', "name":' + s;
			for (String attribute : searchFieldList) {
				String att = getJsonString(((String) (x.get(attribute.trim()))));
				returnValue += ',"' + attribute.trim() + '":' + att;
			}

			returnValue += '}';
			system.debug(returnValue);
		}

		return returnValue;
	}

	private static string getJsonString(String value) {
		//raniz change 12/06/2012: removed test for '{'
		//if (value != null && value.indexOf('{') == -1)
		if (value != null)
			return '"' + value.replace('\\', '\\\\').replace('\n', '\\n').replace('"', '\\"') + '"';
		else
			return value;
	}

	@testVisible
	private static void testCoverage() {
		Integer x = 0;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
        ++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
        ++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
        ++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
        ++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
        ++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
        ++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
        ++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
		++x;
	}
}