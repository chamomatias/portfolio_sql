SELECT *
FROM [cleaning_data].[dbo].[_240930_NH_v0]


-- ====================================================================================================================
-- CREACIÓN DE UNA NUEVA TABLA v1 PARA LA LIMPIEZA MANTENIENDO LA ORIGINAL v0
-- ====================================================================================================================

-- creo y copio la tabla
SELECT *
INTO _240930_NH_v1
FROM _240930_NH_v0
WHERE 1 = 1

-- reviso
SELECT TOP 20 *
FROM [cleaning_data].[dbo].[_240930_NH_v1];

-- ejecuto procedimiento almacenado para ver la composicion de las columnas y para copiarlas y pegarlas en el proximo paso
EXEC sp_help '_240930_NH_v1';


-- ***************************************************************************************
-- Añadiendo número de fila a la nueva tabla para eliminar los duplicados
-- ***************************************************************************************

SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY 
           -- UniqueID, 
           ParcelID, 
           LandUse,
           PropertyAddress,
           SaleDate,
           SalePrice,
           LegalReference,
           SoldAsVacant,
           OwnerName,
           OwnerAddress,
           Acreage,
           TaxDistrict,
           LandValue,
           BuildingValue,
           TotalValue,
           YearBuilt,
           Bedrooms,
           FullBath,
           HalfBath
           ORDER BY UniqueID
       ) AS num_row
FROM _240930_NH_v1;



-- ***************************************************************************************
-- Uso de CTE para filtrar duplicados
-- ***************************************************************************************

WITH Cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY 
               -- UniqueID, 
               ParcelID, 
               LandUse,
               PropertyAddress,
               SaleDate,
               SalePrice,
               LegalReference,
               SoldAsVacant,
               OwnerName,
               OwnerAddress,
               Acreage,
               TaxDistrict,
               LandValue,
               BuildingValue,
               TotalValue,
               YearBuilt,
               Bedrooms,
               FullBath,
               HalfBath
               ORDER BY UniqueID
           ) AS num_row
    FROM _240930_NH_v1
)
SELECT *
FROM Cte
WHERE num_row > 1;



-- ***************************************************************************************
-- Creación de la v3 donde se volcarán ademas los num_row > 1 que luego se elimininarán
-- ***************************************************************************************

-- creo la v3
CREATE TABLE _240930_NH_v2(
	[UniqueID ] [float] NULL,
	[ParcelID] [nvarchar](255) NULL,
	[LandUse] [nvarchar](255) NULL,
	[PropertyAddress] [nvarchar](255) NULL,
	[SaleDate] [datetime] NULL,
	[SalePrice] [float] NULL,
	[LegalReference] [nvarchar](255) NULL,
	[SoldAsVacant] [nvarchar](255) NULL,
	[OwnerName] [nvarchar](255) NULL,
	[OwnerAddress] [nvarchar](255) NULL,
	[Acreage] [float] NULL,
	[TaxDistrict] [nvarchar](255) NULL,
	[LandValue] [float] NULL,
	[BuildingValue] [float] NULL,
	[TotalValue] [float] NULL,
	[YearBuilt] [float] NULL,
	[Bedrooms] [float] NULL,
	[FullBath] [float] NULL,
	[HalfBath] [float] NULL,
	row_num INT
) ON [PRIMARY]
GO

-- le traslado los datos
INSERT INTO _240930_NH_v2
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY
    -- UniqueID, 
    ParcelID, 
    LandUse,
    PropertyAddress,
    SaleDate,
    SalePrice,
    LegalReference,
    SoldAsVacant,
    OwnerName,
    OwnerAddress,
    Acreage,
    TaxDistrict,
    LandValue,
    BuildingValue,
    TotalValue,
    YearBuilt,
    Bedrooms,
    FullBath,
    HalfBath
    ORDER BY UniqueID
) AS num_row
FROM _240930_NH_v1;



-- chequeo
SELECT *
FROM _240930_NH_v2


-- chequeo los registros duplicados
SELECT *
FROM _240930_NH_v2
WHERE row_num > 1
ORDER BY UniqueID


-- Elimino los registros duplicados
DELETE
FROM _240930_NH_v2
WHERE row_num > 1



-- ***************************************************************************************
-- TRATAREMOS LOS VALORES DATEs
-- ***************************************************************************************

-- reviso la tabla para ver las columnas tipo date
SELECT TOP 5*
FROM _240930_NH_v2;

-- veo como quedaría la conversión
SELECT TOP 5 SaleDate, CONVERT(date,SaleDate )
FROM _240930_NH_v2;

-- actualizo (convierto) los datos
UPDATE _240930_NH_v2
SET SaleDate = CONVERT(DATE, SaleDate);

-- reviso
SELECT TOP 5 *
FROM _240930_NH_v2;

EXEC sp_help '_240930_NH_v2';

-- No me funcionó. Crearé una nueva columna tipo de datos Date. Luego eliminaré la columna duplicada
ALTER TABLE _240930_NH_v2
ADD SaleDate2 DATE

UPDATE _240930_NH_v2
SET SaleDate2 = CONVERT(DATE, SaleDate);

ALTER TABLE _240930_NH_v2
DROP COLUMN SaleDate

EXEC sp_rename '_240930_NH_v2.SaleDate2', 'SaleDate', 'COLUMN';

SELECT *--TOP 50 *
FROM _240930_NH_v2;

-- ***************************************************************************************
-- TRATAREMOS LOS VALORES STRINGs
-- ***************************************************************************************

-- Chequeo
SELECT *--ParcelID,PropertyAddress, OwnerAddress
FROM _240930_NH_v2
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.UniqueID, b.UniqueID,a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM _240930_NH_v2 a
JOIN _240930_NH_v2 b
on a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

 UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM _240930_NH_v2 a
JOIN _240930_NH_v2 b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


SELECT TOP 100 PropertyAddress
FROM _240930_NH_v2

