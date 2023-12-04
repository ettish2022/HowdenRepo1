global with sharing class DocumentSearchRefreshCache implements Schedulable{
    global void execute(SchedulableContext ctx) {
        NFILING__InboundDocument__c[] cache =
            [SELECT OwnerId, NFILING__EntId1__c, NFILING__EntId2__c, NFILING__EntId3__c, NFILING__EntId4__c, NFILING__EntId5__c, NFILING__EntId6__c, NFILING__EntId7__c, NFILING__EntId8__c, NFILING__EntId9__c, NFILING__EntId10__c,
                        NFILING__EntId11__c, NFILING__EntId12__c, NFILING__EntId13__c, NFILING__EntId14__c, NFILING__EntId15__c, NFILING__EntId16__c, NFILING__EntId17__c, NFILING__EntId18__c, NFILING__EntId19__c, NFILING__EntId20__c
            FROM NFILING__InboundDocument__c
            WHERE OwnerId = '005D0000001zdwK'
            LIMIT 10000];
    }
}