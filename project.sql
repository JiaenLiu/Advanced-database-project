-- This file is written by Jiaen LIU and Jin-Young BAE and only for the Advanced databases' project.

ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY' ;

-- Oracle does not support constraints and defaults in type specifications. However, you can specify the constraints and defaults when creating the tables:
-- From https://docs.oracle.com/en/database/oracle/oracle-database/18/adobj/constraints-on-objects.html#GUID-7191723A-4956-406B-A527-E2A4C288AE04
-- To add constrains on types, please follow the link above.

-- Create the address type
create type address_type as object 
(
    country varchar2(30),
    city varchar2(30),
    postcode number,
    street_addr varchar2(50)
    -- constrain 
);
/
-- Describe the address type
desc address_type;

-- Create the company table
-- drop table company;
create table company 
(
    comp_id number,
    comp_name varchar2(30),
    comp_balance number,
    comp_address address_type,
    thea_id number,
    constraint pk_comp_id primary key (comp_id),
    constraint nn_comp_name check (comp_name is not null),
    constraint nn_comp_balance check (comp_balance is not null)
);
desc company;

-- Create the show table the relationship between company and show is 1 to n
-- gz means greater than zero.
drop table show;
create table show (
    show_id number,
    show_name varchar2(30),
    show_genre varchar2(30),
    show_cost number,
    comp_id number,
    constraint pk_show_id primary key(show_id),
    constraint nn_show_cost check(show_cost is not null),
    -- constraint nn_show_name check(show_name is not null),
    -- constraint nn_show_genre check(show_genre is not null),
    constraint nn_comp_id check (comp_id is not null),
    constraint gz_show_cost check(show_cost > 0),
    CONSTRAINT fk_comp
    FOREIGN KEY (comp_id)
    REFERENCES company(comp_id)
);

desc show;
-- Create the table of theather
create table theather 
(
    thea_id number,
    thea_name varchar2(30),
    thea_address address_type,
    comp_id number,
    constraint pk_thea_id primary key(thea_id),
    constraint nn_t_comp_id check (comp_id is not null),
    CONSTRAINT fk_t_comp
    FOREIGN KEY (comp_id)
    REFERENCES company(comp_id)
);

desc theather;
-- Create the table of grant
-- The unit of donation is euro
create table grant_ 
(
    grant_id number,
    donor_name varchar2(30),
    grant_type varchar2(30),
    total_amount number,
    total_period_year number,
    period_time_month number,
    thea_id number,
    comp_id number,
    constraint pk_grand_id primary key(grant_id),
    constraint nn_total_amount check(total_amount is not null),
    constraint nn_total_period_year check (total_period_year is not null),
    constraint nn_period_time_month check (period_time_month is not null),
    CONSTRAINT fk_thea
    FOREIGN KEY (thea_id)
    REFERENCES theather(thea_id),
    CONSTRAINT fk_g_comp_id  foreign key (comp_id) references company(comp_id)
);

desc grant_;
-- Create table room

create table room 
(
    room_id number,
    room_name varchar2(30),
    room_capacity number,
    room_cost number,
    thea_id number not null,
    comp_id number,
    constraint pk_room_id primary key(room_id),
    constraint nn_room_capacity check (room_capacity is not null),
    constraint nn_room_cost check (room_cost is not null),
    constraint nn_r_thea_id check (thea_id is not null),
    constraint fk_r_thea_id foreign key (thea_id) references theather(thea_id),
    constraint fk_r_comp_id foreign key (comp_id) references company(comp_id)
);

desc room;

-- Create the table of performanc. The relationship between performance and actor is n to 1.
-- N actors can perform one show in the same time. 
-- But in the same time, multiple shows can take place in different places and by mulitple actors(must be different) 
-- Also we need the conflict detection about the room usage by trigger

create table performance_ 
(
    perf_id number,
    perf_begin varchar2(30), -- The timestamp string like 20/09/2022 19:30:33
    perf_end varchar2(30), -- The timestamp string
    perf_name varchar2(20),
    reserved_sits number,
    room_id number not null,
    thea_id number not null,
    show_id number not null,
    constraint pk_perf_id primary key(perf_id),
    constraint nn_perf_begin check (perf_begin is not null),
    constraint nn_perf_end check (perf_end is not null),
    constraint nn_reserved_sits check (reserved_sits is not null),
    constraint fk_p_room_id foreign key (room_id) references room(room_id),
    constraint fk_p_thea_id foreign key (thea_id) references theather(thea_id),
    constraint fk_p_show_id foreign key (show_id) references show(show_id)
); 

