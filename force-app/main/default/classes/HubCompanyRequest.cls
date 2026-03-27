/**
 * @description       : 
 * @author            : eunsu.kim
 * @group             : 
 * @last modified on  : 03-27-2026
 * @last modified by  : eunsu.kim
**/
public with sharing class HubCompanyRequest {
    public HubCompanyRequest() {}

    public static void hubCompanyRequest() {
        // HubCompanyRequest.hubCompanyRequest();

        HttpRequest request = new HttpRequest();
        System.debug('Start Time : ' + Datetime.now());

        try {
            // HUBSPOT__mdt Key = [SELECT token__c FROM HUBSPOT__mdt LIMIT 1];
            // String tokenKey = key.token__c;

            // String auth_Name = 'Authorization';
            // String auth_Key = tokenKey;

            String uriAddress = '/crm/v3/objects/companies';
            String propertiesAddress = '?properties=name,domain,zip';

            request.setEndpoint('callout:HUBSPOT_AUTH' + uriAddress + propertiesAddress);
            request.setMethod('GET');

            // request.setHeader(auth_Name, auth_Key);
            request.setHeader('Accept-Encoding','gzip, deflate, br');
            request.setHeader('Connection','keep-alive');
            request.setHeader('Content-Length','0');
            request.setHeader('Content-Type','application/json');

            Http http = new Http();
            HttpResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('Status Code : ' + response.getStatusCode());
            System.debug('Response Body : ' + response.getBody());

            Map<String, Object> nameObject = new Map<String, Object>();
            Map<String, Object> zipObject = new Map<String, Object>();  // Postal Code
            Map<String, Object> domainObject = new Map<String, Object>();

            List<propertiesClass> propertiesList = new List<propertiesClass>();
            List<IF_Account__c> insertIFAccountList = new List<IF_Account__c>();

            if (response.getBody() != null) {
                Map<String, Object> resultResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                List<Object> companiesList = (List<Object>) resultResponse.get('results');
                
                for (Object companies : companiesList) {
                    Map<String, Object> companiesMap = (Map<String, Object>) companies;
                    Map<String, Object> propertiesMap = (Map<String, Object>) companiesMap.get('properties');

                    PropertiesClass properties = new PropertiesClass();
                    properties.id = (String) companiesMap.get('id');

                    properties.name = (String) propertiesMap.get('name');
                    properties.zip = (String) propertiesMap.get('zip');
                    properties.domain = (String) propertiesMap.get('domain');

                    propertiesList.add(properties);
                }

                if (propertiesList.size() > 0) {
                    for (PropertiesClass pobj : propertiesList) {
                        insertIFAccountList.add(pobj.convert(pobj));
                    }
                }
            }

            if (insertIFAccountList.size() > 0) {
                List<Database.UpsertResult> saveResult = Database.upsert(insertIFAccountList, IF_Account__c.IFExternalKey__c, false);
                if (saveResult.size() > 0) {
                    for (Integer i = 0; i < saveResult.size(); i++) {
                        if (!saveResult[i].isSuccess()) {
                            for (Database.Error err : saveResult[i].getErrors()) {
                                System.debug('Error : ' + saveResult[i].getId() + ' : ' + err.getStatusCode());
                            }
                        }
                    }
                }
            }

        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage() + ' Line : ' + e.getLineNumber());
        }
    }

    public class propertiesClass {
        public String id {get; set;}
        public String name {get; set;}
        public String zip {get; set;}
        public String domain {get; set;}

        public IF_Account__c convert(propertiesClass pobj) {
            IF_Account__c ifAcc = new IF_Account__c();

            ifAcc.IFExternalKey__c = pobj.id;
            ifAcc.Name = pobj.name;
            ifAcc.PostalCode__c = pobj.zip;
            ifAcc.Domain__c = pobj.domain;

            ifAcc.IsConverted__c = false;

            return ifAcc;
        }
    }
}