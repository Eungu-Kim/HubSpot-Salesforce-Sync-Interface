public with sharing class HubCompanyBatch implements Database.Batchable<SObject>, Database.Stateful {
    public HubCompanyBatch() {}

    // Database.executeBatch(new HubCompanyBatch(), 500);

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id'
                            + ', Name'
                            + ', PostalCode__c'
                            + ', Domain__c'
                            + ', IFExternalKey__c'
                            + ' FROM IF_Account__c'
                            + ' WHERE IsConverted__c = false'
                            + ' ORDER BY CreatedDate DESC';
        
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<IF_Account__c> ifList) {
        Map<String, Account> tempAccMap = new Map<String, Account>();
        List<IF_Account__c> updateIFList = new List<IF_Account__c>();
        List<Account> updateAccList = new List<Account>();

        for (IF_Account__c obj : ifList) {
            Account acc = new Account();
            acc.IFExternalKey__c = obj.IFExternalKey__c;
            acc.Name = obj.Name;
            acc.PostalCode__c = obj.PostalCode__c;
            acc.Email__c = obj.Domain__c;
            acc.IsConverted__c = false;
            tempAccMap.put(acc.IFExternalKey__c, acc);
        }

        updateAccList.addAll(tempAccMap.values());

        Set<String> updateSuccessKeySet = new Set<String>(); // IFExternalKey__c

        if (updateAccList.size() > 0) {
            List<Database.UpsertResult> updateResult = Database.upsert(updateAccList, Account.IFExternalKey__c, false);

            for (Integer index = 0; index < updateResult.size(); index++) {
                if (updateResult[index].isSuccess()) {
                    updateSuccessKeySet.add(updateAccList[index].IFExternalKey__c);
                    System.debug('Success : ' + updateAccList[index].IFExternalKey__c);
                } else {
                    for (Database.Error error : updateResult[index].getErrors()) {
                        System.debug('Error : ' + updateResult[index].getId() + ' : ' + error.getStatusCode());
                    }
                }
            }
        }

        for (IF_Account__c obj : ifList) {
            if (updateSuccessKeySet.contains(obj.IFExternalKey__c)) {
                obj.IsConverted__c = true;
                updateIFList.add(obj);
            }
        }

        if (updateIFList.size() > 0) {
            Update updateIFList;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('HubCompanyBatch Finish');
        //     List<CronTrigger> ctList = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'HubCompanyBatch' LIMIT 1];
        //     if (ctList.size() > 0) {
        //         System.abortJob(ctList[0].Id);
        //     }
        //   ... 스케줄 필요 시 작성
    }
}