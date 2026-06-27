create table customers (
    customer_id serial primary key,
    full_name varchar(100) not null,
    email varchar(100) unique not null,
    balance numeric(10,2) default 0
);

create table products (
    product_id serial primary key,
    product_name varchar(100) not null,
    price numeric(10,2) not null,
    stock_quantity int not null
);

create table orders (
    order_id serial primary key,
    customer_id int references customers(customer_id),
    order_date timestamp default current_timestamp,
    total_amount numeric(10,2) default 0
);

create table order_items (
    order_item_id serial primary key,
    order_id int references orders(order_id),
    product_id int references products(product_id),
    quantity int not null,
    price numeric(10,2) not null
);

create table order_log (
    log_id serial primary key,
    order_id int,
    customer_id int,
    action varchar(50),
    log_date timestamp default current_timestamp
);


--TASK 1--
create or replace function calculate_order_total(p_orders_id int)
returns numeric as $$
declare
	total numeric;
begin
	select coalesce(sum(quantity * price), 0)
	into total
	from order_items
	where order_id = p_orders_id;
	return total;
end;
$$ language plpgsql;


--TASK 2--
create or replace procedure create_order(p_customer_id int)
as $$
begin
    insert into orders (customer_id, total_amount)
    values (p_customer_id, 0);
end;
$$ language plpgsql;


--TASK 3--
create or replace procedure add_product_to_order(
    p_order_id int,
    p_product_id int,
    p_quantity int
)
as $$
declare
    v_price numeric(10,2);
    v_stock int;
begin
    if p_quantity <= 0 then
        raise exception 'Кількість товару має бути більшою за 0';
    end if;

    select price, stock_quantity
    into v_price, v_stock
    from products
    where product_id = p_product_id;

    if v_stock < p_quantity then
        raise exception 'Немає товару у базі або недостатньо на складі';
    end if;

    insert into order_items (order_id, product_id, quantity, price)
    values (p_order_id, p_product_id, p_quantity, v_price);

    update products
    set stock_quantity = stock_quantity - p_quantity
    where product_id = p_product_id;
end;
$$ language plpgsql;


--TASK 4--
create or replace function update_total()
returns trigger as $$
begin
    update orders
    set total_amount = calculate_order_total(coalesce(new.order_id, old.order_id))
    where order_id = coalesce(new.order_id, old.order_id);

    return null;
end;
$$ language plpgsql;

create trigger trg_update_order_total
after insert or update or delete on order_items
for each row
execute function update_total();


--TASK 5--
create or replace function log_order_creation()
returns trigger as $$
begin
    insert into order_log (order_id, customer_id, action, log_date)
    values (new.order_id, new.customer_id, 'ORDER_CREATED', new.order_date);

    return new;
end;
$$ language plpgsql;

drop trigger if exists trg_log_order_creation on orders;

create trigger trg_log_order_creation
after insert on orders
for each row
execute function log_order_creation();


-- TASK 6--
insert into customers (full_name, email, balance)
values ('Anna', 'anna@examle.com', 40000000.00);

insert into products (product_name, price, stock_quantity)
values ('Mac', 150000.00, 10),
       ('airpods', 10000.00, 5);


select * from customers;
select * from products;

call create_order(1);

select * from orders;
select * from order_log;

call add_product_to_order(1,1,2);
call add_product_to_order(1,2,1);
select * from products;
select * from orders;
select * from order_items;

