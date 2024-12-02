-- Proyecto TOTEM AEROPUERTO
-- Topic Avanzados de Base de datos

-- Integrante: 
-- Gianfranco Astorga
-- Ernesto Starck
-- David Ñanculeo

-- Creación del usuario en Oracle

CREATE USER admin IDENTIFIED BY admin;
GRANT ALL PRIVILEGES TO admin;

-- Eliminación de tablas si existen previamente

DROP TABLE CHECK_IN CASCADE CONSTRAINTS;
DROP TABLE ASISTENCIA CASCADE CONSTRAINTS;
DROP TABLE EQUIPAJE CASCADE CONSTRAINTS;
DROP TABLE SERVICIOS_ADICIONALES CASCADE CONSTRAINTS;
DROP TABLE BOLETO CASCADE CONSTRAINTS;
DROP TABLE VUELO CASCADE CONSTRAINTS;
DROP TABLE PASAJERO CASCADE CONSTRAINTS;
DROP TABLE AVION CASCADE CONSTRAINTS;
DROP TABLE PUERTA CASCADE CONSTRAINTS;
DROP TABLE TERMINAL_PUERTA CASCADE CONSTRAINTS;
DROP TABLE AEROPUERTO CASCADE CONSTRAINTS;
DROP TABLE AEROLINEA CASCADE CONSTRAINTS;
DROP TABLE PAIS CASCADE CONSTRAINTS;
DROP TABLE TIPO_EQUIPAJE CASCADE CONSTRAINTS;
DROP TABLE TIPO_BOLETO CASCADE CONSTRAINTS;
DROP TABLE ESTADO CASCADE CONSTRAINTS;

-- Creación de tablas

-- Tabla Estado de Vuelo

CREATE TABLE ESTADO (
    id_estado NUMBER NOT NULL PRIMARY KEY,
    nombre_estado VARCHAR2(50) UNIQUE NOT NULL
);

-- Tabla Tipo de Boleto

CREATE TABLE TIPO_BOLETO (
    id_tipo_boleto NUMBER NOT NULL PRIMARY KEY,
    nombre_tipo_boleto VARCHAR2(50) UNIQUE NOT NULL
);

-- Tabla Tipo de Equipaje

CREATE TABLE TIPO_EQUIPAJE (
    id_tipo_equipaje NUMBER NOT NULL PRIMARY KEY,
    nombre_tipo_equipaje VARCHAR2(50) UNIQUE NOT NULL
);

-- Tabla Pais

CREATE TABLE PAIS (
    id_pais NUMBER NOT NULL PRIMARY KEY,
    nombre_pais VARCHAR2(50) NOT NULL,
    visa_requerida CHAR(1) CHECK (visa_requerida IN ('S', 'N')),
    pasaporte_requerido CHAR(1) CHECK (pasaporte_requerido IN ('S', 'N'))
);

-- Tabla Aerolinea

CREATE TABLE AEROLINEA (
    id_aerolinea NUMBER NOT NULL PRIMARY KEY,
    nombre_aerolinea VARCHAR2(50) UNIQUE NOT NULL
);

-- Tabla Aeropuerto

CREATE TABLE AEROPUERTO (
    id_aeropuerto NUMBER NOT NULL PRIMARY KEY,
    nombre_aeropuerto VARCHAR2(50) NOT NULL,
    ciudad VARCHAR2(50) NOT NULL,
    latitud NUMBER NOT NULL,
    longitud NUMBER NOT NULL,
    id_pais NUMBER NOT NULL,
    CONSTRAINT fk_pais_aeropuerto FOREIGN KEY (id_pais) REFERENCES PAIS(id_pais) ON DELETE CASCADE,
    CONSTRAINT ck_latitud_aeropuerto CHECK (latitud BETWEEN -90 AND 90),
    CONSTRAINT ck_longitud_aeropuerto CHECK (longitud BETWEEN -180 AND 180)
);

-- Tabla Terminal de Aeropuerto

CREATE TABLE TERMINAL_PUERTA (
    id_terminal NUMBER NOT NULL PRIMARY KEY,
    nombre_terminal VARCHAR2(50) NOT NULL,
    id_aeropuerto NUMBER NOT NULL,
    CONSTRAINT fk_aeropuerto_terminal FOREIGN KEY (id_aeropuerto) REFERENCES AEROPUERTO(id_aeropuerto) ON DELETE CASCADE
);

