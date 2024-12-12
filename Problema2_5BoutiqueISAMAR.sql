-- Crear o reemplazar el procedimiento para descontar la disponibilidad de una prenda
CREATE OR REPLACE PROCEDURE descontar_disponibilidad_prenda(
    _id_prenda INT,  -- ID de la prenda que se va a actualizar
    _cantidad_comprada INT  -- Cantidad de la prenda que se desea comprar
)
LANGUAGE plpgsql  -- El lenguaje usado es PL/pgSQL, el cual es específico para PostgreSQL
AS $$
DECLARE
    _disponibilidad_actual INT;  -- Variable para almacenar la cantidad actual de la prenda
BEGIN
    -- Verificar si la prenda existe en la tabla 'prendas'
    IF NOT EXISTS (SELECT 1 FROM prendas WHERE id_prenda = _id_prenda) THEN
        -- Si no existe, lanzar una excepción con un mensaje de error
        RAISE EXCEPTION 'La prenda con ID % no existe.', _id_prenda;
    END IF;

    -- Obtener la cantidad disponible de la prenda en el inventario
    SELECT disponibilidad INTO _disponibilidad_actual
    FROM prendas
    WHERE id_prenda = _id_prenda;

    -- Verificar si hay suficiente cantidad de la prenda disponible
    IF _disponibilidad_actual < _cantidad_comprada THEN
        -- Si no hay suficiente cantidad, lanzar una excepción con un mensaje de error
        RAISE EXCEPTION 'No hay suficiente cantidad disponible de la prenda con ID %.', _id_prenda;
    END IF;

    -- Descontar la cantidad comprada de la disponibilidad de la prenda
    UPDATE prendas
    SET disponibilidad = disponibilidad - _cantidad_comprada  -- Restar la cantidad comprada
    WHERE id_prenda = _id_prenda;

    -- Mensaje de éxito que confirma que la disponibilidad ha sido actualizada correctamente
    RAISE NOTICE 'La disponibilidad de la prenda con ID % ha sido actualizada correctamente.', _id_prenda;
END;
$$;

-- Verificar la disponibilidad de la prenda antes de realizar la compra
SELECT disponibilidad FROM prendas WHERE id_prenda = 1;

-- Ejecutar el procedimiento para descontar la disponibilidad de la prenda con ID 1, comprando 3 unidades
CALL descontar_disponibilidad_prenda(1, 3);

-- Verificar la disponibilidad de la prenda después de la compra para ver si ha sido actualizada
SELECT disponibilidad FROM prendas WHERE id_prenda = 1;

-- Intentar realizar una compra que excede la cantidad disponible de la prenda con ID 2 (ejemplo de error)
CALL descontar_disponibilidad_prenda(2, 15);

-- Intentar realizar una compra de una prenda que no existe (ejemplo de error)
CALL descontar_disponibilidad_prenda(19, 1);