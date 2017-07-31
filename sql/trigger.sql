drop table if exists sqllog;

create table sqllog (
	id   int not null auto_increment,
	query varchar(1024) DEFAULT NULL,
	opt_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	sync_time timestamp,
	primary key (id)
) DEFAULT CHARSET=utf8;

drop trigger if exists ipnet_insert;
drop trigger if exists ipnet_update;
drop trigger if exists ipnet_delete;
drop trigger if exists ipnet_wl_insert;
drop trigger if exists ipnet_wl_update;
drop trigger if exists ipnet_wl_delete;
drop trigger if exists clientset_insert;
drop trigger if exists clientset_update;
drop trigger if exists clientset_delete;
drop trigger if exists iptable_insert;
drop trigger if exists iptable_update;
drop trigger if exists iptable_delete;
drop trigger if exists iptable_wl_insert;
drop trigger if exists iptable_wl_update;
drop trigger if exists iptable_wl_delete;
drop trigger if exists netlink_insert;
drop trigger if exists netlink_update;
drop trigger if exists netlink_delete;
drop trigger if exists netlinkset_insert;
drop trigger if exists netlinkset_update;
drop trigger if exists netlinkset_delete;
drop trigger if exists outlink_insert;
drop trigger if exists outlink_update;
drop trigger if exists outlink_delete;
drop trigger if exists domain_insert;
drop trigger if exists domain_update;
drop trigger if exists domain_delete;
drop trigger if exists domain_pool_insert;
drop trigger if exists domain_pool_update;
drop trigger if exists domain_pool_delete;
drop trigger if exists domainlink_insert;
drop trigger if exists domainlink_update;
drop trigger if exists domainlink_delete;
drop trigger if exists tproxy_insert;
drop trigger if exists tproxy_update;
drop trigger if exists tproxy_delete;
drop trigger if exists routeset_insert;
drop trigger if exists routeset_update;
drop trigger if exists routeset_delete;
drop trigger if exists route_insert;
drop trigger if exists route_update;
drop trigger if exists route_delete;
drop trigger if exists natlink_insert;
drop trigger if exists natlink_update;
drop trigger if exists natlink_delete;
drop trigger if exists ldns_insert;
drop trigger if exists ldns_update;
drop trigger if exists ldns_delete;
drop trigger if exists policy_insert;
drop trigger if exists policy_update;
drop trigger if exists policy_delete;
drop trigger if exists policy_detail_insert;
drop trigger if exists policy_detail_update;
drop trigger if exists policy_detail_delete;
drop trigger if exists viewer_insert;
drop trigger if exists viewer_update;
drop trigger if exists viewer_delete;

DELIMITER $$

CREATE TRIGGER ipnet_insert AFTER INSERT ON ipnet
FOR EACH ROW
BEGIN
	select name into @cs_name from clientset where id = NEW.clientset_id;
	select id   into @cs_id   from iwg.clientset where name = @cs_name;
	INSERT INTO iwg.ipnet(ip_start,ip_end,ipnet,mask,clientset_id) VALUES (NEW.ip_start,NEW.ip_end,NEW.ipnet,NEW.mask,@cs_id);
	insert into sqllog (query) values 
	(CONCAT("insert into ipnet(ip_start,ip_end,ipnet,mask,clientset_id)value('",NEW.ip_start,"','",NEW.ip_end,"','",NEW.ipnet,"',",NEW.mask,",(select id from clientset where name='",@cs_name,"'));"));
END;

CREATE TRIGGER ipnet_update AFTER UPDATE ON ipnet
FOR EACH ROW
BEGIN 
	select name into @cs_name from clientset where id = NEW.clientset_id;
	select id   into @cs_id   from iwg.clientset where name = @cs_name;
	UPDATE iwg.ipnet set clientset_id = @cs_id where ipnet = NEW.ipnet and 
		mask = NEW.mask;
	insert into sqllog (query) values 
	(CONCAT("update ipnet set clientset_id=(select id from clientset where name='",@cs_name,"') where ipnet='" ,OLD.ipnet,"' and mask=",OLD.mask,";"));
END;

CREATE TRIGGER ipnet_delete AFTER DELETE ON ipnet
FOR EACH ROW
BEGIN 
	DELETE from iwg.ipnet where ipnet = OLD.ipnet and mask = OLD.mask;
	insert into sqllog (query) values 
	(CONCAT("delete from ipnet where ipnet='" ,OLD.ipnet,"' and mask=",OLD.mask,";"));
END;

