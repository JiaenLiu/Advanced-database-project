-- This file is written by Jiaen LIU and Jin-Young BAE and only for the Advanced databases' project.

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';

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
    constraint pk_comp_id primary key (comp_id),
    constraint nn_comp_name check (comp_name is not null),
    constraint nn_comp_balance check (comp_balance is not null)
);
desc company;

-- Create the show table the relationship between company and show is 1 to n
-- gz means greater than zero.
create table show (
    show_id number,
    show_name varchar2(30),
    show_genre varchar2(30),
    show_cost number,
    nb_actors number,
    comp_id number,
    constraint pk_show_id primary key(show_id),
    constraint nn_show_cost check(show_cost is not null),
    constraint nn_comp_id check (comp_id is not null),
    constraint gz_show_cost check(show_cost > 0),
    constraint fk_comp foreign key (comp_id) references company(comp_id)
);

desc show;

-- Create the table of theater
create table theater 
(
    thea_id number,
    thea_name varchar2(30),
    thea_address address_type,
    comp_id number,
    constraint pk_thea_id primary key(thea_id),
    constraint nn_t_comp_id check (comp_id is not null),
    constraint fk_t_comp foreign key (comp_id) references company(comp_id)
);

desc theater;

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
    constraint fk_thea foreign key (thea_id) references theater(thea_id)
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
    constraint pk_room_id primary key(room_id),
    constraint nn_room_capacity check (room_capacity is not null),
    constraint nn_room_cost check (room_cost is not null),
    constraint nn_r_thea_id check (thea_id is not null),
    constraint fk_r_thea_id foreign key (thea_id) references theater(thea_id)
);

desc room;

-- Create the table of performanc. The relationship between performance and actor is n to 1.
-- N actors can perform one show in the same time. 
-- But in the same time, multiple shows can take place in different places and by mulitple actors(must be different) 
-- Also we need the conflict detection about the room usage by trigger

create table performance_ 
(
    perf_id number,
    perf_begin date, -- The timestamp string like 20/09/2022 19:30:00
    perf_end date, 
    reserved_sits number default 0,
    room_id number not null,
    show_id number not null,
    discount number(1),
    constraint pk_perf_id primary key(perf_id),
    constraint nn_perf_begin check (perf_begin is not null),
    constraint nn_perf_end check (perf_end is not null),
    constraint nn_reserved_sits check (reserved_sits is not null),
    constraint nn_discount check (discount is not null),
    constraint fk_p_room_id foreign key (room_id) references room(room_id),
    constraint fk_p_show_id foreign key (show_id) references show(show_id)
); 

desc performance_;

-- Create the table of actor
drop table actor;

create table actor 
(
    act_id number,
    act_name varchar2(30),
    act_price number,
    gender varchar2(10),
    act_age number,
    act_balance number,
    constraint pk_act_id primary key(act_id),
    constraint nn_act_price check (act_price is not null),
    constraint nn_act_balance check (act_balance is not null)
);
desc actor;

-- Table staff list is designed to store the staff list in performance. 
-- perf_id's functions is to identify the different performances
create table staff_list 
(
    perf_id number not null,
    act_id number not null,
    constraint pk_staff_list primary key(perf_id, act_id),
    constraint fk_sl_perf_id foreign key (perf_id) references performance_(perf_id),
    constraint fk_sl_act_id foreign key (act_id) references actor(act_id)
);

desc staff_list;

-- create the table ticket
create table ticket (
    ticket_type_id number,
    ticket_type varchar2(10),
    ticket_s_price number,
    perf_id number,
    constraint pk_ticket_type_id primary key(ticket_type_id),
    constraint nn_ticket_type check(ticket_type in ('normal', 'reduced')),
    constraint nn_ticket_s_price check (ticket_s_price is not null),
    constraint fk_t_perf_id foreign key (perf_id) references performance_(perf_id)
);

desc ticket;

-- create the sale table
-- real price is generated by stand price times discount when insert the sales records 
-- price is generated by a trigger when inserting row into this sales table
create table sales (
    sales_id number,
    ticket_type_id number,
    ticket_num number,
    sales_price number, -- The real price of the ticket needs to be calculated by trigger
    sales_time date,
    constraint pk_sales_id primary key(sales_id),
    constraint nn_ticket_num check (ticket_num is not null),
    constraint nn_sales_time check (sales_time is not null),
    constraint fk_s_ticket_type_id foreign key (ticket_type_id) references ticket(ticket_type_id)
);

desc sales;

