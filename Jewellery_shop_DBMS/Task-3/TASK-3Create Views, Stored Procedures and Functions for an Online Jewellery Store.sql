-- Switch to your database
USE ecommerce;

-- Views

-- View for Product Information
CREATE VIEW vw_ProductInfo AS
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    p.Description,
    p.Price,
    p.StockQuantity,
    p.Weight,
    c.CategoryName
FROM Product p
JOIN Category c ON p.CategoryID = c.CategoryID;

-- View for Customer Orders
CREATE VIEW vw_CustomerOrders AS
SELECT 
    o.OrderID,
    o.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    o.OrderDate,
    o.TotalAmount
FROM `Order` o
JOIN Customer c ON o.CustomerID = c.CustomerID;

-- View for Detailed Order Information
CREATE VIEW vw_OrderDetails AS
SELECT 
    od.OrderDetailID,
    od.OrderID,
    p.Name AS ProductName,
    od.Quantity,
    od.Subtotal
FROM OrderDetail od
JOIN Product p ON od.ProductID = p.ProductID;

-- Stored Procedures

-- Procedure to Add a New Order
DELIMITER //

CREATE PROCEDURE sp_AddNewOrder(
    IN p_CustomerID INT,
    IN p_OrderDate DATETIME,
    IN p_TotalAmount DECIMAL(10, 2)
)
BEGIN
    INSERT INTO `Order` (CustomerID, OrderDate, TotalAmount)
    VALUES (p_CustomerID, p_OrderDate, p_TotalAmount);
END //

-- Procedure to Update Product Stock Quantity
CREATE PROCEDURE sp_UpdateStockQuantity(
    IN p_ProductID INT,
    IN p_QuantitySold INT
)
BEGIN
    UPDATE Product
    SET StockQuantity = StockQuantity - p_QuantitySold
    WHERE ProductID = p_ProductID;
END //

-- Procedure to Retrieve Customer Order History
CREATE PROCEDURE sp_GetCustomerOrderHistory(
    IN p_CustomerID INT
)
BEGIN
    SELECT * FROM vw_CustomerOrders
    WHERE CustomerID = p_CustomerID;
END //

DELIMITER ;

-- Functions

-- Function to Calculate Total Order Amount
DELIMITER //

CREATE FUNCTION fn_CalculateOrderTotal(
    p_OrderID INT
) RETURNS DECIMAL(10, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10, 2);

    -- Calculate total amount for the given OrderID
    SELECT COALESCE(SUM(Subtotal), 0) INTO total
    FROM OrderDetail
    WHERE OrderID = p_OrderID;

    RETURN total;
END //

-- Function to Get Product Price
CREATE FUNCTION fn_GetProductPrice(
    p_ProductID INT
) RETURNS DECIMAL(10, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE price DECIMAL(10, 2);

    -- Retrieve price for the given ProductID
    SELECT Price INTO price
    FROM Product
    WHERE ProductID = p_ProductID;

    RETURN price;
END //

DELIMITER ;