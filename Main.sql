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

-- ELiminación de tablas si existen previamente
DROP TABLE PAISE CASCADE CONSTRAINTS;
DROP TABLE CIUDADE CASCADE CONSTRAINTS;
DROP TABLE AEROPUERTO CASCADE CONSTRAINTS;
DROP TABLE VUELO CASCADE CONSTRAINTS;
DROP TABLE PASAJERO CASCADE CONSTRAINTS;
DROP TABLE COMPRA CASCADE CONSTRAINTS;
DROP TABLE RESERVA CASCADE CONSTRAINTS;
DROP TABLE EQUIPAJE CASCADE CONSTRAINTS;    
DROP TABLE AEROLINEA CASCADE CONSTRAINTS;
DROP TABLE SERVICIO CASCADE CONSTRAINTS;
DROP TABLE ASISTENCIA CASCADE CONSTRAINTS;

CREATE TABLE PAIS(
    id_pais NUMBER NOT NULL,
    nombre VARCHAR2(99) NOT NULL,
    CONSTRAINT PK_PAIS PRIMARY KEY (id_pais)
);

CREATE TABLE CIUDAD(
    id_ciudad NUMBER NOT NULL,
    nombre VARCHAR2(99) NOT NULL,
    id_pais NUMBER NOT NULL,
    CONSTRAINT PK_CIUDAD PRIMARY KEY (id_ciudad) ON DELETE CASCADE,
    CONSTRAINT FK_CIUDAD_PAIS FOREIGN KEY (id_pais) REFERENCES PAIS(id_pais) ON DELETE CASCADE
);

CREATE TABLE AEROPUERTO(
    id_aeropuerto NUMBER NOT NULL,
    nombre VARCHAR2(99) NOT NULL,
    id_ciudad NUMBER NOT NULL,
    id_pais NUMBER NOT NULL,
    CONSTRAINT PK_AEROPUERTO PRIMARY KEY (id_aeropuerto),
    CONSTRAINT FK_AEROPUERTO_CIUDAD FOREIGN KEY (id_ciudad) REFERENCES CIUDAD(id_ciudad) ON DELETE CASCADE,
    CONSTRAINT FK_AEROPUERTO_PAIS FOREIGN KEY (id_pais) REFERENCES PAIS(id_pais) ON DELETE CASCADE
);

CREATE TABLE AEROLINEA(
    id_aerolinea NUMBER NOT NULL,
    nombre_aerolinea VARCHAR2(99) NOT NULL,
    CONSTRAINT PK_AEROLINEA PRIMARY KEY (id_aerolinea)
);

CREATE TABLE VUELO(
    id_vuelo VARCHAR2(99) NOT NULL,
    id_aerolinea_vuel NUMBER NOT NULL,
    id_aeropuerto_origen NUMBER NOT NULL,
    id_aeropuerto_destino NUMBER NOT NULL,
    fecha_salida DATE NOT NULL,
    fecha_llegada DATE NOT NULL,
    estado VARCHAR2(20) CHECK (estado IN ('Programado', 'En vuelo', 'Aterrizado', 'Cancelado')),
    CONSTRAINT PK_VUELO PRIMARY KEY (id_vuelo),
    CONSTRAINT FK_VUELO_AEROLINEA FOREIGN KEY (id_aerolinea_vuel) REFERENCES AEROLINEA(id_aerolinea) ON DELETE CASCADE,
    CONSTRAINT FK_VUELO_AEROPUERTO_ORIGEN FOREIGN KEY (id_aeropuerto_origen) REFERENCES AEROPUERTO(id_aeropuerto) ON DELETE CASCADE,
    CONSTRAINT FK_VUELO_AEROPUERTO_DESTINO FOREIGN KEY (id_aeropuerto_destino) REFERENCES AEROPUERTO(id_aeropuerto) ON DELETE CASCADE 
);

