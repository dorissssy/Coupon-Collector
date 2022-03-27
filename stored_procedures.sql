ALTER PROCEDURE GetGenderID
@GenderName VARCHAR(20),
@GenderID INT OUTPUT
AS
SET @GenderID = (SELECT GenderID FROM Gender WHERE GenderName = @GenderName)
GO

-- UserType
ALTER PROCEDURE GetUserTypeID
@UserTypeName VARCHAR(100),
@UserTypeID INT OUTPUT
AS
SET @UserTypeID = (SELECT UserTypeID FROM UserType WHERE UserTypeName = @UserTypeName)
GO

-- User
ALTER PROCEDURE GetUserID
@UserFname VARCHAR(100),
@UserLname VARCHAR(100),
@Email VARCHAR(100),
@UserID INT OUTPUT
AS
SET @UserID = (SELECT UserID 
                FROM [User] 
                WHERE UserFname = @UserFname 
                AND UserLname = @UserLname
                AND Email = @Email)
GO

-- New User
ALTER PROCEDURE NewUser
@Email VARCHAR(100),
@Fname VARCHAR(100),
@Lname VARCHAR(100),
@Gender VARCHAR(20),
@UserTypeName VARCHAR(100)
AS
DECLARE @TypeID INT, @GID INT

EXEC GetGenderID
@GenderName = @Gender,
@GenderID = @GID OUTPUT

IF @GID IS NULL
    BEGIN
    PRINT '@GID is null'
    RAISERROR ('@GID cannot be null', 11, 1)
    RETURN
    END

EXEC GetUserTypeID
@UserTypeName = @UserTypeName,
@UserTypeID = @TypeID OUTPUT

IF @TypeID IS NULL
    BEGIN
    PRINT '@TypeID is null'
    RAISERROR ('@TypeID cannot be null', 11, 1)
    RETURN
    END

BEGIN TRAN T1
INSERT INTO [User](Email, UserTypeID, UserFname, UserLname, GenderID)
VALUES(@Email, @TypeID, @Fname, @Lname, @GID)
IF @@ERROR <> 0
    BEGIN
        ROLLBACK
    END
ELSE
    COMMIT TRAN T1
GO

Use INFO_430_Proj_03
GO

ALTER PROCEDURE GetOrderID
@FNG VARCHAR(100),
@LNG VARCHAR(100),
@EG VARCHAR(100),
@WNG VARCHAR(100),
@OD DATE,
@O INT OUTPUT
AS
DECLARE @UID INT

EXEC GetUserID
@UserFname = @FNG,
@UserLname = @LNG,
@Email = @EG,
@UserID = @UID OUTPUT

SET @O = (SELECT O.OrderID
            FROM [Order] O
                JOIN [User] U ON U.UserID = O.UserID
                JOIN Website W ON W.WebsiteID = O.WebsiteID
            WHERE U.UserID = @UID
            AND O.OrderDate = @OD
            AND W.WebsiteName = @WNG)
GO

ALTER PROCEDURE GetCouponID
@CouponName VARCHAR(50),
@ExiredDate Date,
@CouponID INT OUTPUT
AS
SET @CouponID = (SELECT CouponID FROM Coupon WHERE CouponName = @CouponName AND ExpiredDate = @ExiredDate)
GO

----------------------------------------------------------------------------
ALTER PROCEDURE NewCouponOrder
@FN VARCHAR(100),
@LN VARCHAR(100),
@E VARCHAR(100),
@WEB VARCHAR(100),
@OrderDate DATE,
@CoupName VARCHAR(100),
@ExDate Date
AS
DECLARE @OID INT, @CID INT

EXEC GetOrderID
@FNG = @FN,
@LNG = @LN,
@EG = @E,
@WNG = @WEB,
@OD = @OrderDate,
@O = @OID OUTPUT

IF @OID IS NULL
    BEGIN
        PRINT ('order ID is null');
        THROW 59999, '@OID cannot be null', 1;
    END

EXEC GetCouponID
@CouponName = @CoupName,
@ExiredDate = @ExDate,
@CouponID = @CID OUTPUT

IF @CID IS NULL
    BEGIN
        PRINT ('Coupon ID is null');
        THROW 59999, '@CID cannot be null', 1;
    END

BEGIN TRANSACTION T1
INSERT INTO OrderCoupon(CouponID, OrderID)
VALUES(@CID, @OID)
IF @@ERROR <> 0
    BEGIN
        ROLLBACK TRANSACTION T1
    END
ELSE
    COMMIT TRANSACTION T1
GO