-- Create the table of transactions 
create table transactions
(
    from_comp_id number not null,
    to_comp_id number,
    to_act_id number,
    thea_id number,
    amount_money number not null,
    constraint fk_t_from_comp_id foreign key (from_comp_id) references company(comp_id),
    constraint fk_t_to_comp_id foreign key (to_comp_id) references company(comp_id),
    constraint fk_t_to_act_id foreign key (to_act_id) references actor(act_id),
    constraint fk_t_thea_id foreign key (thea_id) references theater(thea_id),
    constraint gz_amount_money check (amount_money > 0)
);

desc transactions;
-- Another solution:
-- We make all the meta-table (show, performance and actor) into class and object. 
-- Using these objects to create the table of them and store them in the transaction table.

-- Create the table of refund
create table refund (
    sales_id number,
    sales_price number
);

-------------------------------------------------------------------TEST DATA---------------------------------------------------------------------------------------
-- Test data for company
insert into company(comp_id, comp_name, comp_balance, comp_address) values (1, 'company1', 3000000, null);
insert into company(comp_id, comp_name, comp_balance, comp_address) values (2, 'company2', 3000000, null);
insert into company(comp_id, comp_name, comp_balance, comp_address) values (3, 'company3', 3000000, null);
insert into company(comp_id, comp_name, comp_balance, comp_address) values (4, 'company4', 3000000, null);
insert into company(comp_id, comp_name, comp_balance, comp_address) values (5, 'company5', 3000000, null);

-- Test data for theather
insert into theater(thea_id, thea_name, thea_address, comp_id) values (1, 'theater1', null, 1);
insert into theater(thea_id, thea_name, thea_address, comp_id) values (2, 'theater2', null, 2);
insert into theater(thea_id, thea_name, thea_address, comp_id) values (3, 'theater3', null, 3);
insert into theater(thea_id, thea_name, thea_address, comp_id) values (4, 'theater4', null, 4);
insert into theater(thea_id, thea_name, thea_address, comp_id) values (5, 'theater5', null, 5);

-- Test data for room
insert into room(room_id, room_name, room_capacity, room_cost, thea_id) values (1, 'room1',100, 10000, 1);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id) values (2, 'room2',100, 15000, 1);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id) values (3, 'room3',100, 10300, 1);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id) values (4, 'room4',100, 18000, 2);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id) values (5, 'room5',80, 10000, 2);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id) values (6, 'room6',100, 10000, 2);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id) values (7, 'room7',75, 10000, 3);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id) values (8, 'room8',90, 10000, 3);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id) values (9, 'room9',100, 13000, 3);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id) values (10, 'room10',100, 10000,4);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id) values (11, 'room11',90, 10000, 4);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id) values (12, 'room12',84, 10000, 4);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id) values (13, 'room13',72, 10000, 5);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id) values (14, 'room14',89, 10000, 5);
insert into room(room_id, room_name, room_capacity, room_cost, thea_id) values (15, 'room15',71, 10000, 5);

-- Test data for show
insert into show(show_id, show_name, show_genre, show_cost, comp_id, nb_actors) values (1, 'show1', 'genre1', 10000, 1, 3);
insert into show(show_id, show_name, show_genre, show_cost, comp_id, nb_actors) values (2, 'show2', 'genre2', 10000, 1, 3);
insert into show(show_id, show_name, show_genre, show_cost, comp_id, nb_actors) values (3, 'show3', 'genre1', 10000, 1, 3);
insert into show(show_id, show_name, show_genre, show_cost, comp_id, nb_actors) values (4, 'show4', 'genre3', 10000, 2, 3);
insert into show(show_id, show_name, show_genre, show_cost, comp_id, nb_actors) values (5, 'show5', 'genre2', 10000, 2, 3);
insert into show(show_id, show_name, show_genre, show_cost, comp_id, nb_actors) values (6, 'show6', 'genre3', 10000, 2, 3);
insert into show(show_id, show_name, show_genre, show_cost, comp_id, nb_actors) values (7, 'show7', 'genre1', 10000, 3, 3);
insert into show(show_id, show_name, show_genre, show_cost, comp_id, nb_actors) values (8, 'show8', 'genre2', 10000, 3, 3);
insert into show(show_id, show_name, show_genre, show_cost, comp_id, nb_actors) values (9, 'show9', 'genre3', 10000, 3, 3);
insert into show(show_id, show_name, show_genre, show_cost, comp_id, nb_actors) values (10, 'show10', 'genre1', 10000, 4, 3);
insert into show(show_id, show_name, show_genre, show_cost, comp_id, nb_actors) values (11, 'show11', 'genre2', 10000, 4, 3);
insert into show(show_id, show_name, show_genre, show_cost, comp_id, nb_actors) values (12, 'show12', 'genre3', 10000, 4, 3);
insert into show(show_id, show_name, show_genre, show_cost, comp_id, nb_actors) values (13, 'show13', 'genre1', 10000, 5, 3);
insert into show(show_id, show_name, show_genre, show_cost, comp_id, nb_actors) values (14, 'show14', 'genre2', 10000, 5, 3);
insert into show(show_id, show_name, show_genre, show_cost, comp_id, nb_actors) values (15, 'show15', 'genre3', 10000, 5, 3);

