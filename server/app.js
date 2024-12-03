const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const path = require('path');
const oracledb = require('oracledb'); // Usamos oracledb para conectar con Oracle

// Configuración de bodyParser para manejar datos JSON
app.use(bodyParser.json());

// Servir archivos estáticos desde la carpeta 'public' en el directorio raíz
app.use(express.static(path.join(__dirname, '..', 'public')));

// Configuración de conexión a la base de datos Oracle
const dbConfig = {
    user: 'tu_usuario',         // Cambia al usuario de tu base de datos
    password: 'tu_contraseña',  // Cambia a tu contraseña
    connectString: 'localhost:1521/tu_base_de_datos' // Cambia según tu configuración de Oracle
};

// Ruta GET para la página principal (index.html)
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '..', 'public', 'index.html'));  // Ruta correcta al archivo HTML
});

// Ruta POST para el check-in
app.post('/checkin', (req, res) => {
    const { id_boleto, nombre_pasajero, num_pasaporte, fecha_vuelo } = req.body;

    // Formatear la fecha de vuelo (sin moment.js)
    const fechaVueloFormateada = new Date(fecha_vuelo).toISOString().slice(0, 19).replace('T', ' ');

    // Conectar a la base de datos y ejecutar la consulta
    oracledb.getConnection(dbConfig, (err, connection) => {
        if (err) {
            console.error('Error al conectar con la base de datos:', err);
            return res.status(500).json({ success: false, mensaje: 'Error al conectar a la base de datos' });
        }

        const query = `
            SELECT * FROM vuelos
            WHERE id_boleto = :id_boleto
            AND nombre_pasajero = :nombre_pasajero
            AND num_pasaporte = :num_pasaporte
            AND fecha_vuelo = TO_TIMESTAMP(:fecha_vuelo, 'YYYY-MM-DD HH24:MI:SS')
        `;

        connection.execute(query, {
            id_boleto: id_boleto,
            nombre_pasajero: nombre_pasajero,
            num_pasaporte: num_pasaporte,
            fecha_vuelo: fechaVueloFormateada
        }, { outFormat: oracledb.OUT_FORMAT_OBJECT }, (err, result) => {
            if (err) {
                console.error('Error en la consulta:', err);
                return res.status(500).json({ success: false, mensaje: 'Error al consultar la base de datos' });
            }

            if (result.rows.length > 0) {
                // Si se encuentra el vuelo, devolver los detalles
                return res.json({
                    success: true,
                    vuelo: result.rows[0]
                });
            } else {
                // Si no se encuentra el vuelo
                return res.json({ success: false, mensaje: 'No se encontraron datos para el check-in con la información ingresada.' });
            }
        });
    });
});

// Iniciar el servidor en el puerto 3000
app.listen(3000, () => {
    console.log('Servidor corriendo en http://localhost:3000');
});
