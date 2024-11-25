import csv
from faker import Faker
import random
from datetime import datetime, timedelta

# Configuración de Faker
faker = Faker('es_ES')
Faker.seed(12345)
random.seed(12345)

def generar_datos_pais(cantidad=100):
    """
    Genera datos de países asegurando nombres únicos.
    """
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
    """
    Genera datos de aeropuertos asegurando nombres únicos.
    """
    aeropuertos = []
    nombres_generados = set()

    for i, pais in enumerate(paises, start=1):
        id_aeropuerto = i
        while True:
            nombre = f"Aeropuerto {faker.country()} Internacional"
            if nombre not in nombres_generados:
                nombres_generados.add(nombre)
                break
        pais_id = pais[0]
        aeropuertos.append((id_aeropuerto, nombre, pais_id))
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
        nombre_aerolinea = faker.company()[:100]  # Limitar longitud a 100 caracteres
        aerolineas.append((id_aerolinea, nombre_aerolinea))
    return aerolineas

def generar_datos_avion(aerolineas):
    """
    Genera datos de aviones asegurando modelos únicos por aerolínea.
    """
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
    """
    Genera datos de pasajeros asegurando correos electrónicos únicos.
    """
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
        telefono_pasajero = f"+{faker.random_int(1, 999)}{faker.msisdn()[:7]}"  # Prefijo internacional
        documento_identidad = faker.unique.random_int(min=10000000, max=99999999)
        asistencia = random.choice(['Sí', 'No'])
        edad = (datetime.now().year - fecha_nacimiento.year)
        pasajeros.append((id_pasajero, nombre, apellido, fecha_nacimiento, correo_electronico, telefono_pasajero, documento_identidad, asistencia, edad))
    return pasajeros

def generar_datos_equipaje(pasajeros):
    """
    Genera información de equipaje para cada pasajero según el esquema SQL.
    Cada pasajero puede tener uno o más equipajes asociados.
    """
    equipajes = []
    tipos_equipaje = ['Mano', 'De Bodega']  # Alineado con los valores permitidos en SQL
    
    for pasajero in pasajeros:
        id_pasajero = pasajero[0]
        cantidad_equipajes = random.randint(1, 3)  # Cada pasajero puede tener de 1 a 3 equipajes
        for i in range(cantidad_equipajes):
            id_equipaje = len(equipajes) + 1
            tipo = random.choice(tipos_equipaje)
            peso = round(random.uniform(5, 32), 2)  # Peso en kg
            alto = random.randint(30, 80)  # Altura en cm
            ancho = random.randint(20, 60)  # Ancho en cm
            profundidad = random.randint(10, 50)  # Profundidad en cm
            descripcion = f"Equipaje {tipo.lower()} de {peso} kg"
            cobro_extra = 0 if tipo == 'Mano' else random.choice([0, 50, 100])  # Cobro extra solo para equipaje de bodega
            
            equipajes.append((id_equipaje, id_pasajero, tipo, peso, descripcion, alto, ancho, profundidad, cobro_extra))
    
    return equipajes

def generar_datos_asiento(vuelos):
    """
    Genera datos de asientos asegurando números únicos por vuelo.
    """
    asientos = []
    numeros_asiento_generados = {}

    for vuelo in vuelos:
        id_vuelo = vuelo[0]
        if id_vuelo not in numeros_asiento_generados:
            numeros_asiento_generados[id_vuelo] = set()
        for i in range(1, random.randint(20, 50)):
            while True:
                numero_asiento = f"{id_vuelo}-{i:02d}"
                if numero_asiento not in numeros_asiento_generados[id_vuelo]:
                    numeros_asiento_generados[id_vuelo].add(numero_asiento)
                    break
            id_asiento = len(asientos) + 1
            estado = random.choice(['Disponible', 'No disponible'])
            tipo = random.choice(['Económico', 'Ejecutivo', 'Primera Clase'])
            asientos.append((id_asiento, id_vuelo, estado, tipo, numero_asiento))
    return asientos

def generar_datos_reserva(pasajeros, vuelos, asientos):
    reservas = []
    for pasajero in pasajeros:
        id_reserva = len(reservas) + 1
        id_pasajero = pasajero[0]
        id_vuelo = random.choice(vuelos)[0]
        numero_asiento = random.choice([a[4] for a in asientos if a[1] == id_vuelo])
        fecha_hora_reserva = faker.date_time_this_year(before_now=True, after_now=False)
        motivo_viaje = random.choice(['Turismo', 'Negocios', 'Estudio', 'Trabajo'])
        tipo_boleto = random.choice(['Económico', 'Ejecutivo', 'Primera Clase'])
        estado = random.choice(['Confirmada', 'Cancelado', 'Pendiente'])
        reservas.append((id_reserva, id_pasajero, id_vuelo, numero_asiento, fecha_hora_reserva, motivo_viaje, tipo_boleto, estado))
    return reservas