-- Test data for grant_
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id) values (1, 'donor1', 'type1', 100000, 5, 12, 1);
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id) values (2, 'donor2', 'type2', 120000, 0, 6, 1);
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id) values (3, 'donor3', 'type3', 120000, 0, 3, 1);
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id) values (4, 'donor4', 'type1', 100000, 5, 12, 2);
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id) values (5, 'donor5', 'type2', 120000, 0, 4, 2);
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id) values (6, 'donor6', 'type3', 120000, 0, 3, 2);
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id) values (7, 'donor7', 'type1', 100000, 5, 12, 3);
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id) values (8, 'donor8', 'type2', 120000, 0, 4, 3);
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id) values (9, 'donor9', 'type3', 120000, 0, 3, 4);
insert into grant_(grant_id, donor_name, grant_type, total_amount, total_period_year, period_time_month, thea_id) values (10, 'donor10', 'type1', 100000, 5, 12, 5);

-- Test data for performance_
insert into performance_(perf_id, perf_begin, perf_end, room_id,show_id, discount) values (1, '20/09/2022 19:30:00', '20/09/2022 21:30:00', 1, 1, 0);
insert into performance_(perf_id, perf_begin, perf_end, room_id,show_id, discount) values (2, '20/09/2022 19:30:00', '20/09/2022 21:30:00', 2, 1, 0);
insert into performance_(perf_id, perf_begin, perf_end, room_id,show_id, discount) values (3, '20/09/2022 19:30:00', '20/09/2022 21:30:00', 3, 1, 0);
insert into performance_(perf_id, perf_begin, perf_end, room_id,show_id, discount) values (4, '20/09/2022 19:30:00', '20/09/2022 21:30:00', 4, 1, 1);
insert into performance_(perf_id, perf_begin, perf_end, room_id,show_id, discount) values (5, '20/09/2022 19:30:00', '20/09/2022 21:30:00', 5, 2, 1);
insert into performance_(perf_id, perf_begin, perf_end, room_id,show_id, discount) values (6, '20/09/2022 19:30:00', '20/09/2022 21:30:00', 6, 3, 1);
insert into performance_(perf_id, perf_begin, perf_end, room_id,show_id, discount) values (7, '20/09/2022 19:30:00', '20/09/2022 21:30:00', 7, 4, 0);
insert into performance_(perf_id, perf_begin, perf_end, room_id,show_id, discount) values (8, '20/09/2022 19:30:00', '20/09/2022 21:30:00', 8, 5,0 );
insert into performance_(perf_id, perf_begin, perf_end, room_id,show_id, discount) values (9, '20/09/2022 19:30:00', '20/09/2022 21:30:00', 9, 6,1);
insert into performance_(perf_id, perf_begin, perf_end, room_id,show_id, discount) values (10, '20/09/2022 19:30:00', '20/09/2022 21:30:00', 10, 7,0);
insert into performance_(perf_id, perf_begin, perf_end, room_id,show_id, discount) values (11, '20/09/2022 19:30:00', '20/09/2022 21:30:00', 11, 8,1);
insert into performance_(perf_id, perf_begin, perf_end, room_id,show_id, discount) values (12, '20/09/2022 19:30:00', '20/09/2022 21:30:00', 12, 9,0);
insert into performance_(perf_id, perf_begin, perf_end, room_id,show_id, discount) values (13, '20/09/2022 19:30:00', '20/09/2022 21:30:00', 13, 10,0);
insert into performance_(perf_id, perf_begin, perf_end, room_id,show_id, discount) values (14, '20/09/2022 19:30:00', '20/09/2022 21:30:00', 14, 11,1);
insert into performance_(perf_id, perf_begin, perf_end, room_id,show_id, discount) values (15, '20/09/2022 19:30:00', '20/09/2022 21:30:00', 15, 12,1);

