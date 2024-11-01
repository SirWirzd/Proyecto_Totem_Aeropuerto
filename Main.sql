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

-- Eliminación de tablas si existen previamente
DROP TABLE DOCUMENTO_EMBARQUE CASCADE CONSTRAINTS;
DROP TABLE CHECK_IN CASCADE CONSTRAINTS;
DROP TABLE RESERVA CASCADE CONSTRAINTS;
DROP TABLE VUELO CASCADE CONSTRAINTS;
DROP TABLE PASAJERO CASCADE CONSTRAINTS;
DROP TABLE EQUIPAJE CASCADE CONSTRAINTS;
DROP TABLE ASIENTO CASCADE CONSTRAINTS;
DROP TABLE AVION CASCADE CONSTRAINTS;
DROP TABLE AEROLINEA CASCADE CONSTRAINTS;
DROP TABLE PUERTA CASCADE CONSTRAINTS;
DROP TABLE TERMINAL_AEROPUERTO CASCADE CONSTRAINTS;
DROP TABLE AEROPUERTO CASCADE CONSTRAINTS;
DROP TABLE CIUDAD CASCADE CONSTRAINTS;
DROP TABLE PAIS CASCADE CONSTRAINTS;

-- Tabla PAIS
CREATE TABLE PAIS (
    id_pais NUMBER NOT NULL,
    nombre VARCHAR2(100) NOT NULL,
    visa_requerida VARCHAR2(20),
    tipo_visa VARCHAR2(99),
    pasaporte_requerido VARCHAR2(20),
    CONSTRAINT PK_PAIS PRIMARY KEY (id_pais),
    CONSTRAINT chck_visa_pais CHECK (visa_requerida IN ('Sí', 'No')),
    CONSTRAINT chck_tipo_visa CHECK (visa_requerida = 'No' OR tipo_visa IN ('Turismo', 'Negocios', 'Estudio', 'Trabajo')),
    CONSTRAINT chck_pasaporte CHECK (pasaporte_requerido IN ('Sí', 'No'))
);

-- Tabla CIUDAD
CREATE TABLE CIUDAD (
    id_ciudad NUMBER NOT NULL,
    nombre VARCHAR2(100) NOT NULL,
    id_pais NUMBER NOT NULL,
    CONSTRAINT PK_CIUDAD PRIMARY KEY (id_ciudad),
    CONSTRAINT FK_CIUDAD_PAIS FOREIGN KEY (id_pais) REFERENCES PAIS(id_pais) ON DELETE CASCADE
);

-- Tabla AEROPUERTO
CREATE TABLE AEROPUERTO (
    id_aeropuerto NUMBER NOT NULL,
    nombre VARCHAR2(100) NOT NULL,
    id_ciudad NUMBER NOT NULL,
    CONSTRAINT PK_AEROPUERTO PRIMARY KEY (id_aeropuerto),
    CONSTRAINT FK_AEROPUERTO_CIUDAD FOREIGN KEY (id_ciudad) REFERENCES CIUDAD(id_ciudad) ON DELETE CASCADE
);

-- Tabla TERMINAL_AEROPUERTO
CREATE TABLE TERMINAL_AEROPUERTO (
    id_terminal NUMBER NOT NULL,
    nombre VARCHAR2(50) NOT NULL,
    id_aeropuerto NUMBER NOT NULL,
    CONSTRAINT PK_TERMINAL PRIMARY KEY (id_terminal),
    CONSTRAINT FK_TERMINAL_AEROPUERTO FOREIGN KEY (id_aeropuerto) REFERENCES AEROPUERTO(id_aeropuerto) ON DELETE CASCADE
);

-- Tabla PUERTA
CREATE TABLE PUERTA (
    id_puerta NUMBER NOT NULL,
    nombre VARCHAR2(50) NOT NULL,
    id_terminal NUMBER NOT NULL,
    CONSTRAINT PK_PUERTA PRIMARY KEY (id_puerta),
    CONSTRAINT FK_PUERTA_TERMINAL FOREIGN KEY (id_terminal) REFERENCES TERMINAL_AEROPUERTO(id_terminal) ON DELETE CASCADE
);

-- Tabla AEROLINEA
CREATE TABLE AEROLINEA (
    id_aerolinea NUMBER NOT NULL,
    nombre_aerolinea VARCHAR2(100) NOT NULL,
    CONSTRAINT PK_AEROLINEA PRIMARY KEY (id_aerolinea)
);

-- Tabla AVION
CREATE TABLE AVION (
    id_avion NUMBER NOT NULL,
    modelo VARCHAR2(50) NOT NULL,
    capacidad NUMBER NOT NULL,
    id_aerolinea NUMBER NOT NULL,
    CONSTRAINT PK_AVION PRIMARY KEY (id_avion),
    CONSTRAINT FK_AVION_AEROLINEA FOREIGN KEY (id_aerolinea) REFERENCES AEROLINEA(id_aerolinea) ON DELETE CASCADE
);

-- Tabla ASIENTO (con referencia al AVION)
CREATE TABLE ASIENTO (
    id_asiento NUMBER NOT NULL,
    id_avion NUMBER NOT NULL,
    numero_asiento VARCHAR2(10) NOT NULL,
    estado VARCHAR2(20) DEFAULT 'Disponible' CHECK (estado IN ('Disponible', 'No disponible')),
    CONSTRAINT PK_ASIENTO PRIMARY KEY (id_asiento),
    CONSTRAINT FK_ASIENTO_AVION FOREIGN KEY (id_avion) REFERENCES AVION(id_avion) ON DELETE CASCADE
);