CREATE TRIGGER ipnet_wl_insert AFTER INSERT ON ipnet_wl
FOR EACH ROW
BEGIN
	select name into @cs_name from clientset where id = NEW.clientset_id;
	select id   into @cs_id   from iwg.clientset where name = @cs_name;
	INSERT INTO iwg.ipnet_wl(ip_start,ip_end,ipnet,mask,clientset_id) VALUES (NEW.ip_start,NEW.ip_end,NEW.ipnet,NEW.mask,@cs_id);
	insert into sqllog (query) values 
	(CONCAT("insert into ipnet_wl(ip_start,ip_end,ipnet,mask,clientset_id)value('",NEW.ip_start,"','",NEW.ip_end,"','",NEW.ipnet,"',",NEW.mask,",(select id from clientset where name='",@cs_name,"'));"));
END;

CREATE TRIGGER ipnet_wl_update AFTER UPDATE ON ipnet_wl
FOR EACH ROW
BEGIN 
	select name into @cs_name from clientset where id = NEW.clientset_id;
	select id   into @cs_id   from iwg.clientset where name = @cs_name;
	UPDATE iwg.ipnet_wl set clientset_id = @cs_id where ipnet = NEW.ipnet and 
		mask = NEW.mask;
	insert into sqllog (query) values 
	(CONCAT("update ipnet_wl set clientset_id=(select id from clientset where name='",@cs_name,"') where ipnet='" ,OLD.ipnet,"' and mask=",OLD.mask,";"));
END;

CREATE TRIGGER ipnet_wl_delete AFTER DELETE ON ipnet_wl
FOR EACH ROW
BEGIN 
	DELETE from iwg.ipnet_wl where ipnet = OLD.ipnet and mask = OLD.mask;
	insert into sqllog (query) values 
	(CONCAT("delete from ipnet_wl where ipnet='" ,OLD.ipnet,"' and mask=",OLD.mask,";"));

END;

CREATE TRIGGER clientset_insert AFTER INSERT ON clientset
FOR EACH ROW
BEGIN
	INSERT INTO iwg.clientset(name,info) VALUES (NEW.name,NEW.info);
	insert into sqllog (query) values 
	(CONCAT("insert into clientset(name,info)value('",NEW.name,"','",NEW.info,"');"));
END;

CREATE TRIGGER clientset_update AFTER UPDATE ON clientset
FOR EACH ROW
BEGIN 
	UPDATE iwg.clientset set name = NEW.name,info = NEW.info  where name = OLD.name;
	insert into sqllog (query) values 
	(CONCAT("update clientset set name='",NEW.name,"',info='" ,NEW.info,"' where name='",OLD.name,"';"));
END;

CREATE TRIGGER clientset_delete AFTER DELETE ON clientset
FOR EACH ROW
BEGIN 
	DELETE from iwg.clientset where name = OLD.name;
	insert into sqllog (query) values 
	(CONCAT("delete from clientset where name='" ,OLD.name,"';"));

END;



CREATE TRIGGER iptable_insert AFTER INSERT ON iptable
FOR EACH ROW
BEGIN
	select isp into @nl_name from netlink where id = NEW.netlink_id;
	select id  into @nl_id   from iwg.netlink where isp = @nl_name;
	INSERT INTO iwg.iptable(ip_start,ip_end,ipnet,mask,netlink_id) VALUES (NEW.ip_start,NEW.ip_end,NEW.ipnet,NEW.mask,@nl_id);
	insert into sqllog (query) values 
	(CONCAT("insert into iptable(ip_start,ip_end,ipnet,mask,netlink_id)value('",NEW.ip_start,"','",NEW.ip_end,"','",NEW.ipnet,"',",NEW.mask,",(select id from netlink where isp='",@nl_name,"'));"));
END;
--  when update , can only update netlink_id
CREATE TRIGGER iptable_update AFTER UPDATE ON iptable
FOR EACH ROW
BEGIN 
	select isp into @nl_name from netlink where id = NEW.netlink_id;
	select id  into @nl_id   from iwg.netlink where isp = @nl_name;
	UPDATE iwg.iptable set netlink_id = @nl_id where ipnet = NEW.ipnet and 
		mask = NEW.mask;
	insert into sqllog (query) values 
	(CONCAT("update iptable set netlink_id=(select id from netlink where isp='",@nl_name,"') where ipnet='" ,OLD.ipnet,"' and mask=",OLD.mask,";"));
END;

CREATE TRIGGER iptable_delete AFTER DELETE ON iptable
FOR EACH ROW
BEGIN 
	DELETE from iwg.iptable where ipnet = OLD.ipnet and mask = OLD.mask;
	insert into sqllog (query) values 
	(CONCAT("delete from iptable where ipnet='" ,OLD.ipnet,"' and mask=",OLD.mask,";"));

END;


