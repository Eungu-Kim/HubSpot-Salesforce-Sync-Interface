/**
 * @description       : 
 * @author            : eunsu.kim
 * @group             : 
 * @last modified on  : 04-09-2026
 * @last modified by  : eunsu.kim
**/
// Code Coverage 95%, Test Execution Time 289ms
@isTest
public class HubCompanyRequest_Test {
    // Code Coverage 93%
    @isTest
    static void companyRequestTestSuccess() {
        IF_HubspotMockFactory.testCase = 'SUCCESS';
        IF_HubspotMockFactory.targetObject = 'companies';
        Test.setMock(HttpCalloutMock.class, new IF_HubspotMockFactory());
        Test.startTest();
        HubCompanyRequest.hubCompanyRequest();
        Test.stopTest();

        List<IF_Account__c> resultList = [SELECT Id, Name, IFExternalKey__c, PostalCode__c, Domain__c FROM IF_Account__c];
        System.assertEquals(1, resultList.size(), '데이터 1건 생성되어야 합니다');
        
        IF_Account__c res = resultList[0];
    }

    // Code Coverage 38%
    @isTest
    static void meetingLogRequestTestFail() {
        IF_HubspotMockFactory.testCase = 'ERROR';
        IF_HubspotMockFactory.targetObject = 'companies';
        Test.setMock(HttpCalloutMock.class, new IF_HubspotMockFactory());
        Test.startTest();
        HubCompanyRequest.hubCompanyRequest();
        Test.stopTest();

        List<IF_Account__c> resultList = [SELECT Id FROM IF_Account__c];

        System.assertEquals(0, resultList.size(), '에러 시 데이터가 생성되면 안됩니다');
    }
}