-- Tabla PASAJERO
CREATE TABLE PASAJERO (
    id_pasajero NUMBER NOT NULL,
    nombre VARCHAR2(100) NOT NULL,
    apellido VARCHAR2(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    correo_electronico VARCHAR2(100) NOT NULL,
    telefono_pasajero VARCHAR2(99) NOT NULL,
    documento_identidad VARCHAR2(20) NOT NULL,
    asistencia VARCHAR2(20) CHECK (asistencia IN ('Sí', 'No')),
    edad NUMBER,
    CONSTRAINT PK_PASAJERO PRIMARY KEY (id_pasajero),
    CONSTRAINT chck_telefono CHECK (telefono_pasajero LIKE '+%_____%')
);

-- Tabla EQUIPAJE
CREATE TABLE EQUIPAJE (
    id_equipaje NUMBER NOT NULL,
    id_pasajero NUMBER NOT NULL, -- Relación directa con el pasajero
    tipo_equipaje VARCHAR2(20) CHECK (tipo_equipaje IN ('Mano', 'De Bodega')) NOT NULL,
    peso NUMBER NOT NULL,
    descripcion VARCHAR2(100) NOT NULL,
    alto NUMBER NOT NULL,
    ancho NUMBER NOT NULL,
    profundidad NUMBER NOT NULL,
    cobro_extra NUMBER DEFAULT 0,
    CONSTRAINT PK_EQUIPAJE PRIMARY KEY (id_equipaje),
    CONSTRAINT FK_EQUIPAJE_PASAJERO FOREIGN KEY (id_pasajero) REFERENCES PASAJERO(id_pasajero) ON DELETE CASCADE
);

-- Tabla VUELO
CREATE TABLE VUELO (
    id_vuelo NUMBER NOT NULL,
    id_aerolinea NUMBER NOT NULL,
    id_avion NUMBER NOT NULL, -- Relación entre vuelo y avión
    id_aeropuerto_origen NUMBER NOT NULL,
    id_aeropuerto_destino NUMBER NOT NULL,
    fecha_hora_salida TIMESTAMP NOT NULL,
    fecha_hora_llegada TIMESTAMP NOT NULL,
    duracion NUMBER NOT NULL,
    distancia NUMBER NOT NULL,
    estado VARCHAR2(20) CHECK (estado IN ('Programado', 'En vuelo', 'Aterrizado', 'Cancelado')),
    CONSTRAINT PK_VUELO PRIMARY KEY (id_vuelo),
    CONSTRAINT FK_VUELO_AEROLINEA FOREIGN KEY (id_aerolinea) REFERENCES AEROLINEA(id_aerolinea) ON DELETE CASCADE,
    CONSTRAINT FK_VUELO_AEROPUERTO_ORIGEN FOREIGN KEY (id_aeropuerto_origen) REFERENCES AEROPUERTO(id_aeropuerto) ON DELETE CASCADE,
    CONSTRAINT FK_VUELO_AEROPUERTO_DESTINO FOREIGN KEY (id_aeropuerto_destino) REFERENCES AEROPUERTO(id_aeropuerto) ON DELETE CASCADE,
    CONSTRAINT FK_VUELO_AVION FOREIGN KEY (id_avion) REFERENCES AVION(id_avion) ON DELETE CASCADE
);


-- Tabla RESERVA (con una única restricción de unicidad en id_pasajero e id_vuelo)
CREATE TABLE RESERVA (
    id_reserva NUMBER NOT NULL,
    id_pasajero NUMBER NOT NULL,
    id_vuelo NUMBER NOT NULL,
    id_asiento NUMBER NOT NULL,
    id_equipaje NUMBER NOT NULL,
    id_aeropuerto NUMBER NOT NULL,
    fecha_hora_reserva TIMESTAMP NOT NULL,
    motivo_viaje VARCHAR2(100) NOT NULL CHECK (motivo_viaje IN ('Turismo', 'Negocios', 'Estudio', 'Trabajo')),
    tipo_boleto VARCHAR2(50) CHECK (tipo_boleto IN ('Económico', 'Ejecutivo', 'Primera Clase')),
    estado VARCHAR2(20) CHECK (estado IN ('Confirmada', 'Cancelado', 'Pendiente')),
    CONSTRAINT PK_RESERVA PRIMARY KEY (id_reserva),
    CONSTRAINT UQ_RESERVA_PASAJERO_VUELO UNIQUE (id_pasajero, id_vuelo), -- Unicidad pasajero-vuelo
    CONSTRAINT FK_RESERVA_PASAJERO FOREIGN KEY (id_pasajero) REFERENCES PASAJERO(id_pasajero) ON DELETE CASCADE,
    CONSTRAINT FK_RESERVA_VUELO FOREIGN KEY (id_vuelo) REFERENCES VUELO(id_vuelo) ON DELETE CASCADE,
    CONSTRAINT FK_RESERVA_ASIENTO FOREIGN KEY (id_asiento) REFERENCES ASIENTO(id_asiento) ON DELETE CASCADE,
    CONSTRAINT FK_RESERVA_AEROPUERTO FOREIGN KEY (id_aeropuerto) REFERENCES AEROPUERTO(id_aeropuerto) ON DELETE CASCADE
);


-- Tabla CHECK_IN - Relación 1 a 1 con RESERVA
CREATE TABLE CHECK_IN (
    id_check_in NUMBER NOT NULL,
    id_reserva NUMBER NOT NULL UNIQUE, -- Relación 1 a 1
    fecha_hora_check_in TIMESTAMP NOT NULL,
    estado VARCHAR2(20) CHECK (estado IN ('Completado', 'Cancelado', 'Pendiente')),
    tipo_check_in VARCHAR2(20) CHECK (tipo_check_in IN ('Presencial', 'Online')),
    CONSTRAINT PK_CHECK_IN PRIMARY KEY (id_check_in),
    CONSTRAINT FK_CHECK_IN_RESERVA FOREIGN KEY (id_reserva) REFERENCES RESERVA(id_reserva) ON DELETE CASCADE
);


-- Tabla DOCUMENTO_EMBARQUE - Relación 1 a 1 con CHECK_IN
CREATE TABLE DOCUMENTO_EMBARQUE (
    id_documento NUMBER NOT NULL,
    id_check_in NUMBER NOT NULL UNIQUE,  -- Relación 1 a 1
    id_pasajero NUMBER NOT NULL,         -- Relación directa con el pasajero
    id_vuelo NUMBER NOT NULL,            -- Relación con vuelo
    id_asiento NUMBER NOT NULL,          -- Relación con asiento asignado
    nombre_pasajero VARCHAR2(100) NOT NULL,
    apellido_pasajero VARCHAR2(100) NOT NULL,
    numero_vuelo VARCHAR2(20) NOT NULL,
    aerolinea VARCHAR2(100) NOT NULL,
    destino VARCHAR2(100) NOT NULL,
    fecha_salida TIMESTAMP NOT NULL,
    id_terminal NUMBER NOT NULL,
    id_puerta NUMBER NOT NULL,
    asiento VARCHAR2(10) NOT NULL,
    tipo_boleto VARCHAR2(50) NOT NULL CHECK (tipo_boleto IN ('Económico', 'Ejecutivo', 'Primera Clase')),
    fecha_hora TIMESTAMP NOT NULL,
    CONSTRAINT PK_DOCUMENTO_EMBARQUE PRIMARY KEY (id_documento),
    CONSTRAINT FK_DOCUMENTO_EMBARQUE_CHECK_IN FOREIGN KEY (id_check_in) REFERENCES CHECK_IN(id_check_in) ON DELETE CASCADE,
    CONSTRAINT FK_DOCUMENTO_EMBARQUE_PASAJERO FOREIGN KEY (id_pasajero) REFERENCES PASAJERO(id_pasajero) ON DELETE CASCADE,
    CONSTRAINT FK_DOCUMENTO_EMBARQUE_VUELO FOREIGN KEY (id_vuelo) REFERENCES VUELO(id_vuelo) ON DELETE CASCADE,
    CONSTRAINT FK_DOCUMENTO_EMBARQUE_ASIENTO FOREIGN KEY (id_asiento) REFERENCES ASIENTO(id_asiento) ON DELETE SET NULL,
    CONSTRAINT FK_DOCUMENTO_EMBARQUE_TERMINAL FOREIGN KEY (id_terminal) REFERENCES TERMINAL_AEROPUERTO(id_terminal) ON DELETE CASCADE,
    CONSTRAINT FK_DOCUMENTO_EMBARQUE_PUERTA FOREIGN KEY (id_puerta) REFERENCES PUERTA(id_puerta) ON DELETE CASCADE
);

-- Cambiar formato de la fecha

ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'DD-MM-YYYY HH24:MI:SS';


-- ======================
-- 1. Validación de Equipaje
-- ======================

-- Trigger para validar el tamaño y peso del equipaje y aplicar un cobro extra
CREATE OR REPLACE TRIGGER VALIDAR_TAMANO_PESO_Y_COBRO_EQUIPAJE
BEFORE INSERT OR UPDATE ON EQUIPAJE
FOR EACH ROW
BEGIN
    :NEW.cobro_extra := 0;
    IF :NEW.tipo_equipaje = 'Mano' THEN
        IF :NEW.alto > 55 OR :NEW.ancho > 35 OR :NEW.profundidad > 25 THEN
            :NEW.cobro_extra := 22000;
        END IF;
        IF :NEW.peso > 10 THEN
            :NEW.cobro_extra := :NEW.cobro_extra + 25000;
        END IF;
    ELSIF :NEW.tipo_equipaje = 'De Bodega' THEN
        IF :NEW.alto > 80 OR :NEW.ancho > 50 OR :NEW.profundidad > 30 THEN
            :NEW.cobro_extra := 45000;
        END IF;
        IF :NEW.peso > 23 THEN
            :NEW.cobro_extra := :NEW.cobro_extra + 50000;
        END IF;
    END IF;
END;
/

-- Trigger para limitar el número de equipajes por pasajero
CREATE OR REPLACE TRIGGER LIMITE_EQUIPAJES_POR_PASAJERO
BEFORE INSERT ON EQUIPAJE
FOR EACH ROW
DECLARE
    v_numero_equipajes NUMBER;
    v_limite_equipajes CONSTANT NUMBER := 2; -- Límite de equipajes por pasajero
BEGIN
    -- Contar los equipajes ya registrados para el pasajero
    SELECT COUNT(*)
    INTO v_numero_equipajes
    FROM EQUIPAJE
    WHERE id_pasajero = :NEW.id_pasajero;

    -- Verificar si se excede el límite de equipajes
    IF v_numero_equipajes > v_limite_equipajes THEN
        RAISE_APPLICATION_ERROR(-20006, 'El pasajero ha excedido el límite permitido de equipajes.');
    END IF;
END;
/

-- ======================
-- 2. Verificación de Documentos y Asistencia
-- ======================

-- Trigger para verificar y actualizar asistencia para pasajeros menores de edad
CREATE OR REPLACE TRIGGER VERIFICAR_Y_ACTUALIZAR_ASISTENCIA_MENOR_EDAD
BEFORE INSERT OR UPDATE ON PASAJERO
FOR EACH ROW
BEGIN
    IF :NEW.edad < 18 THEN
        IF :NEW.asistencia IS NULL OR :NEW.asistencia = 'No' THEN
            :NEW.asistencia := 'Sí';
        END IF;
        IF :NEW.asistencia = 'No' THEN
            RAISE_APPLICATION_ERROR(-20008, 'El pasajero es menor de edad y requiere un asistente o acompañante para volar.');
        END IF;
    END IF;
END;
/

-- Trigger para verificar la visa según el país de destino
CREATE OR REPLACE TRIGGER TRG_VERIFICAR_VISA
BEFORE INSERT ON RESERVA
FOR EACH ROW
DECLARE
    v_visa_requerida VARCHAR2(20);
    v_tipo_visa VARCHAR2(99);
BEGIN
    SELECT p.visa_requerida, p.tipo_visa
    INTO v_visa_requerida, v_tipo_visa
    FROM PAIS p
    JOIN CIUDAD c ON c.id_pais = p.id_pais
    JOIN AEROPUERTO a ON a.id_ciudad = c.id_ciudad
    JOIN VUELO v ON v.id_aeropuerto_destino = a.id_aeropuerto
    WHERE v.id_vuelo = :NEW.id_vuelo;
    IF v_visa_requerida = 'Sí' AND v_tipo_visa IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'El país de destino requiere especificar el tipo de visa para el pasajero.');
    END IF;
