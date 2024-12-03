const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const oracledb = require('oracledb');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(bodyParser.json());

// Configuración del cliente Oracle
oracledb.initOracleClient({ libDir: 'C:\\oracle\\instantclient' });

// Función para obtener la conexión
async function getConnection() {
    try {
        return await oracledb.getConnection({
            user: process.env.DB_USER || 'admin',
            password: process.env.DB_PASSWORD || 'admin',
            connectString: process.env.DB_CONNECTION || 'localhost:1521/xe',
        });
    } catch (err) {
        console.error('Error conectando a Oracle:', err.message);
        throw err;
    }
}

// Ruta para obtener el itinerario del pasajero del procedimiento sp_itinerario_pasajero

app.get('/itinerario/:id_pasajero', async (req, res) => {
    let connection;
    const { id_pasajero } = req.params;

    try {
        connection = await getConnection();
        const result = await connection.execute(
            `BEGIN sp_itinerario_pasajero(:id_pasajero, :o_itinerario); END;`,
            {
                id_pasajero: parseInt(id_pasajero, 10),
                o_itinerario: { type: oracledb.CURSOR, dir: oracledb.BIND_OUT }
            }
        );

        const cursor = result.outBinds.o_itinerario;
        const rows = [];
        let row;

        // Leer las filas del cursor
        while ((row = await cursor.getRow())) {
            rows.push({
                pasajero: row[0],
                dni: row[1],
                boleto: row[2],
                vuelo: row[3],
                fecha_salida: row[4],
                hora_salida: row[5],
                fecha_llegada: row[6],
                hora_llegada: row[7],
                ciudad_origen: row[8],
                ciudad_destino: row[9],
                asiento: row[10],
                terminal: row[11],
                puerta: row[12],
                estado_boleto: row[13],
            });
        }

        await cursor.close();
        res.json(rows);
    } catch (err) {
        console.error('Error ejecutando procedimiento:', err.message);
        res.status(500).json({ error: 'Error ejecutando procedimiento' });
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error('Error cerrando conexión:', err.message);
            }
        }
    }
});

// Ruta POST para realizar check-in

app.post('/checkin', async (req, res) => {
    let connection;
    const { id_boleto, id_vuelo } = req.body;

    try {
        connection = await getConnection();

        // Ejecutar el procedimiento almacenado sp_checkin
        await connection.execute(
            `BEGIN sp_checkin(:p_id_boleto, :p_id_vuelo); END;`,
            {
                p_id_boleto: parseInt(id_boleto, 10),
                p_id_vuelo: parseInt(id_vuelo, 10),
            }
        );

        res.json({
            message: 'Check-in registrado correctamente.',
            id_boleto,
            id_vuelo,
        });
    } catch (err) {
        console.error('Error ejecutando el procedimiento de check-in:', err.message);
        res.status(500).json({
            error: 'Error realizando el check-in.',
            details: err.message,
        });
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error('Error cerrando conexión:', err.message);
            }
        }
    }
});


// Puerto de la aplicación
const port = process.env.PORT || 3001;
app.listen(port, () => {
    console.log(`Servidor corriendo en el puerto ${port}`);
});