-- Tabla Puerta de Embarque

CREATE TABLE PUERTA (
    id_puerta NUMBER NOT NULL PRIMARY KEY,
    nombre_puerta VARCHAR2(50) NOT NULL,
    id_terminal NUMBER NOT NULL,
    CONSTRAINT fk_terminal_puerta FOREIGN KEY (id_terminal) REFERENCES TERMINAL_PUERTA(id_terminal) ON DELETE CASCADE
);

-- Tabla Avion de Aerolinea

CREATE TABLE AVION (
    id_avion NUMBER NOT NULL PRIMARY KEY,
    nombre_avion VARCHAR2(50) NOT NULL,
    capacidad NUMBER NOT NULL,
    id_aerolinea NUMBER NOT NULL,
    CONSTRAINT fk_aerolinea_avion FOREIGN KEY (id_aerolinea) REFERENCES AEROLINEA(id_aerolinea) ON DELETE CASCADE
);

-- Tabla Pasajero de Vuelo

CREATE TABLE PASAJERO (
    id_pasajero NUMBER NOT NULL PRIMARY KEY,
    dni_pasajero CHAR(10) UNIQUE NOT NULL,
    nombre_pasajero VARCHAR2(50) NOT NULL,
    apellido_pasajero VARCHAR2(50) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    pasaporte CHAR(10) UNIQUE NOT NULL,
    visa CHAR(10) UNIQUE NOT NULL,
    correo_pasajero VARCHAR2(50) UNIQUE NOT NULL,
    telefono_pasajero CHAR(9) UNIQUE NOT NULL,
    asistencia_especial CHAR(1) CHECK (asistencia_especial IN ('S', 'N')),
    id_pais NUMBER NOT NULL,
    CONSTRAINT fk_pais_pasajero FOREIGN KEY (id_pais) REFERENCES PAIS(id_pais) ON DELETE CASCADE
);

-- Tabla Vuelo

CREATE TABLE VUELO (
    id_vuelo NUMBER NOT NULL PRIMARY KEY,
    id_aerolinea NUMBER NOT NULL,
    fecha_salida TIMESTAMP NOT NULL,
    fecha_llegada TIMESTAMP NOT NULL,
    id_estado NUMBER NOT NULL,
    id_avion NUMBER NOT NULL,
    id_terminal NUMBER NOT NULL,
    id_puerta NUMBER NOT NULL,
    id_aeropuerto_origen NUMBER NOT NULL,
    id_aeropuerto_destino NUMBER NOT NULL,
    duracion GENERATED ALWAYS AS (EXTRACT(HOUR FROM (fecha_llegada - fecha_salida))) VIRTUAL,
    CONSTRAINT fk_aerolinea_vuelo FOREIGN KEY (id_aerolinea) REFERENCES AEROLINEA(id_aerolinea) ON DELETE CASCADE,
    CONSTRAINT fk_estado_vuelo FOREIGN KEY (id_estado) REFERENCES ESTADO(id_estado) ON DELETE CASCADE,
    CONSTRAINT fk_avion_vuelo FOREIGN KEY (id_avion) REFERENCES AVION(id_avion) ON DELETE CASCADE,
    CONSTRAINT fk_terminal_vuelo FOREIGN KEY (id_terminal) REFERENCES TERMINAL_PUERTA(id_terminal) ON DELETE CASCADE,
    CONSTRAINT fk_puerta_vuelo FOREIGN KEY (id_puerta) REFERENCES PUERTA(id_puerta) ON DELETE CASCADE,
    CONSTRAINT fk_aeropuerto_origen_vuelo FOREIGN KEY (id_aeropuerto_origen) REFERENCES AEROPUERTO(id_aeropuerto) ON DELETE CASCADE,
    CONSTRAINT fk_aeropuerto_destino_vuelo FOREIGN KEY (id_aeropuerto_destino) REFERENCES AEROPUERTO(id_aeropuerto) ON DELETE CASCADE
);

-- Tabla Boleto de Vuelo