END;
/

-- Trigger para verificar el pasaporte según el país de destino
CREATE OR REPLACE TRIGGER TRG_VERIFICAR_PASAPORTE
BEFORE INSERT ON RESERVA
FOR EACH ROW
DECLARE
    v_pasaporte_requerido VARCHAR2(20);
    v_pasaporte_pasajero VARCHAR2(20);
BEGIN
    SELECT p.pasaporte_requerido
    INTO v_pasaporte_requerido
    FROM PAIS p
    JOIN CIUDAD c ON c.id_pais = p.id_pais
    JOIN AEROPUERTO a ON a.id_ciudad = c.id_ciudad
    JOIN VUELO v ON v.id_aeropuerto_destino = a.id_aeropuerto
    WHERE v.id_vuelo = :NEW.id_vuelo;
    SELECT documento_identidad
    INTO v_pasaporte_pasajero
    FROM PASAJERO
    WHERE id_pasajero = :NEW.id_pasajero;
    IF v_pasaporte_requerido = 'Sí' AND v_pasaporte_pasajero = 'No' THEN
        RAISE_APPLICATION_ERROR(-20003, 'El país de destino requiere que el pasajero tenga pasaporte.');
    END IF;
END;
/

-- Validación de Identidad en PASAJERO para asegurar unicidad en documento de identidad y correo
CREATE OR REPLACE TRIGGER VALIDAR_UNICIDAD_PASAJERO
BEFORE INSERT ON PASAJERO
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM PASAJERO
    WHERE documento_identidad = :NEW.documento_identidad OR correo_electronico = :NEW.correo_electronico;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20034, 'Ya existe un pasajero con el mismo documento de identidad o correo.');
    END IF;