SELECT * FROM dbo.[Order]
GO
---------------------------------------------------------------------------
ALTER PROCEDURE Wrapper_NewCouponOrder
@RUN INT
AS
DECLARE @OrderID INT, @CouponID INT
DECLARE @OrderCount INT = (SELECT COUNT(*) FROM [Order])
DECLARE @CounponCount INT = (SELECT COUNT(*) FROM Coupon)
DECLARE @FFN VARCHAR(100), @LLN VARCHAR(100), @EE VARCHAR(100), @WWEB VARCHAR(100)
DECLARE @OOrderDate DATE, @CCoupName VARCHAR(100), @EExDate DATE

WHILE @RUN > 0
BEGIN
    SET @OrderID = (SELECT RAND() * @OrderCount + 552338)
    SET @CouponID = (SELECT RAND() * @CounponCount + 1)

    DECLARE @UserID INT = (SELECT U.UserID
                FROM [Order] O
                    JOIN [User] U ON O.UserID = U.UserID
                WHERE O.OrderID = @OrderID)
    
    SET @FFN = (SELECT U.UserFname FROM [User] U WHERE U.UserID = @UserID)
    SET @LLN = (SELECT U.UserLname FROM [User] U WHERE U.UserID = @UserID)
    SET @EE = (SELECT U.Email FROM [User] U WHERE U.UserID = @UserID)
    SET @WWEB = (SELECT W.WebsiteName
                FROM [Order] O
                    JOIN Website W ON O.WebsiteID = W.WebsiteID
                WHERE O.OrderID = @OrderID)
    SET @OOrderDate = (SELECT OrderDate FROM [Order] WHERE OrderID = @OrderID)

    SET @CCoupName = (SELECT CouponName FROM Coupon WHERE CouponID = @CouponID)
    SET @EExDate = (SELECT ExpiredDate FROM Coupon WHERE CouponID = @CouponID)

    EXEC NewCouponOrder
    @FN = @FFN,
    @LN = @LLN,
    @E = @EE,
    @WEB = @WWEB,
    @OrderDate = @OOrderDate,
    @CoupName = @CCoupName,
    @ExDate = @EExDate

    SET @RUN = @RUN - 1
END
GO

EXEC Wrapper_NewCouponOrder
@RUN = 5743

GO



-- Get Condition ID
CREATE PROCEDURE GetConDiID
    @ConDiName varchar(100),
    @C_ID INT OUTPUT
AS
SET @C_ID = (SELECT ConditionID
FROM Condition
WHERE ConditionName = @ConDiName)
GO

-- Get Coupon Type ID
CREATE PROCEDURE GetCouponTypeID
    @CouponTyName varchar(100),
    @CoupT_ID INT OUTPUT
AS
SET @CoupT_ID = (SELECT CouponTypeID
FROM CouponType
WHERE CouponTypeName = @CouponTyName)
GO

-- Get Coupon ID
CREATE PROCEDURE GetCouponID
    @CouponnName varchar(100),
    @Coup_ID INT OUTPUT
AS
SET @Coup_ID = (SELECT CouponID
FROM Coupon
WHERE CouponName = @CouponnName)
GO

-- Get Coupon Condition ID
CREATE PROCEDURE GetCouponConID
    @CouponnName varchar(100),
    @CondiCondiName varchar(100),
    @CoupCondi_ID INT OUTPUT
AS
Declare @CondiCondi Int, @CouCouID Int

Exec GetConDiID
@ConDiName = @CondiCondiName,
@C_ID = @CondiCondi Output

Exec GetCouponID
@CouponnName = @CouponnName,
@Coup_ID = @CouCouID Output

SET @CoupCondi_ID = (SELECT CouponConditionID
FROM CouponCondition
WHERE ConditionID = @CondiCondi
    and CouponID = @CouCouID)
GO


--Insert
CREATE PROCEDURE InsertCouponCondition
    @ConditionnnName varchar(100),
    @CouponTyyName varchar(100)
AS
IF @ConditionnnName is null or @CouponTyyName is null
    Begin
    Print('There is one or more null inputs.');
    THROW 53002, 'ID annot be NULL; process terminating', 1;
    RETURN
End

Declare @CondiCondi Int, @CouCouID Int

Exec GetConDiID
@ConDiName = @ConditionnnName,
@C_ID = @CondiCondi Output

Exec GetCouponTypeID
@CouponTyName = @CouponTyyName,
@CoupT_ID = @CouCouID Output

GO

CREATE PROCEDURE InsertCoupon
    @ExxxDate Date,
    @CouponName varchar(100),
    @CouponTyyName varchar(100)
