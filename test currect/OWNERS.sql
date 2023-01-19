--Initial Creation (10-Jan-2023) OWNERS



/*table creation script for "OWNERS"*/


CREATE TABLE  "OWNERS" 
   (	"CURRECT_DATASET_ID" NUMBER, 
	"CURRECT_OWNER_ID" NUMBER GENERATED ALWAYS AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE, 
	"CUST_LEVEL1_ID" VARCHAR2(30) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CUST_LEVEL1_CODE" VARCHAR2(30) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"LEVEL1_NAME" VARCHAR2(80) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"CUST_LEVEL2_ID" VARCHAR2(30) COLLATE "USING_NLS_COMP" DEFAULT 'institution', 
	"CUST_LEVEL2_CODE" VARCHAR2(30) COLLATE "USING_NLS_COMP" DEFAULT 'institution', 
	"LEVEL2_NAME" VARCHAR2(80) COLLATE "USING_NLS_COMP" DEFAULT 'institution', 
	"LEVEL1_DDF" VARCHAR2(80) COLLATE "USING_NLS_COMP" NOT NULL ENABLE, 
	"LEVEL2_DDF" VARCHAR2(80) COLLATE "USING_NLS_COMP" DEFAULT 'institution', 
	"UDF1" VARCHAR2(500) COLLATE "USING_NLS_COMP", 
	"UDF2" VARCHAR2(500) COLLATE "USING_NLS_COMP", 
	"UDF3" VARCHAR2(500) COLLATE "USING_NLS_COMP", 
	"CUST_SORT" NUMBER, 
	"LAST_USER" VARCHAR2(30) COLLATE "USING_NLS_COMP", 
	"LAST_DATE" DATE, 
	 CONSTRAINT "OWN_PK" PRIMARY KEY ("CURRECT_DATASET_ID", "CURRECT_OWNER_ID")
  USING INDEX  ENABLE, 
	 CONSTRAINT "OWN_UK" UNIQUE ("CURRECT_DATASET_ID", "CUST_LEVEL1_ID", "CUST_LEVEL1_CODE", "CUST_LEVEL2_ID", "CUST_LEVEL2_CODE")
  USING INDEX  ENABLE
   )  DEFAULT COLLATION "USING_NLS_COMP"
   
   
   
   
/*sequence creation script for "OWNERS"*/


 CREATE SEQUENCE   "OWNERS_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL




/*trigger creation script for "OWNERS"*/

   
   CREATE OR REPLACE EDITIONABLE TRIGGER  "OWNERS_IUTR" 
BEFORE INSERT or update
ON OWNERS
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

END OWNERS_IUTR;

/
ALTER TRIGGER  "OWNERS_IUTR" ENABLE
/


