import cx_Oracle
from faker import Faker
import random

# Configuración de Faker para generar datos en español
faker = Faker('es_ES')

# Establecer semilla para Faker y random
SEED = 12345
Faker.seed(SEED)
random.seed(SEED)

# Configuración de la conexión a Oracle
dsn_tns = cx_Oracle.makedsn("localhost", 1521, service_name="xe")  # Cambia por tu configuración
connection = cx_Oracle.connect(user="usuario", password="contraseña", dsn=dsn_tns)
cursor = connection.cursor()

# Generación de datos ficticios
def generar_datos_pais():
    paises = []
    for _ in range(100):  # Generar 100 países
        id_pais = faker.random_int(min=1, max=10000)
        nombre = faker.country()
        visa_requerida = random.choice(['Sí', 'No'])
        tipo_visa = random.choice(['Turismo', 'Negocios', 'Estudio', 'Trabajo']) if visa_requerida == 'Sí' else None
        pasaporte_requerido = random.choice(['Sí', 'No'])
        paises.append((id_pais, nombre, visa_requerida, tipo_visa, pasaporte_requerido))
    return paises

def generar_datos_aeropuerto(paises):
    aeropuertos = []
    for i in range(100):  # Generar 10 aeropuertos
        id_aeropuerto = i + 1
        nombre = f"Aeropuerto {faker.city()} Internacional"
        pais = random.choice(paises)[1]  # Seleccionar un país existente
        visa_requerida = random.choice(['Sí', 'No'])
        tipo_visa = random.choice(['Turismo', 'Negocios', 'Estudio', 'Trabajo']) if visa_requerida == 'Sí' else None
        pasaporte_requerido = random.choice(['Sí', 'No'])
        aeropuertos.append((id_aeropuerto, nombre, pais, visa_requerida, tipo_visa, pasaporte_requerido))
    return aeropuertos

def generar_datos_avion():
    aviones = []
    modelos = ['Boeing 737', 'Airbus A320', 'Boeing 787', 'Embraer E190', 'Airbus A330']
    for i in range(100):  # Generar 100 aviones
        id_avion = i + 1
        modelo = random.choice(modelos)
        capacidad = random.randint(100, 300)
        id_aerolinea = random.randint(1, 100)
        aviones.append((id_avion, modelo, capacidad, id_aerolinea))
    return aviones

def generar_datos_vuelo(aeropuertos):
    vuelos = []
    for i in range(10):  # Generar 10 vuelos
        id_vuelo = i + 1
        id_aerolinea = random.randint(1, 100)
        id_avion = random.randint(1, 1000)
        origen = random.choice(aeropuertos)[0]
        destino = random.choice([a[0] for a in aeropuertos if a[0] != origen])
        fecha_salida = faker.date_time_this_year(before_now=False, after_now=True)
        fecha_llegada = faker.date_time_between_dates(datetime_start=fecha_salida, datetime_end=fecha_salida.replace(hour=fecha_salida.hour + 5))
        duracion = (fecha_llegada - fecha_salida).seconds // 60
        distancia = random.randint(500, 5000)
        estado = random.choice(['Programado', 'En vuelo', 'Aterrizado', 'Cancelado'])
        vuelos.append((id_vuelo, id_aerolinea, id_avion, origen, destino, fecha_salida, fecha_llegada, duracion, distancia, estado))
    return vuelos

# Inserción de datos en las tablas
try:
    # Generar datos
    datos_pais = generar_datos_pais()
    datos_aeropuerto = generar_datos_aeropuerto(datos_pais)
    datos_avion = generar_datos_avion()
    datos_vuelo = generar_datos_vuelo(datos_aeropuerto)

    # Tabla PAIS
    cursor.executemany("""
        INSERT INTO PAIS (id_pais, nombre, visa_requerida, tipo_visa, pasaporte_requerido)
        VALUES (:1, :2, :3, :4, :5)
    """, datos_pais)

    # Tabla AEROPUERTO
    cursor.executemany("""
        INSERT INTO AEROPUERTO (id_aeropuerto, nombre, ciudad, pais, visa_requerida, tipo_visa, pasaporte_requerido)
        VALUES (:1, :2, :3, :4, :5, :6, :7)
    """, datos_aeropuerto)

    # Tabla AVION
    cursor.executemany("""
        INSERT INTO AVION (id_avion, modelo, capacidad, id_aerolinea)
        VALUES (:1, :2, :3, :4)
    """, datos_avion)

    # Tabla VUELO
    cursor.executemany("""
        INSERT INTO VUELO (id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, 
        fecha_hora_salida, fecha_hora_llegada, duracion, distancia, estado)
        VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10)
    """, datos_vuelo)

    # Confirmar los cambios
    connection.commit()
    print("Datos insertados correctamente.")

except cx_Oracle.DatabaseError as e:
    error, = e.args
    print("Error al insertar datos:", error.message)
    connection.rollback()

finally:
    # Cerrar conexión
    cursor.close()
    connection.close()
