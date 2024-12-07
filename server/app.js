const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const path = require('path');
const oracledb = require('oracledb');

// Configuración de bodyParser para manejar datos JSON
app.use(bodyParser.json());

// Servir archivos estáticos desde la carpeta 'public'
app.use(express.static(path.join(__dirname, '..', 'public')));

// Configuración de conexión a Oracle
const dbConfig = {
    user: 'ARTURO',
    password: 'ARTURO',
    connectString: 'localhost:1521/tu_base_de_datos' // Ajusta esta configuración según tu base de datos Oracle
};

// Ruta principal para servir el frontend (React)
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '..', 'public', 'index.html'));
});

// Ruta POST para el check-in usando un procedimiento almacenado
app.post('/checkin', async (req, res) => {
    const { identificador, tipo_identificador, id_vuelo } = req.body;
    let connection;

    try {
        connection = await oracledb.getConnection(dbConfig);

        // Llama al procedimiento almacenado para el check-in
        const result = await connection.execute(
            `
            BEGIN
                sp_checkin(:identificador, :tipo_identificador, :id_vuelo);
            END;
            `,
            {
                identificador,
                tipo_identificador,
                id_vuelo: parseInt(id_vuelo, 10),
            },
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );

        res.json({
            success: true,
            message: 'Check-in registrado correctamente.',
            data: result,
        });
    } catch (err) {
        console.error('Error ejecutando el procedimiento de check-in:', err);
        res.status(500).json({
            success: false,
            message: 'Error realizando el check-in.',
            details: err.message,
        });
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error('Error cerrando conexión:', err);
            }
        }
    }
});

// Iniciar el servidor en el puerto 3000
app.listen(3000, () => {
    console.log('Servidor corriendo en http://localhost:3000');
});