END;
/

-- ======================
-- 3. Gestión de Estado de Vuelos
-- ======================

-- Trigger para actualizar el estado del vuelo a "En vuelo", "Aterrizado" o "Programado"
CREATE OR REPLACE TRIGGER ACTUALIZAR_ESTADO_VUELO_TIEMPO
AFTER INSERT OR UPDATE ON VUELO
FOR EACH ROW
BEGIN
    IF :NEW.fecha_hora_salida <= SYSDATE AND :NEW.fecha_hora_llegada > SYSDATE THEN
        UPDATE VUELO
        SET estado = 'En vuelo'
        WHERE id_vuelo = :NEW.id_vuelo;
    ELSIF :NEW.fecha_hora_llegada <= SYSDATE THEN
        UPDATE VUELO
        SET estado = 'Aterrizado'
        WHERE id_vuelo = :NEW.id_vuelo;
    ELSE
        UPDATE VUELO
        SET estado = 'Programado'
        WHERE id_vuelo = :NEW.id_vuelo;
    END IF;
END;
/

-- Trigger para actualizar la duración del vuelo automáticamente
CREATE OR REPLACE TRIGGER TRG_VERIFICAR_DURACION
BEFORE INSERT OR UPDATE ON VUELO
FOR EACH ROW
BEGIN
    :NEW.duracion := (:NEW.fecha_hora_llegada - :NEW.fecha_hora_salida) * 24*60;
