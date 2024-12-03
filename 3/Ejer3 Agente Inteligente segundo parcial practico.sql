DECLARE
    @nombre_cliente VARCHAR(100),  -- El nombre del cliente que buscamos
    @id_cliente INT,               -- El ID del cliente que se usará para comparar
    @longitud INT,                 -- Longitud del nombre
    @contador INT,                 -- Contador para iterar sobre los caracteres del nombre
    @caracter VARCHAR(2),         -- Para almacenar cada caracter del nombre
    @sql NVARCHAR(4000),           -- Consulta dinámica
    @columna VARCHAR(50),          -- Columna para comparar
    @valor INT,                    -- Valor comparativo
    @ParmDefinition NVARCHAR(50)   -- Parámetros de la consulta
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

    -- Búsqueda comparativa por nombre (compara con cada nombre de la base de datos)
    WHILE @contador <= @longitud
    BEGIN
        -- Extraer el primer carácter del nombre y quitarlo de la variable @nombre_cliente
        SELECT @caracter = LEFT(@nombre_cliente, 1);
        SET @nombre_cliente = RIGHT(@nombre_cliente, LEN(@nombre_cliente) - 1);
        
        -- Comparar el carácter extraído con la columna 'nombre' de la tabla 'clientes'
        -- Usaremos la función LIKE para ver qué registros contienen ese carácter
        INSERT INTO #comparaciones (id_cliente, nombre_cliente, similitud)
        SELECT id_cliente, nombre, 
               CASE 
                   WHEN nombre LIKE '%' + @caracter + '%' THEN 1 
                   ELSE 0 
               END
        FROM clientes;
        
        SET @contador = @contador + 1;
    END;

    -- Buscar los registros más similares al cliente con el ID = @id_cliente
    -- Vamos a comparar los resultados en función de la similitud total
    SELECT TOP 5 id_cliente, nombre_cliente, SUM(similitud) AS similitud_total
    FROM #comparaciones
    WHERE id_cliente != @id_cliente  -- Excluir el cliente que estamos buscando
    GROUP BY id_cliente, nombre_cliente
    ORDER BY similitud_total DESC;  -- Ordenamos por la similitud total

    -- Limpiar la tabla temporal
    DROP TABLE IF EXISTS #comparaciones;
END;