AS
IF @ExxxDate is null or @CouponName is null or @CouponTyyName is null
    Begin
    Print('There is one or more null inputs.');
    THROW 53002, 'ID annot be NULL; process terminating', 1;
End
Declare @CouCouTypeID Int
Exec GetCouponTypeID
@CouponTyName = @CouponTyyName,
@CoupT_ID = @CouCouTypeID Output

GO

Create PROCEDURE Insert_Coupon
@RUN INT
AS
DECLARE @ED DATE
DECLARE @Randy INT
DECLARE @CouponTypeCount INT = (SELECT COUNT(*) FROM CouponType)
DECLARE @StudPK INT
DECLARE @Length INT
DECLARE @CharPool varchar(5000)
DECLARE @PoolLength INT
DECLARE @LoopCount INT
DECLARE @RandomString varchar(5000)

WHILE @RUN > 0
BEGIN
SET @Length = RAND() * 5 + 8
SET @Randy = (SELECT RAND() * 300 + (6954))
SET @ED = (DateAdd(Day, @Randy, GETDATE()))
SET @StudPK = (SELECT RAND() * @CouponTypeCount +1)
SET @CharPool = 'abcdefghijkmnopqrstuvwxyzABCDEFGHIJKLMNPQRSTUVWXYZ23456789.,-_!$@#%^&*'
SET @PoolLength = Len(@CharPool)
SET @LoopCount = 0
SET @RandomString = ''

WHILE (@LoopCount < @Length) BEGIN
    SELECT @RandomString = @RandomString + 
        SUBSTRING(@Charpool, CONVERT(int, RAND() * @PoolLength) + 1, 1)
    SELECT @LoopCount = @LoopCount + 1
END

INSERT INTO Coupon (ExpiredDate, CouponName, CouponTypeID)
VALUES (@ED, @RandomString, @StudPK)

SET @RUN = @RUN - 1
END

EXEC Insert_Coupon 
@RUN = 3000
GO


--second syn
Create PROCEDURE Insert_CouponCondition
@RUN INT
AS
DECLARE @RUN INT
DECLARE @Condidition INT
DECLARE @FATE INT

WHILE @RUN < 3001
BEGIN

SET @Condidition = 7

INSERT INTO CouponCondition (ConditionID, CouponID)
VALUES (@Condidition, @RUN)

SET @Condidition = RAND() * 3 + 9

INSERT INTO CouponCondition (ConditionID, CouponID)
VALUES (@Condidition, @RUN)

SET @FATE = RAND() * 5 + 4

if(@FATE >= 7)
INSERT INTO CouponCondition (ConditionID, CouponID)
VALUES (8, @RUN)


SET @RUN = @RUN + 1
END

EXEC Insert_CouponCondition
@RUN = 1
GO


CREATE PROCEDURE getWebsite
    @WN VARCHAR(30),
    @W INT OUTPUT
AS
SET @W = (SELECT WebsiteID
FROM Website
WHERE WebsiteName = @WN)
GO

ALTER PROCEDURE getUser
    @FN VARCHAR(20),
    @LN VARCHAR(20),
    @E VARCHAR(100),
    @U INT OUTPUT
AS
SET @U = (SELECT UserID
FROM [User]
WHERE UserFname = @FN AND UserLname = @LN AND Email = @E)
GO

ALTER PROCEDURE insertOrder
    @ODI DATE,
    @FNI VARCHAR(20),
    @LNI VARCHAR(20),
    @EI VARCHAR(100),
    @WNI VARCHAR(20)
AS
DECLARE @U_IDI INT, @W_IDI INT
EXEC getUser
@FN = @FNI,
@E = @EI,
@LN = @LNI,
@U = @U_IDI OUTPUT
IF @U_IDI IS NULL
    BEGIN
    PRINT '@U_IDI IS NULL'
    RAISERROR ('NULL ERROR', 11, 1)
    RETURN
END
EXEC getWebsite
@WN = @WNI,
@W = @W_IDI OUTPUT
IF @W_IDI IS NULL
    BEGIN
    PRINT '@W_IDI IS NULL'
    RAISERROR ('NULL ERROR', 11, 1)
    RETURN
END
BEGIN TRAN T1
INSERT INTO [Order]
    (OrderDate, UserID, WebsiteID)
VALUES(@ODI, @U_IDI, @W_IDI)
IF @@ERROR <> 0
    BEGIN
    ROLLBACK TRAN T1
END
ELSE
    COMMIT TRAN T1
GO


