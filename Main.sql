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
DROP TABLE PAIS CASCADE CONSTRAINTS;
DROP TABLE CIUDAD CASCADE CONSTRAINTS;
DROP TABLE AEROPUERTO CASCADE CONSTRAINTS;
DROP TABLE VUELO CASCADE CONSTRAINTS;
DROP TABLE PASAJERO CASCADE CONSTRAINTS;
DROP TABLE COMPRA CASCADE CONSTRAINTS;
DROP TABLE RESERVA CASCADE CONSTRAINTS;
DROP TABLE EQUIPAJE CASCADE CONSTRAINTS;    
DROP TABLE AEROLINEA CASCADE CONSTRAINTS;
DROP TABLE SERVICIOS_PASAJERO CASCADE CONSTRAINTS;
DROP TABLE ASISTENCIA CASCADE CONSTRAINTS;

CREATE TABLE PAIS(
    id_pais NUMBER NOT NULL,
    nombre VARCHAR2(100) NOT NULL,
    visa_requerida VARCHAR2(20),
    CONSTRAINT PK_PAIS PRIMARY KEY (id_pais),
    CONSTRAINT chck_visa_pais CHECK (visa_requerida IN ('Sí', 'No'))
);

CREATE TABLE CIUDAD(
    id_ciudad NUMBER NOT NULL,
    nombre VARCHAR2(100) NOT NULL,
    id_pais NUMBER NOT NULL,
    CONSTRAINT PK_CIUDAD PRIMARY KEY (id_ciudad),
    CONSTRAINT FK_CIUDAD_PAIS FOREIGN KEY (id_pais) REFERENCES PAIS(id_pais) ON DELETE CASCADE
);

CREATE TABLE AEROPUERTO(
    id_aeropuerto NUMBER NOT NULL,
    nombre VARCHAR2(100) NOT NULL,
    id_ciudad NUMBER NOT NULL,
    id_pais NUMBER NOT NULL,
    CONSTRAINT PK_AEROPUERTO PRIMARY KEY (id_aeropuerto),
    CONSTRAINT FK_AEROPUERTO_CIUDAD FOREIGN KEY (id_ciudad) REFERENCES CIUDAD(id_ciudad) ON DELETE CASCADE,
    CONSTRAINT FK_AEROPUERTO_PAIS FOREIGN KEY (id_pais) REFERENCES PAIS(id_pais) ON DELETE CASCADE
);

CREATE TABLE AEROLINEA(
    id_aerolinea NUMBER NOT NULL,
    nombre_aerolinea VARCHAR2(100) NOT NULL,
    CONSTRAINT PK_AEROLINEA PRIMARY KEY (id_aerolinea)
);