-- Test data for actor
insert into actor (act_id, act_name, act_price, gender, act_age, act_balance) values(1, 'actor1', 10000, 'M', 20, 100000);
insert into actor (act_id, act_name, act_price, gender, act_age, act_balance) values(2, 'actor2', 10000, 'F', 30, 100000);
insert into actor (act_id, act_name, act_price, gender, act_age, act_balance) values(3, 'actor3', 20000, 'M', 35, 120000);
insert into actor (act_id, act_name, act_price, gender, act_age, act_balance) values(4, 'actor4', 10000, 'F', 30, 100000);
insert into actor (act_id, act_name, act_price, gender, act_age, act_balance) values(5, 'actor5', 10000, 'F', 30, 100000);
insert into actor (act_id, act_name, act_price, gender, act_age, act_balance) values(6, 'actor6', 10000, 'F', 30, 100000);
insert into actor (act_id, act_name, act_price, gender, act_age, act_balance) values(7, 'actor7', 10000, 'F', 59, 100000);
insert into actor (act_id, act_name, act_price, gender, act_age, act_balance) values(8, 'actor8', 10000, 'F', 23, 100000);
insert into actor (act_id, act_name, act_price, gender, act_age, act_balance) values(9, 'actor9', 10000, 'F', 40, 100000);
insert into actor (act_id, act_name, act_price, gender, act_age, act_balance) values(10, 'actor10', 40000, 'F', 30, 100000);
insert into actor (act_id, act_name, act_price, gender, act_age, act_balance) values(11, 'actor11', 30000, 'F', 30, 100000);
insert into actor (act_id, act_name, act_price, gender, act_age, act_balance) values(12, 'actor12', 18000, 'F', 30, 100000);
insert into actor (act_id, act_name, act_price, gender, act_age, act_balance) values(13, 'actor13', 29000, 'F', 30, 100000);

-- Test data for staff_list
insert into staff_list (perf_id, act_id) values (1, 1);
insert into staff_list (perf_id, act_id) values (1, 2);
insert into staff_list (perf_id, act_id) values (1, 3);
insert into staff_list (perf_id, act_id) values (2, 4);
insert into staff_list (perf_id, act_id) values (2, 5);
insert into staff_list (perf_id, act_id) values (2, 6);
insert into staff_list (perf_id, act_id) values (3, 7);
insert into staff_list (perf_id, act_id) values (3, 8);
insert into staff_list (perf_id, act_id) values (3, 9);
insert into staff_list (perf_id, act_id) values (4, 10);
insert into staff_list (perf_id, act_id) values (4, 11);
insert into staff_list (perf_id, act_id) values (4, 12);
insert into staff_list (perf_id, act_id) values (5, 13);

-- Test data for ticket
insert into ticket (ticket_type_id, ticket_type, ticket_s_price, perf_id) values (1, 'normal', 1000, 1);
insert into ticket (ticket_type_id, ticket_type, ticket_s_price, perf_id) values (2, 'reduced', 500, 1);
insert into ticket (ticket_type_id, ticket_type, ticket_s_price, perf_id) values (3, 'normal', 1500, 2);
insert into ticket (ticket_type_id, ticket_type, ticket_s_price, perf_id) values (4, 'reduced', 900, 2);
insert into ticket (ticket_type_id, ticket_type, ticket_s_price, perf_id) values (5, 'normal', 900, 3);
insert into ticket (ticket_type_id, ticket_type, ticket_s_price, perf_id) values (6, 'reduced', 700, 3);
insert into ticket (ticket_type_id, ticket_type, ticket_s_price, perf_id) values (7, 'normal', 1000, 4);
insert into ticket (ticket_type_id, ticket_type, ticket_s_price, perf_id) values (8, 'reduced', 720, 4);
insert into ticket (ticket_type_id, ticket_type, ticket_s_price, perf_id) values (9, 'normal', 1300, 5);
insert into ticket (ticket_type_id, ticket_type, ticket_s_price, perf_id) values (10, 'reduced', 1000, 5);
insert into ticket (ticket_type_id, ticket_type, ticket_s_price, perf_id) values (11, 'normal', 1500, 6);
insert into ticket (ticket_type_id, ticket_type, ticket_s_price, perf_id) values (12, 'reduced', 1200, 6);

-- Test data for sales
insert into sales (sales_id, ticket_type_id, ticket_num, sales_time) values (1, 1, 10, '18/09/2022 19:30:00');
insert into sales (sales_id, ticket_type_id, ticket_num, sales_time) values (2, 2, 10, '18/09/2022 19:30:00');

---------------------------------------------------------------------TRIGGERS--------------------------------------------------------------------------------------
-- Create the trigger to constraint one actor can only be in one performance at the same time
create or replace trigger actor_in_one_performance
before insert or update on staff_list
for each row
declare
    var_same_begin_time_count number;
    var_start_time date;
    var_end_time date;
begin
    select perf_begin, perf_end into var_start_time, var_end_time from performance where perf_id = :new.perf_id;
    select count(*) into var_same_begin_time_count from performance_ where perf_begin between var_start_time and var_end_time; 
    if var_same_begin_time_count > 0 then
        raise_application_error(-20001, 'The actor is already in another performance at the same time');
    end if;
end;
-- Test the trigger
insert into staff_list (perf_id, act_id) values (1, 1);


-- Create the trigger to auto generate the total price of a sale
create or replace trigger calculate_sales_price
before insert or update on sales
for each row

