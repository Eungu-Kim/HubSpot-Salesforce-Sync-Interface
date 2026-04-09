/**
 * @description       : 
 * @author            : eunsu.kim
 * @group             : 
 * @last modified on  : 04-09-2026
 * @last modified by  : eunsu.kim
**/
@isTest
private class HubCompanyBatch_Test {

    @isTest
    static void testBatchExecution() {
        List<IF_Account__c> ifList = new List<IF_Account__c>();

        for (Integer i = 0; i < 5; i++) {
            IF_Account__c obj = new IF_Account__c();
            obj.Name = 'Test ' + i;
            obj.PostalCode__c = '12345';
            obj.Domain__c = 'test' + i + '@email.com';
            obj.IFExternalKey__c = 'KEY' + i;
            obj.IsConverted__c = false;
            ifList.add(obj);
        }

        insert ifList;

        Test.startTest();
        Database.executeBatch(new HubCompanyBatch(), 200);
        Test.stopTest();

        List<Account> accList = [SELECT Id, IFExternalKey__c FROM Account WHERE IFExternalKey__c LIKE 'KEY%'];
        System.assert(accList.size() > 0);

        List<IF_Account__c> updatedList = [
            SELECT Id, IsConverted__c
            FROM IF_Account__c
            WHERE IFExternalKey__c LIKE 'KEY%'
        ];

        for (IF_Account__c obj : updatedList) {
            System.assertEquals(true, obj.IsConverted__c);
        }
    }
}