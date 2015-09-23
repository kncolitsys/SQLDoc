<cfcomponent displayname="static_procedures" hint="Generates different html needed to create static views data dictionaity">
	<cffunction name="build_procs_index" returntype="string" output="false" access="remote">
		<cfargument name="db_name" type="string" required="yes">
		<cfargument name="file_path" type="string" required="yes">
		<cfargument name="dsn" type="string" required="yes">
		<cfargument name="css_path" type="string" required="yes">
		<cfargument name="js_path" type="string" required="yes">
		<cfargument name="doc_path" type="string" required="yes">
		
		<cfparam name="return_string" default="">
		
		<!--- load the css to be displayed --->
		<cfset my_loadCSS = loadCSS() />
		
		<!--- get tree string --->
		<cfset mytree = tree('#dsn#','#doc_path#') />

		<!--- get proc index info from cfc --->
		<cfset proc_text = proc_index('#db_name#','#dsn#','#doc_path#') />
		
		<cfset proc_page = "
<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml' lang='en' xml:lang='en'>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1' />
<title>[#db_name#].[dbo].[Views]</title>
<style type='text/css'>#my_loadCSS#</style>
<link rel='stylesheet' type='text/css' media='all' href='#css_path#/iqcontent.css' />
<link rel='stylesheet' type='text/css' media='all' href='#js_path#/jquery-treeview/jquery.treeview.css' />
<script type='text/javascript' src='http://ajax.googleapis.com/ajax/libs/jquery/1.2/jquery.min.js'></script>
<script type='text/javascript' src='#js_path#/jquery-treeview/lib/jquery.cookie.js'></script>
<script type='text/javascript' src='#js_path#/jquery-treeview/jquery.treeview.js'></script>
<script type='text/javascript' src='#js_path#/jquery-ui-1.7.2.custom.min.js'  language='javascript'></script>


<script type='text/javascript'> 
$(function() {
	$('##table_tree').treeview({
		collapsed: true,
		animated: 'medium',
		control:'##sidetreecontrol',
		persist: 'location'
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
<a href='#doc_path#/#db_name#/index.html'>#db_name#</a>&nbsp;/&nbsp;<a href='#doc_path#/#db_name#/procedures/index.html'><b>Procedures</b></a>
</div>
<br/><br/>
#proc_text#<br/>
</div>
</div>


</body>
</html>
		">
		
		<!--- create main views page --->
		<cffile action="write" file="#file_path#" output="#proc_page#">

	</cffunction>

	<cffunction name="build_proc_page" returntype="string" output="false" access="remote">
		<cfargument name="db_name" type="string" required="yes">
		<cfargument name="proc_name" type="string" required="yes">
		<cfargument name="file_path" type="string" required="yes">
		<cfargument name="dsn" type="string" required="yes">
		<cfargument name="css_path" type="string" required="yes">
		<cfargument name="js_path" type="string" required="yes">
		<cfargument name="doc_path" type="string" required="yes">

		<!--- load the css to be displayed --->
		<cfset myCSS = loadCSS() />

		<!--- get tree string --->
		<cfset mytree = tree('#dsn#','#doc_path#') />
		
		<cfparam name="proc_content" default="">
		
		<!--- get proc info --->
		<cfset my_proc_info = proc_info('#db_name#','#proc_name#','#dsn#') />
		<cfset my_proc_params = proc_params('#db_name#','#proc_name#','#dsn#') />
		<cfset my_proc_sql = proc_sql('#db_name#','#proc_name#','#dsn#') />
		
		<cfif my_proc_info gt "">
			<cfif proc_content gt "">
				<cfset proc_content = "#proc_content##my_proc_info#">
			<cfelse>
				<cfset proc_content = my_proc_info>
			</cfif>
		</cfif>

		<cfif my_proc_params gt "">
			<cfif proc_content gt "">
				<cfset proc_content = "#proc_content##my_proc_params#">
			<cfelse>
				<cfset proc_content = my_proc_params>
			</cfif>
		</cfif>

		<cfif my_proc_sql gt "">
			<cfif proc_content gt "">
				<cfset proc_content = "#proc_content##my_proc_sql#">
			<cfelse>
				<cfset proc_content = my_proc_sql>
			</cfif>
		</cfif>
		


<cfset proc_string="
<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml' lang='en' xml:lang='en'>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1' />
<title>[#db_name#].[dbo].[#proc_name#]</title>
<style type='text/css'>#myCSS#</style>
<link rel='stylesheet' type='text/css' media='all' href='#css_path#/iqcontent.css' />
<link rel='stylesheet' type='text/css' media='all' href='#js_path#/jquery-treeview/jquery.treeview.css' />
<script type='text/javascript' src='http://ajax.googleapis.com/ajax/libs/jquery/1.2/jquery.min.js'></script>
<script type='text/javascript' src='#js_path#/jquery-treeview/lib/jquery.cookie.js'></script>
<script type='text/javascript' src='#js_path#/jquery-treeview/jquery.treeview.js'></script>


<script type='text/javascript'> 
$(function() {
	$('##table_tree').treeview({
		collapsed: false,
		animated: 'fast',
		control: '##sidetreecontrol',
		persist: 'cookie',
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
		<a href='#doc_path#/#db_name#/index.html'>#db_name#</a>&nbsp;/&nbsp;<a href='#doc_path#/#lcase(db_name)#/procedures/index.html'>Procedures</a>&nbsp;/&nbsp;<b>#proc_name#</b>
		<br/><br/>
		#proc_content#<br/>
	</div>
</div>
</body>
</html>">

		<!--- erase table content so it can not be repopulated --->
		<cfset proc_content = "">
		

		<!--- step 7. write this to html file in db/table folder --->
		<cffile action="write" file="#file_path#" output="#proc_string#">

	</cffunction>
	
	<cffunction name="proc_index" returntype="string" output="false" access="remote">
		<cfargument name="db_name" type="string" required="yes">
		<cfargument name="dsn" type="string" required="yes">
		<cfargument name="doc_path" type="string" required="yes">
		
		<cfparam name="return_string" default="">

		<cfquery name="procs" datasource="#dsn#">
			use #db_name#
			select specific_schema, specific_name, created, last_altered
			from information_schema.routines
			where specific_name like 'usp%'
			order by specific_name asc
		</cfquery>
		
		<cfif procs.recordcount gt 0>
			<cfset return_string = "
			<a name='procedures'></a>
			<table border='0' cellspacing='1' cellpadding='2' width='750px'>
			<caption><b>Stored:[dbo].[#procs.specific_name#]</b> Procedures</caption> 
			<thead>
			<tr>
				<th>Sr.</th>
				<th>Schema</th>
				<th>Name</th>
				<th>Created</th>
				<th>Modified</th>
			</tr>
			</thead>
			<tfoot> 
			<tr> 
				<th scope='row'>Total</th> 
				<td colspan='4'>#procs.recordcount# procsews</td> 
			</tr> 
			</tfoot> 
			<tbody>">
			<cfloop query="procs">
			
			<cfset return_string="#return_string#
			<tr>
				<td width='20px' align='center'>#procs.currentrow#</td>
				<td width='150px'>#procs.specific_schema#</td>
				<td width='150px'><a href='#doc_path#/#lcase(db_name)#/procedures/#lcase(procs.specific_name)#.html'>#procs.specific_name#</a></td>
				<td width='150px'>#procs.created#</td>
				<td width='150px'>#procs.last_altered#</td>
			</tr>
			">
			
			</cfloop>
			
			<cfset return_string="#return_string#
			</tbody>
			</table>
			<br/>
			">
		</cfif>
		
		<cfreturn return_string />
	
	</cffunction>

	<cffunction name="proc_info" returntype="string" output="false" access="remote">			
		<cfargument name="db_name" type="string" required="yes">
		<cfargument name="proc_name" type="string" required="yes">
		<cfargument name="dsn" type="string" required="yes">
		
		<cfparam name="return_string" default="">
	
		<cfquery name="proc_details" datasource="#dsn#">
			use #db_name#
			select specific_schema, specific_name, created, last_altered
			from information_schema.routines
			where specific_name = <cfqueryparam value="#proc_name#" cfsqltype="CF_SQL_VARCHAR">
			order by specific_name asc
		</cfquery>
		
		<cfif proc_details.recordcount gt 0>
		
			<cfset return_string = "
			<a name='procedures'></a>
			<table border='0' cellspacing='1' cellpadding='2' width='750px'>
			<caption><b>Table:[dbo].[#proc_details.specific_name#]</b> - Information</caption> 
			<thead>
			<tr>
				<th>Sr.</th>
				<th>Name</th>
				<th>Created</th>
				<th>Modified</th>
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
				<td width='150px'>#proc_details.specific_name#</td>
				<td width='150px'>#proc_details.created#</td>
				<td width='150px'>#proc_details.last_altered#</td>
			</tr>
			</tbody>
			</table>
			<br/>
			">

		
		</cfif>
		
		<cfreturn return_string />
	
	</cffunction>

	<cffunction name="proc_params" returntype="string" output="false" access="remote">			
		<cfargument name="db_name" type="string" required="yes">
		<cfargument name="proc_name" type="string" required="yes">
		<cfargument name="dsn" type="string" required="yes">
		
		<cfparam name="return_string" default="">
	
		<cfquery name="proc_parameters" datasource="#dsn#">
			use #db_name#
			select name,parameter_name,data_type,parameter_mode,character_maximum_length
			from information_schema.parameters a
			inner join sys.objects b on a.specific_name = b.name
			where type ='p'
			and name = <cfqueryparam value="#proc_name#" cfsqltype="CF_SQL_VARCHAR">
			order by specific_name asc
		</cfquery>
		
		<cfif proc_parameters.recordcount gt 0>
		
			<cfset return_string = "
			<a name='procedures'></a>
			<table border='0' cellspacing='1' cellpadding='2' width='750px'>
			<caption><b>Table:[dbo].[#proc_name#]</b> - Parameters</caption> 
			<thead>
			<tr>
				<th>Sr.</th>
				<th>Name</th>
				<th>Type</th>
				<th>Flow</th>
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
				<td width='150px'>#proc_parameters.parameter_name#</td>
				<td width='150px'>#proc_parameters.data_type#</td>
				<td width='150px'>#proc_parameters.parameter_mode#</td>
			</tr>
			</tbody>
			</table>
			<br/>
			">

		
		</cfif>
		
		<cfreturn return_string />
	
	</cffunction>

	<cffunction name="proc_sql" returntype="string" output="false" access="remote">			
		<cfargument name="db_name" type="string" required="yes">
		<cfargument name="proc_name" type="string" required="yes">
		<cfargument name="dsn" type="string" required="yes">
		
		<cfparam name="return_string" default="">
	
		<cfquery name="proc_sqlstring" datasource="#dsn#">
			use #db_name#
			select modu.definition
			from information_schema.routines a
			INNER JOIN sys.objects obj on obj.name = a.specific_name
			inner join sys.sql_modules modu on modu.object_id = obj.object_id
			where a.specific_name = <cfqueryparam value="#proc_name#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		<cfif proc_sqlstring.recordcount gt 0>
		
			<cfset return_string = "
			<a name='procedures'></a>
			<h2>SQL Script</h2>
			<pre class='brush: sql; ruler:true;' style='border:1px solid ##CCC;margin-left:5px;margin-top:5px;padding:5px;background:F8F8F8;'>#proc_sqlstring.definition#</pre>
			<br/>
			">

		
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
			<li><a href='#doc_path#/#lcase(dbs.name)#/procedures/index.html'>Procedures</a>
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