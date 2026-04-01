/**
 * @description       : 
 * @author            : eunsu.kim
 * @group             : 
 * @last modified on  : 04-01-2026
 * @last modified by  : eunsu.kim
**/
// Static Resource 활용 JSON 삽입 방법 추가 시 삭제
// 현 방법으로 Endpoint 별 공통화는 가능하나 재사용성 및 운영 비효율 발생 가능
@isTest
global class IF_HubspotMockFactory implements HttpCalloutMock {
    public static String testCase;
    public static String targetObject;

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        String endpoint = req.getEndpoint();

        if (endpoint.contains('/meetings')) {
            if (testCase == 'SUCCESS') {
                res.setBody(
                    '{' +
                        '"results": [' +
                            '{' +
                                '"id": "123",' +
                                '"properties": {' + 
                                    '"hs_meeting_title": "Test Meeting",' +
                                    '"hs_timestamp": "2026-03-30T10:00:00.000Z"' +
                                '},' +
                                '"associations": {' + 
                                    '"companies": {' +
                                        '"results": [' +
                                            '{ "id": "999" }' +
                                        ']' +
                                    '}' +
                                '}' +
                            '}' +
                        ']' +
                    '}'                
                );
            
                res.setStatusCode(200);
            } else if (testCase == 'NO_ASSOC') {
                res.setBody(
                    '{' +
                        '"results": [' +
                            '{' +
                                '"id": "123",' +
                                '"properties": {' + 
                                    '"hs_meeting_title": "Test Meeting",' +
                                    '"hs_timestamp": "2026-03-30T10:00:00.000Z"' +
                                '}' +
                            '}' +
                        ']' +
                    '}'
                );
            
                res.setStatusCode(200);
            } else if (testCase == 'ERROR') {
                res.setBody('{"error": "Internal Server Error"}');
                res.setStatusCode(500);
            }
        } else if (endpoint.contains('/companies')) {
            if (testCase == 'SUCCESS') {
                res.setBody(
                    '{' +
                        '"results": [' +
                            '{' +
                                '"id": "123",' +
                                '"properties": {' + 
                                    '"domain": "Test Domain.com",' +
                                    '"name": "Test Name",' +
                                    '"zip": "9999"' +
                                '}' +
                            '}' +
                        ']' +
                    '}'                
                );
            
                res.setStatusCode(200);
            } else if (testCase == 'ERROR') {
                res.setBody('{"error": "Internal Server Error"}');
                res.setStatusCode(500);
            }
        }
        return res;
    }
}