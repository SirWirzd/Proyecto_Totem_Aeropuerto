-- Proyecto TOTEM AEROPUERTO
-- Topic Avanzados de Base de datos

-- Integrante: 
-- Gianfranco Astorga
-- Ernesto Starck
-- Sebastián Bustamante
-- David Ñanculeo

-- Creación del usuario en Oracle

CREATE USER admin IDENTIFIED BY admin;
GRANT ALL PRIVILEGES TO admin;

-- Creación de la tabla de usuarios

CREATE TABLE usuarios(
    id_usuario NUMBER PRIMARY KEY,
    nombre VARCHAR2(50),
    apellido VARCHAR2(50),
    email VARCHAR2(50),
    telefono VARCHAR2(50),
    direccion VARCHAR2(50),
    fecha_nacimiento DATE,
    fecha_registro DATE
);