CREATE TABLE PASAJERO(
    id_pasajero NUMBER NOT NULL,
    nombre VARCHAR2(100) NOT NULL,
    apellido VARCHAR2(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    documento_identidad VARCHAR(20) NOT NULL,
    edad NUMBER,
    CONSTRAINT PK_PASAJERO PRIMARY KEY (id_pasajero),
    CONSTRAINT chck_documento_identidad CHECK (LENGTH(documento_identidad) <= 9)
);

CREATE TABLE VUELO(
    id_vuelo NUMBER NOT NULL,
    id_aerolinea_vuel NUMBER NOT NULL,
    id_aeropuerto_origen NUMBER NOT NULL,
    id_aeropuerto_destino NUMBER NOT NULL,
    fecha_de_vuelo DATE NOT NULL,
    fecha_salida DATE NOT NULL,
    fecha_llegada DATE NOT NULL,
    duracion NUMBER NOT NULL,
    distancia NUMBER NOT NULL,
    estado VARCHAR2(20) CHECK (estado IN ('Programado', 'En vuelo', 'Aterrizado', 'Cancelado')),
    CONSTRAINT PK_VUELO PRIMARY KEY (id_vuelo),
    CONSTRAINT FK_VUELO_AEROLINEA FOREIGN KEY (id_aerolinea_vuel) REFERENCES AEROLINEA(id_aerolinea) ON DELETE CASCADE,
    CONSTRAINT FK_VUELO_AEROPUERTO_ORIGEN FOREIGN KEY (id_aeropuerto_origen) REFERENCES AEROPUERTO(id_aeropuerto) ON DELETE CASCADE,
    CONSTRAINT FK_VUELO_AEROPUERTO_DESTINO FOREIGN KEY (id_aeropuerto_destino) REFERENCES AEROPUERTO(id_aeropuerto) ON DELETE CASCADE 
);

CREATE TABLE ASIENTO(
    id_asiento NUMBER NOT NULL,
    id_vuelo NUMBER NOT NULL,
    numero_asiento VARCHAR2(10) NOT NULL,
    estado VARCHAR2(20) CHECK (estado IN ('Disponible', 'No disponible')),
    CONSTRAINT PK_ASIENTO PRIMARY KEY (id_asiento),
    CONSTRAINT FK_ASIENTO_VUELO FOREIGN KEY (id_vuelo) REFERENCES VUELO(id_vuelo) ON DELETE CASCADE
);

CREATE TABLE COMPRA(
    id_compra NUMBER NOT NULL,
    id_pasajero_comp NUMBER NOT NULL,
    id_vuelo_comp NUMBER NOT NULL,
    fecha_compra DATE NOT NULL,
    monto_total_compra NUMBER NOT NULL,
    motivo_viaje VARCHAR2(100) NOT NULL,
    CONSTRAINT PK_COMPRA PRIMARY KEY (id_compra),
    CONSTRAINT FK_COMPRA_PASAJERO FOREIGN KEY (id_pasajero_comp) REFERENCES PASAJERO(id_pasajero) ON DELETE CASCADE,
    CONSTRAINT FK_COMPRA_VUELO FOREIGN KEY (id_vuelo_comp) REFERENCES VUELO(id_vuelo) ON DELETE CASCADE
);

CREATE TABLE RESERVA(
    id_reserva NUMBER NOT NULL,
    id_pasajero_res NUMBER NOT NULL,
    id_vuelo_res NUMBER NOT NULL,
    id_asiento NUMBER NOT NULL,
    fecha_reserva DATE NOT NULL,
    CONSTRAINT PK_RESERVA PRIMARY KEY (id_reserva),
    CONSTRAINT FK_RESERVA_PASAJERO FOREIGN KEY (id_pasajero_res) REFERENCES PASAJERO(id_pasajero) ON DELETE CASCADE,
    CONSTRAINT FK_RESERVA_VUELO FOREIGN KEY (id_vuelo_res) REFERENCES VUELO(id_vuelo) ON DELETE CASCADE,
    CONSTRAINT FK_RESERVA_ASIENTO FOREIGN KEY (id_asiento) REFERENCES ASIENTO(id_asiento) ON DELETE CASCADE
);

CREATE TABLE EQUIPAJE(
    id_equipaje NUMBER NOT NULL,
    id_pasajero_eq NUMBER NOT NULL,
    id_vuelo_eq NUMBER NOT NULL,
    peso NUMBER NOT NULL,
    descripcion VARCHAR2(100) NOT NULL,
    CONSTRAINT PK_EQUIPAJE PRIMARY KEY (id_equipaje),
    CONSTRAINT FK_EQUIPAJE_PASAJERO FOREIGN KEY (id_pasajero_eq) REFERENCES PASAJERO(documento_identidad) ON DELETE CASCADE,
    CONSTRAINT FK_EQUIPAJE_VUELO FOREIGN KEY (id_vuelo_eq) REFERENCES VUELO(id_vuelo) ON DELETE CASCADE
);

CREATE TABLE SERVICIOS_PASAJERO(
    id_servicio_pasajero NUMBER NOT NULL,
    id_pasajero_ser NUMBER NOT NULL,
    nombre_servicio VARCHAR2(100) NOT NULL,
    precio_servicio NUMBER NOT NULL,
    CONSTRAINT PK_SERVICIOS PRIMARY KEY (id_servicio_pasajero),
    CONSTRAINT FK_SERVICIOS_PASAJERO FOREIGN KEY (id_pasajero_ser) REFERENCES PASAJERO(id_pasajero) ON DELETE CASCADE
);

CREATE TABLE ASISTENCIA(
    id_asistencia NUMBER NOT NULL,
    id_pasajero_asi NUMBER NOT NULL,
    tipo_asistencia VARCHAR2(99) NOT NULL,
    CONSTRAINT PK_ASISTENCIA PRIMARY KEY (id_asistencia),
    CONSTRAINT FK_ASISTENCIA_PASAJERO FOREIGN KEY (id_pasajero_asi) REFERENCES PASAJERO(id_pasajero) ON DELETE CASCADE,
    CONSTRAINT chck_tipo_asistencia CHECK(tipo_asistencia IN ('Discapacidad', 'Embarazo', 'Tercera Edad', 'Niños'))
);

-- Cambiar formato de la fecha

ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY';



-- Procedimiento para validar el documento de identidad
CREATE OR REPLACE PROCEDURE VALIDACION (
    p_documento_identidad IN VARCHAR2
) IS
    documento_identidad_invalido EXCEPTION;
BEGIN
    IF REGEXP_LIKE(p_documento_identidad, '^[0-9]{8}-[0-9Kk]{1}$') THEN
        NULL;
    ELSIF REGEXP_LIKE(p_documento_identidad, '^[0-9]{9}$') AND LENGHT(documento_identidad)<= 9 THEN
        NULL;
    ELSE
        RAISE documento_identidad_invalido;
    END IF;
EXCEPTION
    WHEN documento_identidad_invalido THEN
        RAISE_APPLICATION_ERROR(-20001, 'Documento de identidad inválido.');
END;
/
-- Trigger para validar el documento de identidad
CREATE OR REPLACE TRIGGER TRG_VALIDAR_PASAJERO 
BEFORE INSERT OR UPDATE ON PASAJERO 
FOR EACH ROW 
BEGIN
    -- Verificar que la fecha de nacimiento no sea futura
    IF :NEW.fecha_nacimiento >= SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20001, 'La fecha de nacimiento no puede ser futura.'); 
    END IF; 
    -- Verificar que el documento de identidad no exceda los 9 caracteres 
    IF LENGTH(:NEW.documento_identidad) > 9 THEN 
        RAISE_APPLICATION_ERROR(-20002, 'El documento de identidad no puede exceder los 9 caracteres.'); 
    END IF; 
    -- Verificar que el pasajero sea mayor de edad (18 años o más) 
    IF (SYSDATE - :NEW.fecha_nacimiento) / 365 < 18 THEN
        RAISE_APPLICATION_ERROR(-20003, 'El pasajero debe ser mayor de edad.'); 
    END IF;
