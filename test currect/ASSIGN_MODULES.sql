--Initial Creation (10-Jan-2023) ASSIGN_MODULE:


/*table creation script for "ASSIGN_MODULE"*/


CREATE TABLE  "ASSIGN_MODULE" 
   (	"AM_ID" NUMBER, 
	"AM_NAME" VARCHAR2(100) COLLATE "USING_NLS_COMP", 
	"CURRECT_MODULE_ID" NUMBER, 
	"STATUS" NUMBER, 
	 CONSTRAINT "ASSIGN_MODULE_PK" PRIMARY KEY ("AM_ID")
  USING INDEX  ENABLE
   )  DEFAULT COLLATION "USING_NLS_COMP"
/



/*sequence creation script for "ASSIGN_MODULE"*/



 CREATE SEQUENCE   "ASSIGN_MODULE_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL


/*trigger creation script for "ASSIGN_MODULE"*/



CREATE OR REPLACE EDITIONABLE TRIGGER  "BI_ASSIGN_MODULE" 
  before insert on "ASSIGN_MODULE"               
  for each row  
begin   
  if :NEW."AM_ID" is null then 
    select "ASSIGN_MODULE_SEQ".nextval into :NEW."AM_ID" from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_ASSIGN_MODULE" ENABLE
/