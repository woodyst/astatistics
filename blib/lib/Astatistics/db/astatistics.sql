PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE users (
		id INTEGER PRIMARY KEY,
		username char(32) NOT NULL DEFAULT '',
		password char(64) NOT NULL,
		status char(16) NOT NULL DEFAULT 'active'
	);
INSERT INTO "users" VALUES(1,'admin','as/8xnqkI2DkY','active');
INSERT INTO "users" VALUES(2,'designer','as/8xnqkI2DkY','active');
INSERT INTO "users" VALUES(3,'viewer','as/8xnqkI2DkY','active');
INSERT INTO "users" VALUES(4,'viewer_2','as/8xnqkI2DkY','active');
CREATE TABLE users_to_roles (
		user int(11) NOT NULL,
		role int(11) NOT NULL,
		PRIMARY KEY(user,role),
		FOREIGN KEY(user) REFERENCES users(id),
		FOREIGN KEY(role) REFERENCES roles(id)
	);
INSERT INTO "users_to_roles" VALUES(1,1);
INSERT INTO "users_to_roles" VALUES(2,2);
INSERT INTO "users_to_roles" VALUES(2,3);
INSERT INTO "users_to_roles" VALUES(3,3);
INSERT INTO "users_to_roles" VALUES(4,4);
CREATE TABLE roles (
		id INTEGER PRIMARY KEY,
		role char(32) DEFAULT NULL
	);
INSERT INTO "roles" VALUES(1,'superuser');
INSERT INTO "roles" VALUES(2,'can_design');
INSERT INTO "roles" VALUES(3,'can_access_class1_stats');
INSERT INTO "roles" VALUES(4,'can_access_class2_stats');
CREATE TABLE stats (
		id INTEGER PRIMARY KEY,
		name char(32) NOT NULL DEFAULT '',
		visual char(32) NOT NULL DEFAULT 'list',
		conditions text NOT NULL DEFAULT '',
		format text NOT NULL DEFAULT ''
	);
