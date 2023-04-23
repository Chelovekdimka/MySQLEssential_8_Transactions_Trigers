DROP DATABASE MyFunkDB;

CREATE DATABASE MyFunkDB;
USE MyFunkDB;

CREATE TABLE employees (
  id INT PRIMARY KEY auto_increment,
  name VARCHAR(50),
  phone_number VARCHAR(20)
);

CREATE TABLE salaries (
  id INT PRIMARY KEY ,
  position VARCHAR(20),
  salary DECIMAL(10, 2)
);

CREATE TABLE personal_info (
  id INT PRIMARY KEY NOT NULL,
  marital_status VARCHAR(10),
  birth_date DATE,
  address VARCHAR(100)
);

ALTER TABLE salaries ADD FOREIGN KEY (id) REFERENCES employees (id);
ALTER TABLE  personal_info ADD FOREIGN KEY (id) REFERENCES employees(id);


/* INSERT INTO salaries (id, position, salary)
VALUES
    (1, 'Manager', 100000),
    (2, 'Worker', 50000),
    (3, 'Manager', 90000),
    (4, 'Worker', 40000),
    (5, 'Manager', 80000),
    (6, 'Worker', 60000),
    (7, 'Manager', 70000),
    (8, 'Worker', 55000),
    (9, 'Manager', 95000),
    (10, 'Worker', 45000);
    
    INSERT INTO personal_info (id, marital_status, birth_date, address)
VALUES 
    (1, 'Married', '1985-05-15', '123 Main St'),
    (2, 'Married', '1990-09-20', '456 Oak Ave'),
    (3, 'Single', '1978-03-10', '789 Pine St'),
    (4, 'Single', '1982-12-01', '321 Elm St'),
    (5, 'Single', '1995-06-25', '654 Maple Ave'),
    (6, 'Married', '1998-01-12', '987 Cedar St'),
    (7, 'Single', '1989-08-04', '246 Birch Ave'),
    (8, 'Married', '1991-11-17', '135 Oak St'),
    (9, 'Single', '1970-02-18', '864 Pine Ave'),
    (10, 'Single', '1986-07-07', '369 Maple St');

INSERT INTO employees ( name, phone_number)
VALUES
    ( 'John Smith', '555-1234'),
    ('Jane Doe', '555-5678'),
    ( 'Robert Johnson', '555-9012'),
    ( 'Alice Brown',  '555-3456'),
    ( 'David Lee', '555-7890'),
    ('Samantha Taylor', '555-2345'),
    ( 'William Anderson',  '555-6789'),
    ('Emily Hernandez',  '555-0123'),
    ('Michael Jackson',  '555-4567'),
    ( 'Sarah Garcia',  '555-8901');
  /*  
-- Создайте функции / процедуры для таких заданий:

--  1) Требуется узнать контактные данные сотрудников (номера телефонов, место жительства).

DELIMiTER |
CREATE PROCEDURE get_contact_info(IN employee_id INT)
BEGIN
    SELECT e.phone_number, pi.address
    FROM employees e
    JOIN personal_info pi ON e.id = pi.id
    WHERE e.id = employee_id;
END
|

CALL get_contact_info (2); |
DROP PROCEDURE get_contact_info; |

-- 2. Процедура для получения информации о дате рождения не женатых сотрудников и их номерах телефонов:
CREATE PROCEDURE get_unmarried_birthday_phonenumbers()
BEGIN
    SELECT employees.phone_number, personal_info.birth_date FROM employees
    INNER JOIN personal_info ON employees.id = personal_info.id
    WHERE personal_info.marital_status = 'Single';
END
|
CALL get_unmarried_birthday_phonenumbers (); |
DROP PROCEDURE get_unmarried_birthday_phonenumbers; |

-- 3) Требуется узнать информацию о дате рождения всех сотрудников с должностью менеджер и номера телефонов этих сотрудников.

CREATE PROCEDURE get_managers_birthday_phonenumbers()
BEGIN
    SELECT employees.phone_number, personal_info.birth_date 
    FROM employees
    INNER JOIN personal_info ON employees.id = personal_info.id
    INNER JOIN salaries ON personal_info.id = salaries.id
    WHERE salaries.position = 'Manager';
END
|
CALL get_managers_birthday_phonenumbers (); |
DROP PROCEDURE get_managers_birthday_phonenumbers; |
*/



-- Выполните ряд записей вставки в виде транзакции в хранимой процедуре. Если такой сотрудник имеется откатите базу данных обратно. 
DROP PROCEDURE IF EXISTS add_employee; |

DELIMITER |
CREATE PROCEDURE add_employee(IN name VARCHAR(50), IN phone_number VARCHAR(20), IN position VARCHAR(20),
 IN salary DECIMAL(10, 2), IN marital_status VARCHAR(10), IN birth_date DATE, IN address VARCHAR(100))
BEGIN
  DECLARE id INT;
  
  START TRANSACTION;
  INSERT INTO employees (name, phone_number) VALUES (name, phone_number);
  SET @id = LAST_INSERT_ID();
  INSERT INTO salaries (id, position, salary) VALUES (@id, position, salary);
  INSERT INTO personal_info (id, marital_status, birth_date, address) VALUES (@id, marital_status, birth_date, address);
  
  IF EXISTS (SELECT 1 FROM employees e WHERE e.id != @id  AND e.name = name) THEN
   ROLLBACK;
ELSE
	COMMIT;
END IF;
END |



CALL add_employee('John Smith', '555-1234', 'Manager', 100000, 'Married', '1985-05-15', '123 Main St');

SELECT * FROM employees;

-- Создайте триггер, который будет удалять записи со 2-й и 3-й таблиц перед удалением записей из таблиц сотрудников (1-й таблицы), чтобы не нарушить целостность данных.

CREATE TRIGGER before_delete_employee
BEFORE DELETE ON employees
FOR EACH ROW
BEGIN
  DELETE FROM salaries s WHERE s.id = OLD.id;
  DELETE FROM personal_info pi WHERE pi.id = OLD.id;
END;