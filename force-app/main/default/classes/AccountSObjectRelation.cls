public class AccountSObjectRelation {
	public AccountSObjectRelation(){
	}
		
	public AccountSObjectRelation(ID objectId, String objectName, String objectEmail, ID accountId, String accountName){
		this.objectId = objectId;
		this.objectName = objectName;
		this.objectEmail = objectEmail;
		this.accountId = accountId;
		this.accountName = accountName;
	}
	
	public ID accountId {get; set;}
	public String accountName {get; set;}
	public ID objectId {get; set;}
	public String objectName {get; set;}
	public String objectEmail {get; set;}
}