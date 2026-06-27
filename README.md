1) Я створюю функцію calculate_order_total яка прийсає параметр p_orders_id 
та рахує суму (множемо кількість товару на ціну та сумуємо)
select coalesce(sum(quantity * price), 0)

2) Процедура create_order приймає один параметр p_customers_id;
Виконує команду insert для створення нового рядка в таблиці orders та за початкову суму ставимо 0

3) Процедура add_product_to_order, яка приймає три параметри: p_order_id int, p_product_id int, p_quantity int
Перша перевірка на кількість, потрібно щоб вона була не нулем та не -;
Потім з-за допомогою  select та into дізнаюсь ціну та кількість, якщо товару менше, то видає помилку;
Якщо перевірки пройдено,то товар додається у замовлення і робиться апдейт кількосі товарів на складі;

4) Тригер trg_update_order_total на таблицю order_items;
Автоматично спрацьовує після insert or update or delete та викликає функцію update_total, яка визначає номер замовлення і оновлює його суму (total_amount)(викликаючи функцію з Task1) за допомогою coalesce(new.order_id, old.order_id);

5) Тригер trg_log_order_creation для логування на таблицю orders і спрацьовує після insert;
Тригер викликає функцію, яка бере дані щойно створеного рядка через new і записує у order_log; 



Bonus Task 3 — Query Analysis

Hash Join  (cost=27.09..41.32 rows=7 width=274) (actual time=0.573..0.581 rows=4.00 loops=1)
  Hash Cond: (p.product_id = oi.product_id)
  Buffers: shared hit=2
  ->  Seq Scan on products p  (cost=0.00..13.00 rows=300 width=222) (actual time=0.016..0.018 rows=9.00 loops=1)
        Buffers: shared hit=1
  ->  Hash  (cost=27.00..27.00 rows=7 width=28) (actual time=0.026..0.026 rows=4.00 loops=1)
        Buckets: 1024  Batches: 1  Memory Usage: 9kB
        Buffers: shared hit=1
        ->  Seq Scan on order_items oi  (cost=0.00..27.00 rows=7 width=28) (actual time=0.012..0.014 rows=4.00 loops=1)
              Filter: (order_id = 1)
              Rows Removed by Filter: 3
              Buffers: shared hit=1
Planning:
  Buffers: shared hit=170
Planning Time: 3.050 ms
Execution Time: 0.655 ms

Для виконання запиту виконується повне сканування Sequential Scan та метод Hash Join для з'єднання.
Оскільки таблиці не великі спочатку комп'ютер проходить по таблиці з замовленнями, знаходить рядок з order_id = 1.
Потім він так само перебирає таблицю з продуктами, щоб порівняти їхні ID і взяти назви товарів