desc performance_;

-- The schedual table of the performances
-- !!!Need to be implemented and discussed
create table schedual 
(
    perf_id number,
    room_id number,
    thea_id number,
    constraint pk_schedual primary key (perf_id,room_id)
);
desc schedual;


-- Whether we need that stracture? Need to discuss.
-- Create the table of actor(actress)
drop table actor;

create table actor 
(
    act_id number,
    act_name varchar2(30),
    act_price number,
    gender varchar2(10),
    act_type varchar2(30),
    act_age number,
    act_balance number,
    -- perf_id number not null,
    constraint pk_act_id primary key(act_id),
    constraint nn_act_price check (act_price is not null),
    constraint nn_act_balance check (act_balance is not null)
    -- constraint fk_a_perf_id foreign key (perf_id) references performance_(perf_id)
);
desc actor;
-- Test data


-- Table staff list is designed to store the staff list in performance. 
-- perf_id's functions is to identify the different performances
create table staff_list 
(
    perf_id number not null,
    act_id number not null,
    room_id number not null,
    thea_id number not null,
    constraint pk_staff_list primary key(perf_id, act_id)
);

desc staff_list;

desc actor;

-- create the table of ticket
create or replace type ticket as object
(
    ticket_name varchar2(30),
    ticket_type varchar2(20),
    ticket_s_price number
    -- ticket_discount float
);
/

desc ticket;

-- create the sale table
-- real price is generated by stand price times discount when insert the sales records 
-- price is generated by a trigger when inserting row into this sales table

create table sales 
(
    sale_ticket ticket,
    comp_id number not null,
    price number
);


desc actor;
-- Create the table of transactions 
-- 
create table transaction_ 
(
    comp_id number not null,
    an_comp_id number,
    act_id number,
    thea_id number,
    amount_money number not null,
    constraint fk_t_comp_id foreign key (comp_id) references company(comp_id),
    constraint fk_t_an_comp_id foreign key (an_comp_id) references company(comp_id),
    constraint fk_t_act_id foreign key (act_id) references actor(act_id),
    constraint fk_t_thea_id foreign key (thea_id) references theather(thea_id),
    constraint gz_amount_money check (amount_money > 0)
);

desc transaction_;
-- Another solution:
-- We make all the meta-table (show, performance and actor) into class and object. 
-- Using these objects to create the table of them and store them in the transaction table.

-- Tasks:
-- 1. Fill the tables with some test data

-- Test data for company
insert into company(comp_id, comp_name, comp_balance, comp_address, thea_id) values (1, 'company1', 3000000, null, 1);
insert into company(comp_id, comp_name, comp_balance, comp_address, thea_id) values (2, 'company2', 3000000, null, 2);
insert into company(comp_id, comp_name, comp_balance, comp_address, thea_id) values (3, 'company3', 3000000, null, 3);
insert into company(comp_id, comp_name, comp_balance, comp_address, thea_id) values (4, 'company4', 3000000, null, 4);
insert into company(comp_id, comp_name, comp_balance, comp_address, thea_id) values (5, 'company5', 3000000, null, 5);

-- Test data for theather
insert into theather(thea_id, thea_name, thea_address, comp_id) values (1, 'theather1', null, 1);
insert into theather(thea_id, thea_name, thea_address, comp_id) values (2, 'theather2', null, 2);
insert into theather(thea_id, thea_name, thea_address, comp_id) values (3, 'theather3', null, 3);
insert into theather(thea_id, thea_name, thea_address, comp_id) values (4, 'theather4', null, 4);
insert into theather(thea_id, thea_name, thea_address, comp_id) values (5, 'theather5', null, 5);

-- Test data for room
insert into room(room_id, room_name, room_capacity, room_cost, thea_id, comp_id) values (1, 'room1',100, 10000, 1, 1);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id, comp_id) values (2, 'room2',100, 15000, 1, 1);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id, comp_id) values (3, 'room3',100, 10300, 1, 1);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id, comp_id) values (4, 'room4',100, 18000, 2, 2);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id, comp_id) values (5, 'room5',80, 10000, 2, 2);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id, comp_id) values (6, 'room6',100, 10000, 2, 2);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id, comp_id) values (7, 'room7',75, 10000, 3, 3);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id, comp_id) values (8, 'room8',90, 10000, 3, 3);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id, comp_id) values (9, 'room9',100, 13000, 3, 3);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id, comp_id) values (10, 'room10',100, 10000, 4, 4);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id, comp_id) values (11, 'room11',90, 10000, 4, 4);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id, comp_id) values (12, 'room12',84, 10000, 4, 4);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id, comp_id) values (13, 'room13',72, 10000, 5, 5);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id, comp_id) values (14, 'room14',89, 10000, 5, 5);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id, comp_id) values (15, 'room15',71, 10000, 5, 5);