CREATE TRIGGER iptable_wl_insert AFTER INSERT ON iptable_wl
FOR EACH ROW
BEGIN
	select isp into @nl_name from netlink where id = NEW.netlink_id;
	select id  into @nl_id   from iwg.netlink where isp = @nl_name;
	INSERT INTO iwg.iptable_wl(ip_start,ip_end,ipnet,mask,netlink_id) VALUES (NEW.ip_start,NEW.ip_end,NEW.ipnet,NEW.mask,@nl_id);
	insert into sqllog (query) values 
	(CONCAT("insert into iptable_wl(ip_start,ip_end,ipnet,mask,netlink_id)value('",NEW.ip_start,"','",NEW.ip_end,"','",NEW.ipnet,"',",NEW.mask,",(select id from netlink where isp='",@nl_name,"'));"));
END;
--  when update , can only update netlink_id
CREATE TRIGGER iptable_wl_update AFTER UPDATE ON iptable_wl
FOR EACH ROW
BEGIN 
	select isp into @nl_name from netlink where id = NEW.netlink_id;
	select id  into @nl_id   from iwg.netlink where isp = @nl_name;
	UPDATE iwg.iptable_wl set netlink_id = nl_id where ipnet = OLD.ipnet and 
		mask = OLD.mask;
	insert into sqllog (query) values 
	(CONCAT("update iptable_wl set netlink_id=(select id from netlink where isp='",@nl_name,"') where ipnet='" ,OLD.ipnet,"' and mask=",OLD.mask,";"));
END;

CREATE TRIGGER iptable_wl_delete AFTER DELETE ON iptable_wl
FOR EACH ROW
BEGIN 
	DELETE from iwg.iptable_wl where ipnet = OLD.ipnet and mask = OLD.mask;
	insert into sqllog (query) values 
	(CONCAT("delete from iptable_wl where ipnet='" ,OLD.ipnet,"' and mask=",OLD.mask,";"));

END;


CREATE TRIGGER netlink_insert AFTER INSERT ON netlink
FOR EACH ROW
BEGIN
	INSERT INTO iwg.netlink(isp,region,typ) VALUES (NEW.isp,NEW.region,NEW.typ);
	insert into sqllog (query) values 
	(CONCAT("insert into netlink(isp,region,typ)value('",NEW.isp,"','",NEW.region,"','",NEW.typ,"');"));
END;
--  when update , can only update netlink_id
CREATE TRIGGER netlink_update AFTER UPDATE ON netlink
FOR EACH ROW
BEGIN 
	UPDATE iwg.netlink set isp=NEW.isp,region=NEW.region,typ=NEW.typ where isp=OLD.isp and region=OLD.region;
	insert into sqllog (query) values 
	(CONCAT("update netlink set isp='",NEW.isp,"',region='" ,NEW.region,"',typ='",NEW.typ,"' where isp='",OLD.isp,"' and region='",OLD.region,"';"));
END;

CREATE TRIGGER netlink_delete AFTER DELETE ON netlink
FOR EACH ROW
BEGIN 
	DELETE from iwg.netlink where isp = OLD.isp and region = OLD.region;
	insert into sqllog (query) values
       	(CONCAT("delete from netlink where isp='" ,OLD.isp,"' and region='",OLD.region,"';"));
END;



CREATE TRIGGER domain_insert AFTER INSERT ON domain
FOR EACH ROW
BEGIN
	select name into @dmpool_name from domain_pool where domain_pool.id = NEW.domain_pool_id;
	select id into @dmpool_id from iwg.domain_pool where name = @dmpool_name  ;
	INSERT INTO iwg.domain(domain,domain_pool_id) VALUES (NEW.domain,@dmpool_id);
	insert into sqllog (query) values 
	(CONCAT("insert into domain(domain,domain_pool_id)value('",NEW.domain,"',(select id from domain_pool where name='",@dmpool_name,"'));"));
END;

CREATE TRIGGER domain_update AFTER UPDATE ON domain
FOR EACH ROW
BEGIN
	select name into @dmpool_name from domain_pool where domain_pool.id = NEW.domain_pool_id;
	select id into @dmpool_id from iwg.domain_pool where name = @dmpool_name;
	update iwg.domain set domain_pool_id = @dmpool_id where domain = OLD.domain;
	insert into sqllog (query) values 
	(CONCAT("update domain set domain_pool_id=(select id from domain_pool where name ='",@dmpool_name,"') where domain='",OLD.domain,"';"));
END;

CREATE TRIGGER domain_delete AFTER DELETE ON domain
FOR EACH ROW
BEGIN
	delete from iwg.domain where domain = OLD.domain;
	insert into sqllog (query) values 
	(CONCAT("delete from domain where domain='",OLD.domain,"') ;"));
END;

CREATE TRIGGER tproxy_insert AFTER INSERT ON tproxy
FOR EACH ROW
BEGIN
	INSERT INTO iwg.natserver(name,addr,enable,unavailable) 
	VALUES (NEW.name,NEW.addr,NEW.enable,NEW.unavailable);
	insert into sqllog (query) values 
	(CONCAT("insert into natserver(name,addr,enable,unavailable)value('",NEW.name,"','",NEW.addr,"',",NEW.enable,",",NEW.unavailable,");"));
