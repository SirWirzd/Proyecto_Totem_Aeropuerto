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

// Ruta para obtener el cambio de asiento de un pasajero del procedimiento sp_cambio_asiento
app.get('/cambioasiento/:id_boleto', async (req, res) => {
    let connection;
    const { id_boleto } = req.params;

    try {
        // Validación del parámetro
        if (isNaN(id_boleto)) {
            return res.status(400).json({ error: 'El id_boleto debe ser un número válido.' });
        }

        // Establecer conexión
        connection = await getConnection();

        // Ejecutar el procedimiento
        const result = await connection.execute(
            `BEGIN sp_cambio_asiento(:id_boleto, :o_cambio_asiento); END;`,
            {
                id_boleto: parseInt(id_boleto, 10),
                o_cambio_asiento: { type: oracledb.CURSOR, dir: oracledb.BIND_OUT }
            }
        );

        const cursor = result.outBinds.o_cambio_asiento;
        const rows = [];

        try {
            // Leer las filas del cursor
            let row;
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
        } catch (err) {
            console.error('Error al leer el cursor:', err.message);
            return res.status(500).json({ error: 'Error al procesar los datos del cursor.' });
        } finally {
            // Cerrar el cursor
            if (cursor) {
                await cursor.close();
            }
        }

        // Enviar la respuesta
        res.json(rows);
    } catch (err) {
        console.error('Error ejecutando procedimiento:', err.message);
        res.status(500).json({ error: 'Error ejecutando procedimiento' });
    } finally {
        // Cerrar la conexión
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
    const { id_boleto, id_vuelo, identificador, tipo_identificador } = req.body;

    try {
        connection = await getConnection();

        let boletoId = id_boleto;

        // Si se proporciona un identificador flexible, buscar el ID del boleto
        if (!boletoId && identificador && tipo_identificador) {
            if (tipo_identificador === 'numero_compra') {
                const result = await connection.execute(
                    `SELECT id_boleto FROM BOLETO WHERE id_boleto = :identificador`,
                    { identificador: parseInt(identificador, 10) }
                );
                if (result.rows.length === 0) {
                    throw new Error('Número de compra no encontrado.');
                }
                boletoId = result.rows[0][0];
            } else if (tipo_identificador === 'documento_identidad') {
                const result = await connection.execute(
                    `SELECT id_boleto FROM BOLETO b
                     JOIN PASAJERO p ON b.id_pasajero = p.id_pasajero
                     WHERE p.dni_pasajero = :identificador`,
                    { identificador }
                );
                if (result.rows.length === 0) {
                    throw new Error('Documento de identidad no encontrado.');
                }
                boletoId = result.rows[0][0];
            } else if (tipo_identificador === 'pasaporte') {
                const result = await connection.execute(
                    `SELECT id_boleto FROM BOLETO b
                     JOIN PASAJERO p ON b.id_pasajero = p.id_pasajero
                     WHERE p.pasaporte = :identificador`,
                    { identificador }
                );
                if (result.rows.length === 0) {
                    throw new Error('Pasaporte no encontrado.');
                }
                boletoId = result.rows[0][0];
            } else {
                throw new Error('Tipo de identificador no válido.');
            }
        }

        // Validar que el ID del boleto esté presente
        if (!boletoId) {
            throw new Error('No se pudo determinar el ID del boleto.');
        }

        // Ejecutar el procedimiento almacenado sp_checkin
        await connection.execute(
            `BEGIN sp_checkin(:p_id_boleto, :p_id_vuelo); END;`,
            {
                p_id_boleto: parseInt(boletoId, 10),
                p_id_vuelo: parseInt(id_vuelo, 10),
            }
        );

        res.json({
            message: 'Check-in registrado correctamente.',
            id_boleto: boletoId,
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