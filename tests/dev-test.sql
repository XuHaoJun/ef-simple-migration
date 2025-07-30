-- Development Database Schema (Target State)
-- Ecommerce Database - Enhanced Development Version with Changes

-- Users table (ALTERED: added Phone column, renamed FirstName to GivenName)
CREATE TABLE Users (
    Id INT PRIMARY KEY AUTO_INCREMENT,
    UserName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    GivenName VARCHAR(50) NOT NULL, -- RENAMED from FirstName
    LastName VARCHAR(50) NOT NULL,
    Phone VARCHAR(20) NULL, -- ADDED new column
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- ADDED new column
    IsActive BOOLEAN NOT NULL DEFAULT TRUE
);

-- Categories table DELETED (no longer exists in dev)

-- Products table (ALTERED: removed Weight column, added Brand column, removed CategoryId since Categories table is deleted)
CREATE TABLE Products (
    Id INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(200) NOT NULL,
    Description VARCHAR(1000),
    Price DECIMAL(10,2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    SKU VARCHAR(50) NOT NULL UNIQUE,
    Brand VARCHAR(100) NULL, -- ADDED new column
    IsDigital BOOLEAN NOT NULL DEFAULT FALSE, -- ADDED new column
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    -- REMOVED: Weight column
    -- REMOVED: CategoryId column (since Categories table is deleted)
);

-- Orders table (ALTERED: renamed OrderStatus to Status, added TrackingNumber)
CREATE TABLE Orders (
    Id INT PRIMARY KEY AUTO_INCREMENT,
    UserId INT NOT NULL,
    OrderNumber VARCHAR(20) NOT NULL UNIQUE,
    TotalAmount DECIMAL(10,2) NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Pending', -- RENAMED from OrderStatus
    TrackingNumber VARCHAR(50) NULL, -- ADDED new column
    ShippingAddress VARCHAR(500) NOT NULL,
    BillingAddress VARCHAR(500) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users(Id)
);

-- OrderItems table (remains mostly the same)
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

-- NEW TABLE: ProductReviews (CREATE new table)
CREATE TABLE ProductReviews (
    Id INT PRIMARY KEY AUTO_INCREMENT,
    ProductId INT NOT NULL,
    UserId INT NOT NULL,
    Rating INT NOT NULL,
    ReviewTitle VARCHAR(200) NOT NULL,
    ReviewText VARCHAR(2000) NULL,
    IsVerifiedPurchase BOOLEAN NOT NULL DEFAULT FALSE,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductId) REFERENCES Products(Id),
    FOREIGN KEY (UserId) REFERENCES Users(Id)
);

-- NEW TABLE: ShippingAddresses (CREATE new table)
CREATE TABLE ShippingAddresses (
    Id INT PRIMARY KEY AUTO_INCREMENT,
    UserId INT NOT NULL,
    AddressName VARCHAR(50) NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    AddressLine1 VARCHAR(200) NOT NULL,
    AddressLine2 VARCHAR(200) NULL,
    City VARCHAR(100) NOT NULL,
    State VARCHAR(100) NOT NULL,
    PostalCode VARCHAR(20) NOT NULL,
    Country VARCHAR(100) NOT NULL DEFAULT 'United States',
    IsDefault BOOLEAN NOT NULL DEFAULT FALSE,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users(Id)
);

-- NEW TABLE: InventoryLog (CREATE new table)
CREATE TABLE InventoryLog (
    Id INT PRIMARY KEY AUTO_INCREMENT,
    ProductId INT NOT NULL,
    ChangeType VARCHAR(20) NOT NULL, -- 'IN', 'OUT', 'ADJUSTMENT'
    Quantity INT NOT NULL,
    PreviousStock INT NOT NULL,
    NewStock INT NOT NULL,
    Reason VARCHAR(200) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CreatedBy INT NULL,
    FOREIGN KEY (ProductId) REFERENCES Products(Id),
    FOREIGN KEY (CreatedBy) REFERENCES Users(Id)
);

-- Insert sample data for the updated schema
INSERT INTO Users (UserName, Email, PasswordHash, GivenName, LastName, Phone) VALUES
('john_doe', 'john@example.com', 'hashed_password_123', 'John', 'Doe', '+1-555-0101'),
('jane_smith', 'jane@example.com', 'hashed_password_456', 'Jane', 'Smith', '+1-555-0102'),
('bob_wilson', 'bob@example.com', 'hashed_password_789', 'Bob', 'Wilson', '+1-555-0103'),
('alice_brown', 'alice@example.com', 'hashed_password_000', 'Alice', 'Brown', '+1-555-0104');