CREATE TABLE BOLETO (
    id_boleto NUMBER NOT NULL PRIMARY KEY,
    id_pasajero NUMBER NOT NULL,
    id_vuelo NUMBER NOT NULL,
    id_tipo_boleto NUMBER NOT NULL,
    precio NUMBER NOT NULL CHECK (precio > 0),
    CONSTRAINT fk_pasajero_boleto FOREIGN KEY (id_pasajero) REFERENCES PASAJERO(id_pasajero) ON DELETE CASCADE,
    CONSTRAINT fk_vuelo_boleto FOREIGN KEY (id_vuelo) REFERENCES VUELO(id_vuelo) ON DELETE CASCADE,
    CONSTRAINT fk_tipo_boleto_boleto FOREIGN KEY (id_tipo_boleto) REFERENCES TIPO_BOLETO(id_tipo_boleto) ON DELETE CASCADE
);

-- Tabla de Servicios Adicionales

CREATE TABLE SERVICIOS_ADICIONALES (
    id_servicio NUMBER NOT NULL PRIMARY KEY,
    id_boleto NUMBER NOT NULL,
    nombre_servicio VARCHAR2(50) NOT NULL,
    precio NUMBER NOT NULL CHECK (precio > 0),
    CONSTRAINT fk_boleto_servicio FOREIGN KEY (id_boleto) REFERENCES BOLETO(id_boleto) ON DELETE CASCADE
);

-- Tabla Equipaje de Pasajero

CREATE TABLE EQUIPAJE (
    id_equipaje NUMBER NOT NULL PRIMARY KEY,
    id_pasajero NUMBER NOT NULL,
    id_vuelo NUMBER NOT NULL,
    id_tipo_equipaje NUMBER NOT NULL,
    peso NUMBER NOT NULL,
    alto NUMBER NOT NULL,
    ancho NUMBER NOT NULL,
    largo NUMBER NOT NULL,
    precio NUMBER NOT NULL CHECK (precio > 0),
    CONSTRAINT fk_pasajero_equipaje FOREIGN KEY (id_pasajero) REFERENCES PASAJERO(id_pasajero) ON DELETE CASCADE,
    CONSTRAINT fk_vuelo_equipaje FOREIGN KEY (id_vuelo) REFERENCES VUELO(id_vuelo) ON DELETE CASCADE,
    CONSTRAINT fk_tipo_equipaje_equipaje FOREIGN KEY (id_tipo_equipaje) REFERENCES TIPO_EQUIPAJE(id_tipo_equipaje) ON DELETE CASCADE,
    CONSTRAINT ck_dimensiones_equipaje CHECK (peso >0 AND alto > 0 AND ancho > 0 AND largo > 0)
);

-- Tabla Asistencia Especial

CREATE TABLE ASISTENCIA (
    id_asistencia NUMBER NOT NULL PRIMARY KEY,
    id_pasajero NUMBER NOT NULL,
    id_vuelo NUMBER NOT NULL,
    nombre_asistencia VARCHAR2(50) NOT NULL,
    precio NUMBER NOT NULL CHECK (precio > 0),
    CONSTRAINT fk_pasajero_asistencia FOREIGN KEY (id_pasajero) REFERENCES PASAJERO(id_pasajero) ON DELETE CASCADE,
    CONSTRAINT fk_vuelo_asistencia FOREIGN KEY (id_vuelo) REFERENCES VUELO(id_vuelo) ON DELETE CASCADE
);

-- Tabla CHECK-IN

CREATE TABLE CHECK_IN (
    id_checkin NUMBER NOT NULL PRIMARY KEY,
    id_boleto NUMBER NOT NULL,
    id_vuelo NUMBER NOT NULL,
    fecha_checkin TIMESTAMP NOT NULL,
    CONSTRAINT fk_boleto_checkin FOREIGN KEY (id_boleto) REFERENCES BOLETO(id_boleto) ON DELETE CASCADE,
    CONSTRAINT fk_vuelo_checkin FOREIGN KEY (id_vuelo) REFERENCES VUELO(id_vuelo) ON DELETE CASCADE,
    CONSTRAINT uq_pasajero_vuelo_checkin UNIQUE (id_boleto, id_vuelo)
);

