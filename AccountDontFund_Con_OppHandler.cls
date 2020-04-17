/*
 * Name: AccountDontFund_Con_OppHandler
 * @Description: this handler for Trigger AccountDontFund_Con_Opp on Account Object on After Insert 
 *               and After Update
 * ===================================================================================================
 *       Version   | Date        | Author             | Comments
 * ---------------------------------------------------------------------------------------------------
 *       1.0       | 24 Jan,2018 | Saumya Chaturvedi  | trigger update Contact and Opportunity Field 
 *                                                        Don_t_Fund__c
 * ===================================================================================================
 */
  
public with sharing class AccountDontFund_Con_OppHandler 
{
/*    
 *  @ Author Name : Saumya Chaturvedi
 *  @ Discription : Method to update DontFund field with True when Stage is Closed Lost 
 *  @ Param       : Trigger.new   as parameter
 *  @ Output      : update DontFund = true when Stage = Closed Lost or decline               
 */ 
    public void updateFieldOnBeforeEvent(List< Account > newAccountList) {
        // map to update field according to parent object Don_t_Fund__c value
        Map<Id,Account> accIdvsAccMap = new Map<Id,Account>();
        Set < Id> AccIdSettoCheck = new Set<Id>();         
        for(Account accObj : newAccountList) {
        // new opportunity linked with account or not for further comparision 
             if(accObj.Don_t_Fund__c == false) { 
                 accIdvsAccMap.put( accObj.Id,accObj );
                // AccIdSettoCheck.add(accObj.Id);
             }
         } 
         // check enterd opportunity associate with account or not 
         if(!accIdvsAccMap.isEmpty()) {  
            // method contains(List) does not work on object
            // so store id to check account id present or not  
             Set<Id> accIdSetToUpdate = new Set< Id >(); 
            // query to get record which are associate with opportunity and
            // having  Don_t_Fund__c = true
            
             List <Opportunity> oppList =[SELECT Id,AccountId
                                           FROM Opportunity 
                                          where AccountId in :accIdvsAccMap.keySet()
                                            and StageName in('Closed Lost','decline') 
                                         ];
             for(Opportunity accobj :oppList) {
                 accIdSetToUpdate.add(accobj.AccountId);
             }
            
            if(!accIdSetToUpdate.isEmpty()) {
            
            	for( Id oppAccId : accIdvsAccMap.keySet() )  {
                	if( accIdSetToUpdate.contains(oppAccId) ) {  
                  		Account obj = accIdvsAccMap.get(oppAccId);
                  		obj.Don_t_Fund__c=true;
               		 } 
            	}
            }
         }
      }
/*    
 *  @ Author Name : Saumya Chaturvedi
 *  @ Discription : Method to Check new records need updation or not
 *  @ Param       : Trigger.new   as parameter
 *  @ Output      : call Method updateContact(..) and updateOpportunity(..)                
 *        
     public void validateRecord(List<Account> newAccountList) {
        // Set for Account Id for query
        Set<Id> accIdSetforTrue = new Set<Id>();
        Set<Id> accIdSetforFalse = new Set<Id>();  
        // List of Contact Need to be updated ...store query result 
        List< Contact > conListForUpdateTrue = new List<Contact>();
        List< Contact > conListForUpdateFalse = new List<Contact>();  
        // List of Opportunity Need to be updated ...store query result 
        List< Opportunity > oppLitForUpdateTrue = new List<Opportunity>(); 
        List< Opportunity > oppLitForUpdateFalse = new List<Opportunity>();
         for(Account accObj : newAccountList) {
            if(accObj.Don_t_Fund__c==true) {  
               accIdSetforTrue.add(accObj.Id);
            }
            else {
              accIdSetforFalse.add(accObj.Id);   
            }
         }
         // System.debug('debug .. size of Account List 1 '+accIdSet.size());
         // List contain only those record which needs updation on fields
          conListForUpdateTrue = [SELECT Id,Don_t_Fund__c 
                                 FROM Contact
                                WHERE AccountId in: accIdSetforTrue 
                                  AND Don_t_Fund__c= false];
          
          conListForUpdateFalse = [SELECT Id,Don_t_Fund__c 
                                 FROM Contact
                                WHERE AccountId in: accIdSetforTrue 
                                  AND Don_t_Fund__c= True];
                               
          oppLitForUpdateTrue =  [SELECT Id,Don_t_Fund__c 
                                 FROM Opportunity
                                WHERE AccountId in: accIdSetforTrue 
                                  AND Don_t_Fund__c= false];   
          
          oppLitForUpdateFalse =  [SELECT Id,Don_t_Fund__c 
                                 FROM Opportunity
                                WHERE AccountId in: accIdSetforTrue 
                                  AND Don_t_Fund__c= true];
         //if conListForUpdate.size()=0 means ..new Account records does not associate with any Contact  
         if(conListForUpdateTrue.size()>0) {
             updateContact(conListForUpdateTrue,true);
         }
         if(conListForUpdateFalse.size()>0) {
             updateContact(conListForUpdateFalse,False);
         } 
         //if conListForUpdate.size()=0 means ..new Account records does not associate with any Opportunity
         if(oppLitForUpdateTrue.size()>0) {
             updateOpportunity(oppLitForUpdateTrue,true);
         }
         if(oppLitForUpdateFalse.size()>0) {
             updateOpportunity(oppLitForUpdateFalse,false);
         } 
     }
/*    
 *  @ Author Name : Saumya Chaturvedi
 *  @ Discription : Method update Contact
 *  @ Param       : filtered List of Contact as parameter
 *  @ Output      : Update Contact field Don_t_Fund__c= true              
 * 
       
      public void updateContact(List<Contact> newContactList, boolean check) {
         // newContactList List contain only those records which are associate with Account
         // and Don_t_Fund__c =false 
         List< Contact > conUpdate = new List< Contact >(); 
         
            for(Contact conObj : newContactList) {
                // update Field
                conObj.Don_t_Fund__c=check;
                conUpdate.add(conObj);
            }
            update conUpdate;
        
     } 
/*    
 *  @ Author Name : Saumya Chaturvedi
 *  @ Discription : Method update Opportunity
 *  @ Param       : filtered List of Opportunity as parameter 
 *  @ Output      : Update Opportunity field Don_t_Fund__c= true              
 */
     
      public void updateOpportunity(List< Opportunity > newOpportunityList,boolean check) {   
         // newContactList List contain only those records which are associate with Account
         // and Don_t_Fund__c =false 
         List< Opportunity > oppUpdate = new List< Opportunity >(); 
         
         for(Opportunity oppObj : newOpportunityList) {
                // update Field
                oppObj.Don_t_Fund__c=check;
                oppUpdate.add(oppObj);
            }
          try {
              if(oppUpdate.isEmpty()) {
              	throw new DemoException('Cannot update record');
              } else{
                   update oppUpdate;
              }
          }
          catch(DemoException d ) {
			System.debug('Exception msg :: '+d.getMessage());
          }
           
        
     }   
}