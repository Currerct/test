/*Initial Creation (10-Jan-2023) CURRECT_AUTHENTICATION*/




--Package Specs

create or replace PACKAGE currect_authentication 
AS
    function   currect_authentication  	(p_username       IN  varchar2
										,p_password       IN  varchar2
										)
    return boolean;
FUNCTION get_hash (p_username  IN  VARCHAR2,
                     p_password  IN  VARCHAR2)
    RETURN VARCHAR2;
/*procedure login_redirect(p_username in VARCHAR2, 
                         p_password in VARCHAR2);*/
END currect_authentication;




--Package Body 

create or replace PACKAGE BODY currect_authentication
AS

    function   currect_authentication  	(p_username       IN  varchar2
										,p_password       IN  varchar2
										)
    return boolean
    IS
    
        cursor  c_check_user
        is
		select  cuus.currect_user_id
			,   cuus.ddf
			,	data.currect_dataset_id
			,	data.ddf
		from    currect_users	cuus
		left outer join	(		users_datasets	usda
						join	datasets		data
						on		usda.currect_dataset_id	=	data.currect_dataset_id
						)
		on		cuus.currect_user_id	=	usda.currect_user_id				
		where   lower(cuus.user_name)	=	lower(p_username)
		and     cuus.password        	=   get_hash ( UPPER(p_username), p_password) --p_password
		and		usda.current_flag		=	'Y'
		;

		cursor	c_get_cust_terms(cp_dataset_id	in	number)
		is
		select	app_item
			, 	cust_term
			, 	cust_term_short
		from	terms
		where	currect_dataset_id	=	cp_dataset_id;

        l_user_name     	currect_users.ddf%type;
		l_user_id			currect_users.currect_user_id%type;
		l_dataset_id		datasets.currect_dataset_id%type;	
        l_dataset_title 	datasets.ddf%type;
        LV_HOME_PAGE NUMBER;
        LV_STATUS NUMBER;
    BEGIN

        open c_check_user;
        fetch c_check_user into l_user_id
								,l_user_name
								,l_dataset_id
								,l_dataset_title;

        if c_check_user%notfound
        then

			close c_check_user;
            apex_util.set_session_state('A_LOGIN_ERR_MSG', 'Invalid credentials');
			/*
			pd_audit_pk.save_audit_row	(p_user_id		=>	p_username
										,p_action_area	=>	'Connecting to application'
										,p_action		=>	'Login'
										,p_notes		=>	'Invalid login'
										);
            */
			return false;

        end if;

        BEGIN
        SELECT STATUS INTO LV_STATUS
        FROM CURRECT_USERS
        WHERE UPPER(USER_NAME) = UPPER(P_USERNAME);
        EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
        LV_STATUS := NULL;
        END;
        IF LV_STATUS = 9 
        THEN 
        LV_HOME_PAGE := 4;
        ELSif lv_status = 1   then     
        LV_HOME_PAGE := 1;
        END IF;

        Wwv_Flow_Custom_Auth_Std.Post_Login(upper(P_USERNAME) -- p_User_Name
                                                   ,P_PASSWORD -- p_Password
                                                   ,v('APP_SESSION') -- p_Session_Id
                                                   ,V('APP_ID') || ':'|| LV_HOME_PAGE -- p_Flow_page
                                                    ); 

        close c_check_user;

		if l_dataset_id is null
		then
			apex_util.set_session_state('A_LOGIN_ERR_MSG', 'You dont have access to any dataset');
			return false;
		end if;
        apex_util.set_session_state('HOME_PAGE', lv_home_page);                                            
        apex_util.set_session_state('A_APP_USERNAME', l_user_name);
        apex_util.set_session_state('A_APP_USER_ID', l_user_id);
        apex_util.set_session_state('A_DATASET_ID', l_dataset_id);
		apex_util.set_session_state('A_DATASET_TITLE', l_dataset_title);

		for l_rec in c_get_cust_terms(l_dataset_id)
		loop
			apex_util.set_session_state(l_rec.app_item, l_rec.cust_term);
			apex_util.set_session_state(l_rec.app_item||'_SHORT', l_rec.cust_term_short);
		end loop;

        /*
		pd_audit_pk.save_audit_row	(p_client_id	=>	l_client_id
									,p_user_id		=>	p_username
									,p_action_area	=>	'Connecting to application'
									,p_action		=>	'Login'
									,p_notes		=>	'Successful'
									);
		*/
        return true;

	exception

		when others 
		then
			apex_util.set_session_state('A_LOGIN_ERR_MSG', 'Error logging in: '||sqlcode||' --- '||sqlerrm);		
			return false;

    end  currect_authentication;

    FUNCTION get_hash (p_username  IN  VARCHAR2,
                     p_password  IN  VARCHAR2)
    RETURN VARCHAR2 AS
    l_salt VARCHAR2(30) := 'onlinegameencrypt';
  BEGIN
    RETURN DBMS_CRYPTO.HASH(UTL_RAW.CAST_TO_RAW(UPPER(p_username) || l_salt || p_password),DBMS_CRYPTO.HASH_SH1);
  END; 

------------------------------------------------------------------------------------------------------------

/*procedure login_redirect(P_USERNAME in VARCHAR2, P_PASSWORD in VARCHAR2)
IS
LV_HOME_PAGE NUMBER;
LV_STATUS NUMBER;
BEGIN
BEGIN
SELECT STATUS INTO LV_STATUS
FROM CURRECT_USERS
WHERE UPPER(USER_NAME) = UPPER(P_USERNAME);
EXCEPTION
WHEN NO_DATA_FOUND
THEN
LV_STATUS := NULL;
END;
IF LV_STATUS = 9 
THEN 
LV_HOME_PAGE := 10;
ELSE        
LV_HOME_PAGE := 1;
END IF;

  APEX_UTIL.SET_SESSION_STATE ('FSP_AFTER_LOGIN_URL');
        APEX_UTIL.SET_SESSION_STATE ('P0_LANDING_PAGE', LV_HOME_PAGE);
        Wwv_Flow_Custom_Auth_Std.Post_Login (
            UPPER (P_USERNAME)                                 -- p_User_Name
                               ,
            P_PASSWORD                                          -- p_Password
                       ,
            v ('APP_SESSION')                                  -- p_Session_Id
                             ,
            V ('APP_ID') || ':' || V ('P0_LANDING_PAGE')        -- p_Flow_page
                                                        );
END;*/

END currect_authentication;