END;

--  when update , can only update addr
CREATE TRIGGER tproxy_update  AFTER UPDATE ON tproxy
FOR EACH ROW
BEGIN 
	UPDATE iwg.natserver set name = NEW.name,enable=NEW.enable,unavailable=NEW.unavailable where addr=OLD.addr;
	insert into sqllog (query) values 
	(CONCAT("update natserver set addr='",NEW.addr,"',enable=" ,NEW.enable,",unavailable=",NEW.unavailable," where name='",OLD.name,"';"));
END;

CREATE TRIGGER tproxy_delete AFTER DELETE ON tproxy
FOR EACH ROW
BEGIN 
	DELETE from iwg.natserver  where addr = OLD.addr;
	insert into sqllog (query) values 
	(CONCAT("delete from natserver where addr='" ,OLD.addr,"';"));
END;


CREATE TRIGGER outlink_insert AFTER INSERT ON outlink
FOR EACH ROW
BEGIN
	INSERT INTO iwg.outlink(name,addr,typ,enable,unavailable) VALUES (NEW.name,NEW.addr,NEW.typ,NEW.enable,NEW.unavailable);
	insert into sqllog (query) values 
	(CONCAT("insert into outlink(name,addr,typ,enable,unavailable)value('",NEW.name,"','",NEW.addr,"','",NEW.typ,"',",NEW.enable,",",NEW.unavailable,");"));
END;
--  when update , can only update netlink_id
CREATE TRIGGER outlink_update AFTER UPDATE ON outlink
FOR EACH ROW
BEGIN 
	UPDATE iwg.outlink set addr = NEW.addr,typ=NEW.typ,enable=NEW.enable,unavailable=NEW.unavailable where name = OLD.name;
	insert into sqllog (query) values 
	(CONCAT("update outlink set addr='",NEW.addr,"',typ='",NEW.typ,"',enable=",NEW.enable,",unavailable=",NEW.unavailable," where addr='",OLD.name,"';"));
END;

CREATE TRIGGER outlink_delete AFTER DELETE ON outlink
FOR EACH ROW
BEGIN 
	DELETE from iwg.outlink where addr = OLD.addr;
	insert into sqllog (query) values 
	(CONCAT("delete from outlink where addr='" ,OLD.addr,"';"));
END;


CREATE TRIGGER routeset_insert AFTER INSERT ON routeset
FOR EACH ROW
BEGIN
	INSERT INTO iwg.routeset(name,info) VALUES (NEW.name,NEW.info);
	insert into sqllog (query) values 
	(CONCAT("insert into routeset(name,info)value('",NEW.name,"','",NEW.info,"');"));
END;

CREATE TRIGGER routeset_update AFTER UPDATE ON routeset
FOR EACH ROW
BEGIN 
	UPDATE iwg.routeset set name = NEW.name,info = NEW.info  where name = OLD.name;
	insert into sqllog (query) values 
	(CONCAT("update routeset set name='",NEW.name,"',info='" ,NEW.info,"' where name='",OLD.name,"';"));
END;

CREATE TRIGGER routeset_delete AFTER DELETE ON routeset
FOR EACH ROW
BEGIN 
	DELETE from iwg.routeset where name = OLD.name;
	insert into sqllog (query) values 
	(CONCAT("delete from routeset where name='" ,OLD.name,"';"));

END;

CREATE TRIGGER route_insert AFTER INSERT ON route
FOR EACH ROW
BEGIN
	select name into @rs_name from  routeset    where  id = NEW.routeset_id;
	select name into @nl_name from  netlinkset  where  id = NEW.netlinkset_id;
	select name into @ol_name from  outlink     where  id = NEW.outlink_id;
	select id into @rs_id from iwg.routeset   where  name = @rs_name;
	select id into @nl_id from iwg.netlinkset where  name = @nl_name;
	select id into @ol_id from iwg.outlink    where  name = @ol_name;
	INSERT INTO iwg.route(routeset_id,netlinkset_id,outlink_id,enable,priority,score,unavailable) 
	VALUES (@rs_id,@nl_id,@ol_id,NEW.enable,NEW.priority,NEW.score,NEW.unavailable);
	insert into sqllog (query) values 
	(CONCAT("insert into route(routeset_id,netlinkset_id,outlink_id,enable,priority,score,unavailable)value(( select id from  routeset where name='",@rs_name,"'),( select id from netlinkset where name='",@nl_name,"'),( select id from outlink where name='",@ol_name,"'),",NEW.enable,",",NEW.priority,",",NEW.score,",",NEW.unavailable,");"));
END;

