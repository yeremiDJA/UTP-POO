create database Asistencia
use Asistencia
CREATE TABLE Departamento(
    idDepartamento VARCHAR(10) PRIMARY KEY,
    Nombre_Departamento VARCHAR(12),
    Descripcion VARCHAR(20)
);

INSERT INTO Departamento(idDepartamento, Nombre_Departamento, Descripcion)
VALUES
('D1', 'RRHH', 'Recursos Humanos'),
('D2', 'Marketing', 'Área de ventas'),
('D3', 'Finanzas', 'Área contable');

CREATE TABLE Turno(
    idTurno VARCHAR(10) PRIMARY KEY,
    Nombre_Turno VARCHAR(10),
    hora_entrada TIME,
    hora_salida TIME
);

INSERT INTO Turno(idTurno, Nombre_Turno, hora_entrada, hora_salida)
VALUES 
('T1', 'Mañana', '08:00:00', '16:00:00'),
('T2', 'Tarde', '16:00:00', '00:00:00'),
('T3', 'Noche', '00:00:00', '08:00:00');

CREATE TABLE Empleado(
    idEmpleado VARCHAR(10) PRIMARY KEY,
    Nombre VARCHAR(15),
    Apellido VARCHAR(10),
    Dni VARCHAR(8),
    Direccion VARCHAR(15),
    idDepartamento VARCHAR(10),
    idTurno VARCHAR(10),
    FOREIGN KEY (idDepartamento) REFERENCES Departamento(idDepartamento),
    FOREIGN KEY (idTurno) REFERENCES Turno(idTurno)
);

CREATE TABLE Usuario(
	idUsuario VARCHAR(10) PRIMARY KEY,
	Nombre_Usuario VARCHAR(15),
	contraseña VARCHAR(20),
    idEmpleado VARCHAR(10),
	FOREIGN KEY (idEmpleado) REFERENCES Empleado(idEmpleado)
);

CREATE TABLE Asistencia(
    idAsistencia INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
    hora_entrada_real TIME,
    hora_entrada_final TIME,
    idTurno VARCHAR(10),
    idEmpleado VARCHAR(10),
    FOREIGN KEY (idTurno) REFERENCES Turno(idTurno),
    FOREIGN KEY (idEmpleado) REFERENCES Empleado(idEmpleado)
);

CREATE TABLE Permiso(
    idPermiso VARCHAR(20) PRIMARY KEY,
    tipo_permiso VARCHAR(20),
    fecha_inicio DATE,
    fecha_final DATE,
    motivo VARCHAR(100),
    idEmpleado VARCHAR(20),
    FOREIGN KEY (idEmpleado) REFERENCES Empleado(idEmpleado)
);

--Registrar Departamento
DELIMITER $
CREATE PROCEDURE sp_insertar_departamento(
    IN p_idDepartamento VARCHAR(10),
    IN p_nombre VARCHAR(12),
    IN p_descripcion VARCHAR(20)
)
BEGIN
    INSERT INTO Departamento(idDepartamento, Nombre_Departamento, Descripcion)
    VALUES (p_idDepartamento, p_nombre, p_descripcion);
END $

--Actualizar Departamento
DELIMITER $
CREATE PROCEDURE sp_actualizar_departamento(
    IN p_idDepartamento VARCHAR(10),
    IN p_nombre VARCHAR(12),
    IN p_descripcion VARCHAR(20)
)
BEGIN
    UPDATE Departamento
    SET Nombre_Departamento = p_nombre,
        Descripcion = p_descripcion
    WHERE idDepartamento = p_idDepartamento;
END $

--Listar Departamento
DELIMITER $
CREATE PROCEDURE sp_listar_departamentos()
BEGIN
    SELECT * FROM Departamento;
END $

--Registrar turno
DELIMITER $
CREATE PROCEDURE sp_insertar_turno(
    IN p_idTurno VARCHAR(10),
    IN p_nombre VARCHAR(10),
    IN p_horaEntrada TIME,
    IN p_horaSalida TIME
)
BEGIN
    INSERT INTO Turno(idTurno, Nombre_Turno, hora_entrada, hora_salida)
    VALUES (p_idTurno, p_nombre, p_horaEntrada, p_horaSalida);
END $

