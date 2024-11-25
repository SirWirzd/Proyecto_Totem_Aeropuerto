import cx_Oracle
import pandas as pd

# Configuración de conexión
dsn = cx_Oracle.makedsn("localhost", 1521, service_name="xe")
conexion = cx_Oracle.connect(user="admin", password="admin", dsn=dsn)

# Listado de consultas para las tablas principales
consultas = {
    "PAIS": "SELECT * FROM PAIS",
    "AEROPUERTO": "SELECT * FROM AEROPUERTO",
    "TERMINAL_AEROPUERTO": "SELECT * FROM TERMINAL_AEROPUERTO",
    "PUERTA": "SELECT * FROM PUERTA",
    "AEROLINEA": "SELECT * FROM AEROLINEA",
    "AVION": "SELECT * FROM AVION",
    "VUELO": "SELECT * FROM VUELO",
    "PASAJERO": "SELECT * FROM PASAJERO",
    "RESERVA": "SELECT * FROM RESERVA",
    "EQUIPAJE": "SELECT * FROM EQUIPAJE",
    "CHECK_IN": "SELECT * FROM CHECK_IN",
}

# Extracción y escritura en Excel
try:
    with pd.ExcelWriter("datos_totem_checkin.xlsx") as writer:
        for nombre_tabla, consulta in consultas.items():
            df = pd.read_sql(consulta, conexion)
            df.to_excel(writer, sheet_name=nombre_tabla, index=False)
    print("Datos exportados exitosamente a 'datos_totem_checkin.xlsx'")
finally:
     conexion.close()
