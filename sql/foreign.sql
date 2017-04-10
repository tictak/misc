drop database if exists sql_test;
create database sql_test;
use sql_test;

drop table if exists teacher;
drop table if exists class;

create table teacher (
	id int,
	name varchar(126),
	primary key(id)
)DEFAULT CHARSET=utf8 ENGINE=InnoDB;

create table class (
	id int,
	name varchar(126),
	t_id int,
	primary key(id),
	foreign key (t_id) references  teacher(id)  on delete cascade on update cascade
)DEFAULT CHARSET=utf8 ENGINE=InnoDB;

insert into teacher values(1,"yang"),(2,"yan");
insert into class values(1,"math",1),(2,"english",2);
