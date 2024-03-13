public class sapConnectivityController {
    @AuraEnabled
    public static String generateSapToken() {
        system.debug('inside the method');
        String Username='sb-21410e15-6a7c-4922-ace9-8adf3d55eac6!b191339|it-rt-cli-orel-59fos91p!b117912';
        String Password='c5989ec7-3366-4f6b-ad7f-fe2508a798e5$YHznkPg0bojj6Rz5grqCnQfzgWUWFtBX5Gi7PoLmZSc=';
        String endpointUrl = 'https://cli-orel-59fos91p.authentication.eu10.hana.ondemand.com/oauth/token?grant_type=client_credentials';
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password));
        system.debug('before req');
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod('GET');
        request.setHeader('Authorization', authHeader);
        
        HttpResponse response = new Http().send(request);
        system.debug('response status---->'+response.getStatusCode());
        if (response.getStatusCode() == 200) {
            Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String accessToken = (String) responseData.get('access_token');
            // call here
            system.debug('accesstoken----->'+ accessToken);
           String creditNoteRes=createCreditnote(accessToken); 
            String BPSalesAreaExtionRes =BPSalesAreaExtension(accessToken);
           // return accessToken;
           //return creditNoteRes;
      return (creditNoteRes != null) ? BPSalesAreaExtionRes : creditNoteRes;
        } else {
            System.debug('Error response: ' + response.getStatusCode() + ' ' + response.getBody());
            throw new AuraHandledException('Authentication error: ' + response.getStatusCode() + ' ' + response.getBody());
        }
    }
    
   // @AuraEnabled
    public static String createCreditnote(String accessToken) {
        system.debug('method invoking at apex level--->'+accessToken);
        String Username='sb-21410e15-6a7c-4922-ace9-8adf3d55eac6!b191339|it-rt-cli-orel-59fos91p!b117912';
        String Password='c5989ec7-3366-4f6b-ad7f-fe2508a798e5$YHznkPg0bojj6Rz5grqCnQfzgWUWFtBX5Gi7PoLmZSc=';
        String endpointUrl = 'https://cli-orel-59fos91p.it-cpi018-rt.cfapps.eu10-003.hana.ondemand.com/http/CreditNoteCreate';
        // String authHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password));
        // query 
	String requestBody = '{'+
    '"ZSD_CREDITNOTE_CREATE": {'+
        '"RETURN_HEADER_IN": {'+
            '"REFDOCTYPE": "ZDIS",'+
            '"DOC_TYPE": "ZRER",'+
            '"SALES_ORG": "1100",'+
            '"DISTR_CHAN": "10",'+
            '"DIVISION": "10",'+
            '"ORD_REASON": "Z06",'+
            '"REF_DOC": "917000774",'+
            '"REFDOC_CAT": "M"'+
        '},'+
        '"RETURN_HEADER_INX": {'+
            '"UPDATEFLAG": "X",'+
            '"DOC_TYPE": "X",'+
            '"COLLECT_NO": "X",'+
            '"SALES_ORG": "X",'+
            '"DISTR_CHAN": "X",'+
            '"DIVISION": "X",'+
            '"BILL_BLOCK": "X",'+
            '"ORD_REASON": "X"'+
        '}'+
    '}'+
'}';
          
        HttpRequest request = new HttpRequest();
    request.setEndpoint(endpointUrl);
    request.setMethod('GET');
    request.setHeader('Authorization', 'Bearer ' + accessToken);
    request.setHeader('Content-Type', 'application/json');
    request.setBody(requestBody);
    HttpResponse response = new Http().send(request);                  
    
    // Check for successful response
    if (response.getStatusCode() == 200) {
        Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        //String accessToken = (String) responseData.get('access_token');
        system.debug('responsedata ----->'+responseData);
        System.debug('Response: ' + request.getBody());
        return request.getBody();
    } else {
        System.debug('Error response: ' + response.getStatusCode() + ' ' + response.getBody());
        throw new AuraHandledException('Authentication error: ' + response.getStatusCode() + ' ' + response.getBody());
    }
}
    
      public static String BPSalesAreaExtension(String accessToken) {
        system.debug('method invoking at apex level--->'+accessToken);
        String Username='sb-21410e15-6a7c-4922-ace9-8adf3d55eac6!b191339|it-rt-cli-orel-59fos91p!b117912';
        String Password='c5989ec7-3366-4f6b-ad7f-fe2508a798e5$YHznkPg0bojj6Rz5grqCnQfzgWUWFtBX5Gi7PoLmZSc=';
        String endpointUrl = 'https://cli-orel-59fos91p.it-cpi018-rt.cfapps.eu10-003.hana.ondemand.com/http/BPSalesAreaExtension';
        // String authHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password));
String requestBody = '{'+
    '"ZSD_BP_EXTENSION": {'+
        '"SALES_AREA_EXT": {'+
            '"item": ['+
                '{'+
                    '"KUNNR": "22AA01",'+
                    '"VKORG": "1100",'+
                    '"VTWEG": "20",'+
                    '"SPART": "00",'+
                    '"KTGRD": "01",'+
                    '"ZTERM": "Z007",'+
                    '"KDGRP": "14",'+
                    '"KALKS": "1",'+
                    '"VSBED": "01",'+
                    '"INCO1": "CIF",'+
                    '"INCO2": "Colombo 01",'+
                    '"WAERS": "LKR",'+
                    '"PARTNERS": {'+
                        '"item": ['+
                            '{'+
                                '"PARVW": "SE",'+
                                '"PARTNER": "10524"'+
                            '}'+
                        ']'+
                    '}'+
                '},'+
                '{'+
                    '"KUNNR": "22AA01",'+
                    '"VKORG": "1100",'+
                    '"VTWEG": "20",'+
                    '"SPART": "10",'+
                    '"KTGRD": "01",'+
                    '"ZTERM": "Z007",'+
                    '"KDGRP": "14",'+
                    '"KALKS": "1",'+
                    '"VSBED": "01",'+
                    '"INCO1": "CIF",'+
                    '"INCO2": "Colombo 01",'+
                    '"WAERS": "LKR",'+
                    '"PARTNERS": {'+
                        '"item": ['+
                            '{'+
                                '"PARVW": "SE",'+
                                '"PARTNER": "10525"'+
                            '}'+
                        ']'+
                    '}'+
                '}'+
            ']'+
        '}'+
    '}'+
'}';

          
        HttpRequest request = new HttpRequest();
    request.setEndpoint(endpointUrl);
    request.setMethod('GET');
    request.setHeader('Authorization', 'Bearer ' + accessToken);
    request.setHeader('Content-Type', 'application/json');
    request.setBody(requestBody);
    HttpResponse response = new Http().send(request);                  
    
    // Check for successful response
    if (response.getStatusCode() == 200) {
        Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        //String accessToken = (String) responseData.get('access_token');
        system.debug('responsedata ----->'+responseData);
        System.debug('Response: ' + request.getBody());
        return request.getBody();
    } else {
        System.debug('Error response: ' + response.getStatusCode() + ' ' + response.getBody());
        throw new AuraHandledException('Authentication error: ' + response.getStatusCode() + ' ' + response.getBody());
    }
}
}