CREATE TRIGGER route_update AFTER UPDATE ON route
FOR EACH ROW
BEGIN
	select name into @rs_name     from  routeset    where  id = OLD.routeset_id;
	select name into @nl_name     from  netlinkset  where  id = OLD.netlinkset_id;
	select name into @ol_name_old from  outlink     where  id = OLD.outlink_id;
	select name into @ol_name     from  outlink     where  id = NEW.outlink_id;
	select id into @rs_id from iwg.routeset   where  name = @rs_name;
	select id into @nl_id from iwg.netlinkset where  name = @nl_name;
	select id into @ol_id from iwg.outlink    where  name = @ol_name;
	select id into @ol_id_old from iwg.outlink    where  name = @ol_name_old;
	update iwg.route set outlink_id=@ol_id,enable=NEW.enable,priority=NEW.priority,score=NEW.score,unavailable=NEW.unavailable where routeset_id = @rs_id and netlinkset_id = @nl_id and outlink_id = @ol_id_old;
	insert into sqllog (query) values 
	(CONCAT("update route set outlink_id=(select id from outlink where name='",@ol_name,"'),enable=",NEW.enable,",priority=",NEW.priority,",score=",NEW.score,",unavailable=",NEW.unavailable," where routeset_id=(select id from routeset where name='",@rs_name,"') and netlinkset_id =(select id from netlinkset where name='",@nl_name,"') and outlink_id=(select id from outlink where name='",@ol_name_old,"');"));
END;

CREATE TRIGGER route_delete AFTER DELETE ON route
FOR EACH ROW
BEGIN
	select name into @rs_name from  routeset    where  id = OLD.routeset_id;
	select name into @nl_name from  netlinkset  where  id = OLD.netlinkset_id;
	select name into @ol_name from  outlink     where  id = OLD.outlink_id;
	select id into @rs_id from iwg.routeset   where  name = @rs_name;
	select id into @nl_id from iwg.netlinkset where  name = @nl_name;
	select id into @ol_id from iwg.outlink    where  name = @ol_name;
	delete from iwg.route where netlinkset_id = @nl_id and routeset_id = @rs_id and outlink_id = @ol_id;
	insert into sqllog (query) values 
	(CONCAT("delete from route where outlink_id=(select id from outlink where name='",@ol_name,"') and routeset_id=(select id from routeset where name='",@rs_name,"') and netlinkset_id =(select id from netlinkset where name='",@nl_name,"');"));
END;

CREATE TRIGGER domainlink_insert AFTER INSERT ON domainlink
FOR EACH ROW
BEGIN
	select name into @dp_name from  domain_pool where  id = NEW.domain_pool_id;
	select name into @nl_name from  netlink     where  id = NEW.netlink_id;
	select name into @ns_name from  netlinkset  where  id = NEW.netlinkset_id;
	select id into @dp_id from iwg.domain_pool where  name = @dp_name;
	select id into @nl_id from iwg.netlink     where  name = @nl_name;
	select id into @ns_id from iwg.netlinkset  where  name = @ns_name;
	INSERT INTO iwg.domainlink(domain_pool_id,netlink_id,netlinkset_id,enable) VALUES 
	(@dp_id,@nl_id,@ns_id,NEW.enable);
	insert into sqllog (query) values 
	(CONCAT("insert into domainlink(domain_pool_id,netlink_id,netlinkset_id,enable)value((select id from  domain_pool where name='",@dp_name,"'),(select id from netlink where name='",@nl_name,"'),(select id from netlinkset where name='",@ns_name,"'),",NEW.enable,");"));
END;

CREATE TRIGGER domainlink_update AFTER UPDATE ON domainlink
FOR EACH ROW
BEGIN
	select name into @dp_name from  domain_pool where  id = OLD.domain_pool_id;
	select name into @nl_name from  netlink     where  id = OLD.netlink_id;
	select name into @ns_name from  netlinkset  where  id = NEW.netlinkset_id;
	select id into @dp_id from iwg.domain_pool where  name = @dp_name;
	select id into @nl_id from iwg.netlink     where  name = @nl_name;
	select id into @ns_id from iwg.netlinkset  where  name = @ns_name;
	update iwg.domainlink set netlinkset_id=@ns_id,enable=NEW.enable where domain_pool_id = @dp_id and netlink_id = @nl_id;
	insert into sqllog (query) values 
	(CONCAT("update domainlink set netlinkset_id=(select id from netlinkset where name='",@ns_name,"'),enable=",NEW.enable," where domain_pool_id=(select id from domain_pool where name='",@dp_name,"') and netlink_id =(select id from netlink where name='",@nl_name,"');"));
END;

