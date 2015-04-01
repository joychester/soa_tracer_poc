URL_Name | Type | GUID | ServiceID | TS
1> URL_PageA | 0 | ABC | "" | 1111
2> URL_SA | 0 | ABC | ABCa | 1112
3> URL_SB | 0 | ABC | ABCaa | 1113
4> URL_SB | 1 | ABC | ABCaa | 1114
5> URL_SA | 1 | ABC | ABCa | 1115
6> URL_PageA | 1 | ABC | "" | 1116



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