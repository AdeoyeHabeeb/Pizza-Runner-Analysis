-- =========================================
-- Pizza Runner MySQL Script (Traditional)
-- =========================================

-- ======================
-- 1. Customer Orders Clean
-- ======================

-- Replace NULL or empty values with 0
UPDATE customer_orders
SET exclusions = 0
WHERE exclusions IS NULL OR exclusions = '';

UPDATE customer_orders
SET extras = 0
WHERE extras IS NULL OR extras = '';

-- Create cleaned table
CREATE TABLE customer_orders_new (
  order_id INT,
  customer_id INT,
  pizza_id INT,
  exclusions INT,
  extras INT,
  order_time DATETIME
);

-- Insert cleaned data (no splitting of comma values)
INSERT INTO customer_orders_new (order_id, customer_id, pizza_id, exclusions, extras, order_time)
SELECT order_id, customer_id, pizza_id, exclusions, extras, order_time
FROM customer_orders;

-- Replace original table
DROP TABLE customer_orders;
ALTER TABLE customer_orders_new RENAME TO customer_orders;

-- ======================
-- 2. Runner Orders Clean
-- ======================

CREATE TABLE runner_orders_new (
  order_id INT,
  runner_id INT,
  pickup_time DATETIME,
  distance DECIMAL(10,2),
  duration TIME,
  cancellation VARCHAR(10)
);

INSERT INTO runner_orders_new (order_id, runner_id, pickup_time, distance, duration, cancellation)
SELECT 
    order_id,
    runner_id,
    pickup_time,
    CAST(REPLACE(distance, 'km', '') AS DECIMAL(10,2)),
    duration,
    IF(cancellation IS NULL OR cancellation = '', 'No', cancellation)
FROM runner_orders;

DROP TABLE runner_orders;
ALTER TABLE runner_orders_new RENAME TO runner_orders;

-- ======================
-- 3. Pizza Recipes Clean
-- ======================

CREATE TABLE pizza_recipes_new (
  pizza_id INT,
  toppings VARCHAR(255)
);

INSERT INTO pizza_recipes_new (pizza_id, toppings)
SELECT pizza_id, toppings
FROM pizza_recipes;

DROP TABLE pizza_recipes;
ALTER TABLE pizza_recipes_new RENAME TO pizza_recipes;

-- =========================================
-- Business Metrics
-- =========================================

-- 1. Total pizzas ordered
SELECT COUNT(pizza_id) AS pizza_orders
FROM customer_orders;

-- 2. Unique customer orders
SELECT COUNT(DISTINCT customer_id) AS unique_customer_orders
FROM customer_orders;

-- 3. Successful orders per runner
SELECT runner_id AS runner,
       COUNT(*) AS total_delivered_orders
FROM runner_orders
WHERE cancellation = 'No'
GROUP BY runner_id;

-- 4. Orders per pizza type
SELECT p.pizza_id, p.pizza_name, COUNT(c.pizza_id) AS total_delivered
FROM pizza_names p
LEFT JOIN customer_orders c ON p.pizza_id = c.pizza_id
GROUP BY p.pizza_id, p.pizza_name;

-- 5. Orders by customer and pizza type
SELECT c.customer_id, p.pizza_name, COUNT(c.order_id) AS total_order
FROM customer_orders c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id;

-- 6. Maximum pizzas in a single order
SELECT MAX(pizza_count) AS max_pizzas_delivered
FROM (
    SELECT order_id, COUNT(*) AS pizza_count
    FROM customer_orders
    GROUP BY order_id
) AS pizza_counts;

-- 7. Pizzas with and without changes per customer
SELECT customer_id,
       SUM(CASE WHEN exclusions <> 0 OR extras <> 0 THEN 1 ELSE 0 END) AS pizzas_with_change,
       SUM(CASE WHEN exclusions = 0 AND extras = 0 THEN 1 ELSE 0 END) AS pizzas_with_no_change
FROM customer_orders
GROUP BY customer_id
ORDER BY customer_id;

-- 8. Pizzas with both exclusions and extras
SELECT COUNT(order_id) AS pizzas_delivered
FROM customer_orders
WHERE exclusions <> 0 AND extras <> 0;

-- 9. Total pizzas by hour
SELECT DATE_FORMAT(order_time, '%Y-%m-%d %H:00:00') AS order_hour,
       COUNT(*) AS total_pizzas_ordered
FROM customer_orders
GROUP BY order_hour
ORDER BY order_hour;

-- 10. Orders by week/day
SELECT WEEK(order_time) AS order_week,
       DAYOFWEEK(order_time) AS order_day,
       COUNT(*) AS total_orders
FROM customer_orders
GROUP BY order_week, order_day
ORDER BY order_week, order_day;

-- 11. Average pickup time per runner in minutes
SELECT runner_id,
       ROUND(AVG(TIME_TO_SEC(duration)/60)) AS avg_pickup_minutes
FROM runner_orders
GROUP BY runner_id
ORDER BY runner_id;

-- =========================================
-- Views
-- =========================================

DROP VIEW IF EXISTS customer_orders_summary;

CREATE VIEW customer_orders_summary AS
SELECT c.customer_id, p.pizza_name, COUNT(c.order_id) AS total_order
FROM customer_orders c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, p.pizza_name;