INSERT INTO Products (Name, Description, Price, StockQuantity, SKU, Brand, IsDigital) VALUES
('Smartphone X1', 'Latest smartphone with advanced features', 699.99, 50, 'PHONE-X1-001', 'TechCorp', 0),
('Laptop Pro', 'High-performance laptop for professionals', 1299.99, 25, 'LAPTOP-PRO-001', 'CompuBrand', 0),
('Cotton T-Shirt', 'Comfortable cotton t-shirt', 19.99, 100, 'SHIRT-COT-001', 'FashionCo', 0),
('Programming Ebook', 'Digital programming guide', 29.99, 999, 'EBOOK-PROG-001', 'TechBooks', 1),
('Wireless Headphones', 'Premium noise-canceling headphones', 199.99, 75, 'HEADPHONE-WL-001', 'AudioTech', 0);

INSERT INTO Orders (UserId, OrderNumber, TotalAmount, Status, TrackingNumber, ShippingAddress, BillingAddress) VALUES
(1, 'ORD-2024-0001', 719.98, 'Delivered', 'TRK123456789', '123 Main St, City, State 12345', '123 Main St, City, State 12345'),
(2, 'ORD-2024-0002', 1299.99, 'Shipped', 'TRK987654321', '456 Oak Ave, City, State 67890', '456 Oak Ave, City, State 67890'),
(3, 'ORD-2024-0003', 69.98, 'Delivered', 'TRK456789123', '789 Pine Rd, City, State 54321', '789 Pine Rd, City, State 54321'),
(4, 'ORD-2024-0004', 229.98, 'Processing', NULL, '321 Elm St, City, State 98765', '321 Elm St, City, State 98765');

INSERT INTO OrderItems (OrderId, ProductId, Quantity, UnitPrice, TotalPrice) VALUES
(1, 1, 1, 699.99, 699.99),
(1, 3, 1, 19.99, 19.99),
(2, 2, 1, 1299.99, 1299.99),
(3, 3, 2, 19.99, 39.98),
(3, 4, 1, 29.99, 29.99),
(4, 5, 1, 199.99, 199.99),
(4, 4, 1, 29.99, 29.99);

INSERT INTO ProductReviews (ProductId, UserId, Rating, ReviewTitle, ReviewText, IsVerifiedPurchase) VALUES
(1, 1, 5, 'Excellent phone!', 'This smartphone exceeded my expectations. Great camera and battery life.', 1),
(2, 2, 4, 'Great for work', 'Perfect laptop for development work. Fast and reliable.', 1),
(3, 3, 5, 'Comfortable shirt', 'Very soft cotton material. Fits perfectly.', 1),
(4, 1, 4, 'Helpful guide', 'Comprehensive programming guide with good examples.', 1),
(5, 4, 5, 'Amazing sound quality', 'Best headphones I have ever owned. Noise canceling is superb.', 0);

INSERT INTO ShippingAddresses (UserId, AddressName, FullName, AddressLine1, City, State, PostalCode, IsDefault) VALUES
(1, 'Home', 'John Doe', '123 Main St', 'Anytown', 'CA', '12345', 1),
(1, 'Office', 'John Doe', '456 Business Blvd', 'Worktown', 'CA', '54321', 0),
(2, 'Home', 'Jane Smith', '456 Oak Ave', 'Hometown', 'NY', '67890', 1),
(3, 'Home', 'Bob Wilson', '789 Pine Rd', 'Villagetown', 'TX', '54321', 1),
(4, 'Home', 'Alice Brown', '321 Elm St', 'Newtown', 'FL', '98765', 1);

INSERT INTO InventoryLog (ProductId, ChangeType, Quantity, PreviousStock, NewStock, Reason, CreatedBy) VALUES
(1, 'IN', 20, 30, 50, 'New shipment received', 1),
(2, 'OUT', 5, 30, 25, 'Sales', NULL),
(3, 'IN', 50, 50, 100, 'Restocked popular item', 1),
(4, 'IN', 999, 0, 999, 'Digital product - unlimited stock', 1),
(5, 'IN', 25, 50, 75, 'Return from defective batch', 2);
