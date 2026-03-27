public with sharing class NX_DownloadMeetingLogExcelController {
    @AuraEnabled
    public static List<MeetingLog__c> getEvents(Id recordId, Id lastRecordId, Datetime lastCreatedDate, Integer limitSize) {
        String query = 'SELECT Id, Name, Task__c, SoldTo2__c, StartNotAllDay__c, StartAllDay__c, EndNotAllDay__c, EndAllDay__c, Contents__c ' +
                       'FROM MeetingLog__c ';
        
        List<String> conditions = new List<String>();

        try {
            if (lastRecordId != null && lastCreatedDate != null) {
                conditions.add('(CreatedDate < :lastCreatedDate OR (CreatedDate = :lastCreatedDate AND Id < :lastRecordId))');
            }
    
            if (!conditions.isEmpty()) {
                query += ' WHERE ' + String.join(conditions, ' AND ');
            }
    
            query += ' ORDER BY CreatedDate DESC, Id DESC LIMIT :limitSize';
        } catch (Exception e) {
            System.debug(e.getMessage() + 'line : ' + e.getLineNumber());
        }

        return Database.query(query);
    }
}