END;

-- Trigger para validad si un asiento está disponible

CREATE OR REPLACE TRIGGER TRG_VALIDA_ASIENTO_DISPONIBLE
BEFORE INSERT ON RESERVA
FOR EACH ROW
DECLARE
    v_asiento_disponible VARCHAR2(20);
BEGIN
    SELECT estado
    INTO v_asiento_disponible
    FROM ASIENTO
    WHERE id_asiento = :NEW.id_asiento
    AND id_vuelo = :NEW.id_vuelo;


    IF v_asiento_disponible = 'No disponible' THEN
        RAISE_APPLICATION_ERROR(-20001, 'El asiento ya está ocupado o no disponible.');
    END IF;
END;

-- Trigger para verificar visa
CREATE OR REPLACE TRIGGER TRG_VERIFICAR_VISA
BEFORE INSERT ON PAIS
FOR EACH ROW
BEGIN
    IF :NER.visa_requerida = 'Sí' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Se requiere visa para ingresar a ' || :NEW.nombre);
    END IF;
END;
/

-- Trigger para verificar la duración del vuelo
CREATE OR REPLACE TRIGGER TRG_VERIFICAR_DURACION
BEFORE INSERT OR UPDATE ON VUELO
FOR EACH ROW
BEGIN
    :NEW.duracion := (:NEW.fecha_llegada - :NEW.fecha_salida) * 24*60;
END;
/

-- Trigger para actualizar el estado de vuelo

CREATE OR REPLACE TRIGGER ACTUALIZAR_ESTADO_VUELO
AFTER INSERT OR UPDATE ON VUELO
FOR EACH ROW
BEGIN
    IF (:NEW.fecha_salida < SYSDATE AND :NEW.fecha_llegada > SYSDATE) THEN
        UPDATE VUELO
        SET estado = 'En vuelo' 
        WHERE id_vuelo = :NEW.id_vuelo;
    ELSIF (:NEW.fecha_llegada <= SYSDATE) THEN
        UPDATE VUELO
        SET estado = 'Aterrizado' 
        WHERE id_vuelo = :NEW.id_vuelo;
    END IF;
END;

-- Trigger para actualizar el estado de compra

CREATE OR REPLACE TRIGGER ACTUALIZAR_ESTADO_COMPRA
AFTER INSERT OR UPDATE ON COMPRA
FOR EACH ROW
BEGIN
    IF (:NEW.fecha_compra < SYSDATE) THEN
        UPDATE COMPRA
        SET estado = 'Confirmado' 
        WHERE id_compra = :NEW.id_compra;
    END IF;
END;

-- Trigger para actualizar el estado de asiento

CREATE OR REPLACE TRIGGER ACTUALIZAR_ESTADO_ASIENTO
AFTER INSERT OR UPDATE ON ASIENTO
FOR EACH ROW
BEGIN
    IF (:NEW.estado = 'Reservado') THEN
        UPDATE ASIENTO
        SET estado = 'No disponible' 
        WHERE id_asiento = :NEW.id_asiento;
    END IF;
END;

-- Trigger para actualizar el estado de asistencia

