-- how many users placed order on each website in 2020
CREATE FUNCTION fn_Web_User(@PK INT)
RETURNS INT
AS
BEGIN
DECLARE @RET INT = (SELECT COUNT(U.UserID) FROM [User] U
JOIN [Order] O ON O.UserID = U.UserID
JOIN Website W ON W.WebsiteID = O.WebsiteID
WHERE Year(O.OrderDate) = 2020
AND W.WebsiteID = @PK)
RETURN @RET
END
GO

ALTER TABLE Website
ADD Web_User AS
(dbo.fn_Web_User(WebsiteID))
GO


-- Computed Columns: NumOrder
CREATE FUNCTION NumOrder(@PK INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (SELECT COUNT(*)
                    FROM [User] U
                        JOIN [Order] O ON O.UserID = U.UserID
                    WHERE U.UserID = @PK)
RETURN @RET
END
GO

ALTER TABLE [User]
ADD NumOrder AS (dbo.NumOrder(UserID))
GO

-- Computed Columns: NumCoupon
CREATE FUNCTION NumCoupon(@PK INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (SELECT COUNT(*)
                    FROM [User] U
                        JOIN [Order] O ON O.UserID = U.UserID
                        JOIN [OrderCoupon] OC ON OC.OrderID = O.OrderID
                        JOIN Coupon C ON C.CouponID = OC.CouponID
                    WHERE U.UserID = @PK)
RETURN @RET
END
GO

ALTER TABLE [User]
ADD NumCoupon AS (dbo.NumCoupon(UserID))
GO

-- Subtotal from OrderProduct Table
CREATE FUNCTION AlaiaSubtotal(@OPID INT)
RETURNS NUMERIC(10,2)
AS
BEGIN
DECLARE @RET NUMERIC(10,2) = (SELECT P.ProdPrice * OP.Quantity
                            FROM OrderProduct OP
                            JOIN Product P ON OP.ProductID = P.ProductID
                            WHERE OP.OrderProductID = @OPID)
RETURN @RET
END
GO

ALTER TABLE OrderProduct
ADD Subtotal AS (dbo.AlaiaSubtotal(OrderProductID))
GO


-- OriginalOrderTotal
CREATE FUNCTION OriginalOrderTotal(@OID INT)
RETURNS NUMERIC(10,2)
AS
BEGIN
DECLARE @RET NUMERIC(10,2) = (SELECT SUM(OP.Subtotal)
                            FROM [Order] O
                                JOIN OrderProduct OP ON O.OrderID = OP.OrderID
                            WHERE O.OrderID = @OID)

RETURN @RET
END
GO

ALTER TABLE [Order]
ADD OriginalOrderTotal AS (dbo.OriginalOrderTotal(OrderID))
GO

CREATE FUNCTION fn_get_discounted_order_total (@OoderID INT)
RETURNS numeric(12,2)
AS
BEGIN
DECLARE @DiscountValue numeric(12,2) =
       (SELECT min(C.ConditionValue) FROM CONDITION C
        JOIN CouponCondition CC ON C.ConditionID = CC.ConditionID
        JOIN COUPON COU ON CC.CouponID = COU.CouponID
        JOIN OrderCoupon OC on COU.CouponID = OC.CouponID
        WHERE OC.OrderID = @OoderID)

DECLARE @originalTotal numeric(12,2) =
       (SELECT OriginalOrderTotal from [Order]
        where OrderID = @OoderID)

RETURN @DiscountValue * @originalTotal

END
GO




CREATE FUNCTION fn_get_discounted_value (@OoderID INT)
RETURNS numeric(12,2)
AS
BEGIN
Declare @OOT numeric(12,2)
Declare @TPAD numeric(12,2)

Set @OOT = (select OriginalOrderTotal from [order] where OrderID = @OoderID)
Set @TPAD = (select TotalPriceAfterDiscount from [order] where OrderID = @OoderID)

RETURN @OOT - @TPAD

END
GO

ALTER TABLE [ORDER]
ADD DiscountTotal AS (dbo.fn_get_discounted_value(OrderID))
GO
