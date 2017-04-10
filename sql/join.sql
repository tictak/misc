drop database if exists sql_test;
create database sql_test;
use sql_test;

drop table if exists A;
drop table if exists B;
drop table if exists C;

create table A (
	id int
);
create table B (
	id int
);
create table C (
	id int
);
insert into A values (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);
insert into B values (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);
insert into C values (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);

select * from A join B on A.id = B.id  join C on A.id = C.id;
select * from A join B on A.id != B.id  join C on A.id != C.id;
