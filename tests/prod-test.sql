-- Production Database Schema (Baseline State)
-- Ecommerce Database - Initial Production Version

-- Users table
CREATE TABLE Users (
    Id INT PRIMARY KEY AUTO_INCREMENT,
    UserName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN NOT NULL DEFAULT TRUE
);

-- Categories table (will be deleted in dev)
CREATE TABLE Categories (
    Id INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Description VARCHAR(500),
    ParentCategoryId INT NULL,
    IsActive BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (ParentCategoryId) REFERENCES Categories(Id)
);

-- Products table
CREATE TABLE Products (
    Id INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(200) NOT NULL,
    Description VARCHAR(1000),
    Price DECIMAL(10,2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    CategoryId INT NOT NULL,
    SKU VARCHAR(50) NOT NULL UNIQUE,
    Weight DECIMAL(10,3), -- This column will be removed in dev
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (CategoryId) REFERENCES Categories(Id)
);

-- Orders table
CREATE TABLE Orders (
    Id INT PRIMARY KEY AUTO_INCREMENT,
    UserId INT NOT NULL,
    OrderNumber VARCHAR(20) NOT NULL UNIQUE,
    TotalAmount DECIMAL(10,2) NOT NULL,
    OrderStatus VARCHAR(20) NOT NULL DEFAULT 'Pending', -- Will be renamed to Status in dev
    ShippingAddress VARCHAR(500) NOT NULL,
    BillingAddress VARCHAR(500) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users(Id)
);

-- OrderItems table (will remain mostly unchanged)
CREATE TABLE OrderItems (
    Id INT PRIMARY KEY AUTO_INCREMENT,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    TotalPrice DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderId) REFERENCES Orders(Id),
    FOREIGN KEY (ProductId) REFERENCES Products(Id)
);

-- Insert sample data
INSERT INTO Categories (Name, Description) VALUES
('Electronics', 'Electronic devices and accessories'),
('Clothing', 'Apparel and fashion items'),
('Books', 'Physical and digital books'),
('Home & Garden', 'Home improvement and gardening supplies');

INSERT INTO Users (UserName, Email, PasswordHash, FirstName, LastName) VALUES
('john_doe', 'john@example.com', 'hashed_password_123', 'John', 'Doe'),
('jane_smith', 'jane@example.com', 'hashed_password_456', 'Jane', 'Smith'),
('bob_wilson', 'bob@example.com', 'hashed_password_789', 'Bob', 'Wilson');

INSERT INTO Products (Name, Description, Price, StockQuantity, CategoryId, SKU, Weight) VALUES
('Smartphone X1', 'Latest smartphone with advanced features', 699.99, 50, 1, 'PHONE-X1-001', 0.180),
('Laptop Pro', 'High-performance laptop for professionals', 1299.99, 25, 1, 'LAPTOP-PRO-001', 2.100),
('Cotton T-Shirt', 'Comfortable cotton t-shirt', 19.99, 100, 2, 'SHIRT-COT-001', 0.200),
('Programming Book', 'Learn advanced programming concepts', 49.99, 75, 3, 'BOOK-PROG-001', 0.500);

INSERT INTO Orders (UserId, OrderNumber, TotalAmount, OrderStatus, ShippingAddress, BillingAddress) VALUES
(1, 'ORD-2024-0001', 719.98, 'Shipped', '123 Main St, City, State 12345', '123 Main St, City, State 12345'),
(2, 'ORD-2024-0002', 1299.99, 'Processing', '456 Oak Ave, City, State 67890', '456 Oak Ave, City, State 67890'),
(3, 'ORD-2024-0003', 69.98, 'Delivered', '789 Pine Rd, City, State 54321', '789 Pine Rd, City, State 54321');

INSERT INTO OrderItems (OrderId, ProductId, Quantity, UnitPrice, TotalPrice) VALUES
(1, 1, 1, 699.99, 699.99),
(1, 3, 1, 19.99, 19.99),
(2, 2, 1, 1299.99, 1299.99),
(3, 3, 2, 19.99, 39.98),
(3, 4, 1, 49.99, 49.99);
