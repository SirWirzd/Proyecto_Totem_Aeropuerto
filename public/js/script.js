function checkIn() {
    const idBoleto = document.getElementById('id_boleto').value;
    const nombrePasajero = document.getElementById('nombre_pasajero').value;
    const numPasaporte = document.getElementById('num_pasaporte').value;
    const fechaVuelo = document.getElementById('fecha_vuelo').value;

    // Verificar si la fecha de vuelo está vacía
    if (!fechaVuelo) {
        alert("Por favor, ingrese una fecha y hora del vuelo.");
        return;
    }

    // Convertir la fecha y hora al formato 'YYYY-MM-DD HH:MM:SS'
    const fechaParts = fechaVuelo.split('T'); // Separar la fecha y la hora
    const fecha = fechaParts[0]; // 'YYYY-MM-DD'
    const hora = fechaParts[1]; // 'HH:MM'
    const fechaVueloFormateada = `${fecha} ${hora}:00`; // Agregar los segundos como '00'

    // Enviar los datos al servidor
    fetch('/checkin', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            id_boleto: idBoleto,
            nombre_pasajero: nombrePasajero,
            num_pasaporte: numPasaporte,
            fecha_vuelo: fechaVueloFormateada // Enviamos la fecha formateada
        })
    })
    .then(response => response.json())
    .then(data => {
        const resultDiv = document.getElementById('result');
        if (data.success) {
            resultDiv.innerHTML = `
                <h2>Datos del Vuelo</h2>
                <table>
                    <tr><th>ID Vuelo</th><td>${data.vuelo.id_vuelo}</td></tr>
                    <tr><th>Aerolínea</th><td>${data.vuelo.nombre_aerolinea}</td></tr>
                    <tr><th>Fecha Salida</th><td>${data.vuelo.fecha_salida}</td></tr>
                    <tr><th>Fecha Llegada</th><td>${data.vuelo.fecha_llegada}</td></tr>
                </table>`;
        } else {
            resultDiv.innerHTML = `<p>No se encontraron datos para el check-in con la información ingresada.</p>`;
        }
    })
    .catch(() => {
        document.getElementById('result').innerHTML = `<p>Error al realizar la solicitud.</p>`;
    });
}