CREATE TRIGGER domainlink_delete AFTER DELETE ON domainlink
FOR EACH ROW
BEGIN
	select name into @dp_name from  domain_pool where  id = OLD.domain_pool_id;
	select name into @nl_name from  netlink     where  id = OLD.netlink_id;
	select name into @ns_name from  netlinkset  where  id = OLD.netlinkset_id;
	select id into @dp_id from iwg.domain_pool where  name = @dp_name;
	select id into @nl_id from iwg.netlink     where  name = @nl_name;
	select id into @ns_id from iwg.netlinkset  where  name = @ns_name;
	delete from iwg.domainlink where domain_pool_id = @dp_id and netlink_id = @nl_id and netlinkset_id = @ns_id;
	insert into sqllog (query) values 
	(CONCAT("delete from domainlink where domain_pool_id=(select id from domain_pool where name='",@dp_name,"') and netlink_id=(select id from netlink where name='",@nl_name,"') and netlinkset_id=(select id from netlinkset where name='",@ns_name,"');"));
END;

CREATE TRIGGER domain_pool_insert AFTER INSERT ON domain_pool
FOR EACH ROW
BEGIN
	INSERT INTO iwg.domain_pool(name,info,enable,unavailable,domain_monitor) VALUES (NEW.name,NEW.info,NEW.enable,NEW.unavailable,NEW.domain_monitor);
	insert into sqllog (query) values 
	(CONCAT("insert into domain_pool(name,info,enable,unavailable,domain_monitor)value('",NEW.name,"','",NEW.info,"',",NEW.enable,",",NEW.unavailable,",",NEW.domain_monitor,");"));
END;

CREATE TRIGGER domain_pool_update AFTER UPDATE ON domain_pool
FOR EACH ROW
BEGIN 
	UPDATE iwg.domain_pool set name=NEW.name,info=NEW.info,enable=NEW.enable,unavailable=NEW.unavailable,domain_monitor=NEW.domain_monitor where name=OLD.name;
	insert into sqllog (query) values 
	(CONCAT("update domain_pool set name='",NEW.name,"',info='",NEW.info,"',enable=",NEW.enable,",unavailable=",NEW.unavailable,",domain_monitor=",NEW.domain_monitor," where name='",OLD.name,"';"));
END;

CREATE TRIGGER domain_pool_delete AFTER DELETE ON domain_pool
FOR EACH ROW
BEGIN 
	DELETE from iwg.domain_pool where name = OLD.name;
	insert into sqllog (query) values 
	(CONCAT("delete from domain_pool where name='" ,OLD.name,"';"));

END;

CREATE TRIGGER ldns_insert AFTER INSERT ON ldns
FOR EACH ROW
BEGIN
	INSERT INTO iwg.ldns(name,addr,typ,enable,unavailable) VALUES (NEW.name,NEW.addr,NEW.typ,NEW.enable,NEW.unavailable);
	insert into sqllog (query) values 
	(CONCAT("insert into ldns(name,addr,typ,enable,unavailable)value('",NEW.name,"','",NEW.addr,"','",NEW.typ,"',",NEW.enable,",",NEW.unavailable,");"));
END;

CREATE TRIGGER ldns_update AFTER UPDATE ON ldns
FOR EACH ROW
BEGIN 
	UPDATE iwg.ldns set name=NEW.name,addr=NEW.addr,typ=NEW.typ,enable=NEW.enable,unavailable=NEW.unavailable where name=OLD.name;
	insert into sqllog (query) values 
	(CONCAT("update ldns set name='",NEW.name,"',addr='",NEW.addr,"',typ='",NEW.typ,"',enable=",NEW.enable,",unavailable=",NEW.unavailable," where name='",OLD.name,"';"));
END;

CREATE TRIGGER ldns_delete AFTER DELETE ON ldns
FOR EACH ROW
BEGIN 
	DELETE from iwg.ldns where name = OLD.name;
	insert into sqllog (query) values 
	(CONCAT("delete from ldns where name='" ,OLD.name,"';"));
END;

CREATE TRIGGER natlink_insert AFTER INSERT ON natlink
FOR EACH ROW
BEGIN
	select name into @ol_name from  outlink     where  id = NEW.outlink_id;
	select name into @tp_name from  tproxy      where  id = NEW.tproxy_id;
	select id into @ol_id from iwg.outlink    where  name = @ol_name;
	select id into @tp_id from iwg.natserver  where  name = @tp_name;
	INSERT INTO iwg.natlink(outlink_id,natserver_id,addr,status,gw) 
	VALUES (@ol_id,@tp_id,NEW.addr,NEW.status,NEW.gw);
	insert into sqllog (query) values 
	(CONCAT("insert into natlink(outlink_id,natserver_id,addr,status,gw)value((select id from outlink where name='",@ol_name,"'),(select id from natserver where name='",@tp_name,"'),'",NEW.addr,"',",NEW.status,",'",NEW.gw,"');"));
END;