declare
    ticket_price number;
    has_discount number;
    sits_sold number;
    cap_room number;
    perf_date date;
    
begin
    select t1.ticket_s_price, p1.discount, p1.reserved_sits, r.room_capacity, p1.perf_begin into ticket_price, has_discount, sits_sold, cap_room, perf_date
    from ticket t1, performance_ p1, room r
    where t1.ticket_type_id = :new.ticket_type_id and t1.perf_id = p1.perf_id and p1.room_id = r.room_id;
    
    if has_discount = 1 then
        if :new.sales_time <= perf_date - 15 then
            :new.sales_price := (:new.ticket_num * ticket_price) * 0.80;
        end if;
        
        if to_char(:new.sales_time, 'year') = to_char(perf_date, 'year') and to_char(:new.sales_time, 'month') = to_char(perf_date, 'month') and to_char(perf_date, 'day') = to_char(:new.sales_time, 'day') and sits_sold <= 0.50 * cap_room then
            :new.sales_price := (:new.ticket_num * ticket_price) * 0.70;
        end if;
    
        if to_char(:new.sales_time, 'year') = to_char(perf_date, 'year') and to_char(:new.sales_time, 'month') = to_char(perf_date, 'month') and to_char(perf_date, 'day') = to_char(:new.sales_time, 'day') and sits_sold <= 0.30 * cap_room then
            :new.sales_price := (:new.ticket_num * ticket_price) * 0.50;
        end if;
        
        if :new.sales_time > perf_date - 15 and :new.sales_time <= perf_date - 1 then
            :new.sales_price := :new.ticket_num * ticket_price;
        end if;
    
    else
        :new.sales_price := :new.ticket_num * ticket_price;
    end if;
end;
/
--Test the trigger
delete from sales; --initially the price was at 0 for every sale
insert into sales (sales_id, ticket_type_id, ticket_num, sales_time) values (1, 1, 10, '18/09/2022 19:30:00'); --normal price, no discount for show 
insert into sales (sales_id, ticket_type_id, ticket_num, sales_time) values (2, 10, 10, '18/09/2022 19:30:00'); --normal price, discount for show
insert into sales (sales_id, ticket_type_id, ticket_num, sales_time) values (3, 10, 10, '01/09/2022 19:30:00'); --20% discount
insert into sales (sales_id, ticket_type_id, ticket_num, sales_time) values (4, 10, 20, '20/09/2022 12:30:00'); --50% discount
insert into sales (sales_id, ticket_type_id, ticket_num, sales_time) values (5, 10, 5, '20/09/2022 14:30:00'); --30% discount


-- Create the trigger to check the conflict of the room usage
create or replace trigger room_usage_check 
before insert or update on performance_
for each row
declare 
    pragma autonomous_transaction;
    useage_error exception;
    var_same_begin_time_count number;
begin
    -- if the performance is not inserted, then check the conflict of the room usage.
    -- if room_id is same and there are exist shows' begin time in the new show's time, then raise an error
    select count(*) into var_same_begin_time_count from performance_ where room_id = :new.room_id and perf_begin between :new.perf_begin and :new.perf_end; 
    if (var_same_begin_time_count != 0) then 
        raise useage_error;
    end if;
exception
    when useage_error then 
    RAISE_APPLICATION_ERROR(-20002, 'This room is occupied.');
end;
-- Test the trigger
insert into performance_(perf_id, perf_begin, perf_end, reserved_sits, room_id,show_id, discount) values (16, '20/09/2022 19:30:00', '20/09/2022 21:30:00', 100, 1, 1, 0);


-- Create the trigger to check the price of the actor No decreasing.
create or replace trigger actor_price_check
before update on actor
for each row
declare 
    pragma autonomous_transaction;
    price_error exception;
begin
    -- if the actor's price is decreased, then raise an error
    if (:new.act_price < :old.act_price) then 
        raise price_error;
    end if;
exception
    when price_error then
    RAISE_APPLICATION_ERROR(-20003, 'The price of the actor cannot be decreased.');
end;
-- Test the trigger
update actor set act_price = 9000 where act_id = 1;


-- Create the trigger to check the balance of the company Enough money to pay the others.
create or replace trigger company_balance_check
before insert on transactions
for each row
declare 
    pragma autonomous_transaction;
    balance_error exception;
    var_company_balance number;
begin
    -- if the company's balance is not enough to pay the actor, then raise an error
    select act_balance into var_company_balance from company where comp_id = :new.from_comp_id;
    if (var_company_balance < :new.amount_money) then 
        raise balance_error;
    end if;
exception
    when balance_error then
    RAISE_APPLICATION_ERROR(-20004, 'The balance of the company is not enough to pay this transaction.');
