/*Initial Creation (10-Jan-2023) CCM_STRUCTURE*/




--Package Specs

create or replace PACKAGE ccm_structure
AS
	procedure	build_summary_totals(p_twindow_id			in	number
									,p_twindow_ddf			in	varchar2
									,p_grp_credit_sum		in	number
									,p_comp_credit_sum		in	number
									,p_opt_credit_sum		in	number
									,p_grp_hrs_sum			in	number
									,p_grp_contra_hrs_sum	in	number
									,p_err_msg				out	varchar2
									);
	procedure	build_hidden_regions(p_dataset_id		in	number
									,p_err_msg			out	varchar2
									);									
    PROCEDURE   display_course_structure	(p_dataset_id	in	number
											,p_crsyear_id	in	number
											);
	procedure	build_module_list	(p_dataset_id	in	number);
	PROCEDURE   course_report_summary_totals(p_dataset_id	in	number
											,p_crsyear_id	in	number
											);											
END ccm_structure;




--Package Body 

create or replace PACKAGE BODY ccm_structure
AS
 
	procedure	build_module_owner_select	(p_dataset_id		in		number
											,p_err_msg			out		varchar2
											)
	is
	
	BEGIN
 
		htp.p('<div class="select mx-0 my-3">
					<select class="px-0 py-0" onchange="filter_module_list(''ccm_owner'', this.value);">
						<option value="">'||v('A_L1_OWN_TERM')||'</option>');
 
        FOR l_rec IN(select	currect_owner_id
						,	level1_ddf
					from	owners
					where	currect_dataset_id	=	p_dataset_id
					order by nvl(cust_sort, 1), level1_ddf
                    )
        LOOP
            htp.p('<option value="ccm_own_'||l_rec.currect_owner_id||'">'||l_rec.level1_ddf||'</option>');
        END LOOP;                    
 
        htp.p('		</select>
				</div>
			');
 
    exception
 
		when others
		then
			p_err_msg := 'Unexpectd error at level B - display module owners. Please contact system admin with the following details:'||chr(10)||SQLCODE||' --- '||SQLERRM;
 
	end build_module_owner_select;
 
--------------------------------------------------------------------------------------------------------------------------------	
--------------------------------------------------------------------------------------------------------------------------------
 
	procedure	build_twindow_select_filter	(p_dataset_id		in		number
											,p_err_msg			out		varchar2
											)
    IS
 
    BEGIN
 
		htp.p('<div class="select mx-0 my-3">
					<select class="px-0 py-0" onchange="filter_module_list(''ccm_twindow'', this.value);">
						<option value="">'||v('A_SEM_TERM')||'</option>');
 
        FOR l_rec IN(select	currect_twindow_id
						,	full_ddf
					from	time_windows
					where	currect_dataset_id	=	p_dataset_id
					order by nvl(cust_sort, 1), full_ddf
                    )
        LOOP
            htp.p('<option value="ccm_twi_'||l_rec.currect_twindow_id||'">'||l_rec.full_ddf||'</option>');
        END LOOP;                    
 
        htp.p('		</select>
				</div>
			');
 
    exception
 
		when others
		then
			p_err_msg := 'Unexpectd error at level B - display time window list filter. Please contact system admin with the following details:'||chr(10)||SQLCODE||' --- '||SQLERRM;
 
	end build_twindow_select_filter;
 
--------------------------------------------------------------------------------------------------------------------------------	
--------------------------------------------------------------------------------------------------------------------------------
 
	procedure	build_twindow_select	(p_dataset_id		in		number
										,p_err_msg			out		varchar2
										)
    IS
 
    BEGIN
 
		htp.p('<div class="select mx-0 my-3">
					<select class="px-0 py-0" id="new_group_twindow">
						<option value="">'||v('A_SEM_TERM')||'</option>');
 
        FOR l_rec IN(select	currect_twindow_id
						,	full_ddf
					from	time_windows
					where	currect_dataset_id	=	p_dataset_id
					and		indv_twindow		=	'Y'
					order by nvl(cust_sort, 1), full_ddf
                    )
        LOOP
            htp.p('<option value="'||l_rec.currect_twindow_id||'">'||l_rec.full_ddf||'</option>');
        END LOOP;                    
 
        htp.p('		</select>
				</div>
			');
 
    exception
 
		when others
		then
			p_err_msg := 'Unexpectd error at level B - display time window list. Please contact system admin with the following details:'||chr(10)||SQLCODE||' --- '||SQLERRM;
 
	end build_twindow_select;
 
--------------------------------------------------------------------------------------------------------------------------------	
--------------------------------------------------------------------------------------------------------------------------------
 
    procedure	build_grp_type_select	(p_dataset_id	in		number
										,p_err_msg		out		varchar2
										)
    IS
 
    BEGIN
 
		htp.p('<div class="select mx-0 my-3">
					<select class="px-0 py-0" id="new_group_type">
						<option value="">Type</option>');
 
        FOR l_rec IN(SELECT group_name
							||case when nvl(length(group_sub_name), 0) != 0 then ' ('||group_sub_name||')' end	group_ddf
                        ,   currect_grp_type_id
                    FROM    group_types
					where	currect_dataset_id	=	p_dataset_id
					and		group_type_code		in 	(1, 2, 3)
                    ORDER BY nvl(cust_sort, 1), group_ddf
                    )
        LOOP
            htp.p('<option value="'||l_rec.currect_grp_type_id||'">'||l_rec.group_ddf||'</option>');
        END LOOP;                    
 
        htp.p('		</select>
				</div>
			');
 
	exception
 
		when others
		then
			p_err_msg := 'Unexpectd error at level B - display module types. Please contact system admin with the following details:'||chr(10)||SQLCODE||' --- '||SQLERRM;
 
    END build_grp_type_select;
 
 
--------------------------------------------------------------------------------------------------------------------------------	
--------------------------------------------------------------------------------------------------------------------------------	
 
	procedure	build_summary_totals(p_twindow_id			in	number
									,p_twindow_ddf			in	varchar2
									,p_grp_credit_sum		in	number
									,p_comp_credit_sum		in	number
									,p_opt_credit_sum		in	number
									,p_grp_hrs_sum			in	number
									,p_grp_contra_hrs_sum	in	number
									,p_err_msg				out	varchar2
									)
	is
 
	begin
 
		htp.p('<div class="ccm_sum_'||p_twindow_id
				||case when p_grp_credit_sum = 0 and p_grp_hrs_sum = 0 and p_grp_contra_hrs_sum = 0 then ' is-hidden' end
				||'"><div class="has-background-grey-lighter has-text-left px-2 py-2 is-size-4 has-text-weight-medium">
					'||p_twindow_ddf||'
					</div>	
					<div class="columns mx-0 my-0 is-size-5">
						<div class="column px-2 py-2 is-8 has-text-left">
							<div>
								Credits
							</div>
							<div>
								Compulsory
							</div>
							<div>
								Optional
							</div>
							<div>
								Contact hours
							</div>
							<div>
								Cumulative hours
							</div>
						</div>
						<div class="column px-2 py-2 is-1">
						</div>
						<div class="column px-2 py-2 is-3 has-text-left">
							<div class="cryr_credit_total_'||p_twindow_id||'">
								'||p_grp_credit_sum||'
							</div>
							<div class="cryr_credit_comp_'||p_twindow_id||'">
								'||p_comp_credit_sum||'
							</div>	
							<div class="cryr_credit_opt_'||p_twindow_id||'">
								'||p_opt_credit_sum||'
							</div>
							<div class="cryr_hours_total_'||p_twindow_id||'">
								'||p_grp_hrs_sum||'
							</div>
							<div class="cryr_hours_actual_'||p_twindow_id||'">
								'||p_grp_contra_hrs_sum||'
							</div>
						</div>
					</div>
				</div>	
			');
 
	exception
 
		when others
		then
			p_err_msg := 'Unexpectd error at level B - display summary totals. Please contact system admin with the following details:'||chr(10)||SQLCODE||' --- '||SQLERRM;
 
	end build_summary_totals;
 
--------------------------------------------------------------------------------------------------------------------------------	
--------------------------------------------------------------------------------------------------------------------------------	
 
	procedure	build_module_group_header	(p_twindow_id			in		number
											,p_group_type_code		in		number
											,p_group_id				in		number
											,p_group_title			in		varchar2	
											,p_group_header			in		varchar2	
											,p_group_pos			in		number
											,p_group_credits		in		number
											,p_group_contact_hrs	in		number
											,p_group_contra_hrs		in		number
											,p_err_msg				out		varchar2
											)
	is
 
	begin
 
		htp.p('<div class="'||p_twindow_id||'_'||p_group_type_code||' mod_grp">
					<span class="mod_grp_id">'||p_group_id||'</span>
					<span class="disp_seq">'||p_group_pos||'</span>
					<div class="columns mx-0 my-0 has-background-grey-lighter is-size-4 group_type">
						<div class="column is-one-fifth has-text-left py-1">
							<textarea class="textarea" placeholder="Group title" rows="1" style="padding:1px;">'||p_group_title||'</textarea>
						</div>
						<div class="column has-text-centered py-1 has-text-weight-medium">'||p_group_header||'</div>
						<div class="column is-one-fifth has-text-right py-1">
							<i class="fa fa-arrow-up" style="font-size:1.3rem;" onclick="move_group(this, ''up'')"></i>
							<i class="fa fa-arrow-down" style="font-size:1.3rem;" onclick="move_group(this, ''down'')"></i>
							<i class="fa fa-trash" style="font-size:1.3rem;" onclick="l_group_to_remove = this; show_modal(''remove_group'');"></i>
						</div>
					</div>
					<div class="columns mx-0 my-0 has-background-grey has-text-white is-size-5 group_summary">
						<div class="column is-3 has-text-left py-0">Credits: <span class="grp_credit_total">'||p_group_credits||'</span></div>
						<div class="column has-text-centered py-0">Contact hours: <span class="grp_hours_total">'||p_group_contact_hrs||'</span></div>
						<div class="column is-3 has-text-right py-0">Cumulative hours: <span class="grp_hours_actual">'||p_group_contra_hrs||'</span></div>
					</div>
					<table class="table is-size-5 is-fullwidth is-striped grp_mod_list">
						<tbody>
							<tr class="has-text-weight-medium">
								<td class="px-2 py-2" style="width:1%;"></td>	
								<td class="px-2 py-2 is-uppercase" style="width:11%;">'||v('A_MOD_TERM_SHORT')||'</td>
								<td class="px-2 py-2" style="width:30%;">NAME</td>
								<td class="px-2 py-2" style="width:20%;">STUDENTS<br/><span class="is-size-6">(From this '||v('A_CRS_TERM_SHORT')||')</span></td>
								<td class="px-2 py-2" style="width:10%;">CREDITS</td>
								<td class="px-2 py-2" style="width:8%;">CONTACT</td>
								<td class="px-2 py-2 comp_col" style="width:10%;">COMPLEXITY<br/>(RAG)</td>
								<td class="px-2 py-2  is-uppercase contra_col" style="width:10%;">CONFLICTING '||v('A_CRS_TERM_SHORT')||'S</td>
							</tr>
			');
 
	exception
 
		when others
		then
			p_err_msg := 'Unexpectd error at level B - build group header. Please contact system admin with the following details:'||chr(10)||SQLCODE||' --- '||SQLERRM;
 
	end build_module_group_header;											
 
--------------------------------------------------------------------------------------------------------------------------------	
--------------------------------------------------------------------------------------------------------------------------------
 
	procedure	build_module_row	(p_module_id		in		number
									,p_module_code_ddf	in		varchar2
									,p_module_title_ddf	in		varchar2
									,p_students			in		varchar2
									,p_students_prev_2	in		varchar2
									,p_students_prev_3	in		varchar2
									,p_mod_credits		in		varchar2
									,p_split_credits	in		varchar2
									,p_weekly_hours		in		number
									,p_err_msg			out		varchar2
									)
	is
 
	begin
 
		htp.p('<tr class="module_row mod_grp_src">
					<td class="px-1 py-1" style="width:1%;"><i class="fa fa-trash has-text-grey" style="font-size:1.3rem;" onclick="l_module_to_remove = $(this).closest(''tr''); show_modal(''remove_module'')"></i></td>
					<td class="px-2 py-2 mod_code" title="'||p_module_title_ddf||'" style="width:11%;"><span class="mod_code_ddf">'||p_module_code_ddf||'</span><span class="mod_curr_id">'||p_module_id||'</span></td>
					<td class="px-2 py-2 mod_title" style="width:30%;">'||p_module_title_ddf||'</td>
					<td class="px-2 py-2 mod_students" style="width:20%;">
						<i class="fa fa-plus-square has-text-grey prev_students" style="font-size:1.3rem;" onclick="toggle_prev_students(this)"></i>
						&nbsp;'||p_students||'<span class="prev_students is-hidden">&nbsp;|&nbsp;'||p_students_prev_2||'&nbsp;|&nbsp;'||p_students_prev_3||'</span>
					</td>
					<td class="px-2 py-2 mod_credit" style="width:10%;">'||p_mod_credits||p_split_credits||'</td>
					<td class="px-2 py-2 mod_hours" title="'||p_students||'<span class=&quot;prev_students is-hidden&quot;>&nbsp;|&nbsp;'||p_students_prev_2||'&nbsp;|&nbsp;'||p_students_prev_3||'</span>" style="width:8%;">'||p_weekly_hours||'</td>
					<td class="px-2 py-2 mod_comp" style="width:10%;"><span class="has-text-white px-3 mod_comp_dets"></span>&nbsp;<i class="fa fa-plus-square has-text-grey" style="font-size:1.3rem;" onclick="toggle_rag_contra(this, ''mod_contra'')"></i></td>
					<td class="px-2 py-2 mod_contra" style="width:10%;"><span class="has-background-white-ter px-3 mod_contra_dets"></span>&nbsp;<i class="fa fa-plus-square has-text-grey" style="font-size:1.3rem;" onclick="toggle_rag_contra(this, ''mod_comp'')"></i></td>
				</tr>
				<tr class="is-hidden">
					<td colspan="8">
						<div style="max-height:12rem; overflow-y:scroll;">
							<table class="table is-size-5 is-fullwidth rag_tab">
								<tbody>
								</tbody>
							</table>	
						</div>	
					</td>
				</tr>
			');
 
	exception
 
		when others
		then
			p_err_msg := 'Unexpectd error at level B - build module row. Please contact system admin with the following details:'||chr(10)||SQLCODE||' --- '||SQLERRM;
 
	end build_module_row;		
 
--------------------------------------------------------------------------------------------------------------------------------	
--------------------------------------------------------------------------------------------------------------------------------
 
	procedure	build_hidden_regions(p_dataset_id		in	number
									,p_err_msg			out	varchar2
									)
	is
 
		l_err_msg				varchar2(4000) := null;
		l_called_proc_error		exception;
 
	begin
 
		--Create the container for the create group function
		htp.p('<div id="ccm_new_group" class="has-background-grey-dark has-text-white is-size-5 has-text-centered px-2">');
 
		build_twindow_select(p_dataset_id
							,l_err_msg
							);
 
		if l_err_msg is not null
		then
			raise l_called_proc_error;
		end if;								
 
		build_grp_type_select	(p_dataset_id
								,l_err_msg);
 
		if l_err_msg is not null
		then
			raise l_called_proc_error;
		end if;								
 
		htp.p('<button type="button" class="button has-background-grey-lighter is-medium mx-0 my-3 has-text-weight-medium" onclick="add_new_mod_grp()">Create</button>
			</div>
			');
 
		--Create the container for the modules list on the left
		htp.p('<div id="ccm_module_list" class="has-background-grey-dark has-text-white">
					<div class="columns mx-0 my-0 is-size-5">
						<div class="column px-1 py-1">
			');
 
		build_module_owner_select	(p_dataset_id
									,l_err_msg
									);	
 
		if l_err_msg is not null
		then
			raise l_called_proc_error;
		end if;			
 
		htp.p('</div>
				<div class="column px-1 py-1">
			');
 
		--This is a slightly different version than the build_twindow_select used for the create new group function
		build_twindow_select_filter	(p_dataset_id
									,l_err_msg
									);
 
		if l_err_msg is not null
		then
			raise l_called_proc_error;
		end if;		
 
		--Build the module search and then an empty table for the actual module list with just the column headers
		--The column headers sit in a seperate table just above the actual module list table so that the headers stay
		--fixed while the rest of the module list table is scrolled
		--We will build the actual module list using an asynchronous function via Javascript once the structure has loaded
		htp.p('			</div>
					</div>
					<div class="columns mx-0 my-0">	
						<div class="column px-6 py-0">
							<textarea class="textarea is-medium" placeholder="Search '||v('A_MOD_TERM_SHORT')||'..." rows="1" style="padding:1px;" onkeyup="filter_module_list(''ccm_mod_search'', this.value);"></textarea>
						</div>
					</div>
					<div class="content mx-2 mt-3 mb-0 px-0 py-0">
						<table class="table is-size-5 is-fullwidth has-background-grey-dark has-text-white">
							<tbody>
								<tr class="has-text-weight-medium">
									<td class="px-2 pt-2 pb-2 is-uppercase" style="width:30%;">'||v('A_MOD_TERM_SHORT')||'</td>
									<td class="px-2 pt-2 pb-2 is-uppercase" style="width:14%;">'||v('A_SEM_TERM_SHORT')||'</td>
									<td class="px-2 pt-2 pb-2" style="width:20%;">STATUS</td>
									<td class="px-2 pt-2 pb-2" style="width:23%;">CREDITS</td>
									<td class="px-2 pt-2 pb-2" style="width:13%;">HOURS</td>
								</tr>
							</tbody>
						</table>
					</div>
			');
 
		--This is the table that will hold the module rows	
		htp.p('<div class="content mx-0 my-0 px-2" id="ccm_module_list_rows">
					<table class="table is-size-5 is-fullwidth has-background-grey-dark has-text-white ccm_module_list_tab">
						<tbody>
						</tbody>
					</table>
				</div>
			</div>	
			');			
 
		--Build modals for various messages	
		--Remove module group modal
		htp.p('<div class="modal" id="remove_group">
				  <div class="modal-background"></div>
				  <div class="modal-card">
					<header class="modal-card-head py-4">
					  <p class="modal-card-title">Remove <span class="is-lowercase">'||v('A_MOD_TERM')||'</span> group</p>
					  <button type="button" class="delete" aria-label="close" onclick="hide_modal(''remove_group'')"></button>
					</header>
					<section class="modal-card-body">
					  <p>Removing a <span class="is-lowercase">'||v('A_MOD_TERM')||'</span> group will remove all the <span class="is-lowercase">'||v('A_MOD_TERM')||'</span>s in that group from the <span class="is-lowercase">'||v('A_CRS_TERM')||'</span> structure. Do you wish to proceed?</p>
					</section>
					<footer class="modal-card-foot py-4">
					  <button type="button" class="button is-success is-medium" onclick="hide_modal(''remove_group''); remove_module_group();">Yes, remove group</button>
					  <button type="button" class="button is-medium" onclick="hide_modal(''remove_group'');">Cancel</button>
					</footer>
				  </div>
				</div>
			');					
 
		--Remove module modal
		htp.p('<div class="modal" id="remove_module">
				  <div class="modal-background"></div>
				  <div class="modal-card">
					<header class="modal-card-head py-4">
					  <p class="modal-card-title">Remove <span class="is-lowercase">'||v('A_MOD_TERM')||'</span></p>
					  <button type="button" class="delete" aria-label="close" onclick="hide_modal(''remove_module'')"></button>
					</header>
					<section class="modal-card-body">
					  <p>Do you wish to remove this <span class="is-lowercase">'||v('A_MOD_TERM')||'</span> from the <span class="is-lowercase">'||v('A_CRS_TERM')||'</span> structure?</p>
					</section>
					<footer class="modal-card-foot py-4">
					  <button type="button" class="button is-success is-medium" onclick="hide_modal(''remove_module''); remove_module_from_group();">Yes, remove '||lower(v('A_MOD_TERM'))||'</button>
					  <button type="button" class="button is-medium" onclick="hide_modal(''remove_module'');">Cancel</button>
					</footer>
				  </div>
				</div>
			');					
 
		--Duplicate module modal
		htp.p('<div class="modal" id="duplicate_module">
				  <div class="modal-background"></div>
				  <div class="modal-card">
					<header class="modal-card-head py-4">
					  <p class="modal-card-title">'||v('A_MOD_TERM')||' exists</p>
					  <button type="button" class="delete" aria-label="close" onclick="hide_modal(''duplicate_module'')"></button>
					</header>
					<section class="modal-card-body">
					  <p></p>
					</section>
					<footer class="modal-card-foot py-4">
					  <button type="button" class="button is-medium" onclick="hide_modal(''duplicate_module'');">OK</button>
					</footer>
				  </div>
				</div>
			');					
 
		--Save changes progress bar modal
		htp.p('<div class="modal" id="save_progress_bar">
				  <div class="modal-background"></div>
				  <div class="modal-content" style="text-align:center;">
					<label class="py-2 has-text-white is-size-3">Saving <span class="is-lowercase">'||v('A_CRS_TERM')||'</span> structure</label>
					<progress class="progress is-large is-success" max="100" style="width:60%; margin:auto;"></progress>
				  </div>
				</div>
			');
 
		--Save changes success modal
		htp.p('<div class="modal" id="save_complete">
				  <div class="modal-background"></div>
				  <div class="modal-card">
					<header class="modal-card-head py-4">
					  <p class="modal-card-title has-text-success">Changes saved successfully</p>
					  <button type="button" class="delete" aria-label="close" onclick="hide_modal(''save_complete'')"></button>
					</header>
					<section class="modal-card-body">
					  <p>Changes to the <span class="is-lowercase">'||v('A_CRS_TERM')||'</span> structure have been saved successfully</p>
					</section>
					<footer class="modal-card-foot py-4">
					  <button type="button" class="button is-medium" onclick="hide_modal(''save_complete'');">OK</button>
					</footer>
				  </div>
				</div>
			');			
 
		--Save changes error modal
		htp.p('<div class="modal" id="save_error">
				  <div class="modal-background"></div>
				  <div class="modal-card">
					<header class="modal-card-head py-4">
					  <p class="modal-card-title has-text-danger">Error saving changes</p>
					  <button type="button" class="delete" aria-label="close" onclick="hide_modal(''save_error'')"></button>
					</header>
					<section class="modal-card-body">
					  <p>There was an error while saving changes to the <span class="is-lowercase">'||v('A_CRS_TERM')||'</span> structure</p>
					</section>
					<footer class="modal-card-foot py-4">
					  <button type="button" class="button is-medium" onclick="hide_modal(''save_error'');">OK</button>
					</footer>
				  </div>
				</div>
			');	
 
    EXCEPTION
 
		When l_called_proc_error
		then
			p_err_msg := l_err_msg;
 
		when others
		then
			p_err_msg := 'Unexpectd error at level B - build hidden regions. Please contact system admin with the following details:'||chr(10)||SQLCODE||' --- '||SQLERRM;
 
	end build_hidden_regions;
 
--------------------------------------------------------------------------------------------------------------------------------	
--------------------------------------------------------------------------------------------------------------------------------
 
    PROCEDURE   display_course_structure	(p_dataset_id	in	number
											,p_crsyear_id	in	number
											)
    IS
 
        l_grps_start                BOOLEAN :=  FALSE;
        l_grps_end                  BOOLEAN :=  FALSE;
        l_curr_twindow_id           time_windows.currect_twindow_id%type;
		l_apco_seq					number := null;
		l_twindow_credits			number := 0;
		l_twindow_comp_credits		number := 0;
		l_twindow_opt_credits		number := 0;
		l_twindow_contact_hrs		number := 0;
		l_twindow_contra_hrs		number := 0;
        l_err_msg					varchar2(4000);
		l_called_proc_error			exception;
 
    BEGIN
 
		APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION('summary_totals');
 
		FOR l_rec IN(/*For each course year, get the full list of groups and modules within those groups
					Also find every other course that has the same module (in the same time window)
					Using this detect and count the contra hours
					*/
					with	cryr_details
					as		(select	tiwi.full_ddf			tiwi_ddf
								,	nvl(tiwi.cust_sort, 1)	tiwi_sort
								,	cogr.currect_group_id
								,	goty.group_type_code
								,	goty.group_name
								,	goty.group_sub_name
								,	nvl(goty.cust_sort, 1)	goty_sort
								,	cogr.currect_twindow_id	cogr_twindow_id
								,	modu.module_code_ddf
								,	modu.module_title_ddf
								,	modu.weekly_hours
								,	modu.credits			mod_credits
								,	nvl(modu.cust_sort, 1)	modu_sort
								,	cogr.display_position	cogr_sort
								,	cogr.group_title	
								,	case when cogr.currect_group_id = cgoth.currect_group_id then cgmo.currect_module_id else null end	currect_module_id
								,	sum	(case	when cogr.currect_group_id = cgoth.currect_group_id
												then nvl(mocs.credits, 0)
												else 0
												end
										 ) over (partition by cogr.currect_group_id)	grp_credits
								,	case when goty.group_type_code != 2
										 then sum(case when cogr.currect_group_id = cgoth.currect_group_id
													   then nvl(modu.weekly_hours, 0)
													   else 0
													   end
												 ) over (partition by cogr.currect_group_id)
										 else max(case when cogr.currect_group_id = cgoth.currect_group_id
													   then nvl(modu.weekly_hours, 0)
													   else 0
													   end
												 ) over (partition by cogr.currect_group_id)
										 end				grp_contact_hrs
								,	sum(case when 	(	cogr.currect_group_id		!=	cgoth.currect_group_id
													and	goty.group_type_code		=	2
													and	cogr.currect_grp_type_id	!=	cgoth.currect_grp_type_id
													)
											  then	nvl(modu.weekly_hours, 0)
											  else	0
											  end
										)
									over (partition by cogr.currect_group_id, cgoth.currect_group_id)		grp_contra_hrs
							from	courseyear_groups		cogr
								,	group_types				goty
								,	time_windows			tiwi
								,	courseyear_group_modules	cgmo
								,	modules					modu
								,	module_credit_split		mocs
								,	time_windows			motw
								,	courses					cooth
								,	course_years			cyoth
								,	courseyear_groups		cgoth
								,	courseyear_group_modules	cmoth
							--Get the detailed course structure
							where	cogr.currect_crsyear_id		=	p_crsyear_id
							and		cogr.currect_grp_type_id	=	goty.currect_grp_type_id
							and		cogr.currect_twindow_id		=	tiwi.currect_twindow_id
							and		cgmo.currect_group_id		=	cogr.currect_group_id
							and		modu.currect_module_id		=	cgmo.currect_module_id
							and		mocs.currect_module_id		=	modu.currect_module_id
							and		motw.currect_twindow_id		=	mocs.currect_twindow_id		--using motw twice here rather than comparing cogr to mocs as I feel it will make use of the foreign key index and so wil be quicker
							and		motw.currect_twindow_id		=	cogr.currect_twindow_id
							--And now use the "other" tables to get all other courses which have the same module in the same time window
							and		cooth.currect_dataset_id	=	p_dataset_id
							and		cyoth.currect_course_id		=	cooth.currect_course_id
							and		cgoth.currect_crsyear_id	=	cyoth.currect_crsyear_id
							and		cgoth.currect_twindow_id	=	cogr.currect_twindow_id
							and		cmoth.currect_group_id		=	cgoth.currect_group_id
							and		cmoth.currect_module_id		=	cgmo.currect_module_id
							)--select * from cryr_details order by case when currect_module_id is not null then 1 else 2 end
							--	, tiwi_sort, tiwi_ddf, goty_sort, group_type_code, cogr_sort, modu_sort, module_code_ddf;
					--This is to find the worst contra hours for each group		
						,	cryr_contra_summary
					as		(select	currect_group_id
								,	max(grp_contra_hrs)		grp_contra_hrs
							from	cryr_details	
							group by currect_group_id
							)--select	* from cryr_contra_summary;
					--This is to create a display for module credits (especially that span multiple time windows)		
						,	modu_credit_ddf
					as		(select	cyde.currect_group_id
								,	cyde.currect_module_id
								,	'<span class="full_credit">'
									||nvl(cyde.mod_credits, 0)
									||case when count(mocs.credits) > 1
										   then ' ('||listagg(mocs.credits, ', ') within group (order by nvl(motw.cust_sort, 1), motw.full_ddf)||')'
										   end	
									||'</span>'			   mod_credits
								,	listagg('<span class="split_credit '||mocs.currect_twindow_id||'_credit">'||mocs.credits||'</span>', ' ') within group (order by nvl(motw.cust_sort, 1), motw.full_ddf)	split_credits					   		   
							from	cryr_details			cyde
							left outer join	(		module_credit_split		mocs
											join	time_windows			motw
											on		mocs.currect_twindow_id	=	motw.currect_twindow_id
											)
							on		cyde.currect_module_id	=	mocs.currect_module_id						
							where	cyde.currect_module_id is not null
							group by cyde.currect_group_id 
								,	cyde.currect_module_id
								,	cyde.mod_credits
							)--select * from modu_credit_ddf order by 1, 2;
					,		cryr_structure
					as		(select	cyde.tiwi_ddf
								,	cyde.tiwi_ddf||' - '||cyde.group_name
									|| case when cyde.group_sub_name is not null then ' ('||cyde.group_sub_name||')' end	group_header
								,	cyde.currect_group_id
								,	cyde.group_title
								,	cyde.cogr_sort
								,	max(cogr_sort) over (partition by cogr_twindow_id)	max_disp_pos
								,	cyde.group_type_code
								,	cyde.cogr_twindow_id
								,	cyde.module_code_ddf
								,	cyde.module_title_ddf
								,	cyde.modu_sort
								,	cyde.goty_sort
								,	cyde.weekly_hours
								,	mocr.mod_credits
								,	mocr.split_credits
								,	cyde.currect_module_id
								,	cyde.grp_credits
								,	case when cyde.group_type_code = 1 then cyde.grp_credits else 0 end		grp_comp_credits
								,	case when cyde.group_type_code != 1 then cyde.grp_credits else 0 end	grp_opt_credits
								,	cyde.grp_contact_hrs
								,	case when cyde.group_type_code = 2 
										 then greatest(cyco.grp_contra_hrs, cyde.grp_contact_hrs)
										 else cyde.grp_contact_hrs
										 end		grp_contra_hrs
								,	nvl(most.recent_year_total, 0)||' ('||nvl(mcst.recent_year_cryr, 0)||')'	students
								,	nvl(most.prev_year_1_total, 0)||' ('||nvl(mcst.prev_year_1_cryr, 0)||')'	students_prev_2
								,	nvl(most.prev_year_2_total, 0)||' ('||nvl(mcst.prev_year_2_cryr, 0)||')'	students_prev_3
								,   first_value(cyde.currect_module_id) OVER(PARTITION BY cyde.currect_group_id ORDER BY cyde.modu_sort, cyde.module_code_ddf)	first_mod
								,   last_value(cyde.currect_module_id) OVER(PARTITION BY cyde.currect_group_id ORDER BY cyde.modu_sort, cyde.module_code_ddf RANGE BETWEEN
																		UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)                last_mod
							from	((		cryr_details			cyde
									join	cryr_contra_summary		cyco
									on		cyco.currect_group_id	=	cyde.currect_group_id
									join	modu_credit_ddf			mocr
									on		cyde.currect_group_id	=	mocr.currect_group_id
									and		cyde.currect_module_id	=	mocr.currect_module_id
									)
									left outer join	module_student_totals	most		
									on		most.currect_module_id	=	cyde.currect_module_id
									)
									left outer join	module_crsyear_student_totals	mcst		
									on		mcst.currect_module_id	=	cyde.currect_module_id
									and		mcst.currect_crsyear_id	=	p_crsyear_id
							where	cyde.currect_module_id is not null
							)
					select	tiwi.full_ddf	tiwi_ddf
						,	crst.group_header
						,	crst.currect_group_id
						,	crst.group_title
						,	crst.cogr_sort
						,	crst.max_disp_pos
						,	crst.group_type_code
						,	tiwi.currect_twindow_id		cogr_twindow_id
						,	crst.module_code_ddf
						,	crst.module_title_ddf
						,	crst.weekly_hours
						,	crst.mod_credits
						,	crst.split_credits
						,	crst.currect_module_id
						,	crst.grp_credits
						,	crst.grp_comp_credits
						,	crst.grp_opt_credits
						,	crst.grp_contact_hrs
						,	crst.grp_contra_hrs
						,	crst.students
						,	crst.students_prev_2
						,	crst.students_prev_3
						,   crst.first_mod
						,   crst.last_mod
					from	time_windows	tiwi
					left outer join	
							cryr_structure	crst
					on		tiwi.currect_twindow_id	=	crst.cogr_twindow_id		
					where	tiwi.indv_twindow		=	'Y'
					order by tiwi.cust_sort
						,	tiwi.full_ddf
						,	crst.cogr_sort
						, 	crst.goty_sort
						, 	crst.modu_sort
						, 	crst.module_code_ddf
                    )
        LOOP
 
			--Start the structure display		
			IF NOT l_grps_start
			THEN
				--Start the outermost course structure container divs
				htp.p('<div id="ccm_course_structure">
							<div class="px-2 py-2" id="ccm_groups">
								<div class="content px-0 py-1"></div>');
 
				l_grps_start := TRUE;
 
			END IF;
 
			--If the twindow is changing (or this is the first record), create the twindow level items
			IF nvl(l_rec.cogr_twindow_id, -1) != nvl(l_curr_twindow_id, -2)
			THEN
 
				l_curr_twindow_id := l_rec.cogr_twindow_id;
 
				--show the time window divider
				htp.p('	<div class="twi_div_'||l_rec.cogr_twindow_id
						||case when l_rec.currect_module_id is null then ' is-hidden' end
						||' columns is-vcentered mx-6 my-0 px-6 py-0 has-text-centered has-text-weight-medium has-text-white">
							<div class="column ml-6 mr-0 my-0 pl-6 pr-0 py-1 has-background-grey-lighter"></div>
							<div class="column px-0 py-0 has-background-grey">'||l_rec.tiwi_ddf||'</div>
							<div class="column mr-6 ml-0 my-0 pr-6 pl-0 py-1 has-background-grey-lighter"></div>
						</div>
						<div class="'||case when l_rec.currect_module_id is null then 'is-hidden ' end||'content px-0 py-2"></div>
					');
 
				htp.p('<span class="grp_disp_seq disp_pos_'||l_rec.cogr_twindow_id||'">'||nvl(l_rec.max_disp_pos, 0)||'</span>');
 
				--Create a row for the time window's summary information to be added	
				l_apco_seq := APEX_COLLECTION.ADD_MEMBER(p_collection_name => 'SUMMARY_TOTALS'
														,p_c001            => l_rec.cogr_twindow_id
														,p_n001            => 0
														,p_n002            => 0
														,p_n003            => 0
														,p_n004            => 0
														,p_n005            => 0
														);	
 
				--Reset all twindow totals to 0																
				l_twindow_credits	 	:= 0;
				l_twindow_comp_credits	:= 0;
				l_twindow_opt_credits	:= 0;
				l_twindow_contact_hrs	:= 0;
				l_twindow_contra_hrs	:= 0;										
 
			END IF;
 
			--Are we starting a new module group
			IF  nvl(l_rec.currect_module_id, -1) = nvl(l_rec.first_mod, -2)
			THEN
 
				build_module_group_header	(l_rec.cogr_twindow_id
											,l_rec.group_type_code
											,l_rec.currect_group_id
											,l_rec.group_title
											,l_rec.group_header
											,l_rec.cogr_sort
											,l_rec.grp_credits
											,l_rec.grp_contact_hrs
											,l_rec.grp_contra_hrs
											,l_err_msg
											);
 
				if l_err_msg is not null
				then
					raise l_called_proc_error;
				end if;											
 
				--Add the various group totals to the corresponding twindow totals and set the updated values in the Apex collection
				l_twindow_credits := l_twindow_credits + l_rec.grp_credits;
				l_twindow_comp_credits := l_twindow_comp_credits + l_rec.grp_comp_credits;
				l_twindow_opt_credits := l_twindow_opt_credits + l_rec.grp_opt_credits;
				l_twindow_contact_hrs := l_twindow_contact_hrs + l_rec.grp_contact_hrs;
				l_twindow_contra_hrs := l_twindow_contra_hrs + l_rec.grp_contra_hrs;
 
				APEX_COLLECTION.UPDATE_MEMBER(p_collection_name => 'SUMMARY_TOTALS'
											,p_seq				=> l_apco_seq		
											,p_c001            => l_rec.cogr_twindow_id
											,p_n001            => l_twindow_credits
											,p_n002            => l_twindow_comp_credits
											,p_n003            => l_twindow_opt_credits
											,p_n004            => l_twindow_contact_hrs
											,p_n005            => l_twindow_contra_hrs
											);
 
			end if;
 
			--Build the actual module row
			if l_rec.currect_module_id is not null
			then
 
				build_module_row	(l_rec.currect_module_id
									,l_rec.module_code_ddf		
									,l_rec.module_title_ddf	
									,l_rec.students		
									,l_rec.students_prev_2
									,l_rec.students_prev_3
									,l_rec.mod_credits		
									,l_rec.split_credits
									,l_rec.weekly_hours		
									,l_err_msg			
									);
 
				if l_err_msg is not null
				then
					raise l_called_proc_error;
				end if;									
 
			end if;
 
			--Was this the last module in the module group
			IF  nvl(l_rec.currect_module_id, -1) = nvl(l_rec.last_mod, -2)
			THEN								
 
				--Close the module group containers
				htp.p('		</tbody>
						</table>		
					</div>
					<div class="content px-0 py-2"></div>	
					');
			end if;	
 
        END LOOP;				
 
		--If the course has no structure, then no containers would ahve been created
		--Here, we create an empty structure
		IF NOT l_grps_start
		THEN
			--Start the outermost course structure container divs
			htp.p('<div id="ccm_course_structure">
						<div class="px-2 py-2" id="ccm_groups">
							<div class="content px-0 py-1"></div>');
 
			l_grps_start := TRUE;
 
		END IF;
 
		IF NOT l_grps_end
		THEN
 
			--Close the main container for the module groups ccm_course_structure and ccm_groups
			--And also the middle column housing the utilities tool bar at the top and the module groups below
			htp.P('		</div>
					</div>
				');
 
			l_grps_end := TRUE;
 
		end if;
 
    EXCEPTION
 
		When l_called_proc_error
		then
			htp.p(l_err_msg);
 
        WHEN OTHERS
        THEN
            htp.P('Unexpectd error at level B - display structure. Please contact system admin with the following details:'||chr(10)||SQLCODE||' --- '||SQLERRM);
 
    END display_course_structure;
 
--------------------------------------------------------------------------------------------------------------------------------	
--------------------------------------------------------------------------------------------------------------------------------
 
	PROCEDURE   course_report_summary_totals(p_dataset_id	in	number
											,p_crsyear_id	in	number
											)
 
	is
 
		l_err_msg	varchar2(4000);
		l_mod_cnt	number := 0;
 
	begin
 
		FOR l_rec IN(/*For each course year, get the full list of groups and modules within those groups
					Also find every other course that has the same module (in the same time window)
					Using this detect and count the contra hours
					*/
					with	cryr_details
					as		(select	tiwi.full_ddf			tiwi_ddf
								,	nvl(tiwi.cust_sort, 1)	tiwi_sort
								,	cogr.currect_group_id
								,	goty.group_type_code
								,	goty.group_name
								,	goty.group_sub_name
								,	nvl(goty.cust_sort, 1)	goty_sort
								,	cogr.currect_twindow_id	cogr_twindow_id
								,	modu.module_code_ddf
								,	modu.module_title_ddf
								,	modu.weekly_hours
								,	modu.credits			mod_credits
								,	nvl(modu.cust_sort, 1)	modu_sort
								,	cogr.display_position	cogr_sort
								,	cogr.group_title	
								,	case when cogr.currect_group_id = cgoth.currect_group_id then cgmo.currect_module_id else null end	currect_module_id
								,	sum	(case	when cogr.currect_group_id = cgoth.currect_group_id
												then nvl(mocs.credits, 0)
												else 0
												end
										 ) over (partition by cogr.currect_group_id)	grp_credits
								,	case when goty.group_type_code != 2
										 then sum(case when cogr.currect_group_id = cgoth.currect_group_id
													   then nvl(modu.weekly_hours, 0)
													   else 0
													   end
												 ) over (partition by cogr.currect_group_id)
										 else max(case when cogr.currect_group_id = cgoth.currect_group_id
													   then nvl(modu.weekly_hours, 0)
													   else 0
													   end
												 ) over (partition by cogr.currect_group_id)
										 end				grp_contact_hrs
								,	sum(case when 	(	cogr.currect_group_id		!=	cgoth.currect_group_id
													and	goty.group_type_code		=	2
													and	cogr.currect_grp_type_id	!=	cgoth.currect_grp_type_id
													)
											  then	nvl(modu.weekly_hours, 0)
											  else	0
											  end
										)
									over (partition by cogr.currect_group_id, cgoth.currect_group_id)		grp_contra_hrs
							from	courseyear_groups		cogr
								,	group_types				goty
								,	time_windows			tiwi
								,	courseyear_group_modules	cgmo
								,	modules					modu
								,	module_credit_split		mocs
								,	time_windows			motw
								,	courses					cooth
								,	course_years			cyoth
								,	courseyear_groups		cgoth
								,	courseyear_group_modules	cmoth
							--Get the detailed course structure
							where	cogr.currect_crsyear_id		=	p_crsyear_id
							and		cogr.currect_grp_type_id	=	goty.currect_grp_type_id
							and		cogr.currect_twindow_id		=	tiwi.currect_twindow_id
							and		cgmo.currect_group_id		=	cogr.currect_group_id
							and		modu.currect_module_id		=	cgmo.currect_module_id
							and		mocs.currect_module_id		=	modu.currect_module_id
							and		motw.currect_twindow_id		=	mocs.currect_twindow_id		--using motw twice here rather than comparing cogr to mocs as I feel it will make use of the foreign key index and so wil be quicker
							and		motw.currect_twindow_id		=	cogr.currect_twindow_id
							--And now use the "other" tables to get all other courses which have the same module in the same time window
							and		cooth.currect_dataset_id	=	p_dataset_id
							and		cyoth.currect_course_id		=	cooth.currect_course_id
							and		cgoth.currect_crsyear_id	=	cyoth.currect_crsyear_id
							and		cgoth.currect_twindow_id	=	cogr.currect_twindow_id
							and		cmoth.currect_group_id		=	cgoth.currect_group_id
							and		cmoth.currect_module_id		=	cgmo.currect_module_id
							)--select * from cryr_details order by case when currect_module_id is not null then 1 else 2 end
							--	, tiwi_sort, tiwi_ddf, goty_sort, group_type_code, cogr_sort, modu_sort, module_code_ddf;
					--This is to find the worst contra hours for each group		
						,	cryr_contra_summary
					as		(select	currect_group_id
								,	max(grp_contra_hrs)		grp_contra_hrs
							from	cryr_details	
							group by currect_group_id
							)--select	* from cryr_contra_summary;
					,		cryr_structure
					as		(select	cyde.tiwi_ddf
								,	cyde.tiwi_sort
								,	cyde.cogr_twindow_id
								,	cyde.currect_module_id
								,	cyde.grp_credits
								,	case when cyde.group_type_code = 1 then cyde.grp_credits else 0 end		grp_comp_credits
								,	case when cyde.group_type_code != 1 then cyde.grp_credits else 0 end	grp_opt_credits
								,	cyde.grp_contact_hrs
								,	case when cyde.group_type_code = 2 
										 then greatest(cyco.grp_contra_hrs, cyde.grp_contact_hrs)
										 else cyde.grp_contact_hrs
										 end		grp_contra_hrs
								,   first_value(cyde.currect_module_id) OVER(PARTITION BY cyde.currect_group_id ORDER BY cyde.modu_sort, cyde.module_code_ddf)	first_mod
								,	count(distinct cyde.currect_module_id) over (partition by null)		mod_cnt										
							from	cryr_details			cyde
							join	cryr_contra_summary		cyco
							on		cyco.currect_group_id	=	cyde.currect_group_id
							where	cyde.currect_module_id is not null
							)--select * from cryr_structure; 
					select 	cogr_twindow_id			twindow_id
						,	tiwi_ddf
						,	mod_cnt
						,	tiwi_sort
						,	sum(grp_credits)		grp_credits
						,	sum(grp_comp_credits)	grp_comp_credits
						,	sum(grp_opt_credits)	grp_opt_credits
						,	sum(grp_contact_hrs)	grp_contact_hrs
						,	sum(grp_contra_hrs)		grp_contra_hrs
					from 	cryr_structure
					where	currect_module_id	=	first_mod
					group by cogr_twindow_id
						,	tiwi_ddf
						,	mod_cnt
						,	tiwi_sort
					order by tiwi_sort
						,	tiwi_ddf
					)
        LOOP
 
			ccm_structure.build_summary_totals	(l_rec.twindow_id
												,l_rec.tiwi_ddf
												,nvl(l_rec.grp_credits, 0)
												,nvl(l_rec.grp_comp_credits, 0)
												,nvl(l_rec.grp_opt_credits, 0)
												,nvl(l_rec.grp_contact_hrs, 0)
												,nvl(l_rec.grp_contra_hrs, 0)
												,l_err_msg
												);
 
			l_mod_cnt := l_rec.mod_cnt;												
 
		end loop;
 
		APEX_UTIL.SET_SESSION_STATE('P3_BAR_HEIGHT', l_mod_cnt);
 
	exception
 
		WHEN OTHERS
        THEN
            htp.P('Unexpectd error at level B - build course structure summary for report. Please contact system admin with the following details:'||chr(10)||SQLCODE||' --- '||SQLERRM);
 
	end course_report_summary_totals;
 
--------------------------------------------------------------------------------------------------------------------------------	
--------------------------------------------------------------------------------------------------------------------------------
 
	procedure	build_module_list	(p_dataset_id	in	number)
	is
 
	BEGIN
 
		--the following code creates the actual module rows            
		FOR l_rec IN    (SELECT '<tr class="ccm_own_'||modu.currect_owner_id||' ccm_twi_'||modu.currect_twindow_id||' own_show sem_show sch_show" title="'||lower(modu.module_code_ddf)||' '||lower(modu.module_title_ddf)||'">
								<td class="px-2 py-2 mod_code" title="'||modu.module_title_ddf||'" style="width:30%;"><span class="mod_code_ddf">'||modu.module_code_ddf||'</span><span class="mod_curr_id">'||modu.currect_module_id||'</span></td>
								<td class="px-2 py-2" style="width:14%;">'||tiwi.short_ddf||'</td>
								<td class="px-2 py-2" style="width:20%;">'||nvl(modu.status, '')||'</td>
								<td class="px-2 py-2 mod_credit" style="width:23%;"><span class="full_credit">'
								||nvl(modu.credits, 0)
								||case when count(mocs.credits) > 1
									   then ' ('||listagg(mocs.credits, ', ') within group (order by nvl(motw.cust_sort, 1), motw.full_ddf)||')'
									   end
								||'</span>'
								||listagg('<span class="split_credit '||mocs.currect_twindow_id||'_credit">'||mocs.credits||'</span>', ' ') within group (order by nvl(motw.cust_sort, 1), motw.full_ddf)
								||'</td>
								<td class="px-2 py-2 mod_hours" title="'||nvl(most.recent_year_total, 0)||' (0)<span class=&quot;prev_students is-hidden&quot;>&nbsp;|&nbsp;'||nvl(most.prev_year_1_total, 0)||' (0)&nbsp;|&nbsp;'||nvl(most.prev_year_2_total, 0)||' (0)</span>" style="width:13%;">'
								||nvl(modu.weekly_hours, 0)
								||'</td>
								</tr>'		module_row
						FROM	((		modules       	modu
								join	time_windows	tiwi
								on		modu.currect_twindow_id	=	tiwi.currect_twindow_id
								)
								left outer join	
								(		module_credit_split		mocs
								join	time_windows			motw
								on		mocs.currect_twindow_id	=	motw.currect_twindow_id
								)
								on		modu.currect_module_id	=	mocs.currect_module_id
								)
								left outer join	module_student_totals	most		
								on		modu.currect_module_id	=	most.currect_module_id		
						WHERE   modu.currect_dataset_id	=   p_dataset_id
						group by modu.currect_module_id
							,	modu.currect_owner_id
							,	modu.currect_twindow_id
							,	modu.module_code_ddf
							,	modu.module_title_ddf
							,	nvl(modu.status, '')
							,	nvl(modu.credits, 0)
							,	nvl(modu.weekly_hours, 0)
							,	nvl(modu.cust_sort, 1)
							,	tiwi.short_ddf
							,	nvl(most.recent_year_total, 0)
							,	nvl(most.prev_year_1_total, 0)
							,	nvl(most.prev_year_2_total, 0)
						order by nvl(modu.cust_sort, 1)
							,	modu.module_code_ddf
						)
		LOOP
 
			htp.P(l_rec.module_row);
 
		END LOOP;    
 
    EXCEPTION
 
        WHEN OTHERS
        THEN
            htp.P('Unexpectd error at level B - Build module list. Please contact system admin with the following details:'||chr(10)||SQLCODE||' --- '||SQLERRM);
 
	END build_module_list;
 
END ccm_structure;
