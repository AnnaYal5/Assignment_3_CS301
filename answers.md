1. What is the difference between a function and a procedure in PostgreSQL?
Функція завжди повертає результат, а процедура - ні. Функцію запускають через select, а процедуру — через call
2. Can a trigger be executed manually? Why or why not?
Ні, вручну запустити тригер неможливо, він викликається автоматично (через команди insert, update або delete)
3. What are the advantages and disadvantages of storing business logic inside the database?
Плюс у тому, що так працює набагато швидше але мінус, що такий код у базі набагато важче тестувати, оновлювати й масштабувати, коли людей стає забагато