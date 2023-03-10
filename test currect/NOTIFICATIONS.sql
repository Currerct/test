--Initial Creation (10-Jan-2023) NOTIFICATIONS:


/*table creation script for "NOTIFICATIONS"*/


CREATE TABLE  "NOTIFICATIONS" 
   (	"NOTIFICATIONS_ID" NUMBER NOT NULL ENABLE, 
	"NOTIFICATIONS_MSG" VARCHAR2(2000) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"USER_ID" NUMBER NOT NULL ENABLE, 
	"NOTIFICATIONS_TIME" TIMESTAMP (6) NOT NULL ENABLE, 
	"STATUS" NUMBER NOT NULL ENABLE, 
	 CONSTRAINT "NOTIFICATIONS_PK" PRIMARY KEY ("NOTIFICATIONS_ID")
  USING INDEX  ENABLE
   )  DEFAULT COLLATION "USING_NLS_COMP"
/



/*sequence creation script for "NOTIFICATIONS"*/


 CREATE SEQUENCE   "NOTIFICATIONS_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL
 
 
 
 
 /*trigger creation script for "NOTIFICATIONS"*/
 
 

 CREATE OR REPLACE EDITIONABLE TRIGGER  "BI_NOTIFICATIONS" 
  before insert on "NOTIFICATIONS"               
  for each row  
begin   
  if :NEW."NOTIFICATIONS_ID" is null then 
    select "NOTIFICATIONS_SEQ".nextval into :NEW."NOTIFICATIONS_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_NOTIFICATIONS" ENABLE
/

