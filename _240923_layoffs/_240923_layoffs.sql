SELECT * FROM limpiezas._240923_layoffs_v0;

-- ====================================================================================================================
-- CREACIÓN DE UNA NUEVA TABLA PARA LA LIMPIEZA MANTENIENDO LA ORIGINAL
-- ====================================================================================================================
CREATE TABLE _240923_layoffs_v1
LIKE _240923_layoffs_v0;


INSERT INTO _240923_layoffs_v1
SELECT *
FROM _240923_layoffs_v0;

-- ***************************************************************************************
-- Añadiendo número de fila a la nueva tabla
-- ***************************************************************************************
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, country, funds_raised_millions
) AS row_num
FROM _240923_layoffs_v1
;

-- ***************************************************************************************
-- Uso de CTE para filtrar duplicados
-- ***************************************************************************************
WITH _240923_layoffs_v1_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, country, funds_raised_millions
) AS row_num
FROM _240923_layoffs_v1
) 
SELECT *
FROM _240923_layoffs_v1_cte 
-- WHERE company = 'Caspe'
WHERE row_num > 1
;

-- ***************************************************************************************
-- Creación de la segunda versión de la tabla con tipos de datos ajustados
-- ***************************************************************************************
CREATE TABLE `_240923_layoffs_v2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO _240923_layoffs_v2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, country, funds_raised_millions
) AS row_num
FROM _240923_layoffs_v1;

-- Eliminar duplicados
DELETE
FROM _240923_layoffs_v2
WHERE row_num > 1
;

-- Chequeo
SELECT *
FROM _240923_layoffs_v2
;


-- ******************************************************************************************
-- TRATAREMOS LOS DATOS CATEGORICOS
-- ******************************************************************************************

-- 1) Listar distintos
SELECT DISTINCT company
FROM _240923_layoffs_v2
ORDER BY company;

-- 2) Identificar registros con espacios dobles
SELECT *
FROM _240923_layoffs_v2
WHERE LENGTH(company) - LENGTH(REGEXP_REPLACE(company, ' {2,}', ' ')) > 0;

-- 3) Reemplazar espacios dobles por uno solo
UPDATE _240923_layoffs_v2
SET company = REGEXP_REPLACE(company, ' {2,}', ' ');

-- 4) Filtrar/identificar espacios al inicio o al final
SELECT company, TRIM(company)
FROM _240923_layoffs_v2
WHERE LENGTH(company) - LENGTH(TRIM(company)) > 1;

-- 5) Eliminar espacios al inicio y al final
UPDATE _240923_layoffs_v2
SET company = TRIM(company);
-- Esta consulta eliminará los espacios en blanco al inicio y al final de cada valor en la columna 

-- 6) Verificar transformaciones necesarias
SELECT DISTINCT company
FROM _240923_layoffs_v2
ORDER BY company;


-- 7) Esta consulta te mostrará el largo maximo de la columna para, a posterior, convertir la columna.
SELECT MAX(LENGTH(company)) AS max_length
FROM _240923_layoffs_v2;


-- 8) Esta clausula ajustará la columna
ALTER TABLE _240923_layoffs_v2
CHANGE COLUMN `company` `company` VARCHAR(30) NULL DEFAULT NULL ;




-- 1)
SELECT DISTINCT location
FROM _240923_layoffs_v2
ORDER BY location;

-- 2)
SELECT *
FROM _240923_layoffs_v2
WHERE LENGTH(location) - LENGTH(REGEXP_REPLACE(location, ' {2,}', ' ')) > 0;

-- 3)
UPDATE _240923_layoffs_v2
SET location = REGEXP_REPLACE(location, ' {2,}', ' ');

-- 4)
SELECT location, TRIM(location)
FROM _240923_layoffs_v2
WHERE LENGTH(location) - LENGTH(TRIM(location)) > 1;

-- 5)
UPDATE _240923_layoffs_v2
SET location = TRIM(location);

-- 6)
SELECT DISTINCT location
FROM _240923_layoffs_v2
ORDER BY location;

-- 7)
SELECT MAX(LENGTH(location)) AS max_length
FROM _240923_layoffs_v2;

-- 8)
ALTER TABLE _240923_layoffs_v2
CHANGE COLUMN `location` `location` VARCHAR(20) NULL DEFAULT NULL ;


-- 1)
SELECT DISTINCT industry
FROM _240923_layoffs_v2
ORDER BY industry;

-- 2)
SELECT *
FROM _240923_layoffs_v2
WHERE LENGTH(industry) - LENGTH(REGEXP_REPLACE(industry, ' {2,}', ' ')) > 0;

-- 3)
UPDATE _240923_layoffs_v2
SET industry = REGEXP_REPLACE(industry, ' {2,}', ' ');

-- 4)
SELECT industry, TRIM(industry)
FROM _240923_layoffs_v2
WHERE LENGTH(industry) - LENGTH(TRIM(industry)) > 1;

-- 5)
UPDATE _240923_layoffs_v2
SET industry= TRIM(industry);

-- 6)
SELECT DISTINCT industry
FROM _240923_layoffs_v2
ORDER BY industry;

SELECT *, 
    CASE
        WHEN industry LIKE '%CRYPTO%' THEN 'Crypto'
        ELSE industry
    END AS industry_type
FROM _240923_layoffs_v2
WHERE industry LIKE '%CRYPTO%';

UPDATE _240923_layoffs_v2
SET industry = 
    CASE
        WHEN industry LIKE '%CRYPTO%' THEN 'Crypto'
        ELSE industry
    END;

-- 7)
SELECT MAX(LENGTH(industry)) AS max_length
FROM _240923_layoffs_v2;

-- 8)
ALTER TABLE _240923_layoffs_v2
CHANGE COLUMN `industry` `industry` VARCHAR(15) NULL DEFAULT NULL ;


-- 1)
SELECT DISTINCT stage
FROM _240923_layoffs_v2
ORDER BY stage;

-- 2)
SELECT *
FROM _240923_layoffs_v2
WHERE LENGTH(stage) - LENGTH(REGEXP_REPLACE(stage, ' {2,}', ' ')) > 0;

-- 3)
UPDATE _240923_layoffs_v2
SET stage = REGEXP_REPLACE(stage, ' {2,}', ' ');

-- 4)
SELECT stage, TRIM(stage)
FROM _240923_layoffs_v2
WHERE LENGTH(stage) - LENGTH(TRIM(stage)) > 1;

-- 5)
UPDATE _240923_layoffs_v2
SET stage = TRIM(stage);

-- 6)
SELECT DISTINCT stage
FROM _240923_layoffs_v2
ORDER BY stage;

-- 7)
SELECT MAX(LENGTH(stage)) AS max_length
FROM _240923_layoffs_v2;

-- 8)
ALTER TABLE _240923_layoffs_v2
CHANGE COLUMN `stage` `stage` VARCHAR(15) NULL DEFAULT NULL ;


-- 1)
SELECT DISTINCT country
FROM _240923_layoffs_v2
ORDER BY country;

-- 2)
SELECT *
FROM _240923_layoffs_v2
WHERE LENGTH(country) - LENGTH(REGEXP_REPLACE(country, ' {2,}', ' ')) > 0;

-- 3)
UPDATE _240923_layoffs_v2
SET `country` = REGEXP_REPLACE(country, ' {2,}', ' ');

-- 4)
SELECT `country`, TRIM(`country`)
FROM _240923_layoffs_v2
WHERE LENGTH(`country`) - LENGTH(TRIM(`country`)) > 1;

-- 5)
UPDATE _240923_layoffs_v2
SET `country`= TRIM(`country`);

-- 6)
SELECT DISTINCT `country`
FROM _240923_layoffs_v2
ORDER BY `country`;

SELECT *, 
    CASE
        WHEN `country` LIKE '%United Sta%' THEN 'United States'
        ELSE `country`
    END AS industry_type
FROM _240923_layoffs_v2
WHERE country LIKE '%United Sta%';

UPDATE _240923_layoffs_v2
SET country = 
    CASE
        WHEN `country` LIKE '%United Sta%' THEN 'United States'
        ELSE `country`
    END;

-- 7)
SELECT MAX(LENGTH(`country`)) AS max_length
FROM _240923_layoffs_v2;

-- 8)
ALTER TABLE _240923_layoffs_v2
CHANGE COLUMN `country` `country` VARCHAR(20) NULL DEFAULT NULL ;


-- ******************************************************************************************
-- TRATAREMOS LOS DATOS NUMERICOS
-- ******************************************************************************************

-- 1)
SELECT total_laid_off
FROM _240923_layoffs_v2
ORDER BY total_laid_off DESC;

-- 2)
SELECT company,
    total_laid_off,
    CAST(TRIM(REPLACE(REPLACE(total_laid_off, '$', ''), ',', '')) AS DECIMAL(12, 2)) AS total_laid_off_decimal
FROM _240923_layoffs_v2;

-- 3)
UPDATE _240923_layoffs_v2
SET total_laid_off = CAST(TRIM(REPLACE(REPLACE(total_laid_off, '$', ''), ',', '')) AS DECIMAL(12, 2)) 
;

-- 4)
ALTER TABLE _240923_layoffs_v2
CHANGE COLUMN `total_laid_off` `total_laid_off` DECIMAL(10, 2) DEFAULT NULL ;

-- 1)
SELECT percentage_laid_off
FROM _240923_layoffs_v2
ORDER BY percentage_laid_off asc;

-- 2)
SELECT percentage_laid_off,
    CAST(TRIM(REPLACE(REPLACE(percentage_laid_off, '$', ''), ',', '')) AS DECIMAL(5, 2)) AS percentage_laid_off
FROM _240923_layoffs_v2;

-- 3)
UPDATE _240923_layoffs_v2
SET percentage_laid_off = CAST(TRIM(REPLACE(REPLACE(percentage_laid_off, '$', ''), ',', '')) AS DECIMAL(5, 2)) 
;

-- 4)
ALTER TABLE _240923_layoffs_v2
CHANGE COLUMN `percentage_laid_off` `percentage_laid_off` DECIMAL(5, 2) DEFAULT NULL ;


-- 1)
SELECT funds_raised_millions
FROM _240923_layoffs_v2
ORDER BY funds_raised_millions DESC;

-- 2)
SELECT funds_raised_millions,
    funds_raised_millions,
    CAST(TRIM(REPLACE(REPLACE(funds_raised_millions, '$', ''), ',', '')) AS DECIMAL(12, 2)) AS funds_raised_millions
FROM _240923_layoffs_v2;

-- 3)
UPDATE _240923_layoffs_v2
SET funds_raised_millions = CAST(TRIM(REPLACE(REPLACE(funds_raised_millions, '$', ''), ',', '')) AS DECIMAL(12, 2)) 
;

-- 4)
ALTER TABLE _240923_layoffs_v2
CHANGE COLUMN `funds_raised_millions` `funds_raised_millions` DECIMAL(10, 2) DEFAULT NULL ;


-- ******************************************************************************************
-- TRATAREMOS LOS DATOS DATE
-- ******************************************************************************************

SELECT `date`,
CASE 
    WHEN `date` LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(`date`, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN `date` LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(`date`, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL 
END as `date2`
FROM _240923_layoffs_v2;

UPDATE _240923_layoffs_v2
SET `date` =
CASE 
    WHEN `date` LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(`date`, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN `date` LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(`date`, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL 
END;

ALTER TABLE _240923_layoffs_v2
CHANGE COLUMN `date` `date` DATE DEFAULT NULL ;


SELECT *
FROM _240923_layoffs_v2
;

-- Eliminar la columna
ALTER TABLE _240923_layoffs_v2
DROP COLUMN row_num;

-- Cambiar el nombre de la tabla
ALTER TABLE _240923_layoffs_v2
RENAME TO _240923_layoffs_vclean;

SELECT * FROM _240923_layoffs_vclean;
