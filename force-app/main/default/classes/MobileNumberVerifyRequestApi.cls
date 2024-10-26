public class MobileNumberVerifyRequestApi {
        @AuraEnabled
        public static Boolean verifiyMobileNumber(Id Name){
            
            String MobileNumber = [Select Id,Name,Mobile_Number__c,Mobile_Number_Status__c from Applicant_Detail__c where Id =: Name].Mobile_Number__c;
    
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://api.veriphone.io/v2/verify?phone='+MobileNumber+'&key=09B3D719978F489DAA4B5CB4E4FFF76E');
            request.setMethod('GET');
            
            HttpResponse response = http.send(request); // Target Hit 
            
            System.debug('Response Code '+response.getStatusCode());
            System.debug('Response Body '+response.getBody()); // return a JSON Serial
            
            Boolean mystatus;
    
            if(response.getStatusCode() == 200){
                  MobileVerificationRequestAPIWrapper objWrap = new MobileVerificationRequestAPIWrapper();
                 MobileVerificationRequestAPIWrapper objWrapInstance =   objWrap.parse(response.getBody());
                
                System.debug('Status '+objWrapInstance.status);
                System.debug('Valid? '+objWrapInstance.phone_valid);
    
                mystatus = objWrapInstance.phone_valid;
    
                Applicant_Detail__c objAppDoc = new Applicant_Detail__c(Id=Name);
    
                if(objWrapInstance.phone_valid == true){
                    objAppDoc.Mobile_Number_Status__c = true;
                
                }
                else{
                    objAppDoc.Mobile_Number_Status__c = false;
                
                }
    
                update objAppDoc;
            }
    
            return mystatus;
            
        }
        
        
       public class MobileVerificationRequestAPIWrapper {
    
        public String status;
        public String phone;
        public Boolean phone_valid;
        public String phone_type;
        public String phone_region;
        public String country;
        public String country_code;
        public String country_prefix;
        public String international_number;
        public String local_number;
        public String e164;
        public String carrier;
    
        
        public MobileVerificationRequestAPIWrapper parse(String json) {
            return (MobileVerificationRequestAPIWrapper) System.JSON.deserialize(json, MobileVerificationRequestAPIWrapper.class);
        }
    }
    }