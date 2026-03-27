public with sharing class IF_HubMeetingBatch implements Database.Batchable<SObject>, Database.Stateful{
    public IF_HubMeetingBatch() {}

    // Database.executeBatch(new IF_HubMeetingBatch(), 500);

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id'
                            + ', Name'
                            + ', StartAllDay__c'
                            + ', IFExternalKey__c'
                            + ', AccountIFExternalKey__c'
                            + ' FROM IF_MeetingLog__c'
                            + ' WHERE IsConverted__c = false'
                            + ' ORDER BY CreatedDate DESC';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<IF_MeetingLog__c> ifList) {
        Map<String, MeetingLog__c> tempMeetingMap = new Map<String, MeetingLog__c>();
        List<IF_MeetingLog__c> updateIFList = new List<IF_MeetingLog__c>();
        List<MeetingLog__c> updateMeetingList = new List<MeetingLog__c>();
        Map<String, Id> accMap = new Map<String, Id>();

        try {
            for (Account acc : [
                SELECT Id, IFExternalKey__c
                FROM Account
                WHERE IFExternalKey__c != null
            ]) {
                accMap.put(acc.IFExternalKey__c, acc.Id);
            }

            for (IF_MeetingLog__c obj : ifList) {
                MeetingLog__c meeting = new MeetingLog__c();
                meeting.IFExternalKey__c = obj.IFExternalKey__c;
                meeting.Name = obj.Name;
                meeting.StartAllDay__c = obj.StartAllDay__c;
                meeting.IsConverted__c = false;
                meeting.IsAllDay__c	= true;

                if (obj.AccountIFExternalKey__c != null && accMap.containsKey(obj.AccountIFExternalKey__c)) {
                    meeting.SoldTo__c = accMap.get(obj.AccountIFExternalKey__c);
                }

                tempMeetingMap.put(obj.IFExternalKey__c, meeting);
            }

            updateMeetingList.addAll(tempMeetingMap.values());

            Set<String> updateSuccessKeySet = new Set<String>(); // IFExternalKey__c

            if (updateMeetingList.size() > 0) {
                List<Database.UpsertResult> updateResult = Database.upsert(updateMeetingList, MeetingLog__c.IFExternalKey__c, false);

                for (Integer index = 0; index < updateResult.size(); index++) {
                    if (updateResult[index].isSuccess()) {
                        updateSuccessKeySet.add(updateMeetingList[index].IFExternalKey__c);
                        System.debug('Success : ' + updateMeetingList[index].IFExternalKey__c);
                    } else {
                        for (Database.Error error : updateResult[index].getErrors()) {
                            System.debug('Error : ' + updateResult[index].getId() + ' : ' + error.getStatusCode());
                        }
                    }
                }
            }

            for (IF_MeetingLog__c obj : ifList) {
                if (updateSuccessKeySet.contains(obj.IFExternalKey__c)) {
                    obj.IsConverted__c = true;
                    updateIFList.add(obj);
                }
            }

            if (updateIFList.size() > 0) {
                Update updateIFList;
            }
        } catch (Exception e) {
            System.debug('ERROR : ' + e.getMessage() + ' LINE : ' + e.getLineNumber());
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('IF_HubMeetingBatch Finish');
        // ... 스케줄 필요 시 추가
    }

}