END;
/

-- Trigger para actualizar el estado del vuelo a "Cancelado" si una reserva es cancelada
CREATE OR REPLACE TRIGGER ACTUALIZAR_ESTADO_VUELO_CANCELADO
AFTER UPDATE ON RESERVA
FOR EACH ROW
BEGIN
    IF (:NEW.estado = 'Cancelado') THEN
        UPDATE VUELO
        SET estado = 'Cancelado' 
        WHERE id_vuelo = :NEW.id_vuelo;
    END IF;
END;
/

-- Trigger para restringir la actualización de la fecha de salida de un vuelo si faltan menos de 24 horas
CREATE OR REPLACE TRIGGER RESTRINGIR_ACTUALIZACION_FECHA_VUELO
BEFORE UPDATE OF fecha_hora_salida ON VUELO
FOR EACH ROW
BEGIN
    IF :OLD.fecha_hora_salida - INTERVAL '1' DAY < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20013, 'No se permite actualizar la fecha de salida ya que faltan menos de 24 horas para el vuelo.');
    END IF;
END;
/

-- ======================
-- 4. Gestión de Asientos y Puertas
-- ======================

-- Trigger para verificar la disponibilidad de puertas al asignar vuelos
CREATE OR REPLACE TRIGGER VALIDAR_DISPONIBILIDAD_PUERTA
BEFORE INSERT OR UPDATE ON VUELO
FOR EACH ROW
DECLARE
    v_puerta_ocupada NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_puerta_ocupada
    FROM VUELO
    WHERE id_aeropuerto_destino = :NEW.id_aeropuerto_destino
      AND fecha_hora_salida < :NEW.fecha_hora_llegada
      AND fecha_hora_llegada > :NEW.fecha_hora_salida
      AND id_vuelo != :NEW.id_vuelo;
    IF v_puerta_ocupada > 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'La puerta seleccionada ya está ocupada por otro vuelo en este intervalo de tiempo.');
    END IF;
END;
/

-- Trigger para actualizar el estado del asiento al hacer check-in
CREATE OR REPLACE TRIGGER ACTUALIZAR_ESTADO_ASIENTO_CHECK_IN
AFTER INSERT ON CHECK_IN
FOR EACH ROW
BEGIN
    UPDATE ASIENTO
    SET estado = 'No disponible'
    WHERE id_asiento = (SELECT id_asiento FROM RESERVA WHERE id_reserva = :NEW.id_reserva);
END;
/

-- Trigger para liberar el estado del asiento al finalizar el vuelo
CREATE OR REPLACE TRIGGER ACTUALIZAR_ESTADO_ASIENTO_FIN_VUELO
AFTER UPDATE OF estado ON VUELO
FOR EACH ROW
BEGIN
    IF :NEW.estado = 'Aterrizado' THEN
        UPDATE ASIENTO
        SET estado = 'Disponible'
        WHERE id_asiento IN (
            SELECT id_asiento
            FROM RESERVA
            WHERE id_vuelo = :NEW.id_vuelo
        );
    END IF;
END;
/

-- Trigger para liberar y eliminar asientos al cancelar una reserva
CREATE OR REPLACE TRIGGER LIBERAR_ASIENTOS_RESERVA
AFTER DELETE ON RESERVA
FOR EACH ROW
BEGIN
    UPDATE ASIENTO
    SET estado = 'Disponible'
    WHERE id_asiento = :OLD.id_asiento;
END;
/

-- ======================
-- 5. Gestión de Estado de Reservas
-- ======================

-- Trigger para actualizar el estado de la reserva automáticamente
CREATE OR REPLACE TRIGGER ACTUALIZAR_ESTADO_RESERVA
AFTER INSERT OR UPDATE ON RESERVA
FOR EACH ROW
BEGIN
    IF (:NEW.fecha_hora_reserva < SYSDATE) THEN
        UPDATE RESERVA
        SET estado = 'Confirmada' 
        WHERE id_reserva = :NEW.id_reserva;
    END IF;
END;
/

-- Trigger para controlar disponibilidad de vuelos y asientos en modificaciones de reserva
CREATE OR REPLACE TRIGGER VALIDAR_MODIFICACION_RESERVA
BEFORE UPDATE ON RESERVA
FOR EACH ROW
DECLARE
    v_estado_vuelo VARCHAR2(20);
    v_estado_asiento VARCHAR2(20);
BEGIN
    SELECT estado INTO v_estado_vuelo FROM VUELO WHERE id_vuelo = :NEW.id_vuelo;
    IF v_estado_vuelo != 'Programado' THEN
        RAISE_APPLICATION_ERROR(-20031, 'Solo se pueden modificar reservas en vuelos programados.');
    END IF;

    SELECT estado INTO v_estado_asiento FROM ASIENTO WHERE id_asiento = :NEW.id_asiento;
    IF v_estado_asiento != 'Disponible' THEN
        RAISE_APPLICATION_ERROR(-20032, 'El asiento seleccionado no está disponible para esta reserva.');
    END IF;
END;
/

