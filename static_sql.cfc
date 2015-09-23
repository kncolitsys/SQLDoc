<cfcomponent displayname="static_sql" hint="Generates different html needed to create static data dictionaity">

	<cffunction name="build_db_index" returntype="string" output="false" access="remote">
		<cfargument name="db_name" type="string" required="yes">
		<cfargument name="file_path" type="string" required="yes">
		<cfargument name="dsn" type="string" required="yes">
		<cfargument name="css_path" type="string" required="yes">
		<cfargument name="js_path" type="string" required="yes">
		<cfargument name="doc_path" type="string" required="yes">

		<cfparam name="return_string" default="">
		
		<!--- load the css to be displayed --->
		<cfset myCSS = loadCSS() />
		
		<!--- get tree string --->
		<cfset mytree = tree('#dsn#','#doc_path#') />
		
		<!--- get database info --->
		<cfset my_db_info = db_info('#db_name#','#dsn#') />
		
		<!--- get database files --->
		<cfset my_db_files = db_files('#db_name#','#dsn#') />


		<cfset db_index="
<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml' lang='en' xml:lang='en'>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1' />
<title>#db_name# Index Page</title>
<style type='text/css'>#myCSS#</style>
<link rel='stylesheet' type='text/css' media='all' href='#css_path#/iqcontent.css' />
<link rel='stylesheet' type='text/css' media='all' href='#js_path#/jquery-treeview/jquery.treeview.css' />
<script type='text/javascript' src='http://ajax.googleapis.com/ajax/libs/jquery/1.2/jquery.min.js'></script>
<script type='text/javascript' src='#js_path#/jquery-treeview/jquery.treeview.js'></script>
<script type='text/javascript' src='#js_path#/jquery-treeview/lib/jquery.cookie.js'></script>
<script type='text/javascript'> 
$(function() {
	$('##table_tree').treeview({
		collapsed: false,
		animated: 'fast',
		control: '##sidetreecontrol',
		persist: 'location',
		unique:  true
	});
})

</script> 

</head>

<body>

<div id='framecontent'>
	<div class='innertube'>
	#mytree#
	</div>
</div>
<div id='maincontent'>
	<div class='innertube'>
		<a name='top'></a>
		<div id='top' style='position:fixed;top:2;left:2;background-color:white;width:53%'>
		<a href='#doc_path#/#db_name#/index.html'>#db_name#</a>&nbsp;/&nbsp;Database Properties
		</div>
		<br/><br/>
		#my_db_info#<br/>
		#my_db_files#<br/>
	</div>
</div>

