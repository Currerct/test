--Initial Creation (10-Jan-2023) TIME_WINDOW_RELATIONS:


/*table creation script for "TIME_WINDOW_RELATIONS"*/


CREATE TABLE  "TIME_WINDOW_RELATIONS" 
   (	"COMBI_CURRECT_TWINDOW_ID" NUMBER, 
	"INDV_CURRECT_TWINDOW_ID" NUMBER, 
	"LAST_USER" VARCHAR2(30) COLLATE "USING_NLS_COMP", 
	"LAST_DATE" DATE, 
	 CONSTRAINT "TWR_UK" UNIQUE ("COMBI_CURRECT_TWINDOW_ID", "INDV_CURRECT_TWINDOW_ID")
  USING INDEX  ENABLE
   )  DEFAULT COLLATION "USING_NLS_COMP"
   
   
   
/*sequence creation script for "TIME_WINDOW_RELATIONS"*/
   

 CREATE SEQUENCE   "TIME_WINDOW_RELATIONS_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL



/*trigger creation script for "TIME_WINDOW_RELATIONS"*/


CREATE OR REPLACE EDITIONABLE TRIGGER  "TIME_WINDOW_RELATIONS_IUTR" 
BEFORE INSERT or update
ON TIME_WINDOW_RELATIONS
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
		Raise_Application_Error(-20101,'Unexpected system error at level iutr(User Dataset) : '||SQLCODE||' --- '||SQLERRM, TRUE);

END TIME_WINDOW_RELATIONS_IUTR;

/
ALTER TRIGGER  "TIME_WINDOW_RELATIONS_IUTR" ENABLE
/
