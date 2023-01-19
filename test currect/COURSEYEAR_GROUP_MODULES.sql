--Initial Creation (10-Jan-2023) COURSEYEAR_GROUP_MODULES:



/*table creation script for "COURSEYEAR_GROUP_MODULES"*/


CREATE TABLE  "COURSEYEAR_GROUP_MODULES" 
   (	"CURRECT_GROUP_ID" NUMBER, 
	"CURRECT_MODULE_ID" NUMBER, 
	"LAST_USER" VARCHAR2(30) COLLATE "USING_NLS_COMP", 
	"LAST_DATE" DATE
   )  DEFAULT COLLATION "USING_NLS_COMP"
   
   
   
   /*sequence creation script for "COURSEYEAR_GROUP_MODULES"*/


 CREATE SEQUENCE   "COURSEYEAR_GROUPS_MODULES_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL



/*trigger creation script for "COURSEYEAR_GROUP_MODULES"*/



CREATE OR REPLACE EDITIONABLE TRIGGER  "COURSEYEAR_GROUP_MODULES_IUTR" 
BEFORE INSERT or update
ON COURSEYEAR_GROUP_MODULES
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

END COURSEYEAR_GROUP_MODULES_IUTR;

/
ALTER TRIGGER  "COURSEYEAR_GROUP_MODULES_IUTR" ENABLE
/