end;
-- Test the trigger
insert into transactions (from_comp_id,to_comp_id, to_act_id, thea_id, amount_money) values(1, 2, null, null, 300000);


-- Create the trigger to check the price of ticket should not be changed 
create or replace trigger ticket_price_check
before update on ticket
for each row
declare 
    pragma autonomous_transaction;
    price_error exception;
begin
    -- if the ticket's price is changed, then raise an error
    if (:new.ticket_s_price != :old.ticket_s_price) then 
        raise price_error;
    end if;
exception
    when price_error then
    RAISE_APPLICATION_ERROR(-20005, 'The price of the ticket cannot be changed.');
end;
-- Test the trigger
update ticket set ticket_s_price = 1000 where ticket_type_id = 1;


-- Create the trigger to change the balance of the company,actor and theater's company after the transaction.
create or replace trigger company_balance_change
after insert on transactions
for each row
declare 
    -- pragma autonomous_transaction;
    var_from_company_balance number;
    var_to_company_balance number;
    var_actor_balance number;
    var_theater_company_balance number;
    var_theater_company_id number;
    invalid_input exception;
begin
    -- after the transaction, the balance of the company is changed.

    if ((:new.from_comp_id is not null) and (:new.to_comp_id is not null)) then 
        select comp_balance into var_from_company_balance from company where comp_id = :new.from_comp_id;
        select comp_balance into var_to_company_balance from company where comp_id = :new.to_comp_id;
        update company set comp_balance = var_from_company_balance - :new.amount_money where comp_id = :new.from_comp_id;
        update company set comp_balance = var_to_company_balance + :new.amount_money where comp_id = :new.to_comp_id;
    elsif (:new.from_comp_id is not null) and (:new.to_act_id is not null) then 
        select comp_balance into var_from_company_balance from company where comp_id = :new.from_comp_id;
        select act_balance into var_actor_balance from actor where act_id = :new.to_act_id;
        update company set comp_balance = var_from_company_balance - :new.amount_money where comp_id = :new.from_comp_id;
        update actor set act_balance = var_actor_balance + :new.amount_money where act_id = :new.to_act_id;
    elsif (:new.from_comp_id is not null) and (:new.thea_id is not null) then
        select comp_id into var_theater_company_id from theater where thea_id = :new.thea_id;
        select comp_balance into var_theater_company_balance from company where comp_id = var_theater_company_id;
        update company set comp_balance = var_theater_company_balance + :new.amount_money where comp_id = :new.from_comp_id;
        DBMS_OUTPUT.PUT_LINE('The balance of the theater company is changed.');
    else
        raise invalid_input;
    end if;
exception
    when invalid_input then
    RAISE_APPLICATION_ERROR(-20006, 'The input is invalid. only from_comp_id and to_comp_id or from_comp_id and to_act_id or from_comp_id and thea_id can be used.');
end;
-- Test the trigger
insert into transactions (from_comp_id,to_comp_id, to_act_id, thea_id, amount_money) values(1, 2, null, null, 300000); -- Test the company to company
insert into transactions (from_comp_id,to_comp_id, to_act_id, thea_id, amount_money) values(1, null, 1, null, 300000); -- Test the company to actor
insert into transactions (from_comp_id,to_comp_id, to_act_id, thea_id, amount_money) values(1, null, null, 1, 300000); -- Test the donation to theater
select * from company;


-- Create the trigger to check the reserved sits of the performance Enough sits to reserve and do not over the capacity of the room.
create or replace trigger count_reserved_sits
before insert or delete on sales
for each row

declare
    nb_sold_sits number;
    cap_room number;
    
begin

    if inserting then
        select perf1.reserved_sits into nb_sold_sits
        from performance_ perf1, ticket tick1
        where tick1.ticket_type_id = :new.ticket_type_id 
        and tick1.perf_id = perf1.perf_id;
        
        select r.room_capacity into cap_room
        from performance_ perf2, ticket tick2, room r
        where tick2.ticket_type_id = :new.ticket_type_id 
        and tick2.perf_id = perf2.perf_id
        and perf2.room_id = r.room_id;
    
        if nb_sold_sits = cap_room then
            raise_application_error(-20012, 'No more sits available.');
        elsif nb_sold_sits + :new.ticket_num > cap_room then
            raise_application_error(-20022, 'Not enough tickets left.');
        else
            update performance_
            set reserved_sits = reserved_sits + :new.ticket_num
            where perf_id = (
            select tick.perf_id
            from ticket tick
            where tick.ticket_type_id = :new.ticket_type_id);
        end if;
    end if;
        
    if deleting then
    
        select perf1.reserved_sits into nb_sold_sits
        from performance_ perf1, ticket tick1
        where tick1.ticket_type_id = :old.ticket_type_id 
        and tick1.perf_id = perf1.perf_id;
        
        select r.room_capacity into cap_room
        from performance_ perf2, ticket tick2, room r
        where tick2.ticket_type_id = :old.ticket_type_id 
        and tick2.perf_id = perf2.perf_id
        and perf2.room_id = r.room_id;
    
        insert into refund values (:old.sales_id, :old.sales_price);
        update performance_
        set reserved_sits = reserved_sits - :old.ticket_num
        where perf_id = (
        select tick.perf_id
        from ticket tick
        where tick.ticket_type_id = :old.ticket_type_id);
    end if;
