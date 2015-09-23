<cfcomponent displayname="static_views" hint="Generates different html needed to create static views data dictionaity">

	<cffunction name="build_views_index" returntype="string" output="false" access="remote">
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

		<!--- get view index info from cfc --->
		<cfset vi_text = view_index('#db_name#','#dsn#','#doc_path#') />
		
		<cfset vi_page = "
<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml' lang='en' xml:lang='en'>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1' />
<title>[#db_name#].[dbo].[Views]</title>
<style type='text/css'>#myCSS#</style>
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
<a href='#doc_path#/#db_name#/index.html'>#db_name#</a>&nbsp;/&nbsp;<a href='#doc_path#/#db_name#/views/index.html'><b>Views</b></a>
</div>
<br/><br/>
#vi_text#<br/>
</div>
</div>


</body>
</html>
		">
		
		<!--- create main views page --->
		<cffile action="write" file="#file_path#" output="#vi_page#">

	</cffunction>
	
	<cffunction name="build_views_page" returntype="string" output="false" access="remote">
		<cfargument name="db_name" type="string" required="yes">
		<cfargument name="view_name" type="string" required="yes">
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

		<!--- get the view info --->
		<cfset vw_info = view_info('#db_name#','#view_name#','#dsn#','#doc_path#') />

		<cfset return_string = "
<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml' lang='en' xml:lang='en'>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1' />
<title>[#dbs.name#].[dbo].[#view_name#]</title>
<style type='text/css'>#myCSS#</style>
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
			<a href='#doc_path#/#dbs.name#/index.html'>#dbs.name#</a>&nbsp;/&nbsp;<a href='#doc_path#/#lcase(dbs.name)#/views/index.html'>Views</a>&nbsp;/&nbsp;#view_name#
		</div>
		<br/><br/>
		#vw_info#
	</div>
</div>

</body>
</html>
		">
		<!--- step 7. write this to html file in db/table folder --->
		<cffile action="write" file="#file_path#" output="#return_string#">

	</cffunction>

	<cffunction name="view_index" returntype="string" output="false" access="remote">
		<cfargument name="db_name" type="string" required="yes">
		<cfargument name="dsn" type="string" required="yes">
		<cfargument name="doc_path" type="string" required="yes">
		
		<cfparam name="return_string" default="">

		<cfquery name="vi" datasource="#dsn#">
			use #db_name#
			select a.table_schema, a.table_name, b.create_date
			from information_schema.views a inner join sys.views b on a.table_name = b.name
			order by a.table_name asc
		</cfquery>
		
		<cfif vi.recordcount gt 0>
			<cfset return_string = "
			<a name='views'></a>
			<table border='0' cellspacing='1' cellpadding='2' width='750px'>
			<caption><b>Table:[dbo].[#db_name#]</b> Views</caption> 
			<thead>
			<tr>
				<th>Sr.</th>
				<th>Schema</th>
				<th>Name</th>
				<th>Created</th>
			</tr>
			</thead>
			<tfoot> 
			<tr> 
				<th scope='row'>Total</th> 
				<td colspan='4'>#vi.recordcount# Views</td> 
			</tr> 
			</tfoot> 
			<tbody>">
			<cfloop query="vi">
			
			<cfset return_string="#return_string#
			<tr>
				<td width='20px' align='center'>#vi.currentrow#</td>
				<td width='150px'>#vi.table_schema#</td>
				<td width='150px'><a href='#doc_path#/#lcase(db_name)#/views/#lcase(vi.table_name)#.html'>#vi.table_name#</a></td>
				<td width='150px'>#vi.create_date#</td>
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
			

	<cffunction name="view_info" returntype="string" output="false" access="remote">
		<cfargument name="db_name" type="string" required="yes">
		<cfargument name="view_name" type="string" required="yes">
		<cfargument name="dsn" type="string" required="yes">
		<cfargument name="doc_path" type="string" required="yes">
		
		<cfparam name="return_string" default="">
		
		<cfquery name="vw_details" datasource="#dsn#">
			use #db_name#
			select  a.table_schema, a.table_name, a.view_definition, b.create_date, b.modify_date
			from information_schema.views a inner join sys.views b on a.table_name = b.name
			where a.table_name = <cfqueryparam value="#view_name#" cfsqltype="CF_SQL_VARCHAR">
			order by a.table_name asc
		</cfquery>
		
		<cfif vw_details.recordcount gt 0>
		
			<cfset return_string = "
			<a name='views'></a>
			<table border='0' cellspacing='1' cellpadding='2' width='750px'>
			<caption><b>Table:[dbo].[#vw_details.table_name#]</b> - Information</caption> 
			<thead>
			<tr>
				<th>Sr.</th>
				<th>Name</th>
				<th>Schema</th>
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
				<td width='150px'>#vw_details.table_name#</td>
				<td width='150px'>#vw_details.table_schema#</td>
				<td width='150px'>#vw_details.create_date#</td>
				<td width='150px'>#vw_details.modify_date#</td>
			</tr>
			</tbody>
			</table>
			<br/>
			<h2>SQL Script</h2>
			<pre class='brush: sql; ruler:true;' style='border:1px solid ##CCC;margin-left:5px;margin-top:5px;padding:5px;background:F8F8F8;'>#vw_details.view_definition#</pre>
			<br/>
			">
			
			<!--- look up tables inside each view --->
			<cfquery name="tbl_vws" datasource="#dsn#">
				use #db_name#
				select table_name
				from information_schema.view_table_usage
				where view_name = <cfqueryparam value="#vw_details.table_name#" cfsqltype="CF_SQL_VARCHAR">
				order by table_name asc
			</cfquery>
			
			<cfif tbl_vws.recordcount gt 0>
				
				<cfset return_string="#return_string#
				<h2>Tables Listed in the View Above</h2>
				<pre style='border:1px solid ##CCC;margin-left:5px;margin-top:5px;padding:5px;background:F8F8F8;'>
				">
				
				<cfloop query="tbl_vws">
					<cfset return_string = "#return_string#<a href='#doc_path#/#lcase(db_name)#/tables/#lcase(tbl_vws.table_name)#.html'>#tbl_vws.table_name#</a>&nbsp;">
				</cfloop>
				
				<cfset return_string = "#return_string#</pre>">
			
			</cfif>
		
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