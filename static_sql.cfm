<!--- FILE:		static_sql.cfm --->
<!--- VERSION:	2010.08.12.Craig M. Rosenblum --->
<!--- PURPOSE:	Generate Static Sql Db Documentation --->

<head>
<title>CF_SQLDOC</title>
<style type="text/css">
body {
font-family:verdana;
font-size:9pt;
}
td {
font-family:verdana;
font-size:9pt;
}
th {
font-family:verdana;
font-size:9pt;
background:#d3d3d3;
}
table
{
background:#d3d3d3;
}
tr
{
background:#ffffff;
}
</style>
</head>

<body>

<!--- required parameters for all steps to work --->
<cfparam name="datasource" default="your_datasource_name">
<cfparam name="start_path" default="your_folder_path_where_sql_docs_be_stored\sqldoc">
<cfparam name="url_path" default="your_url_for_where_sql_docs_be_displayed">
<cfparam name="css_path" default="#url_path#/css">
<cfparam name="js_path" default="#url_path#/js">
<cfparam name="doc_path" default="#url_path#/sqldoc">
<cfparam name="image_path" default="#url_path#/images">

<!--- create object to access static_sql methods/functions --->
<cfset database_builder = createobject("component","static_db") />
<cfset table_builder = createobject("component","static_tables") />
<cfset view_builder = createobject("component","static_views") />
<cfset procedure_builder = createobject("component","static_procedures") />

<!--- step 1. create folders for each database if not already existing --->
<cfquery name='dbqry' datasource='#dsn#' cachedwithin="#createtimespan(0,0,30,0)#">
	select a.name, b.table_name, object_id(b.table_name) as object_id
	from master..sysdatabases a
		inner join information_schema.tables b on b.table_catalog = a.name
	order by a.name asc, b.table_name asc
</cfquery>

<cfquery name="dbs" dbtype="query">
	select name
	from dbqry
	group by name
	order by name asc
</cfquery>

<cfloop query='dbs'>

	<!--- get lowercase version of name and check if folder exists --->
	<cfset db_name = lcase(dbs.name)>
	
	<!--- setup directories --->
	<cfset db_dir = '#start_path#\#db_name#' />
	<cfset tbl_dir = '#start_path#\#db_name#\tables' />
	<cfset vw_dir = '#start_path#\#db_name#\views' />
	<cfset proc_dir = '#start_path#\#db_name#\procedures' />
	
	<!--- check if folder exists --->
	<cfif not DirectoryExists(db_dir)>
	
		<!--- create the db root directory --->
		<cfdirectory action='create' directory='#db_dir#'>
	
	</cfif>
	<cfif not DirectoryExists(tbl_dir)>
	
		<!--- create the db root directory --->
		<cfdirectory action='create' directory='#tbl_dir#'>
	
	</cfif>
	<cfif not DirectoryExists(vw_dir)>
	
		<!--- create the db root directory --->
		<cfdirectory action='create' directory='#vw_dir#'>
	
	</cfif>
	<cfif not DirectoryExists(proc_dir)>
	
		<!--- create the db root directory --->
		<cfdirectory action='create' directory='#proc_dir#'>
	
	</cfif>
	
	<!--- create db index page now --->
	<cfset build_db_index = database_builder.build_db_index('#dbs.name#','#db_dir#\index.html','#dsn#','#css_path#','#js_path#','#doc_path#') />
	
	<!--- create table index page now --->
	<cfset build_tables_index = table_builder.build_tables_index('#dbs.name#','#tbl_dir#\index.html','#dsn#','#css_path#','#js_path#','#doc_path#') />

	<!--- build individual table pages --->
	<cfquery name="tbl_list" dbtype="query">
		select table_name, object_id
		from dbqry
		where name = '#dbs.name#'
		order by table_name asc
	</cfquery>
	
	<cfloop query='tbl_list'>
	
	
		<!--- call cfc to build this table page --->
		<cfset build_tbl_page = table_builder.build_table_page('#dbs.name#','#tbl_dir#\#lcase(tbl_list.table_name)#.html','#tbl_list.table_name#',#tbl_list.object_id#,'#dsn#','#css_path#','#js_path#','#doc_path#','#image_path#') />
		<cfflush>
		
	</cfloop>

	<!--- call function to build main views page --->
	<cfset build_main_views = view_builder.build_views_index('#dbs.name#','#vw_dir#\index.html','#dsn#','#css_path#','#js_path#','#doc_path#') />

	<!--- build views page for each --->
	<cfquery name="vws" datasource="#dsn#" cachedwithin="#createtimespan(0,0,30,0)#">
		use #dbs.name#
		select table_name
		from information_schema.views
		order by table_name asc
	</cfquery>
	
	<cfloop query="vws">
	
		<!--- build each views page --->
		<cfset build_views_page = view_builder.build_views_page('#dbs.name#','#vws.table_name#','#vw_dir#\#lcase(vws.table_name)#.html','#dsn#','#css_path#','#js_path#','#doc_path#') />
	
	</cfloop>
	
	<!--- build all procedure pages --->
	
	<!--- step 1. build main procedure page --->
	<cfset build_proc_index = procedure_builder.build_procs_index('#dbs.name#','#proc_dir#\index.html','#dsn#','#css_path#','#js_path#','#doc_path#') />
	
	<!--- step 2. query & loop all procedures --->
	<cfquery name="procs" datasource="#dsn#">
		use #db_name#
		select specific_name
		from information_schema.routines
		where specific_name like 'usp%'
		order by specific_name asc
	</cfquery>
	
	<!--- begin loop --->
	<cfloop query="procs">
	
		<!--- get filename for new procedure page --->
		<cfset file_path = "#proc_dir#\#procs.specific_name#.html">
	
		<!--- build this procedure page --->
		<cfset build_path = procedure_builder.build_proc_page('#dbs.name#','#procs.specific_name#','#file_path#','#dsn#','#css_path#','#js_path#','#doc_path#') />
		
	</cfloop>
	<!--- end loop --->

	<!--- summary of built pages --->
	<cfoutput>
	Building for #dbs.name# database:
	<ul>
		<li>Table Pages Built: [#tbl_list.recordcount#]</li>
		<li>View Pages Built: [#vws.recordcount#]</li>
		<li>Procedure Pages Built: [#procs.recordcount#]</li>
	</ul>
	</cfoutput>

</cfloop>