</body>
</html>
		">
		
		<!--- create database index page now --->		
		<cffile action="write" file="#file_path#" output="#db_index#">


	</cffunction>


	<cffunction name="db_info" returntype="string" output="false" access="remote">
		<cfargument name="db_name" type="string" required="yes">
		<cfargument name="dsn" type="string" required="yes">

		<cfquery name="get_size" datasource="#dsn#">
			exec sp_spaceused
		</cfquery>

		<cfquery name="get_info" datasource="#dsn#">
			sp_helpdb '#db_name#'
		</cfquery>

		<cfquery name="info" datasource="#dsn#">
			select owner, recovery, status, collation, version
			from vw_db_info
			where name = <cfqueryparam value="#db_name#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		<cfparam name="return_string" default="">
		
		<cfif db_name gt "">
		
			<cfset return_string = "
		<a name='db_info'></a>
		<table border='0' cellspacing='1' cellpadding='2' width='750px'>
		<caption><b>Table:[dbo].[#db_name#]</b> - Database Properties</caption> 
		<thead>
		<tr>
			<th>Sr.</th>
			<th>Property</th>
			<th>Value</th>
		</tr>
		</thead>
		<tfoot> 
		<tr> 
			<th scope='row'>Total</th> 
			<td colspan='4'>6 Properties</td> 
		</tr> 
		</tfoot> 
		<tbody>
		<tr>
			<td width='20px' align='center'>1</td>
			<td width='150px'>Name</td>
			<td width='150px'>#db_name#</td>
		</tr>
		<tr>
			<td width='20px' align='center'>2</td>
			<td width='150px'>Owner</td>
			<td width='150px'>#info.owner#</td>
		</tr>
		<tr>
			<td width='20px' align='center'>3</td>
			<td width='150px'>Collation</td>
			<td width='150px'>#info.collation#</td>
		</tr>
		<tr>
			<td width='20px' align='center'>4</td>
			<td width='150px'>Size</td>
			<td width='150px'>#get_size.database_size#</td>
		</tr>
		<tr>
			<td width='20px' align='center'>5</td>
			<td width='150px'>Size</td>
			<td width='150px'>#get_info.created#</td>
		</tr>
		<tr>
			<td width='20px' align='center'>6</td>
			<td width='150px'>Version</td>
			<td width='150px'>#info.version#</td>
		</tr>
		</tbody>
		</table>
		<br/>">
					
		</cfif>

		<cfreturn return_string />

	</cffunction>

	<cffunction name="db_exp" returntype="string" output="false" access="remote">
		<cfargument name="db_name" type="string" required="yes">

		<cfparam name="return_string" default="">

		<!--- get any extended properties --->
		

		<cfreturn return_string />

	</cffunction>
	
	<cffunction name="db_files" returntype="string" output="true" access="remote">
		<cfargument name="db_name" type="string" required="yes">
		<cfargument name="dsn" type="string" required="yes">

		<cfparam name="return_string" default="">

		<!--- get db file and log file info --->
		<cfquery name="get_files" datasource="#dsn#">
			use #db_name#
			select name, physical_name as filename, size, max_size,growth, type_desc as usage
			from sys.database_files
		</cfquery>

		<cfif get_files.recordcount gt 0>

			<cfset return_string = "
		<a name='db_files'></a>
		<table border='0' cellspacing='1' cellpadding='2' width='750px'>
		<caption><b>Table:[dbo].[#db_name#]</b> - File Sizes</caption> 
		<thead>
		<tr>
			<th>Sr.</th>
			<th>Name</th>
			<th>Filename</th>
			<th>Size</th>
			<th>MaxSize</th>
			<th>Growth</th>
			<th>Usage</th>
		</tr>
		</thead>
		<tfoot> 
		<tr> 
			<th scope='row'>Total</th> 
			<td colspan='6'>2 Files</td> 
		</tr> 
		</tfoot> 
		<tbody>">
			<cfloop query="get_files">
			
			<cfset return_string = "#return_string#
		<tr>
			<td width='20px' align='center'>1</td>
			<td width='150px'>#get_files.name#</td>
			<td width='150px'>#get_files.filename#</td>
			<td width='150px'>#get_files.size#</td>
			<td width='150px'>#get_files.max_size#</td>
			<td width='150px'>#get_files.growth#</td>
			<td width='150px'>#get_files.usage#</td>
		</tr>
			">
			</cfloop>
			<cfset return_string="#return_string#
			</tbody>
		</table>
		<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>">

		
		</cfif>
		

		<cfreturn return_string />

	</cffunction>
	

	<cffunction name="loadCSS" returntype="string" output="false" access="remote">
	
		<cfset return_string = "
##framecontent {
	position:absolute;
	top:0;
	bottom:0;
	left:0;
	width:210px;
	height:100%;
	background:##FFF;
	color:##FFF;
	border-right:1px solid ##000;
	text-align:center;
	font-size:10px;
	overflow:auto;
}

##maincontent {
	position:fixed;
	top:0;
	left:200px;
	right:0;
	bottom:0;
	overflow:auto;
	background:##fff;
}

* html ##maincontent {
	height:100%;
	width:100%;
}

* html body {
	padding:0 0 0 200px;
}

.innertube {
	margin:15px;
}

a {
	color:blue;
}

