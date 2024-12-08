const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const oracledb = require('oracledb');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(bodyParser.json());

// Configuración del cliente Oracle
try {
    oracledb.initOracleClient({ libDir: 'C:\\oraclexe\\instantclient_21_15' });
    console.log('Cliente Oracle inicializado correctamente.');
} catch (err) {
    console.error('Error inicializando cliente Oracle:', err.message);
    process.exit(1);
}

// Función para obtener la conexión
async function getConnection() {
    try {
        return await oracledb.getConnection({
            user: process.env.DB_USER || 'admin',
            password: process.env.DB_PASSWORD || 'admin',
            connectString: process.env.DB_CONNECTION || 'localhost:1521/xe',
        });
    } catch (err) {
        console.error('Error obteniendo conexión:', err.message);
        throw err;
    }
}

// Ruta para obtener el itinerario del pasajero
app.get('/itinerario/:id_pasajero', async (req, res) => {
    let connection;
    const { id_pasajero } = req.params;

    if (!id_pasajero || isNaN(id_pasajero) || parseInt(id_pasajero, 10) <= 0) {
        return res.status(400).json({ error: 'ID de pasajero no válido. Debe ser un número positivo.' });
    }

    try {
        connection = await getConnection();

        // Ejecutar el procedimiento almacenado
        const result = await connection.execute(
            `BEGIN sp_itinerario_pasajero(:id_pasajero, :o_itinerario); END;`,
            {
                id_pasajero: parseInt(id_pasajero, 10),
                o_itinerario: { type: oracledb.CURSOR, dir: oracledb.BIND_OUT },
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

        if (rows.length > 0) {
            res.json(rows);
        } else {
            res.status(404).json({ error: 'No se encontró ningún itinerario para el pasajero.' });
        }
    } catch (err) {
        console.error('Error ejecutando sp_itinerario_pasajero:', err.message);
        res.status(500).json({ error: 'Error obteniendo itinerario.', details: err.message });
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

// Ruta para obtener los asientos disponibles de un vuelo
app.get('/asientosdisponibles/:idVuelo', async (req, res) => {
    let connection;
    const { idVuelo } = req.params;

    if (!idVuelo || isNaN(idVuelo)) {
        return res.status(400).json({ error: 'ID de vuelo no válido. Debe ser un número positivo.' });
    }

    try {
        connection = await getConnection();
        const result = await connection.execute(
            `SELECT id_asiento, numero_asiento 
             FROM ASIENTOS 
             WHERE id_avion = (
                 SELECT id_avion FROM VUELO WHERE id_vuelo = :id_vuelo
             ) AND estado = 'Disponible'`,
            { id_vuelo: parseInt(idVuelo, 10) }
        );

        res.json(result.rows.map((row) => ({ id_asiento: row[0], numero_asiento: row[1] })));
    } catch (err) {
        console.error('Error obteniendo asientos disponibles:', err.message);
        res.status(500).json({ error: 'Error obteniendo asientos disponibles.', details: err.message });
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

/// Ruta para realizar el check-in
app.post('/checkin', async (req, res) => {
    let connection;
    const { id_boleto, id_asiento_nuevo } = req.body;

    // Validar que el ID de boleto sea proporcionado y válido
    if (!id_boleto || isNaN(id_boleto)) {
        return res.status(400).json({ error: 'ID de boleto es requerido y debe ser un número válido.' });
    }
    if (id_asiento_nuevo && isNaN(id_asiento_nuevo)) {
        return res.status(400).json({ error: 'ID de asiento nuevo debe ser un número válido si se proporciona.' });
    }

    try {
        connection = await getConnection();

        // Paso opcional: Cambio de asiento antes del check-in
        if (id_asiento_nuevo) {
            await connection.execute(
                `BEGIN sp_cambiar_asiento(:p_id_boleto, :p_id_asiento_nuevo); END;`,
                {
                    p_id_boleto: parseInt(id_boleto, 10),
                    p_id_asiento_nuevo: parseInt(id_asiento_nuevo, 10),
                },
                { autoCommit: true }
            );
        }

        // Realizar el check-in solo con el ID del boleto
        await connection.execute(
            `BEGIN sp_checkin(:p_id_boleto); END;`,
            { p_id_boleto: parseInt(id_boleto, 10) },
            { autoCommit: true }
        );

        res.json({ message: 'Check-in realizado correctamente.' });
    } catch (err) {
        console.error('Error realizando check-in:', err.message);
        res.status(500).json({ error: 'Error realizando el check-in.', details: err.message });
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

// Puerto del servidor
const port = process.env.PORT || 3001;
app.listen(port, () => {
    console.log(`Servidor corriendo en el puerto ${port}`);
});