end;
/
-- Test the trigger
insert into sales values (3, 2, 100, '16/09/2022 19:30:00'); --error -20012
insert into sales values (4, 2, 80, '16/09/2022 19:30:00'); --inserted 
insert into sales values (5, 2, 1, '16/09/2022 19:30:00'); --error -20022
delete from sales where sales_id = 4; --deleted from sales and from reserved_sits

-- Create the trigger to check the sales date that is not over the performance date.
create or replace trigger over_deadline
before insert or update on sales
for each row

declare 
    perf_time date;
    
begin
    select perf.perf_begin into perf_time
    from performance_ perf, ticket tick
    where perf.perf_id = tick.perf_id
    and tick.ticket_type_id = :new.ticket_type_id;
    
    if :new.sales_time >= perf_time then
        raise_application_error(-20010, 'The show has already begun or it is over.');
    end if;
end;
/
--Test the trigger
insert into sales (sales_id, ticket_type_id, ticket_num, sales_time) values (6, 2, 10, '17/09/2022 19:30:00'); --added with no problem
insert into sales (sales_id, ticket_type_id, ticket_num, sales_time) values (7, 2, 10, '21/09/2022 19:30:00'); --error -20010


-- Create the trigger to auto pay the company (ticket price)
create or replace trigger company_balance_change_sales
after insert or delete on sales
for each row
declare 
    var_company_balance number;
    var_company_id number;
begin 
    if inserting then
        select company.comp_balance,company.comp_id into var_company_balance, var_company_id from company,sales,ticket,performance_,room,theater where (sales.ticket_type_id = 1) and (sales.ticket_type_id = ticket.ticket_type_id) and (performance_.perf_id = ticket.perf_id) and (room.room_id = performance_.room_id) and (room.room_id = performance_.room_id) and (theater.thea_id = room.thea_id) and (theater.comp_id = company.comp_id);
        update company set comp_balance = comp_balance + :new.sales_price where comp_id = :new.comp_id;
    elsif deleting then
        select company.comp_balance,company.comp_id into var_company_balance, var_company_id from company,sales,ticket,performance_,room,theater where (sales.ticket_type_id = 1) and (sales.ticket_type_id = ticket.ticket_type_id) and (performance_.perf_id = ticket.perf_id) and (room.room_id = performance_.room_id) and (room.room_id = performance_.room_id) and (theater.thea_id = room.thea_id) and (theater.comp_id = company.comp_id);
        update company set comp_balance = comp_balance - :old.sales_price where comp_id = :old.comp_id;
    end if;
end;
-- Test the trigger
insert into sales (sales_id, ticket_type_id, ticket_num,sales_price, sales_time) values (300, 2, 10, 3000, '18/09/2022 19:30:00');

---------------------------------------------------------------------FUNCTIONS---------------------------------------------------------------------------------------
-- Create the function to calculate whether a performance do not have enough actors.

create or replace function check_actor_num (perf_id number) return number
is
    var_perf_id number;
    var_show_id number;
    var_actor_num number;
    var_actor_num_needed number;
begin
    var_perf_id := perf_id;
    select show_id into var_show_id from performance_ where perf_id = var_perf_id;
    select count(*) into var_actor_num from staff_list where perf_id = var_perf_id;
    select nb_actors into var_actor_num_needed from show where show_id = var_show_id;
    return var_actor_num_needed - var_actor_num;
end;

-- Test the function
begin 
    dbms_output.put_line(check_actor_num(1)); -- 0
end;

begin 
    dbms_output.put_line(check_actor_num(5)); -- 2
end;-- 0


-- Create the procedure to check whether all performances do not have enough actors.
create or replace procedure check_all_actor_num
is 
    var_perf_id number;
begin 
    for i in (select perf_id from performance_) loop
        var_perf_id := i.perf_id;
        if check_actor_num(var_perf_id) > 0 then
            dbms_output.put_line('The performance ' || var_perf_id || ' does not have enough actors. Needs ' || check_actor_num(var_perf_id) || ' more.');
        end if;
    end loop;
end;

-- Test the procedure
begin 
    check_all_actor_num;
end;


