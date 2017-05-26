-- =============================================  
-- Author:  Sachin Tyagi  
-- Create date: May 26, 2017  
-- Description: This stored procedure shall return all the guest details 
-- =============================================  
--Exec GETALLGUESTS
 
ALTER PROCEDURE [DBO].GETALLGUESTS 
AS  
BEGIN  


SELECT   
  ID  
 ,FIRSTNAME
 ,LASTNAME
 ,MOBILENUMBER
 ,EMAILADDRESS  
 ,DOB
 ,GENDER
 ,PHOTOPATH
 FROM GUEST
END