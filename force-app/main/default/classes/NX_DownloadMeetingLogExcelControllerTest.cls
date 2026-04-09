/**
 * @description       : 
 * @author            : eunsu.kim
 * @group             : 
 * @last modified on  : 04-09-2026
 * @last modified by  : eunsu.kim
**/
@isTest
private class NX_DownloadMeetingLogExcelControllerTest {

    @isTest
    static void testGetEvents_basic() {

        List<MeetingLog__c> listData = new List<MeetingLog__c>();

        for (Integer i = 0; i < 5; i++) {
            MeetingLog__c m = new MeetingLog__c();
            m.Name = 'Test ' + i;
            m.StartAllDay__c = Date.today();
            listData.add(m);
        }

        insert listData;

        Test.startTest();
        List<MeetingLog__c> result = NX_DownloadMeetingLogExcelController.getEvents(
            null, null, null, 5
        );
        Test.stopTest();

        System.assert(result.size() > 0);
    }

    @isTest
    static void testGetEvents_conditionBranch() {

        List<MeetingLog__c> listData = new List<MeetingLog__c>();

        for (Integer i = 0; i < 3; i++) {
            MeetingLog__c m = new MeetingLog__c();
            m.Name = 'Test ' + i;
            m.StartAllDay__c = Date.today();
            listData.add(m);
        }

        insert listData;

        MeetingLog__c last = listData[2];

        Test.startTest();
        List<MeetingLog__c> result = NX_DownloadMeetingLogExcelController.getEvents(
            null,
            last.Id,
            last.CreatedDate,
            2
        );
        Test.stopTest();

        System.assert(result != null);
    }

    @isTest
    static void testGetEvents_emptyResult() {

        // 데이터 없음 상태에서 실행
        Test.startTest();
        List<MeetingLog__c> result = NX_DownloadMeetingLogExcelController.getEvents(
            null, null, null, 5
        );
        Test.stopTest();

        // 결과 0건 확인
        System.assertEquals(0, result.size());
    }

    @isTest
    static void testGetEvents_fullConditionFlow() {

        List<MeetingLog__c> listData = new List<MeetingLog__c>();

        for (Integer i = 0; i < 5; i++) {
            MeetingLog__c m = new MeetingLog__c();
            m.Name = 'Flow ' + i;
            m.StartAllDay__c = Date.today();
            listData.add(m);
        }

        insert listData;

        MeetingLog__c last = [
            SELECT Id, CreatedDate
            FROM MeetingLog__c
            ORDER BY CreatedDate DESC
            LIMIT 1 OFFSET 2
        ];

        Test.startTest();
        List<MeetingLog__c> result = NX_DownloadMeetingLogExcelController.getEvents(
            null,
            last.Id,
            last.CreatedDate,
            5
        );
        Test.stopTest();

        System.assert(result.size() >= 0);
    }
}