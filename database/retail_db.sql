CREATE DATABASE IF NOT EXISTS retail_db;
USE retail_db;

CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(255),
  city VARCHAR(50),
  country VARCHAR(50)
);

CREATE TABLE products (
  product_id INT PRIMARY KEY,
  name VARCHAR(255),
  category VARCHAR(100),
  cost DECIMAL(10,2),
  retail_price DECIMAL(10,2)
);

CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  status VARCHAR(50),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
  order_item_id INT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT,
  price DECIMAL(10,2),
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO customers VALUES
(1, 'Aisha', 'Khan', 'aisha.khan@example.com', 'Mumbai', 'India'),
(2, 'Mehul', 'Patel', 'mehul.patel@example.com', 'Surat', 'India'),
(3, 'Riya', 'Shah', 'riya.shah@example.com', 'Ahmedabad', 'India'),
(4, 'Arjun', 'Mehta', 'arjun.mehta@example.com', 'Delhi', 'India'),
(5, 'Sneha', 'Nair', 'sneha.nair@example.com', 'Bangalore', 'India'),
(6, 'Kabir', 'Singh', 'kabir.singh@example.com', 'Hyderabad', 'India'),
(7, 'Zara', 'Ali', 'zara.ali@example.com', 'Pune', 'India'),
(8, 'Rohan', 'Verma', 'rohan.verma@example.com', 'Jaipur', 'India'),
(9, 'Mira', 'Joshi', 'mira.joshi@example.com', 'Chennai', 'India'),
(10, 'Dev', 'Gujar', 'dev.gujar@example.com', 'Kolkata', 'India');

INSERT INTO products VALUES
(100, 'Blue T-Shirt', 'Apparel', 200.00, 499.00),
(101, 'Running Shoes', 'Footwear', 1200.00, 2499.00),
(102, 'Wireless Mouse', 'Electronics', 350.00, 799.00),
(103, 'Water Bottle', 'Home', 60.00, 149.00),
(104, 'Laptop Bag', 'Accessories', 450.00, 999.00),
(105, 'Sports Watch', 'Electronics', 800.00, 1699.00),
(106, 'Yoga Mat', 'Fitness', 150.00, 399.00),
(107, 'Backpack', 'Accessories', 300.00, 699.00),
(108, 'Bluetooth Earbuds', 'Electronics', 900.00, 1999.00),
(109, 'Office Chair', 'Furniture', 2500.00, 5499.00);

INSERT INTO orders VALUES
(5001, 1, '2025-01-05', 'Delivered'),
(5002, 2, '2025-01-06', 'Delivered'),
(5003, 3, '2025-01-06', 'Cancelled'),
(5004, 1, '2025-01-07', 'Delivered'),
(5005, 4, '2025-01-08', 'Pending'),
(5006, 5, '2025-01-08', 'Delivered'),
(5007, 2, '2025-01-09', 'Delivered'),
(5008, 6, '2025-01-10', 'Delivered'),
(5009, 7, '2025-01-10', 'Delivered'),
(5010, 1, '2025-01-11', 'Delivered');

INSERT INTO order_items VALUES
(9001, 5001, 100, 2, 499.00),
(9002, 5001, 103, 1, 149.00),
(9003, 5002, 101, 1, 2499.00),
(9004, 5003, 102, 1, 799.00),
(9005, 5004, 100, 1, 499.00),
(9006, 5004, 108, 1, 1999.00),
(9007, 5005, 109, 1, 5499.00),
(9008, 5006, 105, 1, 1699.00),
(9009, 5007, 107, 1, 699.00),
(9010, 5007, 103, 2, 149.00),
(9011, 5008, 100, 3, 499.00),
(9012, 5009, 106, 1, 399.00),
(9013, 5009, 102, 1, 799.00),
(9014, 5010, 108, 1, 1999.00),
(9015, 5010, 104, 1, 999.00);