ALTER PROCEDURE SynInsertOrder
@RUN INT
AS
DECLARE @WebsiteRange INT = (SELECT COUNT(*) FROM Website)
DECLARE @UserRange INT = (SELECT COUNT(*) FROM [User])

DECLARE @OrderDate DATE
DECLARE @UserID INT
DECLARE @WebsiteID INT 

DECLARE @ODI DATE
DECLARE @FN VARCHAR(20)
DECLARE @LN VARCHAR(20)
DECLARE @E VARCHAR(100)
DECLARE @WN VARCHAR(20)

WHILE (@RUN > 0)
BEGIN 
SET @OrderDate = DATEADD(DAY, RAND()*365*21, '2000-01-01')
SET @WebsiteID = (SELECT RAND()*@WebsiteRange + 1)
SET @UserID = (SELECT TOP 1 UserID FROM [User] ORDER BY NEWID())

SET @FN = (SELECT UserFname FROM [User] WHERE UserID = @UserID)
SET @LN = (SELECT UserLname FROM [User] WHERE UserID = @UserID)
SET @E = (SELECT Email FROM [User] WHERE UserID = @UserID)
SET @WN = (SELECT WebsiteName FROM Website WHERE WebsiteID = @WebsiteID)



EXEC insertOrder
@FNI = @FN,
@LNI = @LN,
@EI = @E,
@WNI = @WN,
@ODI = @OrderDate

SET @RUN = @RUN - 1
END

EXEC SynInsertOrder
@RUN = 3000
GO



CREATE PROCEDURE getOrder
    @FNG VARCHAR(20),
    @LNG VARCHAR(20),
    @EG VARCHAR(35),
    @WNG VARCHAR(20),
    @OD DATE,
    @O INT OUTPUT
AS
SET @O = (SELECT OrderID
FROM [Order] O
    JOIN [User] U ON U.UserID = O.OrderID
    JOIN Website W ON W.WebsiteID = O.WebsiteID
WHERE U.UserFname = @FNG
    AND U.UserLname = @LNG
    AND U.Email = @EG
    AND O.OrderDate = @OD
    AND W.WebsiteName = @WNG)
GO

CREATE PROCEDURE insertOrderCoupon
    @OOT NUMERIC(8, 2),
    @DM NUMERIC(8, 2),
    @FNIO VARCHAR(20),
    @LNIO VARCHAR(20),
    @EIO VARCHAR(35),
    @WNIO VARCHAR(20),
    @ODIO DATE,
    @CNIO VARCHAR(100)
AS
DECLARE @O_IDI INT, @C_IDI INT
EXEC getOrder
@FNG = @FNIO,
@LNG = @LNIO,
@EG = @EIO,
@WNG = @WNIO,
@OD = @ODIO,
@O = @O_IDI OUTPUT
IF @O_IDI IS NULL
    BEGIN
    PRINT '@O IS NULL'
    RAISERROR ('NULL ERROR', 11, 1)
    RETURN
END
EXEC GetCouponID
@CouponnName = @CNIO,
@Coup_ID = @C_IDI OUTPUT
IF @C_IDI  IS NULL
    BEGIN
    PRINT '@C_IDI IS NULL'
    RAISERROR ('NULL ERROR', 11, 1)
    RETURN
END
BEGIN TRAN T1
INSERT INTO OrderCoupon
    (CouponID, OrderID, OriginalOrderTotal, DiscountedAmount)
VALUES(@C_IDI, @O_IDI, @OOT, @DM)
IF @@ERROR <> 0
    BEGIN
    ROLLBACK TRAN T1
END
ELSE
    COMMIT TRAN T1
GO


-- stored procedure
CREATE PROCEDURE InsertProdType
    @PTName varchar(100),
    @PTDesc varchar(500)
AS
DECLARE @PTID INT
GO

CREATE PROCEDURE GetPTID
    @PTName varchar(100),
    @PTID INT OUTPUT
AS
SET @PTID = (SELECT ProductTypeID
FROM ProductType
WHERE ProductTypeName = @PTName)
GO

CREATE PROCEDURE InsertProduct
    @PT_Name varchar(100),
    @ProdName varchar(100),
    @P_Price Numeric(8,2)
AS
DECLARE @PT_ID INT

EXEC GetPTID
@PTName = @PT_Name,
@PTID = @PT_ID OUTPUT
IF @PT_ID IS NULL
    BEGIN
    PRINT '@PTID IS NULL';
    RAISERROR ('there is an error', 11,1);
    RETURN
END
GO

CREATE PROCEDURE GetPID
    @PName varchar(100),
    @PID INT OUTPUT
