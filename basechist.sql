CREATE DATABASE chauferia;
USE chauferia;

CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    rol ENUM('ADMIN','VENDEDOR') DEFAULT 'VENDEDOR',
    intentos INT DEFAULT 0,
    bloqueado_hasta DATETIME NULL
);

INSERT INTO usuarios (username, password, rol)
VALUES
('admin', 'admin123', 'ADMIN'),
('vendedor', 'venta123', 'VENDEDOR');

CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    dni VARCHAR(15),
    telefono VARCHAR(20),
    direccion VARCHAR(150)
);

CREATE TABLE proveedores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    ruc VARCHAR(15),
    telefono VARCHAR(20),
    direccion VARCHAR(150)
);

CREATE TABLE productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(150),
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    proveedor_id INT,
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
);

CREATE TABLE ventas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    fecha DATETIME DEFAULT NOW(),
    total DECIMAL(10,2),
    tipo_comprobante ENUM('BOLETA', 'FACTURA') DEFAULT 'BOLETA',
    usuario_id INT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE detalle_venta (
    id INT PRIMARY KEY AUTO_INCREMENT,
    venta_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (venta_id) REFERENCES ventas(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

DELIMITER $$
CREATE TRIGGER tr_restar_stock
AFTER INSERT ON detalle_venta
FOR EACH ROW
BEGIN
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE id = NEW.producto_id;
END $$
DELIMITER ;

CREATE VIEW vw_producto_mas_vendido AS
SELECT p.nombre, SUM(d.cantidad) AS total_vendido, DATE(v.fecha) AS fecha
FROM detalle_venta d
JOIN ventas v ON d.venta_id = v.id
JOIN productos p ON d.producto_id = p.id
GROUP BY p.nombre, DATE(v.fecha)
ORDER BY total_vendido DESC;

CREATE VIEW vw_stock_productos AS
SELECT id, nombre, stock, precio
FROM productos;

CREATE VIEW vw_reporte_ventas AS
SELECT v.id, c.nombre AS cliente, v.fecha, v.total, v.tipo_comprobante
FROM ventas v
LEFT JOIN clientes c ON v.cliente_id = c.id;