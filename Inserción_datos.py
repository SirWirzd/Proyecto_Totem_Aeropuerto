import cx_Oracle
import random
import string
from datetime import datetime, timedelta

# Configuración de conexión a Oracle
dsn = cx_Oracle.makedsn("localhost", 1521, service_name="XE")
connection = cx_Oracle.connect(user="admin", password="admin", dsn=dsn)

# Crear cursor de conexión

cursor = connection.cursor()

# Select de testeo

cursor.execute("SELECT * FROM AEROLINEA")
for row in cursor.fetchall():
    print(row)


# Generar datos simulados para la tabla VUELO
def generar_vuelos(numero_vuelos):
    # Obtener IDs necesarios de tablas relacionadas
    cursor.execute("SELECT id_aerolinea FROM AEROLINEA")
    aerolineas = [row[0] for row in cursor.fetchall()]
    
    cursor.execute("SELECT id_terminal FROM TERMINAL_PUERTA")
    terminales = [row[0] for row in cursor.fetchall()]
    
    cursor.execute("SELECT id_puerta FROM PUERTA")
    puertas = [row[0] for row in cursor.fetchall()]
    
    cursor.execute("SELECT id_aeropuerto FROM AEROPUERTO")
    aeropuertos = [row[0] for row in cursor.fetchall()]
    
    cursor.execute("SELECT id_avion FROM AVION")
    aviones = [row[0] for row in cursor.fetchall()]
    
    cursor.execute("SELECT id_estado FROM ESTADO")
    estados = [row[0] for row in cursor.fetchall()]
    
    vuelos_insertados = 0
    while vuelos_insertados < numero_vuelos:
        id_vuelo = vuelos_insertados + 1
        id_aerolinea = random.choice(aerolineas)
        id_avion = random.choice(aviones)
        id_terminal = random.choice(terminales)
        id_puerta = random.choice(puertas)
        id_estado = random.choice(estados)
        id_aeropuerto_origen, id_aeropuerto_destino = random.sample(aeropuertos, 2)
        
        fecha_salida = datetime.now() + timedelta(days=random.randint(1, 30), hours=random.randint(0, 23))
        fecha_llegada = fecha_salida + timedelta(hours=random.randint(1, 10))  # Duración del vuelo entre 1 y 10 horas
        
        # Insertar datos en la tabla VUELO
        try:
            cursor.execute("""
                INSERT INTO VUELO (
                    id_vuelo, id_aerolinea, fecha_salida, fecha_llegada, id_estado,
                    id_avion, id_terminal, id_puerta, id_aeropuerto_origen, id_aeropuerto_destino
                ) VALUES (
                    :id_vuelo, :id_aerolinea, :fecha_salida, :fecha_llegada, :id_estado,
                    :id_avion, :id_terminal, :id_puerta, :id_aeropuerto_origen, :id_aeropuerto_destino
                )
            """, {
                "id_vuelo": id_vuelo,
                "id_aerolinea": id_aerolinea,
                "fecha_salida": fecha_salida,
                "fecha_llegada": fecha_llegada,
                "id_estado": id_estado,
                "id_avion": id_avion,
                "id_terminal": id_terminal,
                "id_puerta": id_puerta,
                "id_aeropuerto_origen": id_aeropuerto_origen,
                "id_aeropuerto_destino": id_aeropuerto_destino,
            })
            connection.commit()
            print(f"Vuelo {id_vuelo} insertado correctamente.")
            vuelos_insertados += 1
        except cx_Oracle.IntegrityError as e:
            print(f"Error al insertar el vuelo {id_vuelo}: {e}")
        except Exception as e:
            print(f"Error inesperado: {e}")

# Llamar a la función para generar datos
generar_vuelos(2)

# Cerrar la conexión
cursor.close()
connection.close()