-- Create the function to calculate which actor is free for the previous positions.
-- perf_id is the performance id which the actor is going to be assigned to.
create or replace function check_actor_free (perf_id number, actor_id number) 
-- This function returns whether the actor is free for the previous positions.
return number is 
    var_perf_id number;
    var_actor_id number;
    var_start_time date;
    var_end_time date;
    var_start_time_a date;
    var_to_return number;
    var_count number;
begin
    var_perf_id := perf_id;
    var_actor_id := actor_id;
    var_to_return := 0;
    select perf_begin, perf_end into var_start_time, var_end_time from performance_ where perf_id = var_perf_id;
    for i in (select perf_id from staff_list where ACT_ID = var_actor_id) loop
        select perf_begin into var_start_time_a from performance_ where perf_id = i.perf_id;
        if var_start_time_a between var_start_time and var_end_time then
            var_to_return := 0;
        else 
            var_to_return := 1;
        end if;
        if var_to_return = 1 then 
            return var_to_return;
        end if;
    end loop;
    select count(*) into var_count from staff_list where ACT_ID = actor_id;
    if var_count = 0  then
        var_to_return := 1;
    end if;
    return var_to_return;
end;

begin
    dbms_output.put_line(check_actor_free(5,1));
end;

-- Create the procedure to check which actors is free for the previous positions.
create or replace procedure check_all_actor_free(perf_id number)
is 
    var_actor_id number;
begin 
    for i in (select ACT_ID from actor) loop
        var_actor_id := i.ACT_ID;
        if check_actor_free(perf_id, var_actor_id) = 0 then
            dbms_output.put_line('The actor ' || var_actor_id || ' is not free for the previous positions.');
        else 
            dbms_output.put_line('The actor ' || var_actor_id || ' is free for this positions.');
        end if;
    end loop;
end;

-- Test the procedure & function of checking whether an actor is free for the previous positions.
begin
    check_all_actor_free(5);
end;

insert into actor (act_id, act_name, act_price, gender, act_age, act_balance) values(14, 'actor14', 29000, 'F', 30, 100000);

begin
    check_all_actor_free(5);
end;


-- Create the function to calculate the free sits for a performance.
create or replace function sits_left(perf_id_par number)
return number is
    sits number := 0;
begin 
    select (r.room_capacity - perf.reserved_sits) into sits
    from performance_ perf, room r
    where perf.perf_id = perf_id_par and r.room_id = perf.room_id;
    
    return sits;
end;
/

--test the function
DECLARE 
   sits number; 
BEGIN 
   sits := sits_left(5); 
   dbms_output.put_line('Sits left in performance n?? 5 : ' || sits); 
END; 
/

-- Create the procedure to know at once the remaining sits in all performances
-- Possible improvement : add the date to see the the infos of the current performances
CREATE OR REPLACE PROCEDURE all_sits_left
is 
BEGIN 
    declare 
        cursor perfs
        is
            select perf_id
            from performance_;
        sits number;
    
    begin
        for perf in perfs
        loop
            sits := sits_left(perf.perf_id);
            dbms_output.put_line('Sits left in performance n?? ' || perf.perf_id || ' : '|| sits); 
        end loop;
    end;
END;

-- test the procedure
exec all_sits_left;


-- Create the function to calculate the total sales for a performance.
create or replace function tt_sales_perf(perf_id_par number)
return number is
    tt_sales number := 0;
begin 
    select sum(s.sales_price) into tt_sales
    from ticket tick, sales s
    where tick.perf_id = perf_id_par and s.ticket_type_id = tick.ticket_type_id;
    
    return tt_sales;
end;
/

--test the function
DECLARE 
   tt_sales number; 
BEGIN 
   tt_sales := tt_sales_perf(5); 
   dbms_output.put_line('tt sales of performance n?? 5 : ' || tt_sales); 
END; 
/


-- Create the function to calculate the total sales for a company/theater.
create or replace function tt_sales_company(comp_id_par number)
return number is
    tt_sales_comp number := 0;
    
begin 
    declare
        cursor comp_perf
        is
            select perf_id
            from theater th, room r, performance_ perf
            where th.comp_id = comp_id_par and r.thea_id = th.thea_id and perf.room_id = r.room_id;
    
    begin 
        for perf_id in comp_perf
        loop
            tt_sales_comp := tt_sales_comp + tt_sales_perf(perf_id.perf_id);
            dbms_output.put_line(tt_sales_comp);
        end loop;
    return tt_sales_comp;
    end;
end;
/

--test the function
DECLARE 
   tt_sales_comp number; 
BEGIN 
   tt_sales_comp := tt_sales_company(2); 
   dbms_output.put_line('total sales of Company n?? ' || 2 || ' : ' || tt_sales_comp); 
END; 
/


