/**
 * @description       : 
 * @author            : eunsu.kim
 * @group             : 
 * @last modified on  : 03-27-2026
 * @last modified by  : eunsu.kim
**/
public with sharing class IF_HubMeetingRequest {
    public IF_HubMeetingRequest() {}

    public static void hubMeetingRequest() {
        // IF_HubMeetingRequest.hubMeetingRequest();

        HttpRequest request = new HttpRequest();
        System.debug('Start Time : ' + Datetime.now());

        try {
            // HUBSPOT__mdt Key = [SELECT token__c FROM HUBSPOT__mdt LIMIT 1];
            // String tokenKey = key.token__c;

            // String auth_Name = 'Authorization';
            // String auth_Key = tokenKey;

            String uriAddress  = '/crm/v3/objects/meetings';
            String propertiesAddress = '?properties=hs_meeting_title,hs_timestamp' + '&associations=companies';

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

            Map<String, Object> titleObject = new Map<String, Object>();
            // Map<String, Object> bodyObject = new Map<String, Object>();
            Map<String, Object> timeStampObject = new Map<String, Object>(); // StartAllDay__c

            List<propertiesClass> propertiesList = new List<propertiesClass>();
            List<IF_MeetingLog__c> insertIFMeetingList = new List<IF_MeetingLog__c>();

            if (response.getBody() != null) {
                Map<String, Object> resultResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                List<Object> meetingsList = (List<Object>) resultResponse.get('results');

                for (Object meetings : meetingsList) {
                    Map<String, Object> meetingsMap = (Map<String, Object>) meetings;
                    Map<String, Object> propertiesMap = (Map<String, Object>) meetingsMap.get('properties');
                    Map<String, Object> associationsMap = (Map<String, Object>) meetingsMap.get('associations');

                    propertiesClass properties = new propertiesClass();
                    properties.id = (String) meetingsMap.get('id');

                    properties.title = (String) propertiesMap.get('hs_meeting_title');
                    // properties.body = (String) propertiesMap.get('hs_meeting_body');
                    properties.timestamp = (String) propertiesMap.get('hs_timestamp');

                    if (associationsMap != null && associationsMap.containsKey('companies')) {
                        Map<String, Object> companiesMap = (Map<String, Object>) associationsMap.get('companies');
                        List<Object> companiesList = (List<Object>) companiesMap.get('results');
                        
                        Map<String, Object> company = (Map<String, Object>) companiesList[0];
                        properties.assocompanyid = (String) company.get('id');
                    }

                    propertiesList.add(properties);
                }

                if (propertiesList.size() > 0) {
                    for (propertiesClass pobj : propertiesList) {
                        insertIFMeetingList.add(pobj.convert(pobj));
                    }
                }
            }

            if (insertIFMeetingList.size() > 0) {
                List<Database.UpsertResult> saveResult = Database.upsert(insertIFMeetingList, IF_MeetingLog__c.IFExternalKey__c, false);
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
        public String title {get; set;}
        // public String body {get; set;}
        public String timestamp {get; set;}
        public String assocompanyid {get; set;}

        public IF_MeetingLog__c convert(propertiesClass pobj) {
            IF_MeetingLog__c ifMeeting = new IF_MeetingLog__c();

            ifMeeting.IFExternalKey__c = pobj.id;
            ifMeeting.Name = pobj.title != null? pobj.title : ('Meeting Log_' + pobj.timestamp.substring(0, 10));
            // ifMeeting.Contents__c = makeBody(pobj.body);
            ifMeeting.StartAllDay__c = Date.valueOf(pobj.timestamp.substring(0, 10));
            ifMeeting.AccountIFExternalKey__c = pobj.assocompanyid;
            ifMeeting.IsConverted__c = false;

            return ifMeeting;
        }
    }

    // public static String makeBody(String body) {
    //     if (body != null) {
    //         // <br>, </p> 같은 태그를 줄바꿈으로 치환
    //         body = body.replaceAll('</p>', '\n');
    //         body = body.replaceAll('<br\\s*/?>', '\n');

    //         // 나머지 태그 제거
    //         body = body.replaceAll('<[^>]*>', '');
    //     }
    //     return body;
    // }
}