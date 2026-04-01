/**
 * @description       : 
 * @author            : eunsu.kim
 * @group             : 
 * @last modified on  : 04-01-2026
 * @last modified by  : eunsu.kim
**/
// Code Coverage 95%, Test Execution Time 289ms
@isTest
public class IF_HubMeetingRequest_Test {
    // Code Coverage 93%
    @isTest
    static void meetingLogRequestTestSuccess() {
        IF_HubspotMockFactory.testCase = 'SUCCESS';
        IF_HubspotMockFactory.targetObject = 'meetings';
        Test.setMock(HttpCalloutMock.class, new IF_HubspotMockFactory());
        Test.startTest();
        IF_HubMeetingRequest.hubMeetingRequest();
        Test.stopTest();

        List<IF_MeetingLog__c> resultList = [SELECT Id, Name, IFExternalKey__c, StartAllDay__c, AccountIFExternalKey__c FROM IF_MeetingLog__c];
        System.assertEquals(1, resultList.size(), '데이터 1건 생성되어야 합니다');
        
        IF_MeetingLog__c res = resultList[0];

        System.assertEquals('123', res.IFExternalKey__c, 'ExternalKey 오류');
        System.assertEquals('Test Meeting', res.Name, 'Title 매핑 오류');
        System.assertEquals(Date.valueOf('2026-03-30'), res.StartAllDay__c, 'Date 변환 오류');
        System.assertEquals('999', res.AccountIFExternalKey__c, 'Company Id 오류');
    }

    // Code Coverage 87%
    @isTest
    static void meetingLogRequestTestNoAssociation() {
        IF_HubspotMockFactory.testCase = 'NO_ASSOC';
        IF_HubspotMockFactory.targetObject = 'meetings';
        Test.setMock(HttpCalloutMock.class, new IF_HubspotMockFactory());
        Test.startTest();
        IF_HubMeetingRequest.hubMeetingRequest();
        Test.stopTest();

        List<IF_MeetingLog__c> resultList = [SELECT AccountIFExternalKey__c FROM IF_MeetingLog__c];

        System.assertEquals(null, resultList[0].AccountIFExternalKey__c, 'association이 없으면 null이어야 합니다');
    }

    // Code Coverage 38%
    @isTest
    static void meetingLogRequestTestFail() {
        IF_HubspotMockFactory.testCase = 'ERROR';
        IF_HubspotMockFactory.targetObject = 'meetings';
        Test.setMock(HttpCalloutMock.class, new IF_HubspotMockFactory());
        Test.startTest();
        IF_HubMeetingRequest.hubMeetingRequest();
        Test.stopTest();

        List<IF_MeetingLog__c> resultList = [SELECT Id FROM IF_MeetingLog__c];

        System.assertEquals(0, resultList.size(), '에러 시 데이터가 생성되면 안됩니다');
    }
}