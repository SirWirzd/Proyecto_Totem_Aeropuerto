import cx_Oracle
from faker import Faker
import random
from datetime import datetime, timedelta

# Configuración de Faker
faker = Faker('es_ES')
Faker.seed(12345)
random.seed(12345)

# Función genérica para insertar datos
def insertar_datos_oracle(conexion, consulta, datos):
    cursor = conexion.cursor()
    try:
        cursor.executemany(consulta, datos)
        conexion.commit()
        print(f"Datos insertados correctamente en: {consulta.split()[2]}")
    except cx_Oracle.DatabaseError as e:
        print(f"Error al insertar datos: {e}")
        conexion.rollback()
    finally:
        cursor.close()

# Funciones para generar datos
def generar_datos_pais(cantidad=100):
    paises = []
    nombres_generados = set()
    for i in range(1, cantidad + 1):
        id_pais = i
        while True:
            nombre = faker.country()
            if nombre not in nombres_generados:
                nombres_generados.add(nombre)
                break
        visa_requerida = random.choice(['Sí', 'No'])
        pasaporte_requerido = 'Sí' if visa_requerida == 'Sí' else random.choice(['Sí', 'No'])
        tipo_visa = random.choice(['Turismo', 'Negocios', 'Estudio', 'Trabajo']) if visa_requerida == 'Sí' else None
        paises.append((id_pais, nombre, visa_requerida, tipo_visa or '', pasaporte_requerido))
    return paises

def generar_datos_aeropuerto(paises):
    aeropuertos = []
    nombres_generados = set()
    for i, pais in enumerate(paises, start=1):
        id_aeropuerto = i
        while True:
            nombre = f"Aeropuerto {faker.city()} Internacional"
            if nombre not in nombres_generados:
                nombres_generados.add(nombre)
                break
        id_pais = pais[0]
        aeropuertos.append((id_aeropuerto, nombre, id_pais))
    return aeropuertos

def generar_datos_terminal_aeropuerto(aeropuertos):
    terminales = []
    for i, aeropuerto in enumerate(aeropuertos, start=1):
        id_terminal = i
        nombre = f"Terminal {random.randint(1, 5)}"
        id_aeropuerto = aeropuerto[0]
        terminales.append((id_terminal, nombre, id_aeropuerto))
    return terminales

def generar_datos_puerta(terminales):
    puertas = []
    for i, terminal in enumerate(terminales, start=1):
        id_puerta = i
        nombre = f"Puerta {random.randint(1, 20)}"
        id_terminal = terminal[0]
        puertas.append((id_puerta, nombre, id_terminal))
    return puertas

def generar_datos_aerolinea(cantidad=10):
    aerolineas = []
    for i in range(1, cantidad + 1):
        id_aerolinea = i
        nombre_aerolinea = faker.company()[:100]
        aerolineas.append((id_aerolinea, nombre_aerolinea))
    return aerolineas

def generar_datos_avion(aerolineas):
    aviones = []
    modelos_generados = set()
    modelos = ['Boeing 737', 'Airbus A320', 'Boeing 787', 'Embraer E190', 'Airbus A330']
    for i, aerolinea in enumerate(aerolineas, start=1):
        id_avion = i
        while True:
            modelo = random.choice(modelos)
            if (modelo, aerolinea[0]) not in modelos_generados:
                modelos_generados.add((modelo, aerolinea[0]))
                break
        capacidad = random.randint(100, 300)
        id_aerolinea = aerolinea[0]
        aviones.append((id_avion, modelo, capacidad, id_aerolinea))
    return aviones

def generar_datos_vuelo(aeropuertos, aviones):
    vuelos = []
    for i, avion in enumerate(aviones, start=1):
        id_vuelo = i
        id_aerolinea = avion[3]
        id_avion = avion[0]
        id_aeropuerto_origen = random.choice(aeropuertos)[0]
        id_aeropuerto_destino = random.choice([a[0] for a in aeropuertos if a[0] != id_aeropuerto_origen])
        fecha_hora_salida = faker.date_time_this_year(before_now=False, after_now=True)
        fecha_hora_llegada = fecha_hora_salida + timedelta(hours=random.randint(1, 10))
        duracion = (fecha_hora_llegada - fecha_hora_salida).seconds // 60
        distancia = random.randint(500, 5000)
        estado = random.choice(['Programado', 'En vuelo', 'Aterrizado', 'Cancelado'])
        vuelos.append((id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, fecha_hora_salida, fecha_hora_llegada, duracion, distancia, estado))
    return vuelos

def generar_datos_pasajero(cantidad=1000):
    pasajeros = []
    correos_generados = set()
    for i in range(1, cantidad + 1):
        id_pasajero = i
        nombre = faker.first_name()
        apellido = faker.last_name()
        fecha_nacimiento = faker.date_of_birth(minimum_age=18, maximum_age=70)
        while True:
            correo_electronico = faker.email()
            if correo_electronico not in correos_generados:
                correos_generados.add(correo_electronico)
                break
        telefono_pasajero = faker.phone_number()
        documento_identidad = faker.unique.random_int(min=10000000, max=99999999)
        pasajeros.append((id_pasajero, nombre, apellido, fecha_nacimiento, correo_electronico, telefono_pasajero, documento_identidad))
    return pasajeros

