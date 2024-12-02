import csv
from faker import Faker
import random
from datetime import datetime, timedelta
import pandas as pd

# Configuración de Faker
faker = Faker('es_ES')
Faker.seed(12345)
random.seed(12345)

def generar_datos():
    # Datos de país
    paises = []
    nombres_paises = set()
    for i in range(1, 11):
        id_pais = i
        while True:
            nombre = faker.country()
            if nombre not in nombres_paises:
                nombres_paises.add(nombre)
                break
        visa_requerida = random.choice(['Sí', 'No'])
        pasaporte_requerido = 'Sí' if visa_requerida == 'Sí' else random.choice(['Sí', 'No'])
        tipo_visa = random.choice(['Turismo', 'Negocios', 'Estudio', 'Trabajo']) if visa_requerida == 'Sí' else ''
        paises.append((id_pais, nombre, visa_requerida, tipo_visa, pasaporte_requerido))

    # Datos de aeropuertos
    aeropuertos = []
    nombres_aeropuertos = set()
    for i, pais in enumerate(paises, start=1):
        id_aeropuerto = i
        while True:
            nombre = f"Aeropuerto {faker.city()} Internacional"
            if nombre not in nombres_aeropuertos:
                nombres_aeropuertos.add(nombre)
                break
        aeropuertos.append((id_aeropuerto, nombre, pais[0]))

    # Datos de aerolíneas
    aerolineas = [(i, faker.company()[:100]) for i in range(1, 6)]

    # Datos de aviones
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
        aviones.append((id_avion, modelo, capacidad, aerolinea[0]))

    # Datos de vuelos
    vuelos = []
    for i, avion in enumerate(aviones, start=1):
        id_vuelo = i
        id_aerolinea = avion[3]
        id_aeropuerto_origen = random.choice(aeropuertos)[0]
        id_aeropuerto_destino = random.choice([a[0] for a in aeropuertos if a[0] != id_aeropuerto_origen])
        fecha_hora_salida = faker.date_time_this_year(before_now=False, after_now=True)
        fecha_hora_llegada = fecha_hora_salida + timedelta(hours=random.randint(1, 10))
        duracion = (fecha_hora_llegada - fecha_hora_salida).seconds // 60
        distancia = random.randint(500, 5000)
        estado = random.choice(['Programado', 'En vuelo', 'Aterrizado', 'Cancelado'])
        vuelos.append((id_vuelo, id_aerolinea, avion[0], id_aeropuerto_origen, id_aeropuerto_destino,
                       fecha_hora_salida, fecha_hora_llegada, duracion, distancia, estado))

    # Datos de pasajeros
    pasajeros = []
    correos_generados = set()
    for i in range(1, 51):
        id_pasajero = i
        nombre = faker.first_name()
        apellido = faker.last_name()
        fecha_nacimiento = faker.date_of_birth(minimum_age=18, maximum_age=70)
        while True:
            correo = faker.email()
            if correo not in correos_generados:
                correos_generados.add(correo)
                break
        telefono = f"+{faker.random_int(1, 999)}{faker.msisdn()[:7]}"
        documento = faker.unique.random_int(min=10000000, max=99999999)
        asistencia = random.choice(['Sí', 'No'])
        edad = datetime.now().year - fecha_nacimiento.year
        pasajeros.append((id_pasajero, nombre, apellido, fecha_nacimiento, correo, telefono, documento, asistencia, edad))

    # Consolidar todo en un DataFrame para un archivo CSV único
    data_consolidada = []
    for vuelo in vuelos:
        id_vuelo, id_aerolinea, id_avion, id_aeropuerto_origen, id_aeropuerto_destino, fecha_hora_salida, fecha_hora_llegada, duracion, distancia, estado = vuelo
        for pasajero in pasajeros:
            id_pasajero, nombre, apellido, fecha_nacimiento, correo, telefono, documento, asistencia, edad = pasajero
            data_consolidada.append({
                'ID_Vuelo': id_vuelo,
                'Aerolínea': [a[1] for a in aerolineas if a[0] == id_aerolinea][0],
                'Aeropuerto_Origen': [a[1] for a in aeropuertos if a[0] == id_aeropuerto_origen][0],
                'Aeropuerto_Destino': [a[1] for a in aeropuertos if a[0] == id_aeropuerto_destino][0],
                'Fecha_Salida': fecha_hora_salida,
                'Fecha_Llegada': fecha_hora_llegada,
                'Duración': duracion,
                'Distancia': distancia,
                'Estado_Vuelo': estado,
                'Pasajero': f"{nombre} {apellido}",
                'Correo': correo,
                'Teléfono': telefono,
                'Documento': documento,
                'Asistencia': asistencia,
                'Edad': edad
            })

    df = pd.DataFrame(data_consolidada)
    df.to_csv('datos_consolidados.csv', index=False, encoding='utf-8')
    print("Archivo consolidado generado: datos_consolidados.csv")

if __name__ == "__main__":
    generar_datos()
