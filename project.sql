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
    constraint pk_grand_id primary key(grant_id),
    constraint nn_total_amount check(total_amount is not null),
    constraint nn_total_period_year check (total_period_year is not null),
    constraint nn_period_time_month check (period_time_month is not null),
    CONSTRAINT fk_thea
    FOREIGN KEY (thea_id)
    REFERENCES theather(thea_id)
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
    constraint fk_r_thea_id foreign key (thea_id) references theather(thea_id)
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