CREATE OR REPLACE TRIGGER ACTUALIZAR_ESTADO_ASISTENCIA
AFTER INSERT OR UPDATE ON ASISTENCIA
FOR EACH ROW
BEGIN
    IF (:NEW.tipo_asistencia = 'Discapacidad') THEN
        UPDATE ASISTENCIA
        SET estado = 'Discapacidad' 
        WHERE id_asistencia = :NEW.id_asistencia;
    ELSIF (:NEW.tipo_asistencia = 'Embarazo') THEN
        UPDATE ASISTENCIA
        SET estado = 'Embarazo' 
        WHERE id_asistencia = :NEW.id_asistencia;
    ELSIF (:NEW.tipo_asistencia = 'Tercera Edad') THEN
        UPDATE ASISTENCIA
        SET estado = 'Tercera Edad' 
        WHERE id_asistencia = :NEW.id_asistencia;
    ELSIF (:NEW.tipo_asistencia = 'Niños') THEN
        UPDATE ASISTENCIA
        SET estado = 'Niños' 
        WHERE id_asistencia = :NEW.id_asistencia;
    END IF;
END;

-- Trigger para actualizar el estado de equipaje

CREATE OR REPLACE TRIGGER ACTUALIZAR_ESTADO_EQUIPAJE
AFTER INSERT OR UPDATE ON EQUIPAJE
FOR EACH ROW
BEGIN
    IF (:NEW.peso > 20) THEN
        UPDATE EQUIPAJE
        SET estado = 'Sobrepeso' 
        WHERE id_equipaje = :NEW.id_equipaje;
    END IF;
END;

-- Trigger para actualizar el estado de servicios

CREATE OR REPLACE TRIGGER ACTUALIZAR_ESTADO_SERVICIOS
AFTER INSERT OR UPDATE ON SERVICIOS_PASAJERO
FOR EACH ROW
BEGIN
    IF (:NEW.precio_servicio > 100000) THEN
        UPDATE SERVICIOS_PASAJERO
        SET estado = 'Caro' 
        WHERE id_servicio_pasajero = :NEW.id_servicio_pasajero;
    END IF;
END;

-- Trigger para actualizar el monto total de la compra

CREATE OR REPLACE TRIGGER RECUENTO_TOTAL_COMPRA
AFTER INSERT OR UPDATE ON COMPRA
FOR EACH ROW
BEGIN
    UPDATE COMPRA
    SET monto_total_compra = (SELECT SUM(precio_servicio) FROM SERVICIOS_PASAJERO WHERE id_pasajero_ser = :NEW.id_pasajero_comp)
    WHERE id_compra = :NEW.id_compra;
END;

-- Trigger para liberar y eliminar asientos al cancelar una compra

CREATE OR REPLACE TRIGGER LIBERAR_ASIENTOS
AFTER DELETE ON COMPRA
FOR EACH ROW
BEGIN
    DELETE FROM RESERVA
    WHERE id_pasajero_res = :OLD.id_pasajero_comp;
END;

-- Trigger para liberar y eliminar asientos al cancelar una reserva

CREATE OR REPLACE TRIGGER LIBERAR_ASIENTOS_RESERVA
AFTER DELETE ON RESERVA
FOR EACH ROW
BEGIN
    DELETE FROM RESERVA
    WHERE id_pasajero_res = :OLD.id_pasajero_res;
END;

-- Trigger verificar peso del equipaje

CREATE OR REPLACE TRIGGER VERIFICAR_PESO_EQUIPAJE
BEFORE INSERT ON EQUIPAJE
FOR EACH ROW
BEGIN
    IF (:NEW.peso > 20) THEN
        RAISE_APPLICATION_ERROR(-20002, 'El peso del equipaje no puede superar los 20 kg.');
    END IF;
END;

-- Trigger para actualizar de un vuelo al reservar o liberar un asiento

CREATE OR REPLACE TRIGGER ACTUALIZAR_ESTADO_VUELO_RESERVA
AFTER INSERT OR DELETE ON RESERVA
FOR EACH ROW
BEGIN
    UPDATE VUELO
    SET estado = 'En vuelo' 
    WHERE id_vuelo = :NEW.id_vuelo_res;
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

-- Procedimiento para cancelar una compra
CREATE OR REPLACE PROCEDURE cancelar_compra (
    p_id_compra NUMBER
) 
IS
    v_id_vuelo NUMBER;
    v_id_asiento NUMBER;
BEGIN
    SELECT id_vuelo_comp, id_asiento
    FROM COMPRA
    WHERE id_compra = p_id_compra

    BEGIN
        SELECT id_asiento
        INTO v_id_asiento
        FROM RESERVA
        WHERE id_vuelo_res = v_id_vuelo;
        AND id_pasajero_res = (SELECT id_pasajero_comp FROM COMPRA WHERE id_compra = p_id_compra);

        UPDATE ASIENTO
        SET estado = 'Disponible'
        WHERE id_asiento = v_id_asiento;

        DELETE FROM RESERVA
        WHERE id_vuelo_res = v_id_vuelo;
        AND id_pasajero_res = (SELECT id_pasajero_comp FROM COMPRA WHERE id_compra = p_id_compra);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'No se encontró la compra con el ID especificado.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'Ha ocurrido un error al intentar cancelar la compra.');
END;
/