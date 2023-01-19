--Initial Creation (10-Jan-2023) MODULE_CREDIT_SPLIT:


/*table creation script for "MODULE_CREDIT_SPLIT"*/
CREATE TABLE  "MODULE_CREDIT_SPLIT" 
   (	"CURRECT_MODULE_ID" NUMBER, 
	"CURRECT_TWINDOW_ID" NUMBER, 
	"CREDITS" NUMBER, 
	"LAST_USER" VARCHAR2(30) COLLATE "USING_NLS_COMP", 
	"LAST_DATE" DATE
   )  DEFAULT COLLATION "USING_NLS_COMP"
   
   
   
 /*sequence creation script for "MODULE_CREDIT_SPLIT"*/
   
  
 CREATE SEQUENCE   "MODULE_CREDIT_SPLIT_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL



/*trigger creation script for "MODULE_CREDIT_SPLIT"*/



CREATE OR REPLACE EDITIONABLE TRIGGER  "MODULE_CREDIT_SPLIT_IUTR" 
BEFORE INSERT or update
ON MODULE_CREDIT_SPLIT
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
DECLARE
BEGIN

	:NEW.last_date := SYSDATE;

	if :NEW.last_user is null
	then
		:NEW.last_user := NVL(v('APP_USER'), USER);
	end if;	

EXCEPTION

	WHEN OTHERS THEN
		Raise_Application_Error(-20101,'Unexpected system error at level iutr(Course year group) : '||SQLCODE||' --- '||SQLERRM, TRUE);

END MODULE_CREDIT_SPLIT_IUTR;

/
ALTER TRIGGER  "MODULE_CREDIT_SPLIT_IUTR" ENABLE
/