def generar_datos_check_in(reservas):
    check_in = []
    for reserva in reservas:
        id_check_in = reserva[0]
        id_reserva = reserva[0]
        fecha_hora_check_in = reserva[4] + timedelta(hours=1)
        estado = random.choice(['Completado', 'Cancelado', 'Pendiente'])
        tipo_check_in = random.choice(['Presencial', 'Online'])
        check_in.append((id_check_in, id_reserva, fecha_hora_check_in, estado, tipo_check_in))
    return check_in

# Exportar datos
def exportar_a_csv(nombre_archivo, datos, columnas):
    with open(nombre_archivo, mode='w', newline='', encoding='utf-8-sig') as archivo_csv:  # Cambiar a utf-8-sig
        escritor = csv.writer(archivo_csv)
        escritor.writerow(columnas)
        escritor.writerows(datos)


# Ejecución principal
if __name__ == "__main__":
    # Generación de datos
    datos_pais = generar_datos_pais()
    datos_aeropuerto = generar_datos_aeropuerto(datos_pais)
    datos_terminal_aeropuerto = generar_datos_terminal_aeropuerto(datos_aeropuerto)
    datos_puerta = generar_datos_puerta(datos_terminal_aeropuerto)
    datos_aerolinea = generar_datos_aerolinea()
    datos_avion = generar_datos_avion(datos_aerolinea)
    datos_vuelo = generar_datos_vuelo(datos_aeropuerto, datos_avion)
    datos_pasajero = generar_datos_pasajero()
    datos_asiento = generar_datos_asiento(datos_vuelo)
    datos_reserva = generar_datos_reserva(datos_pasajero, datos_vuelo, datos_asiento)
    datos_check_in = generar_datos_check_in(datos_reserva)
    datos_equipaje = generar_datos_equipaje(datos_reserva)

    # Exportación de datos
    exportar_a_csv("pais.csv", datos_pais, ["id_pais", "nombre", "visa_requerida", "tipo_visa", "pasaporte_requerido"])
    exportar_a_csv("aeropuerto.csv", datos_aeropuerto, ["id_aeropuerto", "nombre", "pais_id"])
    exportar_a_csv("terminal_aeropuerto.csv", datos_terminal_aeropuerto, ["id_terminal", "nombre", "id_aeropuerto"])
    exportar_a_csv("puerta.csv", datos_puerta, ["id_puerta", "nombre", "id_terminal"])
    exportar_a_csv("aerolinea.csv", datos_aerolinea, ["id_aerolinea", "nombre_aerolinea"])
    exportar_a_csv("avion.csv", datos_avion, ["id_avion", "modelo", "capacidad", "id_aerolinea"])
    exportar_a_csv("vuelo.csv", datos_vuelo, ["id_vuelo", "id_aerolinea", "id_avion", "id_aeropuerto_origen", "id_aeropuerto_destino", "fecha_hora_salida", "fecha_hora_llegada", "duracion", "distancia", "estado"])
    exportar_a_csv("pasajero.csv", datos_pasajero, ["id_pasajero", "nombre", "apellido", "fecha_nacimiento", "correo_electronico", "telefono_pasajero", "documento_identidad", "asistencia", "edad"])
    exportar_a_csv("asiento.csv", datos_asiento, ["id_asiento", "id_vuelo", "estado", "tipo", "numero_asiento"])
    exportar_a_csv("reserva.csv", datos_reserva, ["id_reserva", "id_pasajero", "id_vuelo", "numero_asiento", "fecha_hora_reserva", "motivo_viaje", "tipo_boleto", "estado"])
    exportar_a_csv("check_in.csv", datos_check_in, ["id_check_in", "id_reserva", "fecha_hora_check_in", "estado", "tipo_check_in"])
    exportar_a_csv("equipaje.csv", datos_equipaje, ["id_equipaje", "id_pasajero", "tipo_equipaje", "peso","descripcion", "alto", "ancho", "profundidad", "cobro_extra"])


    print("Archivos CSV generados correctamente.")
