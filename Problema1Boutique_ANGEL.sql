-- Crear o reemplazar una función llamada registrar_venta
CREATE OR REPLACE FUNCTION registrar_venta(
    _id_cliente INT,        -- ID del cliente que realiza la compra
    _monto_total NUMERIC,   -- Monto total de la venta
    _anticipo NUMERIC,      -- Cantidad adelantada como anticipo
    _dia INT,               -- Día de la compra
    _mes INT,               -- Mes de la compra
    _ano INT,               -- Año de la compra
    _metodo_pago VARCHAR,   -- Método de pago utilizado (por ejemplo: Tarjeta, Efectivo)
    _tipo_venta VARCHAR,    -- Tipo de venta (por ejemplo: En línea, Físico)
    _id_prenda INT          -- ID de la prenda que se está comprando
)
RETURNS INT AS $$ -- La función devuelve el ID de la venta registrada
DECLARE
    _id_venta INT;          -- Variable para almacenar el ID de la venta generada
    _prenda_disponible BOOLEAN; -- Variable para verificar si la prenda está disponible
BEGIN
    -- Verificar si el cliente existe en la tabla clientes
    IF EXISTS (SELECT 1 FROM clientes WHERE id_cliente = _id_cliente) THEN
        -- Verificar si la prenda existe y está disponible en inventario
        SELECT COUNT(*) > 0 INTO _prenda_disponible 
        FROM prendas 
        WHERE id_prenda = _id_prenda;

        -- Si la prenda no está disponible, lanzar un error
        IF NOT _prenda_disponible THEN
            RAISE EXCEPTION 'La prenda con ID % no está disponible.', _id_prenda;
        END IF;

        -- Generar un nuevo ID para la venta (incrementando el máximo ID actual)
        SELECT COALESCE(MAX(id_venta), 0) + 1 INTO _id_venta FROM ventas;

        -- Insertar los datos de la venta en la tabla ventas
        INSERT INTO ventas (
            id_venta, id_cliente, monto_total, anticipo, dia_compra, mes_compra, 
            ano_compra, metodo_pago, tipo_venta, id_prenda
        )
        VALUES (
            _id_venta, _id_cliente, _monto_total, _anticipo, _dia, _mes, _ano, 
            _metodo_pago, _tipo_venta, _id_prenda
        );

        -- Retornar el ID de la venta registrada
        RETURN _id_venta;
    ELSE
        -- Si el cliente no existe, mostrar un mensaje y retornar -1 como indicador de error
        RAISE NOTICE 'El cliente con ID % no existe.', _id_cliente;
        RETURN -1;
    END IF;
END;
$$ LANGUAGE plpgsql; -- Especificar que la función utiliza PL/pgSQL

-----pruebas

-- Llamada de ejemplo 1: Registrar una venta con anticipo de $300
SELECT registrar_venta(
    1,          -- ID del cliente
    1000,       -- Monto total de la venta
    300,        -- Anticipo
    10,         -- Día de la compra
    12,         -- Mes de la compra
    2024,       -- Año de la compra
    'Tarjeta',  -- Método de pago
    'En línea', -- Tipo de venta
    1           -- ID de la prenda
);

-- Llamada de ejemplo 2: Registrar una venta sin anticipo
SELECT registrar_venta(
    1,                  -- ID del cliente
    550.00,             -- Monto total de la venta
    0.00,               -- Anticipo
    10,                 -- Día de la compra
    12,                 -- Mes de la compra
    2024,               -- Año de la compra
    'Tarjeta de Crédito', -- Método de pago
    'En línea',         -- Tipo de venta
    2                   -- ID de la prenda
);

--Verificamos loque se inserto en el registro 
select * from ventas 
where id_venta = 12;