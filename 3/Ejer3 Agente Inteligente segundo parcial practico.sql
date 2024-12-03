DECLARE
    @nombre_cliente VARCHAR(100),  -- El nombre del cliente que buscamos
    @id_cliente INT,               -- El ID del cliente que se usar� para comparar
    @longitud INT,                 -- Longitud del nombre
    @contador INT,                 -- Contador para iterar sobre los caracteres del nombre
    @caracter VARCHAR(2),         -- Para almacenar cada caracter del nombre
    @sql NVARCHAR(4000),           -- Consulta din�mica
    @columna VARCHAR(50),          -- Columna para comparar
    @valor INT,                    -- Valor comparativo
    @ParmDefinition NVARCHAR(50)   -- Par�metros de la consulta
BEGIN
    -- Asignar el nombre del cliente a buscar
    SET @nombre_cliente = 'Juan Ricardo';  -- Se asigna el nombre que se busca
    SET @id_cliente = 1;  -- Asumimos que buscamos el cliente con ID = 1

    -- Calcular la longitud del nombre
    SELECT @longitud = LEN(@nombre_cliente);
    SET @contador = 1;
    SET @sql = '';

    -- Crear una tabla temporal para almacenar las comparaciones
    CREATE TABLE #comparaciones (
        id_cliente INT,
        nombre_cliente VARCHAR(100),
        similitud INT
    );

    -- B�squeda comparativa por nombre (compara con cada nombre de la base de datos)
    WHILE @contador <= @longitud
    BEGIN
        -- Extraer el primer car�cter del nombre y quitarlo de la variable @nombre_cliente
        SELECT @caracter = LEFT(@nombre_cliente, 1);
        SET @nombre_cliente = RIGHT(@nombre_cliente, LEN(@nombre_cliente) - 1);
        
        -- Comparar el car�cter extra�do con la columna 'nombre' de la tabla 'clientes'
        -- Usaremos la funci�n LIKE para ver qu� registros contienen ese car�cter
        INSERT INTO #comparaciones (id_cliente, nombre_cliente, similitud)
        SELECT id_cliente, nombre, 
               CASE 
                   WHEN nombre LIKE '%' + @caracter + '%' THEN 1 
                   ELSE 0 
               END
        FROM clientes;
        
        SET @contador = @contador + 1;
    END;

    -- Buscar los registros m�s similares al cliente con el ID = @id_cliente
    -- Vamos a comparar los resultados en funci�n de la similitud total
    SELECT TOP 5 id_cliente, nombre_cliente, SUM(similitud) AS similitud_total
    FROM #comparaciones
    WHERE id_cliente != @id_cliente  -- Excluir el cliente que estamos buscando
    GROUP BY id_cliente, nombre_cliente
    ORDER BY similitud_total DESC;  -- Ordenamos por la similitud total

    -- Limpiar la tabla temporal
    DROP TABLE IF EXISTS #comparaciones;
END;