CREATE DATABASE INFO_430_Proj_03
USE INFO_430_Proj_03

CREATE TABLE Gender
(
    GenderID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    GenderName VARCHAR(20) NOT NULL
)

CREATE TABLE UserType
(
    UserTypeID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    UserTypeNmae VARCHAR(100) NOT NULL,
    UserTypeDescription VARCHAR(1000) NULL
)

CREATE TABLE [User]
(
    UserID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Email VARCHAR(100) NULL,
    UserTypeID INT REFERENCES UserType(UserTypeID) NOT NULL,
    UserFname VARCHAR(100) NOT NULL,
    UserLname VARCHAR(100) NOT NULL,
    GenderID INT REFERENCES Gender(GenderID) NOT NULL
)


CREATE TABLE Website
(
    WebsiteID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    WebsiteName VARCHAR(100) NOT NULL,
    WebsiteDomain VARCHAR(100) NOT NULL
)

CREATE TABLE [Order]
(
    OrderID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    OrderDate DATE NOT NULL,
    UserID INT REFERENCES [User](UserID) NOT NULL,
    WebsiteID INT REFERENCES Website(WebsiteID) NOT NULL,
)

CREATE TABLE OrderCoupon
(
    OrderCouponID INT IDENTITY(1,1) PRIMARY KEY,
    CouponID INT FOREIGN KEY REFERENCES Coupon(CouponID) NOT NULL,
    OrderID INT FOREIGN KEY REFERENCES [Order](OrderID) NOT NULL
)
GO

CREATE TABLE Coupon
(
    CouponID INT IDENTITY(1,1) PRIMARY KEY,
    CouponTypeID INT FOREIGN KEY REFERENCES CouponType(CouponTypeID) NOT NULL,
    ExpiredDate DATE NOT NULL,
    CouponName varchar(50) NOT NULL
)
GO

CREATE TABLE CouponCondition
(
    CouponConditionID INT IDENTITY(1,1) PRIMARY KEY,
    ConditionID INT FOREIGN KEY REFERENCES Condition(ConditionID) NOT NULL,
    CouponID INT FOREIGN KEY REFERENCES Coupon(CouponID) NOT NULL
)
GO

CREATE TABLE CouponType
(
    CouponTypeID INT IDENTITY(1,1) PRIMARY KEY,
    CouponTypeName varchar(50) NOT NULL,
    CouponDescription varchar(500) NULL
)
GO

CREATE TABLE Condition
(
    ConditionID INT IDENTITY(1,1) PRIMARY KEY,
    ConditionDesc varchar(50) NOT NULL,
    ConditionName varchar(500) NOT NULL
)
GO


CREATE TABLE OrderProduct
(
    OrderProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT FOREIGN KEY REFERENCES Product(ProductID) NOT NULL,
    OrderID INT FOREIGN KEY REFERENCES [Order](OrderID) NOT NULL,
    Quantity INT NOT NULL
)
GO

CREATE TABLE ProductType
(
    ProductTypeID INT IDENTITY(1,1) primary key,
    ProductTypeName varchar(50) not null,
    ProductTypeDescription varchar(500) NULL
)
GO

CREATE TABLE Product
(
    ProductID INT IDENTITY(1,1) primary key,
    ProductName varchar(200) not null,
    ProductTypeID INT FOREIGN KEY REFERENCES ProductType(ProductTypeID) not null,
    ProdPrice Numeric(8,2) NULL
)
GO

ALTER TABLE Product
ALTER COLUMN ProductName VARCHAR(200);

GO
