ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH:MI:SS' 

create type address_type as object  
( 
    country varchar2(30), 
    city varchar2(30), 
    postcode number, 
    street_name varchar2(50)  
);

desc address_type

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
)

desc company

create table show ( 
    show_id number, 
    show_name varchar2(30), 
    show_genre varchar2(30), 
    show_cost number, 
    nb_actors number, 
    comp_id number, 
    constraint pk_show_id primary key(show_id), 
    constraint nn_show_cost check(show_cost is not null), 
    constraint nn_show_name check(show_name is not null), 
    constraint nn_nb_actors check(nb_actors is not null),
    -- constraint nn_show_genre check(show_genre is not null), 
    constraint nn_comp_id check (comp_id is not null), 
    constraint gz_show_cost check(show_cost > 0), 
    constraint fk_comp foreign key (comp_id) references company(comp_id) 
)

desc show

create table theater  
( 
    thea_id number, 
    thea_name varchar2(30), 
    thea_address address_type, 
    comp_id number, 
    constraint pk_thea_id primary key(thea_id), 
    constraint nn_t_comp_id check (comp_id is not null), 
    constraint fk_t_comp foreign key(comp_id) references company(comp_id) 
)

desc theater

create table grant_  
( 
    grant_id number, 
    donor_name varchar2(30), 
    donor_type varchar2(30), 
    total_amount number, 
    begin_date date,
    -- total_period_year number, 
    -- period_time_month number, 
    thea_id number, 
    constraint pk_grand_id primary key(grant_id), 
    constraint nn_total_amount check(total_amount is not null), 
    constraint nn_donor_type check(donor_type is not null),
    -- constraint nn_total_period_year check (total_period_year is not null), 
    -- constraint nn_period_time_month check (period_time_month is not null), 
    constraint fk_thea foreign key (thea_id) references theater(thea_id)
)

desc grant_

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
)

desc room

create table performance_  
( 
    perf_id number, 
    perf_begin date, 
    perf_end date,
    -- perf_name varchar2(20), 
    reserved_sits number, 
    room_id number not null, 
    show_id number not null, 
    constraint pk_perf_id primary key(perf_id), 
    constraint nn_perf_begin check (perf_begin is not null), 
    constraint nn_perf_end check (perf_end is not null), 
    constraint nn_reserved_sits check (reserved_sits is not null), 
    constraint fk_p_room_id foreign key (room_id) references room(room_id), 
    constraint fk_p_show_id foreign key (show_id) references show(show_id) 
)

desc performance_

create table schedule  
( 
    perf_id number, 
    room_id number, 
    --thea_id number, 
    constraint pk_schedual primary key (perf_id,room_id) 
)

desc schedule

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
)

desc actor

create table staff_list  
( 
    perf_id number not null, 
    nb_actors_perf number,
    -- act_id number not null, 
    -- room_id number not null, 
    -- thea_id number not null,
    constraint pk_staff_list primary key(perf_id, act_id), 
    constraint fk_sl_perf_id foreign key (perf_id) references performance_(perf_id), 
    constraint nn_nb_actors_perf check(nb_actors_perf is not null)
    -- constraint fk_sl_act_id foreign key (act_id) references actor(act_id), 
    -- constraint fk_sl_room_id foreign key (room_id) references room(room_id), 
    -- constraint fk_sl_thea_id foreign key (thea_id) references theater(thea_id) 
)

desc staff_list

create table ticket (
    ticket_id number,
    -- ticket_type number,
    ticket_s_price number,
    perf_id number,
    -- thea_id number,
    -- room_id number,
    -- number_of_tickets number, 
    sold_tickets number,   -- or nb_left_tickets number
    constraint pk_ticket_type_id primary key(ticket_type_id),
    constraint nn_ticket_s_price check (ticket_s_price is not null),
    constraint fk_t_perf_id foreign key (perf_id) references performance_(perf_id),
    -- constraint fk_t_thea_id foreign key (thea_id) references theater(thea_id),
    -- constraint fk_t_room_id foreign key (room_id) references room(room_id)
)

desc ticket

create table sales (
    sales_id number,
    ticket_id number,
    ticket_type varchar(20),
    -- ticket_num number, 
    sales_price number,
    sales_time timestamp,
    constraint pk_sales_id primary key(sales_id),
    -- constraint nn_ticket_num check (ticket_num is not null),
    constraint nn_ticket_type check(ticket_type in ['normal', 'reduced'])
    constraint nn_sales_price check (sales_price is not null),
    constraint nn_sales_time check (sales_time is not null),
    constraint fk_s_ticket_type_id foreign key (ticket_type_id) references ticket(ticket_id)
)

desc sales

create table transaction_  
( 
    from_comp_id number not null, 
    to_comp_id number, 
    to_act_id number, 
    --thea_id number, 
    amount_money number not null, 
    constraint fk_t_from_comp_id foreign key (from_comp_id) references company(comp_id), 
    constraint fk_t_to_comp_id foreign key (to_comp_id) references company(comp_id), 
    constraint fk_t_to_act_id foreign key (to_act_id) references actor(act_id), 
    --constraint fk_t_thea_id foreign key (thea_id) references theater(thea_id), 
    constraint gz_amount_money check (amount_money > 0) 
)

desc transaction_