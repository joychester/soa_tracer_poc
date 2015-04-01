Sample output with Google Chart timeline:
![SOA_Tracer_Timeline](https://github.com/joychester/soa_tracer_poc/blob/master/gchart_timing.png)

DB schema:  
ID| URL_Name | Type | PageID | ServiceID | TS

Sample Records:  
"/page/pageA|2d52bc55b4b986aa1dfd||0|1427190743.714614|"
"/rest/serviceA|2d52bc55b4b986aa1dfd|2d52bc55b4b986aa1dfda|00|1427190743.872463|"
"/rest/serviceB|2d52bc55b4b986aa1dfd|2d52bc55b4b986aa1dfdaa|00|1427190744.0136323|"
"/rest/serviceB|2d52bc55b4b986aa1dfd|2d52bc55b4b986aa1dfdaa|11|1427190744.0192983|"
"/rest/serviceA|2d52bc55b4b986aa1dfd|2d52bc55b4b986aa1dfda|11|1427190744.0392191|"
"/page/pageA|2d52bc55b4b986aa1dfd||1|1427190744.1119723|"

conflunt.io or samza in the future??

Add column id serial,  
ADD COLUMN URL_Name text,  
Add column Type integer,  
Add column GUID uuid,   
add column ServiceID uuid,   
add column TS  numeric;  
