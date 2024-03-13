public class OrelSapAuthController {
    @AuraEnabled
    public static String getBasicAuthCallout() {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:OrelSapAuthCredentialApi/oauth/token?grant_type=client_credentials');
            req.setMethod('POST');
            
            // Set the client ID and client secret in the request header
            String clientId = 'sb-21410e15-6a7c-4922-ace9-8adf3d55eac6!b191339|it-rt-cli-orel-59fos91p!b117912';
            String clientSecret = 'c5989ec7-3366-4f6b-ad7f-fe2508a798e5$YHznkPg0bojj6Rz5grqCnQfzgWUWFtBX5Gi7PoLmZSc=';
            String authHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(clientId + ':' + clientSecret));
            req.setHeader('Authorization', authHeader);

            Http http = new Http();
            HTTPResponse res = http.send(req);

            // Check for successful response
            if (res.getStatusCode() == 200) {
                // Parse the response to get the access token
                Object parsedResponse = JSON.deserializeUntyped(res.getBody());

                if (parsedResponse instanceof Map<String, Object>) {
                    Map<String, Object> responseMap = (Map<String, Object>) parsedResponse;
                    String accessToken = (String) responseMap.get('access_token');

                    // Now you can use the obtained access token in subsequent requests
                    req = new HttpRequest();
                    req.setEndpoint('callout:OrelSapNamedCredential/http/CreditNoteCreate');
                    req.setMethod('GET');
                    req.setHeader('Authorization', 'Bearer ' + accessToken);

                    res = http.send(req);

                    // Check for successful response
                    if (res.getStatusCode() == 200) {
                        String responseBody = res.getBody();
                        System.debug('CreditNoteCreate Response Body: ' + responseBody);
                        return responseBody;
                    } else {
                        System.debug('HTTP Request Failed for CreditNoteCreate. Status Code: ' + res.getStatusCode());
                        System.debug('CreditNoteCreate Response Body: ' + res.getBody());
                    }
                } else {
                    System.debug('Unexpected response type: ' + parsedResponse);
                }
            } else {
                System.debug('HTTP Request Failed for token request. Status Code: ' + res.getStatusCode());
                System.debug('Token Request Response Body: ' + res.getBody());
            }
        } catch (Exception e) {
            // Log the exception details
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Type: ' + e.getTypeName());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
        }

        // Return an error message if there are issues
        return 'Error in API call.';
    }
}