AS
SET @PID = (SELECT ProductID
FROM Product
WHERE ProductName = @PName)
GO

CREATE PROCEDURE GetOrderID
    @FNG VARCHAR(20),
    @LNG VARCHAR(20),
    @EG VARCHAR(35),
    @WNG VARCHAR(20),
    @OD DATE,
    @O INT OUTPUT
AS
SET @O = (SELECT OrderID
FROM [Order] O
    JOIN [User] U ON U.UserID = O.OrderID
    JOIN Website W ON W.WebsiteID = O.WebsiteID
WHERE U.UserFname = @FNG
    AND U.UserLname = @LNG
    AND U.Email = @EG
    AND O.OrderDate = @OD
    AND W.WebsiteName = @WNG)
GO



CREATE PROCEDURE InsertOrderProduct
@Quant INT,
@P__NAME varchar(100),
@F__Name varchar(50),
@L__Name varchar(50),
@Eml varchar(35),
@O__Date DATE,
@W__Name varchar(50)
AS
DECLARE @P__ID INT, @O__ID INT
EXEC GetPID
@PName = @P__Name,
@PID = @P__ID OUTPUT
IF @P__ID IS NULL
    BEGIN
        PRINT '@PID IS NULL';
        RAISERROR ('there is an error', 11,1);
        RETURN
    END

EXEC GetOrderID
@FNG = @F__Name,
@LNG = @L__Name,
@EG = @Eml,
@WNG = @W__Name,
@OD = @O__Date,
@O = @O__ID OUTPUT
IF @O__ID IS NULL
    BEGIN
        PRINT '@O IS NULL';
        RAISERROR ('there is an error', 11,1);
        RETURN
    END
BEGIN TRAN T1
INSERT INTO OrderProduct
    (ProductID, OrderID)
VALUES(@P__ID, @O__ID)
IF @@ERROR <> 0
    BEGIN
    ROLLBACK TRAN T1
END
ELSE
    COMMIT TRAN T1
GO


-- orderprod synthetic transaction

ALTER PROCEDURE Wrapper_InsertOrderProd
@RUN INT
AS
DECLARE @OrderPK INT
DECLARE @ProdPK INT
DECLARE @OrderCount INT = (SELECT COUNT(*) FROM [Order])
DECLARE @ProdCount INT = (SELECT COUNT(*) FROM Product)

DECLARE @WebsiteRange INT = (SELECT COUNT(*) FROM Website)
DECLARE @UserRange INT = (SELECT COUNT(*) FROM [User])

DECLARE @Prod_Name varchar(50), @First_Name varchar(50), @Last_Name varchar(50), 
@E_mail varchar(35), @Order_Date DATE, @Web_Name varchar(50), @Quantity INT, @UserID INT,
@WebsiteID INT

WHILE @RUN > 0
BEGIN
SET @OrderPK = (SELECT TOP 1 OrderID
FROM [Order]
ORDER BY NEWID())
SET @ProdPK = (SELECT TOP 1 ProductID
FROM Product
ORDER BY NEWID())

SET @WebsiteID = (SELECT W.WebsiteID FROM Website W JOIN [Order] O ON O.WebsiteID = W.WebsiteID WHERE OrderID = @OrderPK) -- You have Order PK, use OrderPK to find websiteID
SET @UserID = (SELECT U.UserID FROM [User] U JOIN [Order] O ON O.UserID = U.UserID WHERE O.OrderID = @OrderPK) -- change this accordingly, see above comment


SET @First_Name = (SELECT UserFname FROM [User] WHERE UserID = @UserID)
SET @Last_Name = (SELECT UserLname FROM [User] WHERE UserID = @UserID)
SET @E_mail = (SELECT Email FROM [User] WHERE UserID = @UserID)
SET @Web_Name = (SELECT WebsiteName FROM Website WHERE WebsiteID = @WebsiteID)
SET @Prod_Name = (SELECT ProductName FROM Product WHERE ProductID = @ProdPK)
SET @Order_Date = (SELECT O.OrderDate FROM [Order] O WHERE O.OrderID = @OrderPK)

SET @Quantity = (SELECT ROUND((100 * RAND()), 0))



EXEC InsertOrderProduct
@Quant  = @Quantity,
@P__NAME = @Prod_Name,
@F__Name = @First_Name,
@L__Name = @Last_Name,
@Eml = @E_mail,
@O__Date = @Order_Date,
@W__Name = @Web_Name

SET @RUN = @RUN - 1
END

EXEC Wrapper_InsertOrderProd
@RUN = 100
