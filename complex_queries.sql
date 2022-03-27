-- Use case statement to categorize the user original total expenses  
-- in most recent 10 year and find the number of user in each category
SELECT (CASE
        WHEN A.OriginalTotal > 1000
        THEN 'Gold'
        WHEN A.OriginalTotal BETWEEN 500 AND 1000
        THEN 'Sliver'
        WHEN A.OriginalTotal BETWEEN 100 AND 499
        THEN 'Bronze'
        ELSE 'Unknow'
        END) AS 'Class', COUNT(*)
FROM (SELECT U.UserID, SUM(O.OriginalOrderTotal) AS 'OriginalTotal'
        FROM [USER] U
            JOIN [Order] O ON U.UserID = O.UserID
        WHERE O.OrderDate >= DATEADD(YEAR, -10, GETDATE())
        GROUP BY U.UserID) A
GROUP BY (CASE
        WHEN A.OriginalTotal > 1000
        THEN 'Gold'
        WHEN A.OriginalTotal BETWEEN 500 AND 1000
        THEN 'Sliver'
        WHEN A.OriginalTotal BETWEEN 100 AND 499
        THEN 'Bronze'
        ELSE 'Unknow'
        END)
GO

-- Find the 8th highest sale product during most recent 10 years
WITH CTE_TOPsaleProduct(ProductID, ProductName, SaleRank)
AS(
SELECT P.ProductID, P.ProductName,
    DENSE_RANK() OVER (ORDER BY SUM(OP.Quantity)) AS 'SaleRank'
FROM [Order] O
    JOIN OrderProduct OP ON O.OrderID = OP.OrderID
    JOIN Product P ON OP.ProductID = P.ProductID
WHERE O.OrderDate >= DATEADD(YEAR, -10, GETDATE())
GROUP BY P.ProductID, P.ProductName
)

SELECT ProductName
FROM CTE_TOPsaleProduct P 
WHERE SaleRank = 8


GO

-- Who are the top 5 users spending the most since 2018 on amazon.com with total numbers of orders to be more than 7? (Suzy)
SELECT TOP 3
    W.WebsiteID, W.WebsiteName, COUNT(*) AS TotalOrder
FROM Website W
    JOIN [Order] O ON O.WebsiteID = W.WebsiteID
    JOIN (SELECT W.WebsiteID, W.WebsiteName, AVG(P.ProdPrice) AS AvgPrice
    FROM [Order] O
        JOIN OrderProduct OP ON O.OrderID = OP.OrderID
        JOIN Product P ON P.ProductID = OP.ProductID
        JOIN Website W ON W.WebsiteID = O.WebsiteID
    GROUP BY W.WebsiteID, W.WebsiteName
    HAVING AVG(P.ProdPrice)> 20) AS subq1 ON subq1.WebsiteID = W.WebsiteID
GROUP BY W.WebsiteID, W.WebsiteName
ORDER BY TotalOrder DESC

-- What are the top three websites that receive the most orders and have an average product price bigger than 20 dollars? (Suzy)
SELECT TOP 5 U.UserFname, U.UserLname, SUM(O.OriginalOrderTotal) AS OrderTotal
FROM [User] U
    JOIN [Order] O ON O.UserID = U.UserID
    JOIN Website W ON W.WebsiteID = O.WebsiteID
    JOIN (SELECT O.OrderID, COUNT(*) AS NumOrder
    FROM OrderProduct OP
        JOIN [Order] O ON O.OrderID = OP.OrderID
    GROUP BY O.OrderID
    HAVING COUNT(*)  > 7) As subq1 ON subq1.OrderID = O.OrderID
WHERE WebsiteName = 'Amazon'
AND YEAR(O.OrderDate) > 2018
GROUP BY U.UserFname, U.UserLname
ORDER BY OrderTotal DESC
GO



-- get the most recent used coupon for Nike for the first order that is greater than $1000
select CouponName from Coupon C
    join OrderCoupon OC on C.CouponID = OC.CouponID
    where OC.OrderID = 
    (select top 1 O.orderID from [Order] O
        join website W on O.WebsiteID = W.WebsiteID
        join OrderCoupon OC on O.OrderID = OC.OrderID
        join Coupon C on OC.CouponID = C.CouponID
        where O.OriginalOrderTotal > 1000
        AND W.WebsiteName = 'Nike')
GO

-- Lee: Complex Query
select C.CouponName
from website W
    join [Order] O on W.WebsiteID = O.WebsiteID
    join OrderCoupon OC on O.OrderID = OC.OrderID
    join Coupon C on OC.CouponID = C.CouponID
    join CouponCondition CC on C.CouponID = CC.CouponID
    join Condition Con on CC.ConditionID = Con.ConditionID
where W.WebsiteName = 'Amazon'
    and Con.ConditionValue < 0.81
GO

-- The 3 most popular product types that users who are registered 
-- purchase the most often and who also placed order in 2021

SELECT TOP 3
    PT.ProductTypeName, COUNT(*) AS Freq
FROM ProductType PT
    JOIN Product P ON P.ProductTypeID = PT.ProductTypeID
    JOIN OrderProduct OP ON OP.OrderProductID = P.ProductID
    JOIN [Order] O ON O.OrderID = OP.OrderID
    JOIN [User] U ON U.UserID = O.UserID
    JOIN UserType UT ON UT.UserTypeID = U.UserTypeID
    JOIN (SELECT U.UserID
    FROM [User] U
        JOIN [Order] O ON O.UserID = U.UserID
    WHERE YEAR(O.OrderDate) = 2021) AS subq1 ON subq1.UserID = U.UserID
WHERE UT.UserTypeName = 'Registered'
GROUP BY PT.ProductTypeName
ORDER BY Freq DESC
GO

-- Which users placed orders on product type sneakers in 2020 
-- and who also placed orders on product type boots in 2021

SELECT U.UserID, U.UserFname, U.UserLname
FROM [User] U
    JOIN [Order] O ON O.OrderID = U.UserID
    JOIN OrderProduct OP ON OP.OrderID = O.OrderID
    JOIN Product P ON P.ProductID = OP.ProductID
    JOIN ProductType PT ON PT.ProductTypeID = P.ProductTypeID
    JOIN (SELECT U.UserID, U.UserFname, U.UserLname
    FROM [User] U
        JOIN [Order] O ON O.OrderID = U.UserID
        JOIN OrderProduct OP ON OP.OrderID = O.OrderID
        JOIN Product P ON P.ProductID = OP.ProductID
        JOIN ProductType PT ON PT.ProductTypeID = P.ProductTypeID
    WHERE PT.ProductTypeName = 'sneakers'
        AND YEAR(O.OrderDate) = 2020) AS subq1 ON subq1.UserID = U.UserID
WHERE PT.ProductTypeName = 'boots'
    AND YEAR(O.OrderDate) = 2021
GO