--Listar turnos
DELIMITER $
CREATE PROCEDURE sp_listar_turnos()
BEGIN
    SELECT * FROM Turno;
END $

--Registrar empleado
DELIMITER $
CREATE PROCEDURE sp_insertar_empleado(
    IN p_idEmpleado VARCHAR(10),
    IN p_nombre VARCHAR(15),
    IN p_apellido VARCHAR(10),
    IN p_dni VARCHAR(8),
    IN p_direccion VARCHAR(15),
    IN p_idDepartamento VARCHAR(10),
    IN p_idTurno VARCHAR(10)
)
BEGIN
    INSERT INTO Empleado(idEmpleado, Nombre, Apellido, Dni, Direccion, idDepartamento, idTurno)
    VALUES (p_idEmpleado, p_nombre, p_apellido, p_dni, p_direccion, p_idDepartamento, p_idTurno);
END $

--Actualizar empleado
DELIMITER $
CREATE PROCEDURE sp_actualizar_empleado(
    IN p_idEmpleado VARCHAR(10),
    IN p_nombre VARCHAR(15),
    IN p_apellido VARCHAR(10),
    IN p_dni VARCHAR(8),
    IN p_direccion VARCHAR(15),
    IN p_idDepartamento VARCHAR(10),
    IN p_idTurno VARCHAR(10)
)
BEGIN
    UPDATE Empleado
    SET Nombre = p_nombre,
        Apellido = p_apellido,
        Dni = p_dni,
        Direccion = p_direccion,
        idDepartamento = p_idDepartamento,
        idTurno = p_idTurno
    WHERE idEmpleado = p_idEmpleado;
END $
--Eliminar Empleado
DELIMITER $$

CREATE PROCEDURE sp_eliminar_empleado(
    IN p_idEmpleado VARCHAR(10)
)
BEGIN
    DELETE FROM Empleado
    WHERE idEmpleado = p_idEmpleado;
END $$

DELIMITER ;

--Listar empleados
DELIMITER $$

CREATE PROCEDURE sp_listar_empleados()
BEGIN
    SELECT e.idEmpleado, e.Nombre, e.Apellido, e.Dni, e.Direccion,
           d.Nombre_Departamento, 
           t.Nombre_Turno
    FROM Empleado e
    INNER JOIN Departamento d ON e.idDepartamento = d.idDepartamento
    INNER JOIN Turno t ON e.idTurno = t.idTurno;
END $$

DELIMITER ;

--Registrar usuario
DELIMITER $
CREATE PROCEDURE sp_insertar_usuario(
    IN p_nombreUsuario VARCHAR(15),
    IN p_contraseña VARCHAR(20),
    IN p_idEmpleado VARCHAR(10)
)
BEGIN
    INSERT INTO Usuario(Nombre_Usuario, contraseña, idEmpleado)
    VALUES (p_nombreUsuario, p_contraseña, p_idEmpleado);
END $
DROP PROCEDURE IF EXISTS sp_insertar_usuario;
--Validar login
DELIMITER $$
CREATE PROCEDURE sp_login(
    IN p_usuario VARCHAR(15),
    IN p_contaseña VARCHAR(20)
)
BEGIN
    SELECT * FROM Usuario
    WHERE Nombre_Usuario = p_usuario
      AND contraseña = p_contraseña;
END $$

--Registrar entrada de un empleado
DELIMITER $$

CREATE PROCEDURE sp_registrar_entrada(
    IN p_idEmpleado VARCHAR(10)
)
BEGIN
    DECLARE turno_emp VARCHAR(10);

    -- Obtener turno del empleado
    SELECT idTurno INTO turno_emp
    FROM Empleado
    WHERE idEmpleado = p_idEmpleado;

    -- Insertar entrada
    INSERT INTO Asistencia(fecha, horaEntrada, horaSalida, idTurno, idEmpleado)
    VALUES (CURDATE(), CURTIME(), NULL, turno_emp, p_idEmpleado);
END $$

DELIMITER ;


--Registrar salida de un empleado
DELIMITER $$

CREATE PROCEDURE sp_registrar_salida(
    IN p_idEmpleado VARCHAR(10)
)
BEGIN
    UPDATE Asistencia
    SET horaSalida = CURTIME()
    WHERE idEmpleado = p_idEmpleado
      AND fecha = CURDATE()
      AND horaSalida IS NULL;
