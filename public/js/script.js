function checkIn() {
    const idBoleto = document.getElementById('id_boleto').value;
    const nombrePasajero = document.getElementById('nombre_pasajero').value;
    const numPasaporte = document.getElementById('num_pasaporte').value;
    const fechaVuelo = document.getElementById('fecha_vuelo').value;

    fetch('/checkin', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            id_boleto: idBoleto,
            nombre_pasajero: nombrePasajero,
            num_pasaporte: numPasaporte,
            fecha_vuelo: fechaVuelo
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