def generar_datos_reserva(pasajeros, vuelos):
    reservas = []
    for i, pasajero in enumerate(pasajeros[:100], start=1):
        id_reserva = i
        id_pasajero = pasajero[0]
        id_vuelo = random.choice(vuelos)[0]
        fecha_hora_reserva = faker.date_time_this_year(before_now=True, after_now=False)
        motivo_viaje = random.choice(['Negocios', 'Vacaciones'])
        tipo_boleto = random.choice(['Económico', 'Ejecutivo', 'Primera Clase'])
        estado = random.choice(['Confirmado', 'Pendiente', 'Cancelado'])
        reservas.append((id_reserva, id_pasajero, id_vuelo, fecha_hora_reserva, motivo_viaje, tipo_boleto, estado))
    return reservas

def generar_datos_equipaje(reservas):
    equipajes = []
    for i, reserva in enumerate(reservas, start=1):
        id_equipaje = i
        id_reserva = reserva[0]
        tipo_equipaje = random.choice(['Mano', 'Bodega'])
        peso = random.uniform(5, 30)
        descripcion = f"Equipaje {tipo_equipaje.lower()} de {peso:.2f} kg"
        cobro_extra = 0 if tipo_equipaje == 'Mano' else random.randint(0, 50)
        equipajes.append((id_equipaje, id_reserva, tipo_equipaje, peso, descripcion, cobro_extra))
    return equipajes

def generar_datos_check_in(reservas):
    check_in = []
    for i, reserva in enumerate(reservas, start=1):
        id_check_in = i
        id_reserva = reserva[0]
        fecha_hora_check_in = reserva[3] + timedelta(hours=random.randint(1, 24))
        estado = random.choice(['Completado', 'Pendiente', 'Cancelado'])
        tipo_check_in = random.choice(['Online', 'Presencial'])
        check_in.append((id_check_in, id_reserva, fecha_hora_check_in, estado, tipo_check_in))
    return check_in

# Conexión a Oracle
dsn = cx_Oracle.makedsn("localhost", 1521, service_name="xe")
conexion = cx_Oracle.connect(user="admin", password="admin", dsn=dsn)

try:
    # Generar datos
    datos_pais = generar_datos_pais()
    datos_aeropuerto = generar_datos_aeropuerto(datos_pais)
    datos_terminal_aeropuerto = generar_datos_terminal_aeropuerto(datos_aeropuerto)
    datos_puerta = generar_datos_puerta(datos_terminal_aeropuerto)
    datos_aerolinea = generar_datos_aerolinea()
    datos_avion = generar_datos_avion(datos_aerolinea)
    datos_vuelo = generar_datos_vuelo(datos_aeropuerto, datos_avion)
    datos_pasajero = generar_datos_pasajero()
    datos_reserva = generar_datos_reserva(datos_pasajero, datos_vuelo)
    datos_equipaje = generar_datos_equipaje(datos_reserva)
    datos_check_in = generar_datos_check_in(datos_reserva)

    # Insertar datos en la base de datos
    insertar_datos_oracle(conexion, """
        INSERT INTO PAIS (id_pais, nombre, visa_requerida, tipo_visa, pasaporte_requerido)
        VALUES (:1, :2, :3, :4, :5)
    """, datos_pais)

    insertar_datos_oracle(conexion, """
        INSERT INTO AEROPUERTO (id_aeropuerto, nombre, id_pais)
        VALUES (:1, :2, :3)
    """, datos_aeropuerto)

    insertar_datos_oracle(conexion, """
        INSERT INTO TERMINAL_AEROPUERTO (id_terminal, nombre, id_aeropuerto)
        VALUES (:1, :2, :3)
    """, datos_terminal_aeropuerto)

    insertar_datos_oracle(conexion, """
        INSERT INTO PUERTA (id_puerta, nombre, id_terminal)
        VALUES (:1, :2, :3)
    """, datos_puerta)

    insertar_datos_oracle(conexion, """
        INSERT INTO AEROLINEA (id_aerolinea, nombre_aerolinea)
        VALUES (:1, :2)
    """, datos_aerolinea)

    insertar_datos_oracle(conexion, """
        INSERT INTO AVION (id_avion, modelo, capacidad, id_aerolinea)
        VALUES (:1, :2, :3, :4)
    """, datos_avion)

    insertar_datos_oracle(conexion, """
        INSERT INTO VUELO (id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, 
        fecha_hora_salida, fecha_hora_llegada, duracion, distancia, estado)
        VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10)
    """, datos_vuelo)

    insertar_datos_oracle(conexion, """
        INSERT INTO PASAJERO (id_pasajero, nombre, apellido, fecha_nacimiento, correo_electronico, telefono_pasajero, documento_identidad)
        VALUES (:1, :2, :3, :4, :5, :6, :7)
    """, datos_pasajero)

    insertar_datos_oracle(conexion, """
        INSERT INTO RESERVA (id_reserva, id_pasajero, id_vuelo, fecha_hora_reserva, motivo_viaje, tipo_boleto, estado)
        VALUES (:1, :2, :3, :4, :5, :6, :7)
    """, datos_reserva)

    insertar_datos_oracle(conexion, """
        INSERT INTO EQUIPAJE (id_equipaje, id_reserva, tipo_equipaje, peso, descripcion, cobro_extra)
        VALUES (:1, :2, :3, :4, :5, :6)
    """, datos_equipaje)

    insertar_datos_oracle(conexion, """
        INSERT INTO CHECK_IN (id_check_in, id_reserva, fecha_hora_check_in, estado, tipo_check_in)
        VALUES (:1, :2, :3, :4, :5)
    """, datos_check_in)

    print("Todos los datos se insertaron correctamente.")

except Exception as e:
    print(f"Error general: {e}")
finally:
    conexion.close()
