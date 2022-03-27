-- Coupon cannot be applied to order if it passed valid date
CREATE FUNCTION NoPassDateCoupon()
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0

IF EXISTS(SELECT *
            FROM [Order] O
                JOIN OrderCoupon OC ON O.OrderID = OC.OrderID
                JOIN Coupon C ON OC.CouponID = C.CouponID
            WHERE O.OrderDate > C.ExpiredDate)
    BEGIN
        SET @RET = 1
    END

RETURN @RET
END
GO

ALTER TABLE OrderCoupon WITH NOCHECK
ADD CONSTRAINT CK_NoExpiredCouonOnOrder
CHECK (dbo.NoPassDateCoupon() = 0)
GO

-- Same coupon cannot applied more than one time to the same order
CREATE FUNCTION CouponNoMoreThanOnce()
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0

IF EXISTS(SELECT COUNT(*)
            FROM OrderCoupon
            GROUP BY OrderID, CouponID
            HAVING COUNT(*) > 1)
    BEGIN
        SET @RET = 1
    END

RETURN @RET
END
GO

ALTER TABLE OrderCoupon WITH NOCHECK
ADD CONSTRAINT CK_CouponNoMoreThanOnce
CHECK (dbo.CouponNoMoreThanOnce() = 0)
GO




-- Business Rule: Email Must Contain @
CREATE FUNCTION EmailContainsAtSign()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
IF EXISTS (
        SELECT *
        FROM [User]
        WHERE Email NOT LIKE '%@%')
    BEGIN
        SET @RET = 1
    END
RETURN @RET
END
GO

ALTER TABLE [USER] with nocheck
ADD CONSTRAINT CK_Check_@_sign
CHECK(dbo.EmailContainsAtSign() = 0)

GO

-- Business Rule: No Negative Price
CREATE FUNCTION NoNegativePrice()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
IF EXISTS (
        SELECT *
        FROM Product
        WHERE ProdPrice < 0)
    BEGIN
        SET @RET = 1
    END
RETURN @RET
END
GO

ALTER TABLE Product with nocheck
ADD CONSTRAINT CK_Check_Neg_Price
CHECK(dbo.NoNegativePrice() = 0)
GO


CREATE FUNCTION dbo.fn_CheckTotal()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
IF EXISTS (SELECT * FROM [Order] O
                join OrderCoupon OC on O.orderID = OC.orderID
                Join Coupon C on OC.CouponID = C.CouponID
                Join CouponCondition CC on C.CouponID = CC.CouponID
                join Condition Con on CC.ConditionID = Con.ConditionID
                where O.originalOrderTotal * Con.ConditionValue < 0)
            BEGIN
                SET @RET = 1
            END
RETURN @RET
END
GO

ALTER TABLE OrderCoupon with nocheck
ADD CONSTRAINT CK_Check_Order
CHECK(dbo.fn_CheckTotal() = 0)

GO

CREATE FUNCTION dbo.fn_stop_unreg()
RETURNS INTEGER
AS
BEGIN
DECLARE @RET INTEGER = 0
IF EXISTS (SELECT * FROM UserType UT    
                join [user] U on UT.usertypeID = U.UsertypeID
                join[order] O on U.userID = O.userID
                join website W on O.WebsiteID = W.WebsiteID
            WHERE UT.UserTypeName = 'Unregistered'
            AND W.WebsiteName = 'Dior')
            BEGIN
                SET @RET = 1
            END
RETURN @RET
END
GO

ALTER TABLE [Order] with nocheck
ADD CONSTRAINT CK_unreg
CHECK(dbo.fn_stop_unreg() = 0)

GO


--  users how have blank user first or last names cannot place an order
CREATE FUNCTION fn_no_Blank()
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0
IF EXISTS(SELECT * FROM [USER] U
WHERE U.UserFname = ''
AND U.UserLname = '')
BEGIN
SET @RET = 1
END
RETURN @RET
END
GO

ALTER TABLE [Order] WITH NOCHECK
ADD CONSTRAINT no_Blank
CHECK(dbo.fn_no_Blank() = 0)
GO
-- The expiration date of the newly inserted coupons must not be earlier than today
CREATE FUNCTION fn_check_date()
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0
IF EXISTS(SELECT * FROM Coupon C
WHERE C.ExpiredDate < GETDATE())
BEGIN
SET @RET = 1
END
RETURN @RET
END
GO

ALTER TABLE Coupon WITH NOCHECK
ADD CONSTRAINT check_date
CHECK(dbo.fn_check_date() = 0)
GO