-- Test data for show
insert into show(show_id, show_name, show_genre, show_cost, comp_id) values (1, 'show1', 'genre1', 10000, 1);
insert into show(show_id, show_name, show_genre, show_cost, comp_id) values (2, 'show2', 'genre2', 10000, 1);
insert into show(show_id, show_name, show_genre, show_cost, comp_id) values (3, 'show3', 'genre1', 10000, 1);
insert into show(show_id, show_name, show_genre, show_cost, comp_id) values (4, 'show4', 'genre3', 10000, 2);
insert into show(show_id, show_name, show_genre, show_cost, comp_id) values (5, 'show5', 'genre2', 10000, 2);
insert into show(show_id, show_name, show_genre, show_cost, comp_id) values (6, 'show6', 'genre3', 10000, 2);
insert into show(show_id, show_name, show_genre, show_cost, comp_id) values (7, 'show7', 'genre1', 10000, 3);
insert into show(show_id, show_name, show_genre, show_cost, comp_id) values (8, 'show8', 'genre2', 10000, 3);
insert into show(show_id, show_name, show_genre, show_cost, comp_id) values (9, 'show9', 'genre3', 10000, 3);
insert into show(show_id, show_name, show_genre, show_cost, comp_id) values (10, 'show10', 'genre1', 10000, 4);
insert into show(show_id, show_name, show_genre, show_cost, comp_id) values (11, 'show11', 'genre2', 10000, 4);
insert into show(show_id, show_name, show_genre, show_cost, comp_id) values (12, 'show12', 'genre3', 10000, 4);
insert into show(show_id, show_name, show_genre, show_cost, comp_id) values (13, 'show13', 'genre1', 10000, 5);
insert into show(show_id, show_name, show_genre, show_cost, comp_id) values (14, 'show14', 'genre2', 10000, 5);
insert into show(show_id, show_name, show_genre, show_cost, comp_id) values (15, 'show15', 'genre3', 10000, 5);

-- Test data for grant_
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id, comp_id) values (1, 'donor1', 'type1', 100000, 5, 12, 1, 1);
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id, comp_id) values (2, 'donor2', 'type2', 120000, 0, 6, 1, 1);
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id, comp_id) values (3, 'donor3', 'type3', 120000, 0, 3, 1, 1);
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id, comp_id) values (4, 'donor4', 'type1', 100000, 5, 12, 2, 2);
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id, comp_id) values (5, 'donor5', 'type2', 120000, 0, 4, 2, 2);
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id, comp_id) values (6, 'donor6', 'type3', 120000, 0, 3, 2, 2);
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id, comp_id) values (7, 'donor7', 'type1', 100000, 5, 12, 3, 3);
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id, comp_id) values (8, 'donor8', 'type2', 120000, 0, 4, 3, 3);
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id, comp_id) values (9, 'donor9', 'type3', 120000, 0, 3, 4, 4);
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id, comp_id) values (10, 'donor10', 'type1', 100000, 5, 12, 5, 5);

-- Test data for performance_
insert into performance_(perf_id, perf_begin, perf_end, perf_name, reserved_sits, room_id, thea_id, comp_id) values (1, '2018-01-01 00:00:00', '2018-01-01 00:00:00', 'perf1', 100, 1, 1, 1);


-- TODO 

-- 2. Create the trigger to check the conflict of the room usage

-- TODO

-- 3. Create the trigger to check the balance of the actor No decreasing.

-- TODO

-- 4. Create the trigger to check the balance of the company Enough money to pay the actor.

-- TODO 

-- Create the trigger to check the reserved sit is not over the capacity of the room

-- Create the trigger to check the room useage is not overlaped.

-- 5. And more to be discussed.
-- 6. Create the trigger to auto generate the real price of the ticket

-- TODO

-- 7. Create the trigger to auto pay the actor

-- TODO

-- 8. Create the trigger to auto pay the company (ticket price)

-- TODO

-- 10. To be discussed.
