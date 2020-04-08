# OTRS-Process-Management-ACL-For-Owner-or-Responsible
- Built for OTRS CE v 6.0.x
- ACL module that restrict Activity Dialog ID to current logged user and ticket owner or responsible.  
- In Process Management, there is possibility that Owner and Responsible have a different Activity Dialog screen in specific Activity.   
- Thus, this system ACL will restrict the Activity Dialog screen to each owner and resposible by getting the current logged user and compare it to the ticket owner or resposible.  
- If owner = responsible, no ACL will be applied.  

1. Do update the ACL parameter at System Configuration > Core::Ticket::ACL > Ticket::Acl::Module###5-Ticket::Acl::Module  

2.	Configuration Parameter :  

	  	Name: The ACL Name. Must be unique.  
	  	
	  	PropertiesProcessEntityID  
	  	= To restrict ACL on specific process. One Process ID only.  
	  	  
	  	PropertiesActivityEntityID  
	  	= To restricl ACL on specific Activity. One Activity ID only.  
	  	
	  	OwnerActivityDialogEntityID  
	  	= To determine what Activity Dialog screen that available to ticket owner.  
	  	= Can be multiple separate by semicolon (;)  
	  	
	  	ResponsibleActivityDialogEntityID  
	  	= To determine what Activity Dialog screen that available to ticket responsible.  
	  	= Can be multiple separate by semicolon (;)  
	
	
3. Only 1 ACL is activate by default. If you have additional Process Management or Activity to apply this ACL, please activate another config (Valid="0" to Valid="1") and configure it.  

4. Additonally, if the provided config not enough, please write additional xml param to the xml file and rebuild config.  
**Setting Name** , **Name** must be **unique** !

    		Setting Name = <Setting Name="Ticket::Acl::Module###10-Ticket::Acl::Module" Required="0" Valid="1">
    		 
    		Name = <Item Key="Name">ACL 6</Item>
  
  
Owner and Responsible Details  
[![a1.png](https://i.postimg.cc/HnTgrmJD/a1.png)](https://postimg.cc/MM34Lhbd)

Owner Screen  
[![a2.png](https://i.postimg.cc/Gh2pKP20/a2.png)](https://postimg.cc/Dm9FyXL5)

Responsible Screen  
[![a3.png](https://i.postimg.cc/W4HR2rVZ/a3.png)](https://postimg.cc/cKwkhvr1)  