CREATE TABLE PASAJERO(
    documento_identidad VARCHAR(99) NOT NULL,
    nombre VARCHAR2(99) NOT NULL,
    apellido VARCHAR2(99) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    edad NUMBER NOT NULL,
    CONSTRAINT PK_PASAJERO PRIMARY KEY (documento_identidad)
);

CREATE TABLE COMPRA(
    id_compra NUMBER NOT NULL,
    id_pasajero_comp NUMBER NOT NULL,
    id_vuelo_comp VARCHAR2(99) NOT NULL,
    fecha_compra DATE NOT NULL,
    monto_total_compra NUMBER NOT NULL,
    motivo_viaje VARCHAR2(99) NOT NULL,
    CONSTRAINT PK_COMPRA PRIMARY KEY (id_compra),
    CONSTRAINT FK_COMPRA_PASAJERO FOREIGN KEY (id_pasajero_comp) REFERENCES PASAJERO(documento_identidad) ON DELETE CASCADE,
    CONSTRAINT FK_COMPRA_VUELO FOREIGN KEY (id_vuelo_comp) REFERENCES VUELO(id_vuelo) ON DELETE CASCADE
);

CREATE TABLE RESERVA(
    id_reserva NUMBER NOT NULL,
    id_pasajero_res NUMBER NOT NULL,
    id_vuelo_res VARCHAR2(99) NOT NULL,
    fecha_reserva DATE NOT NULL,
    CONSTRAINT PK_RESERVA PRIMARY KEY (id_reserva),
    CONSTRAINT FK_RESERVA_PASAJERO FOREIGN KEY (id_pasajero_res) REFERENCES PASAJERO(documento_identidad) ON DELETE CASCADE,
    CONSTRAINT FK_RESERVA_VUELO FOREIGN KEY (id_vuelo_res) REFERENCES VUELO(id_vuelo) ON DELETE CASCADE
);

CREATE TABLE EQUIPAJE(
    id_equipaje NUMBER NOT NULL,
    id_pasajero_eq NUMBER NOT NULL,
    id_vuelo_eq VARCHAR2(99) NOT NULL,
    peso NUMBER NOT NULL,
    descripcion VARCHAR2(99) NOT NULL,
    CONSTRAINT PK_EQUIPAJE PRIMARY KEY (id_equipaje),
    CONSTRAINT FK_EQUIPAJE_PASAJERO FOREIGN KEY (id_pasajero_eq) REFERENCES PASAJERO(documento_identidad) ON DELETE CASCADE,
    CONSTRAINT FK_EQUIPAJE_VUELO FOREIGN KEY (id_vuelo_eq) REFERENCES VUELO(id_vuelo) ON DELETE CASCADE
);

CREATE TABLE SERVICIO(
    id_servicio NUMBER NOT NULL,
    id_pasajero_ser NUMBER NOT NULL,
    nombre_servicio VARCHAR2(99) NOT NULL,
    precio_servicio NUMBER NOT NULL,
    CONSTRAINT PK_SERVICIOS PRIMARY KEY (id_servicio),
    CONSTRAINT FK_SERVICIOS_PASAJERO FOREIGN KEY (id_pasajero_ser) REFERENCES PASAJERO(documento_identidad) ON DELETE CASCADE
);

CREATE TABLE ASISTENCIA(
    id_asistencia NUMBER NOT NULL,
    id_pasajero_asi NUMBER NOT NULL,
    tipo_asistencia VARCHAR2(99) NOT NULL,
    CONSTRAINT PK_ASISTENCIA PRIMARY KEY (id_asistencia),
    CONSTRAINT FK_ASISTENCIA_PASAJERO FOREIGN KEY (id_pasajero_asi) REFERENCES PASAJERO(documento_identidad) ON DELETE CASCADE,
    CONSTRAINT chck_tipo_asistencia CHECK(tipo_asistencia IN ('Discapacidad', 'Embarazo', 'Tercera Edad', 'Niños')) ON DELETE CASCADE
);