CREATE TRIGGER natlink_update AFTER UPDATE ON natlink
FOR EACH ROW
BEGIN
	select name into @ol_name from  outlink     where  id = NEW.outlink_id;
	select name into @tp_name from  tproxy      where  id = NEW.tproxy_id;
	select id into @ol_id from iwg.outlink    where  name = @ol_name;
	select id into @tp_id from iwg.natserver  where  name = @tp_name;
	update iwg.natlink set addr=NEW.addr,status=NEW.status,gw=NEW.gw where natserver_id= @tp_id and outlink_id = @ol_id_old;
	insert into sqllog (query) values 
	(CONCAT("update natlink set addr='",NEW.addr,"',status=",NEW.status,",gw='",NEW.gw,"' where natserver_id=(select id from natserver where name='",@tp_name,"') and outlink_id=(select id from outlink where name='",@ol_name,"');"));
END;

CREATE TRIGGER natlink_delete AFTER DELETE ON natlink
FOR EACH ROW
BEGIN
	select name into @ol_name from  outlink     where  id = OLD.outlink_id;
	select name into @tp_name from  tproxy      where  id = OLD.tproxy_id;
	select id into @ol_id from iwg.outlink    where  name = @ol_name;
	select id into @tp_id from iwg.natserver  where  name = @tp_name;
	delete from iwg.natlink where outlink_id=@ol_id and natserver_id=@tp_id;
	insert into sqllog (query) values 
	(CONCAT("delete from natlink where outlink_id=(select id from outlink where name='",@ol_name,"') and natserver_id=(select id from natserver where name='",@tp_name,"');"));
END;

CREATE TRIGGER netlinkset_insert AFTER INSERT ON netlinkset
FOR EACH ROW
BEGIN
	INSERT INTO iwg.netlinkset(name) VALUES (NEW.name);
	insert into sqllog (query) values 
	(CONCAT("insert into netlinkset(name)value('",NEW.name,"');"));
END;

CREATE TRIGGER netlinkset_update AFTER UPDATE ON netlinkset
FOR EACH ROW
BEGIN 
	UPDATE iwg.netlinkset set name = NEW.name where name = OLD.name;
	insert into sqllog (query) values 
	(CONCAT("update netlinkset set name='",NEW.name,"' where name='",OLD.name,"';"));
END;

CREATE TRIGGER netlinkset_delete AFTER DELETE ON netlinkset
FOR EACH ROW
BEGIN 
	DELETE from iwg.netlinkset where name = OLD.name;
	insert into sqllog (query) values 
	(CONCAT("delete from netlinkset where name='" ,OLD.name,"';"));
END;

CREATE TRIGGER policy_insert AFTER INSERT ON policy
FOR EACH ROW
BEGIN
	INSERT INTO iwg.policy(name) VALUES (NEW.name);
	insert into sqllog (query) values 
	(CONCAT("insert into policy(name)value('",NEW.name,"');"));
END;

CREATE TRIGGER policy_update AFTER UPDATE ON policy
FOR EACH ROW
BEGIN 
	UPDATE iwg.policy set name = NEW.name where name = OLD.name;
	insert into sqllog (query) values 
	(CONCAT("update policy set name='",NEW.name,"' where name='",OLD.name,"';"));
END;

CREATE TRIGGER policy_delete AFTER DELETE ON policy
FOR EACH ROW
BEGIN 
	DELETE from iwg.policy where name = OLD.name;
	insert into sqllog (query) values 
	(CONCAT("delete from policy where name='" ,OLD.name,"';"));
END;

CREATE TRIGGER viewer_insert AFTER INSERT ON viewer
FOR EACH ROW
BEGIN
	select name into @cs_name from  clientset    where  id = NEW.clientset_id;
	select name into @dp_name from  domain_pool  where  id = NEW.domain_pool_id;
	select name into @rs_name from  routeset     where  id = NEW.routeset_id;
	select name into @pc_name from  policy       where  id = NEW.policy_id;
	select id into @cs_id from iwg.clientset   where  name = @cs_name;
	select id into @dp_id from iwg.domain_pool where  name = @dp_name;
	select id into @rs_id from iwg.routeset    where  name = @rs_name;
	select id into @pc_id from iwg.policy      where  name = @pc_name;
	INSERT INTO iwg.viewer(clientset_id,domain_pool_id,routeset_id,policy_id,enable)
	VALUES (@cs_id,@dp_id,@rs_id,@pc_id,NEW.enable);
	insert into sqllog (query) values 
	(CONCAT("insert into viewer(clientset_id,domain_pool_id,routeset_id,policy_id,enable)value((select id from clientset where name='",@cs_name,"'),(select id from domain_pool where name='",@dp_name,"'),(select id from  routeset where name='",@rs_name,"'),(select id from policy where name='",@pc_name,"'),",NEW.enable,");"));
END;

