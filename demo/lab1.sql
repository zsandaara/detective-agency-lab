-- demo/lab1.sql
-- Три вставки, которые база должна отклонить.

-- expect: error unique
INSERT INTO clients (name, email) VALUES ('Дубликат', 'ivan.petrov@example.com');

-- expect: error check
INSERT INTO cases (client_id, title, status, opened_at, fee)
VALUES (1, 'Плохой статус', 'invalid', now(), 1000.00);

-- expect: error fk
INSERT INTO cases (client_id, title, status, opened_at, fee)
VALUES (999, 'Несуществующий клиент', 'open', now(), 1000.00);