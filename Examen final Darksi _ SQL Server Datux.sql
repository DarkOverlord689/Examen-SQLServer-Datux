-- SOLUCION EXAMEN FINAL: GABRIEL 
USE TSQL
/*
1. Yo necesito crear un proceso automático que haga las siguientes tareas:
Obtener la Cantidad de Ordenes y la suma Total del monto de todas sus Ordenes
    por cliente y por año, todo debe ser leído por el parametro @CodigoCliente.
Tablas: Sales.Orders y Sales.OrderDetails
***Pasos:***
1° Voy a crear una tabla con la siguiente estructura:
    CustID, Año, Conteo_Ord, Suma_VentaTotal
2° Insertar los registros a esa tabla cada vez que ejecuto mi procedimiento.
*/

CREATE PROCEDURE ObtenerVentasPorClienteYAno
    @CodigoCliente INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Crear tabla temporal para almacenar los resultados
    CREATE TABLE #VentasPorClienteYAno (
        CustID INT,
        Ano INT,
        Conteo_Ord INT,
        Suma_VentaTotal MONEY
    );

    -- Insertar los registros de ventas por cliente y año en la tabla temporal
    INSERT INTO #VentasPorClienteYAno (CustID, Ano, Conteo_Ord, Suma_VentaTotal)
    SELECT
        o.custid,
        YEAR(o.OrderDate),
        COUNT(DISTINCT o.OrderID),
        SUM(od.UnitPrice * od.qty)
    FROM
        Sales.Orders o
        JOIN Sales.OrderDetails od ON o.OrderID = od.OrderID
    WHERE
        o.custid = @CodigoCliente
    GROUP BY
        o.custid,
        YEAR(o.OrderDate);

    -- Seleccionar los registros de la tabla temporal
    SELECT * FROM #VentasPorClienteYAno;

    -- Eliminar la tabla temporal
    DROP TABLE #VentasPorClienteYAno;
END

EXEC ObtenerVentasPorClienteYAno @CodigoCliente = 34;
/*
2. Convierte la siguiente consulta (tablas derivadas) a una consulta con CTEs (USE TSQL):
SELECT año_orden, COUNT(DISTINCT Cod_Cliente) AS cant_clientes
FROM (SELECT YEAR(orderdate) AS año_orden ,custid AS Cod_Cliente
FROM Sales.Orders) AS tablita
GROUP BY año_orden
HAVING COUNT(DISTINCT Cod_Cliente) > 70;
*/


with CTE_convierte AS
(
SELECT YEAR(orderdate) AS año_orden ,custid AS Cod_Cliente
FROM Sales.Orders
)
SELECT año_orden, COUNT(DISTINCT Cod_Cliente) AS cant_clientes
FROM CTE_convierte
GROUP BY año_orden;


/*
3. El área de programación necesita una query para consultar las ventas a través del
parámetro: nombre del país, crea un procedimiento almacenado que ayude a este
requerimiento. (usar tabla de Orders y Customers en TSQL)
*/

CREATE PROCEDURE GetVentas
    @country NVARCHAR(50) 
AS 
BEGIN 
    SELECT 
        o.orderid, o.orderdate, c.custid, c.contactname
    FROM 
        Sales.Orders o 
        INNER JOIN Sales.Customers c ON o.custid = c.custid
    WHERE 
        c.country = @country
END 

EXEC GetVentas @country = 'Brazil'


/*
4. -Caso: Obtener la cantidad de productos que hay por categoryid y obtener las categorías
que tengan más de 12 productos. (USE TSQL; [Production].[Products])
*/

SELECT 
    c.CategoryName, 
    COUNT(*) AS ProductCount 
FROM 
    Production.Products p 
    INNER JOIN Production.Categories c ON p.CategoryID = c.CategoryID 
GROUP BY 
    c.CategoryName 
HAVING 
    COUNT(*) > 12

