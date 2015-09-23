======================================
Purpose of SQLDOC
======================================

Rather simply, is that this is a cheap alternative to buying an expensive tool to build a data dictionairy. There are a lot of nice tools that do this well. 

However, I was in a position where I could not afford any, and decided to create my own.

This tool can be expanded to gather additional details from the database, and convert them to html data documentation, but this is just a starting point.

======================================
Real Credit
======================================

I do not claim credit for having created all the css, images, and sql statements. But I do claim full credit for putting it all together, in a free solution, that helps
you have an easily updatable data dictionairy, on any of your databases.

September 20, 2010

======================================
Installation instructions
======================================

1. You need to modify the cfparam values in static_sql.cfm
	a. dsn = your datasource
	b. start_path = the folder path where you will be placing the sqldoc folder
	c. url_path = the url path to the sqldoc folder
	d. css_path = the url path to the css folder inside the sqldoc root
	e. js_path = the url path to javascript folder inside the sqldoc root
	f. image_path = the url path to the images folder inside the sqldoc root
	
2. Create the following view in your database, that allows secured access to data stored in the master.dbo.sysdatabases

CREATE VIEW [dbo].[vw_db_info]
AS
SELECT     name, SUSER_SNAME(sid) AS Owner, DATABASEPROPERTYEX(name, 'Recovery') AS Recovery, DATABASEPROPERTYEX(name, 'Status') AS Status, 
                      DATABASEPROPERTYEX(name, 'Collation') AS Collation, DATABASEPROPERTYEX(name, 'Version') AS Version
FROM         master.dbo.sysdatabases

3. Make sure the datasource username has full access to run this view.

4. This system is built to work on windows based file systems, you will have to modify to work on other operating systems.

5. Then go to url path, and run #url_path#/static_sql.cfm Which will go thru all databases the datasource you specified it has access to, 
and will then generate html pages for all databases, tables, views, and procedures. 

======================================
How this works
======================================

1. static_sql.cfm
	a. Builds up a list of databases
	b. Makes sure all subfolders exist
		1. database folder
		2. tables folder inside database folder
		3. views folder inside database folder
		4. procedures folder inside database folder
	c. Builds Master Database Index File that will be the front page for all info on 1 specific database
	d. Builds Index File for each all tables, all views and all procedures
	e. Builds Each Individual Table, Views and Procedures File
	f. Generates Summary of Build Progress
	
2. static_db.cfc - Contains functions for building database level html pages
3. static_tables.cfc - Contains functions for building table level html pages
4. static_views.cfc - Contains functions for building view level html pages
5. static_procedures.cfc - Contains functions for building procedure level html pages.

======================================
Usage Examples & Ideas
======================================

Once you have manually run this, and are satisfied with the results, you could set it up as a 2 part coldfusion
scheduled task:

1. Run the SQLDOC Generate Static HTML Pages

2. Download to your dev server or development machines, to give yourself scalable/easy way to learn/manipulate production datastructures.
