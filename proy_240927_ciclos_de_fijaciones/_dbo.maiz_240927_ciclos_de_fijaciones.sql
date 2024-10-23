-- ********************************************************************************************************************************************
-- TRATAMIENTO DE LA TABLA
-- ********************************************************************************************************************************************

-- 1. Visualizamos la tabla original v0 con la totalidad de los datos.
SELECT *
FROM [dbo].[240926_liquid_v0];

-- 2. Obtenemos las características de las columnas para igualarlas.
EXEC sp_help 'dbo.240926_liquid_v0';

-- 3. Eliminamos la tabla v1 si ya existe, para reiniciar el proceso.
DROP TABLE IF EXISTS [dbo].[240926_liquid_v1];

-- 4. Creamos la tabla versión 1 (v1) con las columnas necesarias para manipularla.
CREATE TABLE [dbo].[240926_liquid_v1] (
    fecha VARCHAR(50) NULL,
    kgs_netos VARCHAR(50) NULL,
    estado VARCHAR(50) NULL
);

-- 5. Insertamos los datos seleccionados de la tabla v0 a la tabla v1.
INSERT INTO [dbo].[240926_liquid_v1] (fecha, kgs_netos, estado)
SELECT Fecha_Origen, Kgs_Netos, Estado
FROM [dbo].[240926_liquid_v0];

-- 6. Realizamos un análisis breve de los registros según su Estado.
SELECT estado, COUNT(estado) AS cantidad
FROM [dbo].[240926_liquid_v1]
GROUP BY estado;

-- 7. Visualizamos los registros anulados.
SELECT *
FROM [dbo].[240926_liquid_v1] 
WHERE estado = 'Anulada';

-- 8. Eliminamos los registros anulados de la tabla v1.
DELETE FROM [dbo].[240926_liquid_v1] 
WHERE estado = 'Anulada';

-- 9. Revisamos cómo quedaron los registros según estados.
SELECT estado, COUNT(estado) AS cantidad
FROM [dbo].[240926_liquid_v1]
GROUP BY estado;

-- 10. Verificamos el estado actual de la tabla v1.
SELECT *
FROM [dbo].[240926_liquid_v1];

-- ********************************************************************************************************************************************
-- TRATAMIENTO DE LOS DATOS
-- ********************************************************************************************************************************************

-- 11. Revisamos la columna fecha y la convertimos de tipo VARCHAR a DATE.
SELECT fecha
FROM [dbo].[240926_liquid_v1];

SELECT fecha,
       CONVERT(VARCHAR(10), TRY_CONVERT(DATETIME, fecha, 103), 120) AS FechaConvertida
FROM [dbo].[240926_liquid_v1];

UPDATE [dbo].[240926_liquid_v1]
SET fecha = CONVERT(VARCHAR(10), TRY_CONVERT(DATETIME, fecha, 103), 120);

-- 12. Verificamos los resultados de la conversión de la columna fecha.
SELECT *
FROM [dbo].[240926_liquid_v1];

-- 13. Revisamos la columna kgs_netos y la convertimos de tipo VARCHAR a INT.
SELECT kgs_netos
FROM [dbo].[240926_liquid_v1];

SELECT kgs_netos,
       CAST(REPLACE(TRIM(kgs_netos), '.', '') AS INT) AS ValorEntero
FROM [dbo].[240926_liquid_v1];

UPDATE [dbo].[240926_liquid_v1]
SET kgs_netos = CAST(REPLACE(TRIM(kgs_netos), '.', '') AS INT);

-- 14. Verificamos los resultados de la conversión de la columna kgs_netos.
SELECT *
FROM [dbo].[240926_liquid_v1];

-- 15. Eliminamos la columna Estado ya que no es necesaria.
ALTER TABLE [dbo].[240926_liquid_v1]
DROP COLUMN estado;

-- 16. Visualizamos el estado final de la tabla v1.
SELECT *
FROM [dbo].[240926_liquid_v1];

-- ********************************************************************************************************************************************
-- FIN DEL PROCESO
-- ********************************************************************************************************************************************


/*
Notas para la presentación:
    Estructura clara: Se ha separado cada paso con comentarios numerados para facilitar la comprensión del flujo del trabajo.
    Nombres descriptivos: Se ha mantenido un uso consistente de nombres en las consultas y se han añadido alias cuando es útil para clarificar el propósito de cada consulta.
    Eliminación condicional: Se utiliza DROP TABLE IF EXISTS para evitar errores si la tabla no existe.
    Verificación de resultados: Se incluyen consultas de verificación después de cada transformación de datos para mostrar la evolución de la tabla.
*/