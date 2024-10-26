trigger ContactTrigger on Contact (before insert, before update, after undelete) {
    
    SET<ID> accIdSet = new SET<ID>();
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate) || (trigger.isAfter && trigger.isUndelete)){
        for(Contact objCon : trigger.new){
            if(objCon.AccountId !=null){
                
                if(trigger.isInsert || trigger.isUndelete){
                    accIdSet.add( objCon.AccountId);
                }
                if(trigger.isUpdate){
                    if( objCon.Email !=trigger.oldMap.get(objCon.Id).Email){
                        accIdSet.add(objCon.AccountId);
                    }
                }
                
            }
            
        } 
    }
    
    Map<Id,Account> accMap = new Map<Id, Account>();
    if(!accIdSet.isEmpty()){
        for(Account objAcc : [Select Id, (Select Id, Email from Contacts) from Account where ID IN : accIdSet]){ //ICICI Bank--> First Raju
            accMap.put(objAcc.Id, objAcc);
        }
    }
    
    if(!accMap.isEmpty()){
        if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate) || (trigger.isAfter && trigger.isUndelete)){
            for(Contact objCon : trigger.new){
                if(accMap.containsKey(objCon.AccountId)){
                    List<Contact> existingConList =   accMap.get(objCon.AccountId).Contacts ; 
                    
                    for(Contact objConExisting : existingConList){
                        if(objCon.Email == objConExisting.Email){
                            objCon.Email.addError('This Email id Contacts is already exists');
                        }
                    }
                    
                }
            } 
        }
    }
    
}