END $$

DELIMITER ;

--listar asistencia
DELIMITER $$
CREATE PROCEDURE sp_listar_asistencia()
BEGIN
    SELECT a.idAsistencia, a.fecha, a.hora_entrada_real, a.hora_entrada_final,
           e.idEmpleado, e.Nombre, e.Apellido,
           t.Nombre_Turno
    FROM Asistencia a
    INNER JOIN Empleado e ON a.idEmpleado = e.idEmpleado
    INNER JOIN Turno t ON a.idTurno = t.idTurno
    ORDER BY a.fecha DESC;
END $$
DELIMITER ;

--eliminar asistencia
DELIMITER $$
CREATE PROCEDURE sp_eliminar_asistencia(
    IN p_idAsistencia INT
)
BEGIN
    DELETE FROM tb_asistencia
    WHERE idAsistencia = p_idAsistencia;
END $$
DELIMITER ;

--Registrar permiso
DELIMITER $$
CREATE PROCEDURE sp_insertar_permiso(
    IN p_idPermiso VARCHAR(20),
    IN p_tipoPermiso VARCHAR(20),
    IN p_fechaInicio DATE,
    IN p_fechaFinal DATE,
    IN p_motivo VARCHAR(15),
    IN p_idAsistencia INT
)
BEGIN
    INSERT INTO Permiso(idPermiso, tipo_permiso, Fecha_inicio, fecha_final, Motivo, idAsistencia)
    VALUES (p_idPermiso, p_tipoPermiso, p_fechaInicio, p_fechaFinal, p_motivo, p_idAsistencia);
END $$
DELIMITER ;

--Listar permisos
DELIMITER $
CREATE PROCEDURE sp_listar_permisos()
BEGIN
    SELECT p.idPermiso, p.tipo_permiso, p.Fecha_inicio, p.fecha_final, 
           p.Motivo, e.Nombre, e.Apellido
    FROM Permiso p
    INNER JOIN Asistencia a ON p.idAsistencia = a.idAsistencia
    INNER JOIN Empleado e ON a.idEmpleado = e.idEmpleado;
END $


ALTER TABLE Usuario
    DROP FOREIGN KEY Usuario_ibfk_1,
    ADD CONSTRAINT fk_usuario_empleado
    FOREIGN KEY (idEmpleado)
    REFERENCES Empleado(idEmpleado)
    ON DELETE CASCADE;

ALTER TABLE Asistencia
    DROP FOREIGN KEY Asistencia_ibfk_2,
    ADD CONSTRAINT fk_asistencia_empleado
    FOREIGN KEY (idEmpleado)
    REFERENCES Empleado(idEmpleado)
    ON DELETE CASCADE;
SHOW CREATE TABLE Permiso;
ALTER TABLE Permiso DROP FOREIGN KEY permiso_ibfk_1;

ALTER TABLE Permiso DROP COLUMN idAsistencia;

ALTER TABLE Permiso 
ADD COLUMN idEmpleado VARCHAR(10) NOT NULL;

ALTER TABLE Permiso
ADD CONSTRAINT fk_permiso_empleado
FOREIGN KEY (idEmpleado) REFERENCES Empleado(idEmpleado)
ON DELETE CASCADE;
ALTER TABLE Usuario
DROP PRIMARY KEY;
ALTER TABLE Usuario
MODIFY COLUMN idUsuario INT;
ALTER TABLE Usuario
MODIFY COLUMN idUsuario INT AUTO_INCREMENT PRIMARY KEY;

DELIMITER $$
CREATE PROCEDURE sp_actualizar_entrada_asistencia(
    IN p_idAsistencia INT,
    IN p_horaEntrada TIME 
)
BEGIN
    UPDATE Asistencia
    SET hora_entrada_real = p_horaEntrada
    WHERE idAsistencia = p_idAsistencia;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_actualizar_salida_asistencia(
    IN p_idAsistencia INT,
    IN p_horaSalida TIME 
)
BEGIN
    UPDATE Asistencia
    SET hora_entrada_final = p_horaSalida
    WHERE idAsistencia = p_idAsistencia;
END $$
DELIMITER ;
select * from empleado