--Trigger genera documento de embarque automáticamente tras completar el CHECK_IN.
CREATE OR REPLACE TRIGGER GENERAR_DOCUMENTO_TRAS_CHECK_IN
AFTER INSERT ON CHECK_IN
FOR EACH ROW
BEGIN
    INSERT INTO DOCUMENTO_EMBARQUE (
        id_documento, id_check_in, id_pasajero, id_vuelo, id_asiento, 
        nombre_pasajero, apellido_pasajero, numero_vuelo, aerolinea, 
        destino, fecha_salida, id_terminal, id_puerta, asiento, tipo_boleto, fecha_hora
    )
    SELECT SEQ_DOCUMENTO_EMBARQUE.NEXTVAL, :NEW.id_check_in, p.id_pasajero, r.id_vuelo, r.id_asiento,
           p.nombre, p.apellido, v.numero_vuelo, a.nombre_aerolinea, d.nombre,
           v.fecha_hora_salida, t.id_terminal, g.id_puerta, a.numero_asiento, r.tipo_boleto, SYSDATE
    FROM PASAJERO p
    JOIN RESERVA r ON p.id_pasajero = r.id_pasajero
    JOIN VUELO v ON r.id_vuelo = v.id_vuelo
    JOIN AEROLINEA a ON v.id_aerolinea = a.id_aerolinea
    JOIN CIUDAD d ON d.id_ciudad = (SELECT id_ciudad FROM AEROPUERTO WHERE id_aeropuerto = v.id_aeropuerto_destino)
    JOIN TERMINAL_AEROPUERTO t ON t.id_aeropuerto = v.id_aeropuerto_destino
    JOIN PUERTA g ON g.id_terminal = t.id_terminal
    WHERE r.id_reserva = :NEW.id_reserva;
END;
/



-- ======================
-- Procedimientos
-- ======================

-- Procedimiento para realizar el check-in de un pasajero
CREATE OR REPLACE PROCEDURE proc_realizar_check_in (
    p_id_reserva NUMBER,
    p_documento_identidad VARCHAR2,
    p_id_asiento NUMBER,
    p_peso_equipaje NUMBER
) IS
    v_id_pasajero NUMBER;
    v_documento_valido BOOLEAN := FALSE;
    v_nuevo_id_check_in NUMBER;
BEGIN
    -- Verificación del ID de reserva
    SELECT id_pasajero
    INTO v_id_pasajero
    FROM RESERVA
    WHERE id_reserva = p_id_reserva;

    -- Validación del formato del documento de identidad (RUN o pasaporte)
    IF p_documento_identidad IS NOT NULL THEN
        IF REGEXP_LIKE (p_documento_identidad, '^[0-9]{8}-[0-9Kk]{1}$') OR REGEXP_LIKE (p_documento_identidad, '^[A-Za-z]{1}[0-9]{5,9}$') THEN 
            v_documento_valido := TRUE;
        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'Documento de identidad inválido.');
        END IF;
    END IF;

    -- Verificación de disponibilidad del asiento
    BEGIN
        SELECT 1
        INTO v_id_pasajero
        FROM ASIENTO
        WHERE id_asiento = p_id_asiento
        AND estado = 'Disponible';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'El asiento no está disponible.');
    END;

    -- Verificación del peso del equipaje
    IF p_peso_equipaje > 23 THEN
        RAISE_APPLICATION_ERROR(-20004, 'El peso del equipaje excede el límite permitido. Por favor, pague una multa o reduzca el peso.');
    END IF;

    -- Obtener un nuevo ID para CHECK_IN
    SELECT NVL(MAX(id_check_in), 0) + 1 INTO v_nuevo_id_check_in FROM CHECK_IN;

    -- Inserción en la tabla de CHECK_IN
    INSERT INTO CHECK_IN (
        id_check_in, id_reserva, fecha_hora_check_in, estado, tipo_check_in
    ) VALUES (
        v_nuevo_id_check_in, p_id_reserva, SYSDATE, 'Completado', 
        CASE 
            WHEN p_documento_identidad IS NOT NULL THEN 'Presencial' 
            ELSE 'Online' 
        END
    );

    -- Actualización del estado del asiento a 'No disponible'
    UPDATE ASIENTO
    SET estado = 'No disponible'
    WHERE id_asiento = p_id_asiento;

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005, 'Pasajero o reserva no encontrada.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- Procedimiento para asignar un asiento disponible si el pasajero no tiene uno asignado
CREATE OR REPLACE PROCEDURE asignar_asiento_disponible (
    p_id_reserva IN NUMBER
) IS
    v_id_vuelo NUMBER;
    v_id_asiento NUMBER;
BEGIN
    -- Obtener el ID del vuelo de la reserva
    SELECT id_vuelo
    INTO v_id_vuelo
    FROM RESERVA
    WHERE id_reserva = p_id_reserva;
    
    -- Buscar un asiento disponible en el vuelo especificado
    SELECT id_asiento
    INTO v_id_asiento
    FROM ASIENTO
    WHERE estado = 'Disponible'
      AND id_avion = (SELECT id_avion FROM VUELO WHERE id_vuelo = v_id_vuelo)
      AND ROWNUM = 1;  -- Toma el primer asiento disponible

    -- Actualizar la reserva con el asiento asignado
    UPDATE RESERVA
    SET id_asiento = v_id_asiento
    WHERE id_reserva = p_id_reserva;

    -- Cambiar el estado del asiento a "No disponible"
    UPDATE ASIENTO
    SET estado = 'No disponible'
    WHERE id_asiento = v_id_asiento;

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20014, 'No hay asientos disponibles para este vuelo.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- Procedimiento para notificar a los pasajeros de un cambio de puerta de embarque
CREATE OR REPLACE PROCEDURE notificar_cambio_puerta (
    p_id_vuelo IN NUMBER,
    p_id_pasajero IN NUMBER
) IS
    v_nombre VARCHAR2(100);
    v_telefono_pasajero VARCHAR2(20);
    v_puerta NUMBER;
