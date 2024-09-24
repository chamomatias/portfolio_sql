-- ====================================================================================================================
-- USO DE LA BASE DE DATOS
-- ====================================================================================================================
USE limpiezas;

-- ====================================================================================================================
-- CREACIÓN DE UNA NUEVA TABLA PARA LA LIMPIEZA MANTENIENDO LA ORIGINAL
-- ====================================================================================================================
CREATE TABLE _240921_limpieza_v1 LIKE _240921_limpieza_v0;

-- ====================================================================================================================
-- INSERCIÓN DE DATOS DE LA TABLA ORIGINAL A LA NUEVA TABLA
-- ====================================================================================================================
INSERT INTO _240921_limpieza_v1
SELECT *
FROM _240921_limpieza_v0;

-- ====================================================================================================================
-- ELIMINACIÓN DE DUPLICADOS
-- ====================================================================================================================
-- 1. Numeramos las filas y detectamos registros duplicados
WITH _240921_limpieza_v2 AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY `ï»¿Id?empleado`, `Name`, Last_Name, birth_date, Gender, Area, Salary, Start_Date, Finish_Date, Promotion_Date, Type
        ) AS row_num
    FROM _240921_limpieza_v1
)

-- 2. Creamos una nueva tabla para almacenar los datos únicos
CREATE TABLE _240921_limpieza_v3 (
    Id VARCHAR(50),
    Name VARCHAR(15),
    Last_Name VARCHAR(25),
    Birth_Date TEXT,
    Gender VARCHAR(1),
    Area VARCHAR(25),
    Salary DECIMAL(12,2),
    Start_Date DATE,
    Finish_Date DATETIME,
    Promotion_Date DATE,
    Type VARCHAR(10),
    Row_Num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Insertamos solo los registros únicos
INSERT INTO _240921_limpieza_v3
SELECT Id, Name, Last_Name, Birth_Date, Gender, Area, Salary, Start_Date, Finish_Date, Promotion_Date, Type, row_num
FROM _240921_limpieza_v2
WHERE row_num = 1;

-- 4. Eliminamos la columna Row_Num de la tabla final
ALTER TABLE _240921_limpieza_v3 DROP COLUMN Row_Num;

-- ====================================================================================================================
-- TRATAMIENTO DE COLUMNAS CATEGÓRICAS
-- ====================================================================================================================
-- 1. Para la columna Id, eliminamos espacios en blanco
UPDATE _240921_limpieza_v3
SET Id = TRIM(REPLACE(REPLACE(Id, '$', ''), ',', ''));

-- 2. Para la columna Name
UPDATE _240921_limpieza_v3
SET Name = TRIM(REPLACE(REPLACE(Name, '$', ''), ',', ''));

-- 3. Para la columna Last_Name
UPDATE _240921_limpieza_v3
SET Last_Name = TRIM(REPLACE(REPLACE(Last_Name, '$', ''), ',', ''));

-- 4. Para la columna Area
UPDATE _240921_limpieza_v3
SET Area = TRIM(REPLACE(REPLACE(Area, '$', ''), ',', ''));

-- 5. Para la columna Gender, estandarizamos valores
UPDATE _240921_limpieza_v3
SET Gender = CASE
    WHEN Gender = 'hombre' THEN 'M'
    WHEN Gender = 'mujer' THEN 'F'
    ELSE 'O'
END;

-- 6. Para la columna Type, estandarizamos valores
UPDATE _240921_limpieza_v3
SET Type = CASE
    WHEN Type = 0 THEN 'Remote'
    WHEN Type = 1 THEN 'Hybrid'
    ELSE 'Other'
END;

-- ====================================================================================================================
-- TRATAMIENTO DE COLUMNAS NUMÉRICAS
-- ====================================================================================================================
-- Convertimos la columna Salary a decimal, eliminando caracteres no deseados
UPDATE _240921_limpieza_v3
SET Salary = CAST(TRIM(REPLACE(REPLACE(Salary, '$', ''), ',', '')) AS DECIMAL(12,2));

-- ====================================================================================================================
-- TRATAMIENTO DE COLUMNAS DE TIPO FECHA
-- ====================================================================================================================
-- 1. Para la columna Birth_Date
UPDATE _240921_limpieza_v3
SET Birth_Date = CASE 
    WHEN Birth_Date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(Birth_Date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN Birth_Date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(Birth_Date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL 
END;

-- 2. Para la columna Start_Date
UPDATE _240921_limpieza_v3
SET Start_Date = CASE 
    WHEN Start_Date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(Start_Date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN Start_Date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(Start_Date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL 
END;

-- 3. Para la columna Finish_Date
UPDATE _240921_limpieza_v3
SET Finish_Date = CASE 
    WHEN Finish_Date IS NOT NULL AND Finish_Date != '' THEN STR_TO_DATE(REPLACE(Finish_Date, ' UTC', ''), '%Y-%m-%d %H:%i:%s') 
    ELSE NULL 
END;

-- 4. Para la columna Promotion_Date
UPDATE _240921_limpieza_v3
SET Promotion_Date = CASE 
    WHEN Promotion_Date IS NOT NULL AND Promotion_Date != '' THEN DATE_FORMAT(STR_TO_DATE(Promotion_Date, '%M %d, %Y'), '%Y-%m-%d') 
    ELSE NULL 
END;

-- ====================================================================================================================
-- CREACIÓN DE LA TABLA LIMPIA FINAL
-- ====================================================================================================================
CREATE TABLE _240921_limpieza_vclean LIKE _240921_limpieza_v3;

-- INSERTAMOS LOS DATOS LIMPIOS EN LA NUEVA TABLA
INSERT INTO _240921_limpieza_vclean 
SELECT * 
FROM _240921_limpieza_v3;

-- ====================================================================================================================
-- SELECCIONAMOS LOS DATOS LIMPIOS PARA VERIFICAR
-- ====================================================================================================================
SELECT * FROM _240921_limpieza_vclean;
