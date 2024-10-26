trigger PreventDuplicateDrivingLicense on Document_Detail__c (before insert, before update, After undelete) {
    Set<id> appidSet = new Set<id>();  
    if(trigger.isbefore && (trigger.isinsert || trigger.isupdate) || (trigger.isAfter && trigger.isundelete)){
        for(Document_Detail__c objDoc : trigger.new){
            if(objDoc.Select_Application__c !=null){
                if(trigger.isinsert || trigger.isundelete){
                    appidSet.add(objDoc.Select_Application__c);
                }
                if(trigger.isupdate){
                    if(objDoc.Select_Application__c !=trigger.oldMap.get(objDoc.Id).Select_Application__c){
                        appidSet.add(objDoc.Select_Application__c);
                    }
                }
            }
        }
    }
    Map<id,Applicant_Detail__c> appMap = new Map<id,Applicant_Detail__c>();
    if(!appidSet.isEmpty()){
        for(Applicant_Detail__c objApp : [Select id,(Select id, Select_Identity_Proof_Document__c, Select_Application__c from Document_Details__r) from Applicant_Detail__c Where id IN : appidSet]){
            appMap.put(objApp.Id,objApp);
        }
    }
    if(!appMap.isEMpty()){
        if(trigger.isbefore && (trigger.isinsert || trigger.isupdate) || (trigger.isAfter && trigger.isundelete)){
            for(Document_Detail__c objDoc : trigger.new){
                if(appMap.containsKey(objDoc.Select_Application__c)){
                    List<Document_Detail__c> DocDetailExistingList = appMap.get(objDoc.Select_Application__c).Document_Details__r;
                    if(DocDetailExistingList.size()>=1){
                        objDoc.AddError('More than one driving license not allowed');
                    }
                }
            }
        }
    }
}