BEGIN
    -- Obtener los datos del pasajero y la nueva puerta de embarque del vuelo
    SELECT p.nombre, p.telefono_pasajero, pt.id_puerta
    INTO v_nombre, v_telefono_pasajero, v_puerta
    FROM PASAJERO p
    JOIN RESERVA r ON p.id_pasajero = r.id_pasajero
    JOIN VUELO v ON r.id_vuelo = v.id_vuelo
    JOIN PUERTA pt ON pt.id_terminal = (SELECT id_terminal FROM TERMINAL_AEROPUERTO WHERE id_aeropuerto = v.id_aeropuerto_destino)
    WHERE v.id_vuelo = p_id_vuelo
      AND p.id_pasajero = p_id_pasajero;

    -- Simulación de notificación al pasajero (mensaje de texto)
    RAISE_APPLICATION_ERROR(-20015,
        'Estimado ' || v_nombre || ', su puerta de embarque ha sido cambiada a la puerta ' || v_puerta || '. Gracias.');
END;
/

-- Procedimiento para informar sobre el retraso de un vuelo
CREATE OR REPLACE PROCEDURE notificar_retraso_vuelo (
    p_id_vuelo IN NUMBER,
    p_id_pasajero IN NUMBER,
    p_nueva_hora_salida TIMESTAMP
) IS
    v_nombre VARCHAR2(100);
    v_telefono_pasajero VARCHAR2(20);
BEGIN
    -- Obtener los datos del pasajero
    SELECT nombre, telefono_pasajero
    INTO v_nombre, v_telefono_pasajero
    FROM PASAJERO
    WHERE id_pasajero = p_id_pasajero;

    -- Simulación de notificación al pasajero sobre el retraso del vuelo
    RAISE_APPLICATION_ERROR(-20016,
        'Estimado ' || v_nombre || ', su vuelo ha sido retrasado. La nueva hora de salida es ' || TO_CHAR(p_nueva_hora_salida, 'DD-MM-YYYY HH24:MI') || '. Gracias.');
END;
/

-- Procedimiento para Cancelar una Reserva
CREATE OR REPLACE PROCEDURE cancelar_reserva (
    p_id_reserva NUMBER
) IS
BEGIN
    -- Actualizar el estado de la reserva a 'Cancelado'
    UPDATE RESERVA
    SET estado = 'Cancelado'
    WHERE id_reserva = p_id_reserva;

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20017, 'Reserva no encontrada.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/


-- Procedimiento para Actualizar Estado de Asientos en Base al Estado de Vuelo
CREATE OR REPLACE PROCEDURE actualizar_estado_vuelo (
    p_id_vuelo NUMBER,
    p_nuevo_estado VARCHAR2
) IS
BEGIN
    UPDATE VUELO
    SET estado = p_nuevo_estado
    WHERE id_vuelo = p_id_vuelo;

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20020, 'Vuelo no encontrado.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- Procedimiento para Asignar Equipaje a un Pasajero
CREATE OR REPLACE PROCEDURE asignar_equipaje_a_pasajero (
    p_id_pasajero NUMBER,
    p_tipo_equipaje VARCHAR2,
    p_peso NUMBER,
    p_alto NUMBER,
    p_ancho NUMBER,
    p_profundidad NUMBER
) IS
BEGIN
    -- Insertar el nuevo equipaje para el pasajero especificado
    INSERT INTO EQUIPAJE (
        id_equipaje, id_pasajero, tipo_equipaje, peso, alto, ancho, profundidad, cobro_extra
    ) VALUES (
        (SELECT NVL(MAX(id_equipaje), 0) + 1 FROM EQUIPAJE),  -- Generar un nuevo ID para el equipaje
        p_id_pasajero,
        p_tipo_equipaje,
        p_peso,
        p_alto,
        p_ancho,
        p_profundidad,
        0  -- El trigger de validación de tamaño y peso actualizará el cobro_extra si es necesario
    );

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- Procedimiento Para Registrar Equipaje Extra con Cobro Adicional
CREATE OR REPLACE PROCEDURE registrar_equipaje_extra (
    p_id_pasajero NUMBER,
    p_tipo_equipaje VARCHAR2,
    p_peso NUMBER,
    p_alto NUMBER,
    p_ancho NUMBER,
    p_profundidad NUMBER
) IS
BEGIN
    -- Registrar el equipaje sin necesidad de cálculos adicionales
    INSERT INTO EQUIPAJE (
        id_equipaje, id_pasajero, tipo_equipaje, peso, alto, ancho, profundidad
    ) VALUES (
        (SELECT NVL(MAX(id_equipaje), 0) + 1 FROM EQUIPAJE), p_id_pasajero, p_tipo_equipaje, p_peso, p_alto, p_ancho, p_profundidad
    );

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20021, 'Pasajero no encontrado.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

