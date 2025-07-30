START TRANSACTION;
ALTER TABLE `Products` DROP CONSTRAINT `Products_ibfk_1`;

DROP TABLE `Categories`;

DROP INDEX CategoryId ON Products;

ALTER TABLE `Products` DROP COLUMN `CategoryId`;

ALTER TABLE `Products` DROP COLUMN `Weight`;

ALTER TABLE `Users` CHANGE `FirstName` `GivenName` varchar(50) NOT NULL DEFAULT '';

ALTER TABLE `Orders` CHANGE `OrderStatus` `Status` varchar(20) NOT NULL DEFAULT 'Pending';

ALTER TABLE `OrderItems` RENAME INDEX `ProductId` TO `ProductId1`;

ALTER TABLE `Users` ADD `Phone` varchar(20) NULL;

ALTER TABLE `Users` ADD `UpdatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE `Products` ADD `Brand` varchar(100) NULL;

ALTER TABLE `Products` ADD `IsDigital` tinyint(1) NOT NULL DEFAULT FALSE;

ALTER TABLE `Orders` ADD `TrackingNumber` varchar(50) NULL;

CREATE TABLE `InventoryLog` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `ProductId` int NOT NULL,
    `ChangeType` varchar(20) NOT NULL,
    `Quantity` int NOT NULL,
    `PreviousStock` int NOT NULL,
    `NewStock` int NOT NULL,
    `Reason` varchar(200) NULL,
    `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `CreatedBy` int NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `InventoryLog_ibfk_1` FOREIGN KEY (`ProductId`) REFERENCES `Products` (`Id`),
    CONSTRAINT `InventoryLog_ibfk_2` FOREIGN KEY (`CreatedBy`) REFERENCES `Users` (`Id`)
);

CREATE TABLE `ProductReviews` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `ProductId` int NOT NULL,
    `UserId` int NOT NULL,
    `Rating` int NOT NULL,
    `ReviewTitle` varchar(200) NOT NULL,
    `ReviewText` varchar(2000) NULL,
    `IsVerifiedPurchase` tinyint(1) NOT NULL,
    `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `UpdatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Id`),
    CONSTRAINT `ProductReviews_ibfk_1` FOREIGN KEY (`ProductId`) REFERENCES `Products` (`Id`),
    CONSTRAINT `ProductReviews_ibfk_2` FOREIGN KEY (`UserId`) REFERENCES `Users` (`Id`)
);

CREATE TABLE `ShippingAddresses` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `UserId` int NOT NULL,
    `AddressName` varchar(50) NOT NULL,
    `FullName` varchar(100) NOT NULL,
    `AddressLine1` varchar(200) NOT NULL,
    `AddressLine2` varchar(200) NULL,
    `City` varchar(100) NOT NULL,
    `State` varchar(100) NOT NULL,
    `PostalCode` varchar(20) NOT NULL,
    `Country` varchar(100) NOT NULL DEFAULT 'United States',
    `IsDefault` tinyint(1) NOT NULL,
    `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Id`),
    CONSTRAINT `ShippingAddresses_ibfk_1` FOREIGN KEY (`UserId`) REFERENCES `Users` (`Id`)
);

CREATE INDEX `CreatedBy` ON `InventoryLog` (`CreatedBy`);

CREATE INDEX `ProductId` ON `InventoryLog` (`ProductId`);

CREATE INDEX `ProductId2` ON `ProductReviews` (`ProductId`);

CREATE INDEX `UserId1` ON `ProductReviews` (`UserId`);

CREATE INDEX `UserId2` ON `ShippingAddresses` (`UserId`);

INSERT INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`)
VALUES ('20250730161145_ProductionToDev', '9.0.7');

COMMIT;