a:hover {
	color:##7bc4f4;
}

body {
	border:0;
	overflow:hidden;
	height:100%;
	max-height:100%;
	margin:0;
	padding:0;
}

table {
	background:##d3d3d3;
}

td,body,td {
	font-family:verdana;
	font-size:9pt;
}

th {
	font-family:verdana;
	font-size:9pt;
	background:##d3d3d3;
}

tr {
	background:##ffffff;
}
">

		<cfreturn return_string />

	</cffunction>

	<cffunction name="tree" returntype="string" output="true" access="remote">
		<cfargument name="dsn" type="string" required="yes">
		<cfargument name="doc_path" type="string" required="yes">
	
		<cfparam name="return_string" default="">

		<cfquery name='dbs' datasource='#dsn#'>
			SELECT name
			FROM master..sysdatabases
		</cfquery>

		<cfset return_string = "
		<div id='sidetreecontrol' style='margin-left:-2px;'><a href='?##'>Collapse All</a> | <a href='?##'>Expand All</a></div>
		Database Documentation
		<ul id='table_tree' style='font-size:10px;text-align:left;;margin-left:-2px;'>
		">
		<!--- add list of databases with links here --->
		<cfloop query="dbs">

			<!--- get list of alpha tables for this database --->
			<cfquery name="tbls" datasource="#dsn#" cachedwithin="#createtimespan(0,0,30,0)#">
				use #dbs.name#
				select table_name
				from information_schema.tables
				where table_type = 'base table'
				order by table_name asc
			</cfquery>

			<cfset return_string="#return_string#<li style='font-size:10px;margin-left:-5px;'><a href='#doc_path#/#lcase(dbs.name)#/index.html'>#dbs.name#</a>
			<ul>
			<li><a href='#doc_path#/#lcase(dbs.name)#/tables/index.html'>Tables</a>
			<ul>
			">

			<cfloop query="tbls">
				<cfset return_string="#return_string#<li style='font-size:8px;'><a href='#doc_path#/#lcase(dbs.name)#/tables/#lcase(tbls.table_name)#.html'>#tbls.table_name#</a></li>">
			</cfloop>
			<cfset return_string = "#return_string#</ul> </li>">
			
			<!--- get list of views for this database --->
			<cfquery name="vws" datasource="#dsn#" cachedwithin="#createtimespan(0,0,30,0)#">
				use #dbs.name#
				select table_name
				from information_schema.views
				order by table_name asc
			</cfquery>

			<cfset return_string="#return_string#
			<li><a href='#doc_path#/#lcase(dbs.name)#/views/index.html'>Views</a>
			<ul>
			">

			<cfloop query="vws">
				<cfset return_string="#return_string#<li style='font-size:8px;'><a href='#doc_path#/#lcase(dbs.name)#/views/#lcase(vws.table_name)#.html'>#vws.table_name#</a></li>">
			</cfloop>
			<cfset return_string = "#return_string#</ul> </li>">


			<!--- get list of procedures for this database --->
			<cfquery name="procs" datasource="#dsn#" cachedwithin="#createtimespan(0,0,30,0)#">
				use #dbs.name#
				select specific_name as table_name
				from information_schema.ROUTINES
				where routine_name like 'usp%'
				order by specific_name asc
			</cfquery>

			<cfset return_string="#return_string#
			<li><a href='##'>Procedures</a>
			<ul>
			">

			<cfloop query="procs">
				<cfset return_string="#return_string#<li style='font-size:8px;'><a href='#doc_path#/#lcase(dbs.name)#/procedures/#lcase(procs.table_name)#.html'>#procs.table_name#</a></li>">
			</cfloop>
			<cfset return_string = "#return_string#</ul> </li>">


		</cfloop>

		<!--- and end of left nav and start of main content area --->
		<cfset return_string="#return_string#</ul></li></ul>">

		<cfreturn return_string />

	</cffunction>

</cfcomponent>