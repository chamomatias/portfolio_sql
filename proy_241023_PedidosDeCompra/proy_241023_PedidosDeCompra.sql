SELECT TOP (50) 
		[Fecha] AS fecha
      ,[Fecha necesidad] AS fecha_necesidad
      ,[Solicitante] AS solicitante
      ,[N° pc] AS nro_pc
      ,[Estado] AS estado
      ,[Cod# producto] AS cod_prod
      ,[Producto]
      ,[Descripción producto]
      ,[Cantidad pedida] AS cantidad
      ,[Pendiente de compra]
      ,[Pendiente de recepción]
      ,[Link oc]
      ,[Oc nro]
      ,[Ultima novedad]
      ,[Depósito destino]
  FROM [dsr].[compras].[informe_pedidos_de_compra]


-- Hago una copia de la tabla (la version _v0) con las columnas y los encabezados ajustados s/necesidad en la DB [cleaning_data].[dbo].
SELECT 
		[Fecha] AS fecha
      ,[Fecha necesidad] AS fecha_necesidad
      ,[Solicitante] AS solicitante
      ,[N° pc] AS nro_pc
      ,[Estado] AS estado
      ,[Cod# producto] AS cod_prod
      ,[Cantidad pedida] AS cantidad
INTO [cleaning_data].[dbo].[informe_pedidos_de_compra_v0]
FROM [dsr].[compras].[informe_pedidos_de_compra]
WHERE 1 = 1

-- me paso a la BD [cleaning_data] para operar desde ahí
USE cleaning_data

-- controlo
SELECT TOP (20) *
FROM informe_pedidos_de_compra_v0

-- ejecuto procedimiento almacenado para ver la composicion de las columnas y para copiarlas y pegarlas en el proximo paso
EXEC sp_help 'informe_pedidos_de_compra_v0';


-- Añadiendo con ROW_NUMBER() OVER(PARTITION BY) un num_row para poder identificar registros repetidos (num_row > 1)
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY
				fecha,
				fecha_necesidad,
				solicitante,
				nro_pc,
				estado,
				cod_prod,
				cantidad
			 ORDER BY fecha
       ) AS num_row
FROM informe_pedidos_de_compra_v0;


-- Uso de CTE para detectar los registros que se repiten, los num_row > 1
WITH Cte AS (
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY
				fecha,
				fecha_necesidad,
				solicitante,
				nro_pc,
				estado,
				cod_prod,
				cantidad
			 ORDER BY fecha
       ) AS num_row
FROM informe_pedidos_de_compra_v0
)
SELECT *
FROM Cte
WHERE num_row = 1; -- acá probamos; los num_row > 1 son los registros que se repiten

-- Creación de la tabla v1 donde se volcarán ademas los num_row = 1, los registros únicos
CREATE TABLE informe_pedidos_de_compra_v1 (
    fecha DATE NULL,
    fecha_necesidad DATE NULL,
    solicitante VARCHAR(100) NULL,
    nro_pc VARCHAR(100) NULL,
    estado VARCHAR(100) NULL,
    cod_prod VARCHAR(100) NULL,
    cantidad INT,
    num_row INT
) ON [PRIMARY];
GO

-- traslado los datos
INSERT INTO informe_pedidos_de_compra_v1
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY
				fecha,
				fecha_necesidad,
				solicitante,
				nro_pc,
				estado,
				cod_prod,
				cantidad
			 ORDER BY fecha
       ) AS num_row
FROM informe_pedidos_de_compra_v0



-- controlo
SELECT *
FROM informe_pedidos_de_compra_v1

-- controlo
EXEC sp_help 'informe_pedidos_de_compra_v1';

-- controlo
SELECT  *
FROM informe_pedidos_de_compra_v1

--consulto
SELECT COUNT(*) AS estado_, estado
FROM informe_pedidos_de_compra_v1
GROUP BY estado -- opto por mantener todos los estados. Pensaba eliminar los PC rechazados pero opté por medirlos finalmente y plasmarlos en el estudio

-- elimino las columnas irrelevantes
ALTER TABLE informe_pedidos_de_compra_v1
DROP COLUMN num_row;

-- reviso como queda
SELECT  *
FROM informe_pedidos_de_compra_v1


--Traslado de tabla final a la BD [portfolio].[dbo]. para continuar el proyecto con alguna herramienta de visualizacion
SELECT *
INTO [portfolio].[dbo].[proy_241023_PedidosDeCompra]
FROM informe_pedidos_de_compra_v1
WHERE 1 = 1