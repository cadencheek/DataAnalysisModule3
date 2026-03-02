-- Drop & create fresh schema
DROP DATABASE IF EXISTS coffeeshop_db;
CREATE DATABASE coffeeshop_db;
USE coffeeshop_db;

-- --------------------------------------------
-- Tables
-- --------------------------------------------
CREATE TABLE customers (
  customer_id INT PRIMARY KEY AUTO_INCREMENT,
  first_name  TEXT  NOT NULL,
  last_name   TEXT  NOT NULL,
  email       TEXT  NOT NULL UNIQUE,
  city        TEXT ,
  state       TEXT );

CREATE TABLE stores (
  store_id INT PRIMARY KEY AUTO_INCREMENT,
  name     TEXT  NOT NULL,
  city     TEXT  NOT NULL,
  state    TEXT  NOT NULL
);

CREATE TABLE employees (
  employee_id INT PRIMARY KEY AUTO_INCREMENT,
  store_id    INT         NOT NULL,
  first_name  TEXT NOT NULL,
  last_name   TEXT NOT NULL,
  title       TEXT NOT NULL,
  hire_date   DATE        NOT NULL,
  FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

CREATE TABLE categories (
  category_id INT PRIMARY KEY AUTO_INCREMENT,
  name        TEXT  NOT NULL UNIQUE
);

CREATE TABLE products (
  product_id  INT PRIMARY KEY AUTO_INCREMENT,
  category_id INT          NOT NULL,
  name        TEXT  NOT NULL UNIQUE,
  price       DECIMAL(6,2) NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
  order_id       INT PRIMARY KEY AUTO_INCREMENT,
  customer_id    INT       NOT NULL,
  store_id       INT       NOT NULL,
  order_datetime DATETIME  NOT NULL,
  status         ENUM('paid','refunded','void') DEFAULT 'paid' NOT NULL,
  payment_method ENUM('cash','card','app')      DEFAULT 'card' NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (store_id)    REFERENCES stores(store_id)
);

CREATE TABLE order_items (
  order_item_id INT PRIMARY KEY AUTO_INCREMENT,
  order_id   INT NOT NULL,
  product_id INT NOT NULL,
  quantity   INT NOT NULL CHECK (quantity > 0),
  FOREIGN KEY (order_id)  REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE inventory (
  store_id   INT NOT NULL,
  product_id INT NOT NULL,
  on_hand    INT NOT NULL CHECK (on_hand >= 0),
  PRIMARY KEY (store_id, product_id),
  FOREIGN KEY (store_id)   REFERENCES stores(store_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- --------------------------------------------
-- Seed data
-- --------------------------------------------

INSERT INTO stores (name, city, state) VALUES
 ('Lihue Cafe','Lihue','HI'),
 ('Kapaa Cafe','Kapaa','HI'),
 ('Hanalei Cafe','Hanalei','HI');

INSERT INTO employees (store_id, first_name, last_name, title, hire_date) VALUES
 (1,'Malia','Kea','Manager','2023-11-02'),
 (1,'Noa','Ikaika','Barista','2024-06-10'),
 (2,'Kai','Tan','Manager','2024-02-14'),
 (2,'Leilani','Wong','Barista','2025-01-05'),
 (3,'Keanu','Lee','Manager','2024-08-20'),
 (3,'Ana','Rivera','Barista','2025-03-01');

INSERT INTO customers (first_name,last_name,email,city,state) VALUES
 ('Ava','Kona','ava.kona@example.com','Lihue','HI'),
 ('Mason','Imai','m.ima@example.com','Kapaa','HI'),
 ('Olivia','Park','olivia.park@example.com','Hanalei','HI'),
 ('Liam','Akana','liam.ak@example.com','Kilauea','HI'),
 ('Emma','Lau','emma.lau@example.com','Wailua','HI'),
 ('Noah','Kim','noah.kim@example.com','Princeville','HI'),
 ('Sophia','Ng','sophia.ng@example.com','Lihue','HI'),
 ('Ethan','Nakamura','ethan.n@example.com','Kapaa','HI');

INSERT INTO categories (name) VALUES
 ('Espresso'),
 ('Tea'),
 ('Bakery'),
 ('Beans'),
 ('Merch');

INSERT INTO products (category_id, name, price) VALUES
 (1,'Espresso',3.00),
 (1,'Latte',4.75),
 (1,'Cappuccino',4.50),
 (1,'Cold Brew',4.25),
 (2,'Green Tea',3.25),
 (2,'Chai Latte',4.50),
 (3,'Croissant',3.50),
 (3,'Banana Bread',3.75),
 (4,'House Beans 12oz',12.00),
 (4,'Kona Blend 12oz',16.00),
 (5,'Mug',10.00),
 (5,'T-Shirt',18.00);

INSERT INTO orders (customer_id, store_id, order_datetime, status, payment_method) VALUES
 (1,1,'2025-09-01 07:42:00','paid','card'),
 (2,2,'2025-09-01 08:15:00','paid','cash'),
 (3,3,'2025-09-02 09:05:00','paid','card'),
 (4,1,'2025-09-02 14:20:00','paid','app'),
 (5,2,'2025-09-03 07:50:00','paid','card'),
 (6,2,'2025-09-03 12:10:00','paid','card'),
 (7,1,'2025-09-04 16:45:00','refunded','card'),
 (8,3,'2025-09-05 10:30:00','paid','cash'),
 (1,1,'2025-09-06 06:58:00','paid','app'),
 (2,2,'2025-09-06 13:22:00','paid','card'),
 (3,3,'2025-09-07 08:40:00','paid','card'),
 (4,1,'2025-09-08 09:10:00','paid','cash'),
 (5,2,'2025-09-08 15:05:00','void','card'),
 (6,2,'2025-09-09 07:33:00','paid','app'),
 (7,1,'2025-09-09 11:12:00','paid','card');

-- Order items (no unit_price; keep it simple & consistent)
INSERT INTO order_items (order_id, product_id, quantity) VALUES
 (1,2,1),(1,7,1),(2,1,2),(3,4,1),(3,8,1),(4,6,1),(4,11,1),(5,2,2),(6,10,1),(6,7,2),
 (7,9,1),(8,5,2),(8,12,1),(9,3,1),(9,7,1),(10,4,2),(11,2,1),(11,8,1),(12,1,1),(12,7,1),
 (13,2,1),(14,6,1),(14,10,1),(15,2,1),(15,7,1);

INSERT INTO inventory (store_id, product_id, on_hand) VALUES
 (1,1,50),(1,2,40),(1,3,35),(1,4,25),(1,5,30),(1,6,20),(1,7,40),(1,8,25),(1,9,15),(1,10,10),(1,11,20),(1,12,15),
 (2,1,45),(2,2,42),(2,3,33),(2,4,28),(2,5,26),(2,6,24),(2,7,38),(2,8,22),(2,9,18),(2,10,12),(2,11,18),(2,12,16),
 (3,1,30),(3,2,28),(3,3,22),(3,4,20),(3,5,18),(3,6,14),(3,7,26),(3,8,16),(3,9,12),(3,10,8),(3,11,10),(3,12,9);