INSERT INTO "stats" VALUES(1,'stat_1 (class 1)','list','','');
INSERT INTO "stats" VALUES(2,'stat_2 (class 2)','list','','');
INSERT INTO "stats" VALUES(3,'Llamadas outbound_line_1/2 entre dos fechas','list','table=cdr; show=calldate,clid,src,dst,dcontext,channel,dstchannel,lastapp,lastdata,duration,billsec,amaflags,accountcode,userfield,uniqueid,linkedid,sequence,peeraccount; where=calldate > #date#Fecha inicio# and calldate < #date#Fecha fin# and dcontext = #checkbox#Destination context(outbound_line_1|outbound_line_2--checked)#; order_by=calldate,clid ASC;','title=Llamadas outbound_line_1/2 entre #date#Fecha inicio# y #date#Fecha fin#; rows_per_page=20');
INSERT INTO "stats" VALUES(4,'Llamadas outbound_line_1/2 entre dos fechas (menos campos)','list','table=cdr; show=calldate,src,dst,channel,dstchannel,duration,billsec,dcontext; where=calldate > #date#Fecha inicio# and calldate < #date#Fecha fin# and dcontext = #checkbox#Destination context(outbound_line_1|outbound_line_2--checked)#; order_by=calldate,clid ASC;','title=Llamadas outbound_line_1/2 entre #date#Fecha inicio# y #date#Fecha fin#; rows_per_page=#Resultados por página#10#');
INSERT INTO "stats" VALUES(5,'Llamadas usuario entre fechas','list','table=cdr; show=calldate,src,dst,channel,dstchannel,duration,billsec,dcontext; where=calldate > #date#Fecha inicio# and calldate < #date#Fecha fin# and src = #checkbox#Usuario(luis--checked|edi--checked|juanjo--checked|comercial1--checked|comercial2--checked|comercial3--checked|tecni1--checked|casa--checked)#; order_by=calldate,clid ASC;','title=Llamadas usuario entre #date#Fecha inicio# y #date#Fecha fin#; rows_per_page=#Resultados por página#20#');
INSERT INTO "stats" VALUES(6,'Todo','list','table=cdr; show=calldate,src,dst,channel,dstchannel,duration,billsec,dcontext; where=calldate > #date#Fecha inicio# and calldate < #date#Fecha fin#; order_by=calldate,clid ASC;','title=Todas las llamadas entre #date#Fecha inicio# y #date#Fecha fin#; rows_per_page=#Resultados por página#20#');
INSERT INTO "stats" VALUES(7,'Todo queuelog','list','table=queuelog; show=id,time,callid,queuename,agent,event,data','title=Todas las entradas queue_log; rows_per_page=#Resultados por página#20#');
INSERT INTO "stats" VALUES(8,'Tiempo facturable total','list','table=cdr; show=SUM(billsec); where=calldate > #date#Fecha inicio# and calldate < #date#Fecha fin#;','title=Tiempo facturable entre #date#Fecha inicio# y #date#Fecha fin#;');
INSERT INTO "stats" VALUES(9,'Todo (copia)','list','table=cdr; show=calldate,src,dst,channel,dstchannel,duration,billsec,dcontext; where=calldate > #date#Fecha inicio# and calldate < #date#Fecha fin#; order_by=calldate,clid ASC;','title=Todas las llamadas entre #date#Fecha inicio# y #date#Fecha fin#; rows_per_page=#Resultados por página#20#');
INSERT INTO "stats" VALUES(10,'Máximo tiempo facturable en llamada','list','table=cdr; show=MAX(billsec); where=calldate > #date#Fecha inicio# and calldate < #date#Fecha fin#;','title=Máximo tiempo facturable entre #date#Fecha inicio# y #date#Fecha fin#;');
INSERT INTO "stats" VALUES(11,'Llamadas más largas primero','list','table=cdr; show=calldate,src,dst,channel,dstchannel,duration,billsec,dcontext; where=calldate > #date#Fecha inicio# and calldate < #date#Fecha fin# and src = #checkbox#Usuario(luis--checked|edi--checked|juanjo--checked|comercial1--checked|comercial2--checked|comercial3--checked|tecni1--checked|casa--checked)#; order_by=billsec DESC;','title=Llamadas más largas entre #date#Fecha inicio# y #date#Fecha fin#; rows_per_page=#Resultados por página#20#');
INSERT INTO "stats" VALUES(12,'Gráfica número llamadas entre fechas','area','table=cdr; show=x:date:calldate:Fecha,y:COUNT:calldate:Llamadas; group_by=YEAR(calldate),MONTH(calldate),DAY(calldate); where=calldate > #date#Fecha inicio# and calldate < #date#Fecha fin# and src = #checkbox#Usuario(luis--checked|edi--checked|juanjo--checked|comercial1--checked|comercial2--checked|comercial3--checked|tecni1--checked|casa--checked)#;','title=Llamadas entre #date#Fecha inicio# y #date#Fecha fin#; rows_per_page=#Resultados por página#20#;
width=650; height=350;');
INSERT INTO "stats" VALUES(13,'Lista número llamadas entre fechas','list','table=cdr; show=x:date:calldate:Fecha,y:COUNT:calldate:Llamadas; group_by=YEAR(calldate),MONTH(calldate),DAY(calldate); where=calldate > #date#Fecha inicio# and calldate < #date#Fecha fin# and src = #checkbox#Usuario(luis--checked|edi--checked|juanjo--checked|comercial1--checked|comercial2--checked|comercial3--checked|tecni1--checked|casa--checked)#;','title=Llamadas entre #date#Fecha inicio# y #date#Fecha fin#; rows_per_page=#Resultados por página#20#;
width=650; height=350;');
INSERT INTO "stats" VALUES(14,'Queso número llamadas entre fechas series','pie','table=cdr; show=x:date:calldate:Fecha,y:COUNT:calldate:Llamadas,src; group_by=src,YEAR(calldate),MONTH(calldate),DAY(calldate); where=calldate > #date#Fecha inicio# and calldate < #date#Fecha fin# and src = #checkbox#Usuario(luis--checked|edi--checked|juanjo--checked|comercial1--checked|comercial2--checked|comercial3--checked|tecni1--checked|casa--checked)#;
series_by=src;','title=Llamadas entre #date#Fecha inicio# y #date#Fecha fin#; rows_per_page=#Resultados por página#20#;
width=650; height=250;');
INSERT INTO "stats" VALUES(15,'Area número llamadas entre fechas no series','area','table=cdr; show=x:date:calldate:Fecha,y:COUNT:calldate:Llamadas,src; group_by=YEAR(calldate),MONTH(calldate),DAY(calldate); where=calldate > #date#Fecha inicio# and calldate < #date#Fecha fin# and src = #checkbox#Usuario(luis--checked|edi--checked|juanjo--checked|comercial1--checked|comercial2--checked|comercial3--checked|tecni1--checked|casa--checked)#;','title=Llamadas entre #date#Fecha inicio# y #date#Fecha fin#; rows_per_page=#Resultados por página#20#;
width=650; height=250;');
INSERT INTO "stats" VALUES(16,'Area número llamadas entre fechas series','area','table=cdr; show=x:date:calldate:Fecha,y:COUNT:calldate:Llamadas,src; group_by=src,YEAR(calldate),MONTH(calldate),DAY(calldate); where=calldate > #date#Fecha inicio# and calldate < #date#Fecha fin# and src = #checkbox#Usuario(luis--checked|edi--checked|juanjo--checked|comercial1--checked|comercial2--checked|comercial3--checked|tecni1--checked|casa--checked)#;
series_by=src;','title=Llamadas entre #date#Fecha inicio# y #date#Fecha fin#; rows_per_page=#Resultados por página#20#;
width=650; height=250;');
INSERT INTO "stats" VALUES(17,'Area número llamadas entre fechas series un usuario','area','table=cdr; show=x:date:calldate:Fecha,y:COUNT:calldate:Llamadas,src; group_by=src,YEAR(calldate),MONTH(calldate),DAY(calldate); where=calldate > #date#Fecha inicio# and calldate < #date#Fecha fin# and src = #radio#Usuario(luis--checked|edi|juanjo|comercial1|comercial2|comercial3|tecni1|casa)#;
series_by=src;','title=Llamadas entre #date#Fecha inicio# y #date#Fecha fin#; rows_per_page=#Resultados por página#20#;
width=650; height=250;');
INSERT INTO "stats" VALUES(18,'Gasto telefónico por usuario entre fechas','area','table=cdr; show=x:date:calldate:Fecha,y:SUM:billsec:Segundos_facturables,src; group_by=src,YEAR(calldate),MONTH(calldate),DAY(calldate); where=calldate > #date#Fecha inicio# and calldate < #date#Fecha fin# and src = #checkbox#Usuario(luis--checked|edi--checked|juanjo--checked|comercial1--checked|comercial2--checked|comercial3--checked|tecni1--checked|casa--checked)#;
series_by=src;','title=Gasto telefónico entre #date#Fecha inicio# y #date#Fecha fin#; rows_per_page=#Resultados por página#20#;
width=650; height=250;');
INSERT INTO "stats" VALUES(19,'Lista número llamadas entre fechas series','list','table=cdr; show=x:date:calldate:Fecha,y:COUNT:calldate:Llamadas; group_by=YEAR(calldate),MONTH(calldate),DAY(calldate); where=calldate > #date#Fecha inicio# and calldate < #date#Fecha fin# and src = #checkbox#Usuario(luis--checked|edi--checked|juanjo--checked|comercial1--checked|comercial2--checked|comercial3--checked|tecni1--checked|casa--checked)#;
series_by=src;','title=Llamadas entre #date#Fecha inicio# y #date#Fecha fin#; rows_per_page=#Resultados por página#20#;
width=650; height=250;');
INSERT INTO "stats" VALUES(20,'test','list','table=cdr; show=calldate,src,dst,channel,dstchannel,duration,billsec,dcontext; where=calldate > #date#Fecha inicio# and calldate < #date#Fecha fin# and src = #checkbox#Usuario(luis|edi|juanjo|comercial1|comercial2|comercial3|tecni1--checked|casa)#; order_by=calldate,clid ASC;','title=test;');
CREATE TABLE st_groups (
		id INTEGER PRIMARY KEY,
		name char(32) NOT NULL,
		parent INTEGER NULL -- group is a child of this one
	);
INSERT INTO "st_groups" VALUES(1,'root',0);
INSERT INTO "st_groups" VALUES(2,'grupo_1 (class 1)',NULL);
INSERT INTO "st_groups" VALUES(4,'grupo_2 (all)',NULL);
INSERT INTO "st_groups" VALUES(5,'Estadísticas Eurogarán',NULL);
CREATE TABLE stats_to_st_groups (
		stat_id INTEGER NOT NULL,
		group_id INTEGER NOT NULL,
		position INTEGER NULL,								-- visualization order in group (stats)
		PRIMARY KEY(stat_id,group_id),
		FOREIGN KEY(stat_id) REFERENCES stats(id),
		FOREIGN KEY(group_id) REFERENCES st_groups(id)
	);
INSERT INTO "stats_to_st_groups" VALUES(1,1,0);
INSERT INTO "stats_to_st_groups" VALUES(1,2,NULL);
INSERT INTO "stats_to_st_groups" VALUES(2,2,0);
INSERT INTO "stats_to_st_groups" VALUES(2,1,NULL);
INSERT INTO "stats_to_st_groups" VALUES(3,1,0);
INSERT INTO "stats_to_st_groups" VALUES(4,1,0);
INSERT INTO "stats_to_st_groups" VALUES(5,5,NULL);
INSERT INTO "stats_to_st_groups" VALUES(6,5,NULL);
INSERT INTO "stats_to_st_groups" VALUES(7,5,0);
INSERT INTO "stats_to_st_groups" VALUES(6,2,NULL);
INSERT INTO "stats_to_st_groups" VALUES(9,2,0);
INSERT INTO "stats_to_st_groups" VALUES(8,5,NULL);
INSERT INTO "stats_to_st_groups" VALUES(10,5,NULL);
INSERT INTO "stats_to_st_groups" VALUES(11,5,0);
INSERT INTO "stats_to_st_groups" VALUES(12,5,0);
INSERT INTO "stats_to_st_groups" VALUES(13,5,0);
INSERT INTO "stats_to_st_groups" VALUES(14,5,0);
INSERT INTO "stats_to_st_groups" VALUES(15,5,0);
INSERT INTO "stats_to_st_groups" VALUES(16,5,0);
INSERT INTO "stats_to_st_groups" VALUES(17,5,0);
INSERT INTO "stats_to_st_groups" VALUES(18,5,0);
INSERT INTO "stats_to_st_groups" VALUES(19,5,0);
INSERT INTO "stats_to_st_groups" VALUES(20,1,0);
CREATE TABLE stats_to_roles (
		stat_id INTEGER NOT NULL,
		role_id INTEGER NOT NULL,
		PRIMARY KEY(stat_id,role_id),
		FOREIGN KEY(stat_id) REFERENCES stats(id),
		FOREIGN KEY(role_id) REFERENCES roles(id)
	);
INSERT INTO "stats_to_roles" VALUES(1,3);
INSERT INTO "stats_to_roles" VALUES(2,4);
INSERT INTO "stats_to_roles" VALUES(3,3);
INSERT INTO "stats_to_roles" VALUES(4,3);
INSERT INTO "stats_to_roles" VALUES(4,4);
INSERT INTO "stats_to_roles" VALUES(5,3);
INSERT INTO "stats_to_roles" VALUES(5,4);
INSERT INTO "stats_to_roles" VALUES(6,3);
INSERT INTO "stats_to_roles" VALUES(6,4);
INSERT INTO "stats_to_roles" VALUES(7,3);
INSERT INTO "stats_to_roles" VALUES(7,4);
INSERT INTO "stats_to_roles" VALUES(8,3);
INSERT INTO "stats_to_roles" VALUES(8,4);
INSERT INTO "stats_to_roles" VALUES(9,3);
INSERT INTO "stats_to_roles" VALUES(9,4);
INSERT INTO "stats_to_roles" VALUES(10,3);
INSERT INTO "stats_to_roles" VALUES(10,4);
INSERT INTO "stats_to_roles" VALUES(11,3);
INSERT INTO "stats_to_roles" VALUES(11,4);
INSERT INTO "stats_to_roles" VALUES(12,3);
INSERT INTO "stats_to_roles" VALUES(12,4);
INSERT INTO "stats_to_roles" VALUES(13,3);
INSERT INTO "stats_to_roles" VALUES(13,4);
INSERT INTO "stats_to_roles" VALUES(14,3);
INSERT INTO "stats_to_roles" VALUES(14,4);
INSERT INTO "stats_to_roles" VALUES(15,3);
INSERT INTO "stats_to_roles" VALUES(15,4);
INSERT INTO "stats_to_roles" VALUES(16,3);
INSERT INTO "stats_to_roles" VALUES(16,4);
INSERT INTO "stats_to_roles" VALUES(17,3);
INSERT INTO "stats_to_roles" VALUES(17,4);
INSERT INTO "stats_to_roles" VALUES(18,3);
INSERT INTO "stats_to_roles" VALUES(18,4);
INSERT INTO "stats_to_roles" VALUES(19,3);
INSERT INTO "stats_to_roles" VALUES(19,4);
INSERT INTO "stats_to_roles" VALUES(20,3);
INSERT INTO "stats_to_roles" VALUES(20,4);
CREATE TABLE st_groups_to_roles (
		st_group_id INTEGER NOT NULL,
		role_id INTEGER NOT NULL,
		PRIMARY KEY(st_group_id,role_id),
		FOREIGN KEY(st_group_id) REFERENCES st_groups(id),
		FOREIGN KEY(role_id) REFERENCES roles(id)
	);
INSERT INTO "st_groups_to_roles" VALUES(2,3);
INSERT INTO "st_groups_to_roles" VALUES(4,3);
INSERT INTO "st_groups_to_roles" VALUES(4,4);
INSERT INTO "st_groups_to_roles" VALUES(5,3);
INSERT INTO "st_groups_to_roles" VALUES(5,4);
INSERT INTO "st_groups_to_roles" VALUES(6,3);
CREATE TABLE st_groups_to_st_groups (
		group_id INTEGER NOT NULL,
		parent_group_id INTEGER NOT NULL,
		position INTEGER NULL,
		PRIMARY KEY(group_id,parent_group_id),
		FOREIGN KEY(group_id) REFERENCES groups(id),
		FOREIGN KEY(parent_group_id) REFERENCES groups(id)
);
INSERT INTO "st_groups_to_st_groups" VALUES(2,1,0);
INSERT INTO "st_groups_to_st_groups" VALUES(4,1,NULL);
INSERT INTO "st_groups_to_st_groups" VALUES(5,1,0);
INSERT INTO "st_groups_to_st_groups" VALUES(2,2,NULL);
COMMIT;
