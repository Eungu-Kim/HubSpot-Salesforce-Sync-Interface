/**
 * @description       : 
 * @author            : eunsu.kim
 * @group             : 
 * @last modified on  : 04-09-2026
 * @last modified by  : eunsu.kim
**/
@isTest
private class IF_HubMeetingBatch_Test {

    @isTest
    static void testBatchExecution() {

        List<Account> accList = new List<Account>();

        for (Integer i = 0; i < 3; i++) {
            Account acc = new Account();
            acc.Name = 'Account ' + i;
            acc.IFExternalKey__c = 'ACC_KEY' + i;
            acc.PostalCode__c = '12345';
            accList.add(acc);
        }

        insert accList;

        List<IF_MeetingLog__c> ifList = new List<IF_MeetingLog__c>();

        for (Integer i = 0; i < 5; i++) {
            IF_MeetingLog__c obj = new IF_MeetingLog__c();
            obj.Name = 'Meeting ' + i;
            obj.StartAllDay__c = Date.today();
            obj.IFExternalKey__c = 'MEETING_KEY' + i;

            if (i < 3) {
                obj.AccountIFExternalKey__c = 'ACC_KEY' + i;
            }

            obj.IsConverted__c = false;
            ifList.add(obj);
        }

        insert ifList;

        Test.startTest();
        Database.executeBatch(new IF_HubMeetingBatch(), 200);
        Test.stopTest();

        List<MeetingLog__c> meetingList = [
            SELECT Id, IFExternalKey__c, SoldTo__c
            FROM MeetingLog__c
            WHERE IFExternalKey__c LIKE 'MEETING_KEY%'
        ];

        System.assert(meetingList.size() > 0);

        for (MeetingLog__c m : meetingList) {
            if (m.IFExternalKey__c == 'MEETING_KEY0' ||
                m.IFExternalKey__c == 'MEETING_KEY1' ||
                m.IFExternalKey__c == 'MEETING_KEY2') {

                System.assertNotEquals(null, m.SoldTo__c);
            }
        }

        List<IF_MeetingLog__c> updatedList = [
            SELECT Id, IsConverted__c
            FROM IF_MeetingLog__c
            WHERE IFExternalKey__c LIKE 'MEETING_KEY%'
        ];

        for (IF_MeetingLog__c obj : updatedList) {
            System.assertEquals(true, obj.IsConverted__c);
        }
    }
}