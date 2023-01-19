--Initial Creation (10-Jan-2023) GROUP_TYPES:


/*table creation script for "GROUP_TYPES"*/


CREATE TABLE  "GROUP_TYPES" 
   (	"CURRECT_DATASET_ID" NUMBER, 
	"CURRECT_GRP_TYPE_ID" NUMBER GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE, 
	"GROUP_TYPE_CODE" NUMBER, 
	"GROUP_TYPE" VARCHAR2(30) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"GROUP_NAME" VARCHAR2(20) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"GROUP_SUB_NAME" VARCHAR2(20) COLLATE "USING_NLS_COMP", 
	"CUST_SORT" NUMBER, 
	"LAST_USER" VARCHAR2(30) COLLATE "USING_NLS_COMP", 
	"LAST_DATE" DATE, 
	 CONSTRAINT "GRP_PK" PRIMARY KEY ("CURRECT_GRP_TYPE_ID")
  USING INDEX  ENABLE, 
	 CONSTRAINT "GRP_UK" UNIQUE ("CURRECT_DATASET_ID", "GROUP_TYPE_CODE")
  USING INDEX  ENABLE
   )  DEFAULT COLLATION "USING_NLS_COMP"
   
   
/*sequence creation script for "GROUP_TYPES"*/


 CREATE SEQUENCE   "GROUP_TYPES_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL

 
 /*trigger creation script for "GROUP_TYPES"*/


 CREATE OR REPLACE EDITIONABLE TRIGGER  "GROUP_TYPES_IUTR" 
BEFORE INSERT or update
ON GROUP_TYPES
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

END GROUP_TYPES_IUTR;

/
ALTER TRIGGER  "GROUP_TYPES_IUTR" ENABLE
/

   