CREATE TRIGGER viewer_update AFTER UPDATE ON viewer
FOR EACH ROW
BEGIN
	select name into @cs_name from  clientset    where  id = OLD.clientset_id;
	select name into @dp_name from  domain_pool  where  id = OLD.domain_pool_id;
	select name into @rs_name from  routeset     where  id = NEW.routeset_id;
	select name into @pc_name from  policy       where  id = NEW.policy_id;
	select id into @cs_id from iwg.clientset   where  name = @cs_name;
	select id into @dp_id from iwg.domain_pool where  name = @dp_name;
	select id into @rs_id from iwg.routeset    where  name = @rs_name;
	select id into @pc_id from iwg.policy      where  name = @pc_name;
	update iwg.viewer set routeset_id=@rs_id,policy_id=@pc_id,enable=NEW.enable where  clientset_id=@cs_id and domain_pool_id=@dp_id;
	insert into sqllog (query) values 
	(CONCAT("update viewer set routeset_id=(select id from routeset where name='",@rs_name,"'),policy_id=(select id from policy where name='",@pc_name,"'),enable=",NEW.enable," where clientset_id=(select id from clientset where name='",@cs_name,"') and domain_pool_id=(select id from domain_pool where name='",@dp_name,"');"));
END;

CREATE TRIGGER viewer_delete AFTER DELETE ON viewer
FOR EACH ROW
BEGIN
	select name into @cs_name from  clientset    where  id = OLD.clientset_id;
	select name into @dp_name from  domain_pool  where  id = OLD.domain_pool_id;
	select id into @cs_id from iwg.clientset   where  name = @cs_name;
	select id into @dp_id from iwg.domain_pool where  name = @dp_name;
	delete from iwg.viewer where routeset_id = @rs_id and clientset_id = @cs_id;
	insert into sqllog (query) values
	(CONCAT("delete from viewer where clientset_id=(select id from clientset where name='",@cs_name,"') and routeset_id=(select id from routeset where name='",@rs_name,"');"));
END;

CREATE TRIGGER policy_detail_insert AFTER INSERT ON policy_detail
FOR EACH ROW
BEGIN
	select name into @ln_name from  ldns         where  id = NEW.ldns_id;
	select name into @pc_name from  policy       where  id = NEW.policy_id;
	select id into @ln_id from iwg.ldns	   where  name = @ln_name;
	select id into @pc_id from iwg.policy      where  name = @pc_name;
	INSERT INTO iwg.policy_detail(policy_id,policy_sequence,enable,priority,weight,op,op_typ,ldns_id)
	VALUES (@pc_id,NEW.policy_sequence,NEW.enable,NEW.priority,NEW.weight,NEW.op,NEW.op_typ,@ln_id);
	insert into sqllog (query) values 
	(CONCAT("insert into policy_detail(policy_id,policy_sequence,enable,priority,weight,op,op_typ,ldns_id)value((select id from policy where name='",@pc_name,"'),",NEW.policy_sequence,",",NEW.enable,",",NEW.priority,",",NEW.weight,",'",NEW.op,"','",NEW.op_typ,"',(select id from ldns where name='",@ln_name,"'));"));
END;


-- can not change ldns_id
CREATE TRIGGER policy_detail_update AFTER UPDATE ON policy_detail
FOR EACH ROW
BEGIN
	select name into @ln_name from  ldns       where  id = OLD.ldns_id;
	select name into @pc_name from  policy     where  id = OLD.policy_id;
	select id into @ln_id from iwg.ldns	   where  name = @ln_name;
	select id into @pc_id from iwg.policy      where  name = @pc_name;
	update iwg.policy_detail set policy_sequence=NEW.policy_sequence,enable=NEW.enable,priority=NEW.priority,weight=NEW.weight,op=NEW.op,op_typ=NEW.op_typ  where  policy_id=@pc_id and ldns_id =@ln_id;
	insert into sqllog (query) values 
	(CONCAT("update policy_detail set policy_sequence=",NEW.policy_sequence,",enable=",NEW.enable,",priority=",NEW.priority,",weight=",NEW.weight,",op='",NEW.op,"',op_typ='",NEW.op_typ,"' where policy_id=(select id from policy where name='",@pc_name,"') and ldns_id=(select ldns_id from ldns where name='",@ln_name,"');"));
END;

CREATE TRIGGER policy_detail_delete AFTER DELETE ON policy_detail
FOR EACH ROW
BEGIN
	select name into @ln_name from  ldns       where  id = OLD.ldns_id;
	select name into @pc_name from  policy     where  id = OLD.policy_id;
	select id into @ln_id from iwg.ldns	   where  name = @ln_name;
	select id into @pc_id from iwg.policy      where  name = @pc_name;
	delete from iwg.policy_detail where  policy_id=@pc_id and ldns_id =@ln_id;
	insert into sqllog (query) values
	(CONCAT("delete from policy_detail where policy_id=(select id from policy where name='",@pc_name,"') and ldns_id=(select ldns_id from ldns where name='",@ln_name,"');"));
END;


 $$
DELIMITER ;