-- Secuencias para generar los IDs automáticos

CREATE SEQUENCE seq_compra START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_reserva START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_servicios_pasajeros START WITH 1 INCREMENT BY 1;

-- Trigger para validad si un asiento está disponible

CREATE OR REPLACE TRIGGER TRG_VALIDA_ASIENTO_DISPONIBLE
BEFORE INSERT ON RESERVA
FOR EACH ROW
DECLARE
    v_asiento_ocupado NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_asiento_ocupado
    FROM RESERVA
    WHERE id_vuelo = :NEW.id_vuelo 
    AND id_asiento = :NEW.id_asiento
    AND estado = "Confirmado";

    IF v_asiento_ocupado > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Asiento ya está ocupado');
    END IF;
END;

-- Trigger para actualizar el estado de vuelo

CREATE OR REPLACE TRIGGER ACTUALIZAR_ESTADO_VUELO
AFTER INSERT OR UPDATE ON VUELO
FOR EACH ROW
BEGIN
    IF (:NEW.fecha_salida < SYSDATE) THEN
        UPDATE VUELO
        SET estado = 'En vuelo' 
        WHERE id_vuelo = :NEW.id_vuelo;
    END IF;
END;

-- Procedimiento para confirmar una compra y generar el ticket

CREATE OR REPLACE PROCEDURE confirmar_compra (
    p_id_pasajero   NUMBER,       
    p_id_vuelo      VARCHAR2,     
    p_asiento       VARCHAR2,     
    p_maletas       NUMBER,       
    p_servicios     VARCHAR2,     
    p_total_pago    NUMBER        
) AS
    v_asiento_disponible NUMBER;  
BEGIN
    -- Verificar si el vuelo existe
    IF NOT EXISTS (SELECT 1 FROM VUELO WHERE id_vuelo = p_id_vuelo) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Vuelo no encontrado.');
    END IF;

    -- Verificar disponibilidad del asiento
    SELECT COUNT(*)
    INTO v_asiento_disponible
    FROM RESERVA
    WHERE id_vuelo = p_id_vuelo AND asiento = p_asiento AND estado = 'Reservado';

    IF v_asiento_disponible > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Asiento ya reservado.');
    END IF;

    -- Registrar la compra en la tabla COMPRA

    INSERT INTO COMPRA (id_compra, id_pasajero, id_vuelo, fecha_compra, total_pago)
    VALUES (seq_compra.NEXTVAL, p_id_pasajero, p_id_vuelo, SYSDATE, p_total_pago);

    -- Registrar la reserva del asiento

    INSERT INTO RESERVA (id_reserva, id_vuelo, id_pasajero, asiento, estado)
    VALUES (seq_reserva.NEXTVAL, p_id_vuelo, p_id_pasajero, p_asiento, 'Reservado');

    -- Registrar servicios adicionales si existen
    
    IF p_servicios IS NOT NULL THEN
        INSERT INTO SERVICIOS_PASAJERO (id_servicio_pasajero, id_pasajero, descripcion, maletas)
        VALUES (seq_servicios_pasajero.NEXTVAL, p_id_pasajero, p_servicios, p_maletas);
    END IF;

    -- Actualizar estado del asiento a 'Reservado'
    UPDATE ASIENTO
    SET estado = 'Reservado'
    WHERE numero_asiento = p_asiento AND id_vuelo = p_id_vuelo;


    -- Mensaje de confirmación
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Compra confirmada para el pasajero ' || p_id_pasajero_comp || ' en el vuelo ' || p_id_vuelo_comp || ' con el asiento ' || p_asiento);
    DBMS_OUTPUT.PUT_LINE('Compra confirmada para el vuelo ' || p_id_vuelo || '. Asiento ' || p_asiento || ' reservado.');
    DBMS_OUTPUT.PUT_LINE('Total pagado: ' || p_total_pago || ' CLP.');
END;
/