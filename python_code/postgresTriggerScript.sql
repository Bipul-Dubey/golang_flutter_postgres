select * from employees;


-- create table to update when any insertion happen inside employee table
create table report(id int,fullname text,gender char(6),experience_year text);

-- view table
select * from report;

-- create update function
create or replace function updatefunc() returns trigger 
language PLPGSQL as
$$
begin 
	insert into report(id,fullname,gender,experience_year) values 
	(new.id,new.full_name,new.gender,age(new.to_date::DATE,new.from_date::DATE));
return new;
end;
$$

-- create trigger
create TRIGGER update_report after insert on employees
for each row execute procedure updatefunc();