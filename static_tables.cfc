<cfcomponent displayname="static_tables" hint="Generates different html needed to create static tables data dictionaity">

	<cfsetting REQUESTTIMEOUT="65000">

	<cffunction name="build_table_page" returntype="string" output="true" access="remote">
		<cfargument name="db_name" type="string" required="yes">
		<cfargument name="file_path" type="string" required="yes">
		<cfargument name="tbl_name" type="string" required="yes">
		<cfargument name="object_id" type="numeric" required="yes">
		<cfargument name="dsn" type="string" required="yes">
		<cfargument name="css_path" type="string" required="yes">
		<cfargument name="js_path" type="string" required="yes">
		<cfargument name="doc_path" type="string" required="yes">
		<cfargument name="image_path" type="string" required="yes">
		
		<cfparam name="tbl_content" default="">
		<cfparam name="tbl_info" default="">
		<cfparam name="my_reference_keys" default="">
		<cfparam name="my_constraints" default="">
		<cfparam name="check_con" default="">
		
		<!--- load the css to be displayed --->
		<cfset myCSS = loadCSS() />

		<!--- get tree string --->
		<cfset mytree = tree('#dsn#','#doc_path#') />

		<!--- table object setup --->
		<cfset tbl_obj = createobject("component","static_tables") />
		
		<!--- step 1. get constraints --->
		<cfset my_constraints = tbl_obj.constraints('#db_name#',#object_id#,'#tbl_name#','#dsn#') />

		<!--- step 2. get check_constraints --->
		<cfset check_con = tbl_obj.check_constraints('#db_name#',#object_id#,'#tbl_name#','#dsn#') />

		<!--- step 3. get triggers --->
		<cfset my_triggers = tbl_obj.triggers('#db_name#',#object_id#,'#tbl_name#','#dsn#') />

		<!--- step 4. get indexes --->
		<cfset my_indexes = tbl_obj.indexes('#db_name#',#object_id#,'#tbl_name#','#dsn#') />

		<!--- step 5. get reference keys --->
		<cfset my_reference_keys = tbl_obj.ref_keys('#db_name#',#object_id#,'#tbl_name#','#dsn#') />

		<!--- step 6. get table info --->
		<cfset my_tbl_info = tbl_obj.table_info('#db_name#','#tbl_name#','#dsn#','#image_path#') />

		
<cfset table_string="
<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml' lang='en' xml:lang='en'>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1' />
<title>[#db_name#].[dbo].[#tbl_name#]</title>
<style type='text/css'>#myCSS#</style>
<link rel='stylesheet' type='text/css' media='all' href='#css_path#/iqcontent.css' />
<link rel='stylesheet' type='text/css' media='all' href='#js_path#/jquery-treeview/jquery.treeview.css' />
<script type='text/javascript' src='http://ajax.googleapis.com/ajax/libs/jquery/1.2/jquery.min.js'></script>
<script type='text/javascript' src='#js_path#/jquery-treeview/lib/jquery.cookie.js'></script>
<script type='text/javascript' src='#js_path#/jquery-treeview/jquery.treeview.js'></script>
<script type='text/javascript' src='#js_path#/syntaxhighlighter/scripts/shCore.js'></script>
<script type='text/javascript' src='#js_path#/syntaxhighlighter/scripts/shBrushSql.js'></script>


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
		<a href='#doc_path#/#db_name#/index.html'>#db_name#</a>&nbsp;/&nbsp;<a href='#doc_path#/#lcase(db_name)#/tables/index.html'>Tables</a>&nbsp;/&nbsp;<b>#tbl_name#</b>
		<br/><br/>
		#my_tbl_info#
		#my_reference_keys#
		#my_constraints#
		#check_con#
		#my_indexes#
		#my_triggers#
		<br/>
	</div>
</div>
</body>
</html>">

		<!--- reset values of incoming function data --->
		<cfset my_tbl_info = "">
		<cfset my_reference_keys = "">
		<cfset my_constraints = "">
		<cfset check_con = "">
		<cfset my_triggers = "">

		<!--- erase table content so it can not be repopulated --->
		<cfset tbl_content = "">

		<!--- step 7. write this to html file in db/table folder --->
		<cffile action="write" file="#file_path#" output="#table_string#">

	</cffunction>
	
	<cffunction name="build_tables_index" returntype="string" output="false" access="remote">
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
		
		<cfset tbl_qry = querynew("schema,table,row_count,data_size,index_size,created,modified")>
		
		<!--- query to get all important all tables information --->
		<cfquery name="all_tables" datasource="#dsn#" cachedwithin="#createtimespan(0,0,30,0)#">
			use #db_name#
			select a.table_schema, a.table_name, b.create_date, b.modify_date
			from  information_schema.tables a inner join sys.tables b on b.name = a.table_name
			order by a.table_schema asc, a.table_name asc
		</cfquery>
		
		
		<cfloop query="all_tables">
		
			<!--- query to get rowcount and other info --->
			<cfquery name="tbl_sizes" datasource="#dsn#" cachedwithin="#createtimespan(0,0,30,0)#">
			use #db_name#
			exec sp_spaceused #all_tables.table_name#
			</cfquery>
			
			<!--- add to new query --->
			<cfset temp = queryaddrow(tbl_qry) />
			<cfset temp = querysetcell(tbl_qry,'schema','#all_tables.table_schema#') />
			<cfset temp = querysetcell(tbl_qry,'table','#all_tables.table_name#') />
			<cfset temp = querysetcell(tbl_qry,'row_count','#tbl_sizes.rows#') />
			<cfset temp = querysetcell(tbl_qry,'data_size','#tbl_sizes.data#') />
			<cfset temp = querysetcell(tbl_qry,'index_size','#tbl_sizes.index_size#') />
			<cfset temp = querysetcell(tbl_qry,'created','#all_tables.create_date#') />
			<cfset temp = querysetcell(tbl_qry,'modified','#all_tables.modify_date#') />
			
		</cfloop>

		<cfset table_string = "
		<a name='tables'></a>
		<table border='0' cellspacing='1' cellpadding='2' width='750px'>
		<caption><b>Table:[dbo].[#db_name#]</b> All Tables</caption> 
		<thead>
		<tr>
			<th>Sr.</th>
			<th>Schema</th>
			<th>Name</th>
			<th>Row Count</th>
			<th>Data Size</th>
			<th>Index Size</th>
			<th>Created</th>
			<th>Modified</th>
		</tr>
		</thead>
		<tfoot> 
		<tr> 
			<th scope='row'>Total</th> 
			<td colspan='6'>#all_tables.recordcount# Tables</td> 
		</tr> 
		</tfoot> 
		<tbody>">

		
		<!--- lets build table main table --->
		<cfloop query="tbl_qry">

			<cfset table_string="#table_string#
			<tr>
				<td width='20px' align='center'>#tbl_qry.currentrow#</td>
				<td width='150px'>#tbl_qry.schema#</td>
				<td width='150px'><a href='#doc_path#/#lcase(db_name)#/tables/#lcase(tbl_qry.table)#.html'>#tbl_qry.table#</a></td>
				<td width='150px'>#tbl_qry.row_count#</td>
				<td width='150px'>#tbl_qry.data_size#</td>
				<td width='150px'>#tbl_qry.index_size#</td>
				<td width='150px' nowrap>#dateformat(tbl_qry.created,'mm/dd/yyyy')# #timeformat(tbl_qry.created,'hh:mm tt')#</td>
				<td width='150px' nowrap>#dateformat(tbl_qry.modified,'mm/dd/yyyy')# #timeformat(tbl_qry.modified,'hh:mm tt')#</td>
			</tr>
			">
			
		</cfloop>

		<cfset table_string="#table_string#
		</tbody>
		</table>
		<br/>
		">

		
		<!--- now let's build a table index page --->
		<cfset table_index = "
<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
<html xmlns='http://www.w3.org/1999/xhtml' lang='en' xml:lang='en'>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1' />
<title>[#db_name#].[dbo].[All Tables]</title>
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
<div id='top' style='position:fixed;top:2;left:2;background-color:white;width:53%'>
<a href='#doc_path#/#db_name#/index.html'>#db_name#</a>&nbsp;/&nbsp;<a href='#doc_path#/#db_name#/tables/index.html'><b>Tables</b></a>
</div>
<br/><br/>
#table_string#<br/>
</div>
</div>


</body>
</html>
		">
		
		<!--- create main views page --->
		<cffile action="write" file="#file_path#" output="#table_index#">
			
	</cffunction>

	<cffunction name="table_info" returntype="string" output="true" access="remote">
		<cfargument name="db_name" type="string" required="true" hint="the name of the database to look up constraints for">
		<cfargument name="tbl_name" type="string" required="true" hint="the object id of the table we need to look up for">
		<cfargument name="dsn" type="string" required="true" hint="datasource name">
		<cfargument name="image_path" type="string" required="true" hint="path for images shown for primary key.">
	
		<cfparam name="return_string" default="">

		<!--- get the following information about each column of this table
		primary key, foreign key, identity, name, datatyep, allow nulls, collation, references, default, computed, compute expression
		--->
		
		<cfquery name="table_info" datasource="#dsn#">
			select c.column_name as columnname,c.column_default,c.data_type,c.is_nullable,c.collation_name,c.character_maximum_length, c.ordinal_position,columnproperty(object_id(c.table_schema + '.' + c.table_name), c.column_name,'isidentity') as isidentity, case when constraint_name in (select name from sys.objects where type = 'pk') then 1 else 0 end as isprimarykey, case when constraint_name in (select name from sys.objects where type = 'f') then 1 else 0 end as isforeignkey
			from information_schema.tables t
				inner join information_schema.columns c on c.table_catalog = t.table_catalog and c.table_schema = t.table_schema and c.table_name = t.table_name
				left join information_schema.key_column_usage u on c.table_catalog = u.table_catalog and c.table_schema = u.table_schema and c.table_name = u.table_name and c.column_name = u.column_name
			where table_type = <cfqueryparam value='base table' cfsqltype="CF_SQL_VARHCAR">
			and c.table_name = <cfqueryparam value='#tbl_name#' cfsqltype='cf_sql_varchar'>
			order by c.ordinal_position
		</cfquery>
		
		<!--- first get column list --->
		<cfquery name="cols" dbtype="query">
			select distinct columnname
			from table_info
			order by ordinal_position asc
		</cfquery>
		
		<cfif table_info.recordcount gt 0>

			<cfset return_string = "
			<a name='tables'></a>
			<table border='0' cellspacing='1' cellpadding='2' width='750px'>
			<caption><b>Table:[dbo].[#tbl_name#]</b> Columns</caption> 
			<thead>
			<tr>
				<th>PK</th>
				<th>Key</th>
				<th>Identity</th>
				<th>Name</th>
				<th>Data Type</th>
				<th>Allows Nulls</th>
				<th>Collation</th>
				<th>References</th>
				<th>Default</th>
			</tr>
			</thead>
			<tfoot> 
			<tr> 
				<th scope='row'>Total</th> 
				<td colspan='9'>#table_info.recordcount# Columns</td> 
			</tr> 
			</tfoot> 
			<tbody>
			">
			
			<cfloop query="cols">

				<!--- get table info properties for this column --->
				<cfquery name="col_props" dbtype="query">
					select column_default, data_type, is_nullable, collation_name, character_maximum_length, max(isidentity) as isidentity, max(isprimarykey) as isprimarykey, max(isforeignkey) as isforeignkey
					from table_info
					where columnname = '#cols.columnname#'
					group by column_default, data_type, is_nullable, collation_name, character_maximum_length
				</cfquery>
				
				<!--- append to table string the details of this table column info --->
				<cfset return_string = "#return_string#<tr>">
				
				<cfif col_props.isprimarykey eq 1>
					<cfset return_string = "#return_string#<td width='20px' align='center'><img src='#image_path#/primary_key.png' alt='primary key' border=0></td>">
				<cfelse>
					<cfset return_string = "#return_string#<td width='20px' align='center'>&nbsp;</td>">
				</cfif>
				<cfif col_props.isforeignkey eq 1 or col_props.isprimarykey eq 1>
					<cfset return_string = "#return_string#<td width='20px' align='center'><input type=checkbox id='key_#cols.columnname#' checked disabled></td>">
				<cfelse>
					<cfset return_string = "#return_string#<td width='20px' align='center'><input type=checkbox id='key_#cols.columnname#' unchecked disabled></td>">
				</cfif>
				<cfif col_props.isidentity eq 1>
					<cfset return_string = "#return_string#<td width='20px' align='center'><input type=checkbox id='identity_#cols.columnname#' checked disabled></td>">
				<cfelse>
					<cfset return_string = "#return_string#<td width='20px' align='center'><input type=checkbox id='identity_#cols.columnname#' unchecked disabled></td>">
				</cfif>
				
				<cfset return_string = "#return_string#
					<td width='150px'>#cols.columnname#</td>
				">
				<cfif col_props.character_maximum_length gt 0 and col_props.data_type neq "text" and col_props.data_type neq "ntext">
					<cfset return_string ="#return_string#<td width='150px'>#col_props.data_type#(#col_props.character_maximum_length#)</td>">
				<cfelse>
					<cfset return_string ="#return_string#<td width='150px'>#col_props.data_type#</td>">
				</cfif>
				
				<cfif col_props.is_nullable eq "Yes">
					<cfset return_string = "#return_string#<td width='20px' align='center'><input type=checkbox id='allownulls_#cols.columnname#' checked disabled></td>">
				<cfelse>
					<cfset return_string = "#return_string#<td width='20px' align='center'><input type=checkbox id='allownulls_#cols.columnname#' unchecked disabled></td>">
				</cfif>
				
				<cfset return_string="#return_string#
					<td width='150px'>#col_props.collation_name#</td>
					<td width='150px'>&nbsp;</td>
					<td width='150px'>#col_props.column_default#</td>
				</tr>
				">
			
			</cfloop>

			<cfset return_string = "#return_string#</tbody></table><Br/>">

		</cfif>
		

		<cfreturn return_string />

	</cffunction>
	
	<cffunction name="ref_keys" returntype="string" output="true" access="remote">
		<cfargument name="db_name" type="string" required="true" hint="the name of the database to look up constraints for">
		<cfargument name="tbl_obj_id" type="string" required="true" hint="the object id of the table we need to look up for">
		<cfargument name="table_name" type="string" required="true" hint="table name">
		<cfargument name="dsn" type="string" required="true">
		
		<cfquery name="ref_keys_qry" datasource="#dsn#" cachedwithin="#createtimespan(0,0,30,0)#">
			select f.name, COL_NAME (fc.parent_object_id, fc.parent_column_id) as 'column', '[' + object_name(fc.referenced_object_id) + '].[' + COL_NAME (fc.referenced_object_id, fc.referenced_column_id)  + ']'  as reference_to
			from sys.foreign_keys f
				inner  join  sys.foreign_key_columns  fc  on f.object_id = fc.constraint_object_id	
			where f.parent_object_id = <cfqueryparam value="#tbl_obj_id#" cfsqltype="CF_SQL_INTEGER">
			order by f.name
		</cfquery>

		<cfparam name="return_string" default="">
		<cfset return_string = "">

		<cfif ref_keys_qry.recordcount gt 0>

			<cfset return_string = "<a name='reference_keys'></a>
			<table border='0' cellspacing='1' cellpadding='2' width='750px'>
			<caption><b>Table:[dbo].[#table_name#]</b> - Reference Keys</caption> 
			<thead>
			<tr>
				<th>Sr.</th>
				<th>Name</th>
				<th>Column</th>
				<th>Reference To</th>
			</tr>
			</thead>
			<tfoot> 
			<tr> 
				<th scope='row'>Total</th> 
				<td colspan='4'>#ref_keys_qry.recordcount# Reference Keys</td> 
			</tr> 
			</tfoot> 
			<tbody>
			">

			<cfloop query="ref_keys_qry">

				<cfset return_string="#return_string#
				<tr>
					<td width='20px' align='center'>#ref_keys_qry.currentrow#</td>
					<td width='150px'>#ref_keys_qry.name#</td>
					<td width='150px'>#ref_keys_qry.column#</td>
					<td>#ref_keys_qry.reference_to#</td>
				</tr>
				">

			</cfloop>

			<cfset return_string = "#return_string#</tbody></table><br/>">

		</cfif>
		
		<cfreturn return_string />
		
		<cfset return_string = "">


	</cffunction>
	<cffunction name="constraints" returntype="string" output="false" access="remote">
		<cfargument name="db_name" type="string" required="true" hint="the name of the database to look up constraints for">
		<cfargument name="tbl_obj_id" type="string" required="true" hint="the object id of the table we need to look up for">
		<cfargument name="table_name" type="string" required="true" hint="table name">
		<cfargument name="dsn" type="string" required="true">
		
		<cfquery name="constraints_qry" datasource="#dsn#" cachedwithin="#createtimespan(0,0,30,0)#">
			use #db_name#
			select c.name,  col_name(parent_object_id, parent_column_id) as 'column', c.definition as 'value'
			from sys.default_constraints c
			where c.parent_object_id = <cfqueryparam value="#tbl_obj_id#" cfsqltype="CF_SQL_INTEGER">
			order by c.name
		</cfquery>

		<cfparam name="return_string" default="">

		<cfif constraints_qry.recordcount gt 0>

			<cfset return_string = "#return_string#<a name='default_constraints'></a>
			<table border='0' cellspacing='1' cellpadding='2' width='750px'>
			<caption><b>Table:[dbo].[#table_name#]</b> - Default Constraints</caption> 
			<thead>
			<tr>
				<th>Sr.</th>
				<th>Name</th>
				<th>Column</th>
				<th>Value</th>
			</tr>
			</thead>
			<tfoot> 
			<tr> 
				<th scope='row'>Total</th> 
				<td colspan='4'>#constraints_qry.recordcount# Constraints</td> 
			</tr> 
			</tfoot> 
			<tbody>
			">

			<cfloop query="constraints_qry">

				<cfset return_string="#return_string#
				<tr>
					<td width='20px' align='center'>#constraints_qry.currentrow#</td>
					<td width='150px'>#constraints_qry.name#</td>
					<td width='150px'>#constraints_qry.column#</td>
					<td>#constraints_qry.value#</td>
				</tr>
				">

			</cfloop>

			<cfset return_string = "#return_string#</tbody></table><br/>">
		
		</cfif>
		
		<cfreturn return_string />


	</cffunction>
	

	<cffunction name="check_constraints" returntype="string" output="false" access="remote">
		<cfargument name="db_name" type="string" required="true" hint="the name of the database to look up check_constraints for">
		<cfargument name="tbl_obj_id" type="string" required="true" hint="the object id of the table we need to look up for">
		<cfargument name="table_name" type="string" required="true" hint="table name">
		<cfargument name="dsn" type="string" required="true">
		
		<cfquery name="check_constraints_qry" datasource="#dsn#" cachedwithin="#createtimespan(0,0,30,0)#">
			use #db_name#
			select c.name,  col_name(parent_object_id, parent_column_id) as 'column', definition 
			from sys.check_constraints c
			where c.parent_object_id = <cfqueryparam value="#tbl_obj_id#" cfsqltype="CF_SQL_INTEGER">
			order by c.name
		</cfquery>

		<cfparam name="return_string" default="">

		<cfif check_constraints_qry.recordcount gt 0>

			<cfset return_string = "#return_string#<a name='check_constraints'></a>
			<table border='0' cellspacing='1' cellpadding='2' width='750px'>
			<caption><b>Table:[dbo].[#table_name#]</b> - Check Constraints</caption>
			<thead>
			<tr>
				<th>Sr.</th>
				<th>Name</th>
				<th>Column</th>
				<th>Definition</th>
			</tr>
			</thead>
			<tfoot> 
			<tr> 
				<th scope='row'>Total</th> 
				<td colspan='4'>#check_con_qry.recordcount# Check Constraints</td> 
			</tr> 
			</tfoot> 
			<tbody>
			">

			<cfloop query="check_con_qry">

				<cfset return_string="#return_string#
				<tr>
					<td width='20px' align='center'>#check_con_qry.currentrow#</td>
					<td width='150px'>#check_con_qry.name#</td>
					<td width='150px'>#check_con_qry.column#</td>
					<td>#check_con_qry.definition#</td>
				</tr>
				">

			</cfloop>

			<cfset return_string = "#return_string#</tbody></table><br/>">
		
		</cfif>
		
		<!--- compress return string --->
		<cfset return_string = compress(return_string,2) />

		<cfreturn return_string />


	</cffunction>
	

	<cffunction name="triggers" returntype="string" output="false" access="remote">
		<cfargument name="db_name" type="string" required="true" hint="the name of the database to look up triggers for">
		<cfargument name="tbl_obj_id" type="string" required="true" hint="the object id of the table we need to look up for">
		<cfargument name="table_name" type="string" required="true" hint="table name">
		<cfargument name="dsn" type="string" required="true">
		
		<cfquery name="triggers_qry" datasource="#dsn#" cachedwithin="#createtimespan(0,0,30,0)#">
			use #db_name#
			SELECT tr.name
			FROM sys.triggers tr
			where tr.parent_id = <cfqueryparam value="#tbl_obj_id#" cfsqltype="CF_SQL_INTEGER">
			order by tr.name
		</cfquery>

		<cfparam name="return_string" default="">

		<cfif triggers_qry.recordcount gt 0>

			<cfset return_string = "#return_string#<a name='triggers'></a>
			<table border='0' cellspacing='1' cellpadding='2' width='750px'>
			<caption><b>Table:[dbo].[#table_name#]</b> - Triggers</caption>
			<thead>
			<tr>
				<th>Sr.</th>
				<th>Name</th>
			</tr>
			</thead>
			<tfoot> 
			<tr> 
				<th scope='row'>Total</th> 
				<td colspan='4'>#triggers_qry.recordcount# Triggers</td> 
			</tr> 
			</tfoot> 
			<tbody>
			">

			<cfloop query="triggers_qry">

				<cfset return_string="#return_string#
				<tr>
					<td width='20px' align='center'>#triggers_qry.currentrow#</td>
					<td width='150px'>#triggers_qry.name#</td>
				</tr>
				">

			</cfloop>

			<cfset return_string = "#return_string#</tbody></table><br/>">
		
		</cfif>
		
		<!--- compress return string --->
		<cfset return_string = compress(return_string,2) />
		
		<cfreturn return_string />


	</cffunction>
	
	<cffunction name="indexes" returntype="string" output="false" access="remote">
		<cfargument name="db_name" type="string" required="true" hint="the name of the database to look up indexes for">
		<cfargument name="tbl_obj_id" type="string" required="true" hint="the object id of the table we need to look up for">
		<cfargument name="table_name" type="string" required="true" hint="table name">
		<cfargument name="dsn" type="string" required="true">
		
		<cfquery name="indexes_qry" datasource="#dsn#" cachedwithin="#createtimespan(0,0,30,0)#">
			use #db_name#
			select i.name, case when i.type = 0 then 'Heap' when i.type = 1 then 'Clustered' else 'Nonclustered' end as 'type',  col_name(i.object_id, c.column_id) as 'column'
			from sys.indexes i 
				inner join sys.index_columns c on i.index_id = c.index_id and c.object_id = i.object_id 
			where i.object_id = <cfqueryparam value="#tbl_obj_id#" cfsqltype="CF_SQL_INTEGER">
			order by i.name, c.column_id
		</cfquery>

		<cfparam name="return_string" default="">
		
		<cfif indexes_qry.recordcount gt 0>

			<cfset return_string = "#return_string#<a name='indexes'></a>
			<table border='0' cellspacing='1' cellpadding='2' width='750px'>
			<caption><b>Table:[dbo].[#table_name#]</b> - Indexes</caption>
			<thead>
			<tr>
				<th>Sr.</th>
				<th>Name</th>
				<th>Type</th>
				<th>Columns</th>
			</tr>
			</thead>
			<tfoot> 
			<tr> 
				<th scope='row'>Total</th> 
				<td colspan='4'>#indexes_qry.recordcount# Indexes</td> 
			</tr> 
			</tfoot> 
			<tbody>
			">

			<cfloop query="indexes_qry">

				<cfset return_string="#return_string#
				<tr>
					<td width='20px' align='center'>#indexes_qry.currentrow#</td>
					<td width='150px'>#indexes_qry.name#</td>
					<td width='150px'>#indexes_qry.type#</td>
					<td width='150px'>#indexes_qry.column#</td>
				</tr>
				">

			</cfloop>

			<cfset return_string = "#return_string#</tbody></table><br/>">

		</cfif>

		<!--- compress return string --->
		<cfset return_string = compress(return_string,2) />

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

	<cffunction name="tree" returntype="string" output="false" access="remote">
		<cfargument name="dsn" type="string" required="yes">
		<cfargument name="doc_path" type="string" required="yes">
	
		<cfparam name="return_string" default="">

		<cfquery name='dbs' datasource='#dsn#' cachedwithin="#createtimespan(0,0,30,0)#">
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

		<!--- compress return string --->
		<cfset return_string = compress(return_string,2) />

		<cfreturn return_string />

	</cffunction>
	<cffunction name="compress" displayname="Compress HTML" description="Removes any extra whitespacing in HTML." access="public" output="false" returntype="String">

		<!--- PASS IN HTML AND LEVEL OF COMPRESSION --->
		<cfargument name="htmlString" displayName="HTML String" type="string" hint="String to be compressed." required="true" />
		<cfargument name="level" displayName="Compression Level" type="numeric" hint="Level of compression" default="2" required="false" />

		<cfset var stringToCompress = ARGUMENTS.htmlString>
		<cfset var compressionLevel = ARGUMENTS.level>

		<!--- TRIM OFF ANY EXTRA SPACES FROM STRING TO BE FILTERED --->
		<cfset stringToCompress = trim(stringToCompress)>

		<!--- RUN FILTER BASED ON SPECIFIED COMPRESSION LEVEL --->
		<cfswitch expression="#compressionLevel#">
			<cfcase value="3">
				<cfset stringToCompress = reReplace(stringToCompress, "[[:space:]]{2,}", " ", "all")>
				<cfset stringToCompress = replace(stringToCompress, "> <", "><", "all")>
				<cfset stringToCompress = reReplace(stringToCompress, "<!--[^>]+>", "", "all")>
			</cfcase>

			<cfcase value="2">
				<cfset stringToCompress = reReplace(stringToCompress, "[[:space:]]{2,}", chr( 13 ), "all")>
			</cfcase>

			<cfdefaultcase>
				<cfset stringToCompress = reReplace(stringToCompress, "(" & chr( 10 ) & "|" & chr( 13 ) & ")+[[:space:]]{2,}", chr( 13 ), "all")>
			</cfdefaultcase>
		</cfswitch>

		<!--- RETURN COMPRESSED HTML --->
		<cfreturn stringToCompress>

	</cffunction>
	
</cfcomponent>