--Procedimiento para Generar Informe de Vuelos de un Pasajero
CREATE OR REPLACE PROCEDURE generar_informe_vuelos_pasajero (
    p_id_pasajero NUMBER
) IS
    CURSOR c_vuelos IS
        SELECT v.id_vuelo, a.nombre_aerolinea, v.fecha_hora_salida, v.fecha_hora_llegada, d.nombre AS destino
        FROM VUELO v
        JOIN RESERVA r ON v.id_vuelo = r.id_vuelo
        JOIN AEROLINEA a ON v.id_aerolinea = a.id_aerolinea
        JOIN AEROPUERTO ap_dest ON v.id_aeropuerto_destino = ap_dest.id_aeropuerto
        JOIN CIUDAD d ON ap_dest.id_ciudad = d.id_ciudad
        WHERE r.id_pasajero = p_id_pasajero
        AND v.estado IN ('Programado', 'En vuelo');
BEGIN
    FOR vuelo_rec IN c_vuelos LOOP
        DBMS_OUTPUT.PUT_LINE('Vuelo ID: ' || vuelo_rec.id_vuelo);
        DBMS_OUTPUT.PUT_LINE('Aerolínea: ' || vuelo_rec.nombre_aerolinea);
        DBMS_OUTPUT.PUT_LINE('Salida: ' || TO_CHAR(vuelo_rec.fecha_hora_salida, 'DD-MM-YYYY HH24:MI'));
        DBMS_OUTPUT.PUT_LINE('Llegada: ' || TO_CHAR(vuelo_rec.fecha_hora_llegada, 'DD-MM-YYYY HH24:MI'));
        DBMS_OUTPUT.PUT_LINE('Destino: ' || vuelo_rec.destino);
        DBMS_OUTPUT.PUT_LINE('-----------------------');
    END LOOP;
END;
/

-- Procedimiento Completo para Obtener el Boleto de Abordaje
CREATE OR REPLACE PROCEDURE obtener_boleto_abordaje (
    p_id_check_in NUMBER
) IS
    v_id_documento NUMBER;
    v_nombre_pasajero VARCHAR2(100);
    v_apellido_pasajero VARCHAR2(100);
    v_numero_vuelo VARCHAR2(20);
    v_aerolinea VARCHAR2(100);
    v_origen VARCHAR2(100);
    v_destino VARCHAR2(100);
    v_fecha_salida TIMESTAMP;
    v_fecha_llegada TIMESTAMP;
    v_terminal NUMBER;
    v_puerta NUMBER;
    v_asiento VARCHAR2(10);
    v_tipo_boleto VARCHAR2(50);
    v_clase_servicio VARCHAR2(50);
    v_fecha_emision TIMESTAMP;
BEGIN
    -- Obtener los datos del boleto de abordaje y detalles adicionales del vuelo y pasajero
    SELECT id_documento, nombre_pasajero, apellido_pasajero, numero_vuelo,
           aerolinea, origen, destino, fecha_salida, fecha_llegada, 
           id_terminal, id_puerta, asiento, tipo_boleto, fecha_hora
    INTO v_id_documento, v_nombre_pasajero, v_apellido_pasajero, v_numero_vuelo,
         v_aerolinea, v_origen, v_destino, v_fecha_salida, v_fecha_llegada, 
         v_terminal, v_puerta, v_asiento, v_tipo_boleto, v_fecha_emision
    FROM DOCUMENTO_EMBARQUE
    WHERE id_check_in = p_id_check_in;

    -- Mostrar la información del boleto de abordaje
    DBMS_OUTPUT.PUT_LINE('--- TICKET DE ABORDAJE ---');
    DBMS_OUTPUT.PUT_LINE('Documento ID: ' || v_id_documento);
    DBMS_OUTPUT.PUT_LINE('Pasajero: ' || v_nombre_pasajero || ' ' || v_apellido_pasajero);
    DBMS_OUTPUT.PUT_LINE('Vuelo: ' || v_numero_vuelo || ' - ' || v_aerolinea);
    DBMS_OUTPUT.PUT_LINE('Origen: ' || v_origen || ' - Destino: ' || v_destino);
    DBMS_OUTPUT.PUT_LINE('Fecha de Salida: ' || TO_CHAR(v_fecha_salida, 'DD-MM-YYYY HH24:MI'));
    DBMS_OUTPUT.PUT_LINE('Fecha de Llegada: ' || TO_CHAR(v_fecha_llegada, 'DD-MM-YYYY HH24:MI'));
    DBMS_OUTPUT.PUT_LINE('Terminal: ' || v_terminal || ' - Puerta: ' || v_puerta);
    DBMS_OUTPUT.PUT_LINE('Asiento: ' || v_asiento);
    DBMS_OUTPUT.PUT_LINE('Clase de Servicio: ' || v_tipo_boleto);
    DBMS_OUTPUT.PUT_LINE('Fecha de Emisión: ' || TO_CHAR(v_fecha_emision, 'DD-MM-YYYY HH24:MI'));
    DBMS_OUTPUT.PUT_LINE('--------------------------');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20025, 'No se encontró el documento de abordaje para el check-in proporcionado.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
