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
            user: process.env.DB_USER || 'ARTURO',
            password: process.env.DB_PASSWORD || 'ARTURO',
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

// Ruta para obtener los detalles de un boleto
app.get('/boleto/:idBoleto', async (req, res) => {
    let connection;
    const { idBoleto } = req.params;

    if (!idBoleto || isNaN(idBoleto)) {
        return res.status(400).json({ error: 'ID de boleto no válido.' });
    }

    try {
        connection = await getConnection();

        const result = await connection.execute(
            `SELECT v.id_vuelo, ad.ciudad AS ciudad_destino, a.numero_asiento AS asiento
             FROM BOLETO b
             JOIN VUELO v ON b.id_vuelo = v.id_vuelo
             JOIN AEROPUERTO ad ON v.id_aeropuerto_destino = ad.id_aeropuerto
             JOIN ASIENTOS a ON b.id_asiento = a.id_asiento
             WHERE b.id_boleto = :id_boleto`,
            { id_boleto: parseInt(idBoleto, 10) }
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'No se encontró el boleto.' });
        }

        const [vuelo, ciudad_destino, asiento] = result.rows[0];
        res.json({ vuelo, ciudad_destino, asiento });
    } catch (err) {
        console.error('Error obteniendo detalles del boleto:', err.message);
        res.status(500).json({ error: 'Error obteniendo detalles del boleto.', details: err.message });
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


// Ruta para obtener los asientos disponibles basados en el id del boleto
app.get('/asientosdisponiblesporboleto/:idBoleto', async (req, res) => {
    let connection;
    const { idBoleto } = req.params;

    if (!idBoleto || isNaN(idBoleto)) {
        return res.status(400).json({ error: 'ID de boleto no válido.' });
    }

    try {
        connection = await getConnection();

        // Consultar el vuelo y avión asociados al boleto
        const vueloAvionResult = await connection.execute(
            `SELECT v.id_vuelo, v.id_avion 
             FROM BOLETO b 
             JOIN VUELO v ON b.id_vuelo = v.id_vuelo 
             WHERE b.id_boleto = :id_boleto`,
            { id_boleto: parseInt(idBoleto, 10) }
        );

        if (vueloAvionResult.rows.length === 0) {
            return res.status(404).json({ error: 'No se encontró información del vuelo para el boleto.' });
        }

        const [idVuelo, idAvion] = vueloAvionResult.rows[0];

        // Obtener los asientos disponibles
        const asientosResult = await connection.execute(
            `SELECT id_asiento, numero_asiento 
             FROM ASIENTOS 
             WHERE id_avion = :id_avion AND estado = 'Disponible'`,
            { id_avion: idAvion }
        );

        res.json(asientosResult.rows.map((row) => ({ id_asiento: row[0], numero_asiento: row[1] })));
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
// Ruta para cambbiar el asiento 
app.post('/cambioasiento', async (req, res) => {
    let connection;
    const { id_boleto, id_asiento_nuevo } = req.body;

    if (!id_boleto || isNaN(id_boleto) || !id_asiento_nuevo || isNaN(id_asiento_nuevo)) {
        return res.status(400).json({ error: 'ID de boleto e ID de asiento nuevo son requeridos y deben ser números válidos.' });
    }

    try {
        connection = await getConnection();

        // Cambiar el estado del asiento actual a "Disponible"
        await connection.execute(
            `UPDATE ASIENTOS 
             SET estado = 'Disponible' 
             WHERE id_asiento = (
                 SELECT id_asiento 
                 FROM BOLETO 
                 WHERE id_boleto = :id_boleto
             )`,
            { id_boleto: parseInt(id_boleto, 10) }
        );

        // Actualizar el asiento en el boleto
        await connection.execute(
            `UPDATE BOLETO 
             SET id_asiento = :id_asiento_nuevo 
             WHERE id_boleto = :id_boleto`,
            {
                id_boleto: parseInt(id_boleto, 10),
                id_asiento_nuevo: parseInt(id_asiento_nuevo, 10),
            }
        );

        // Cambiar el estado del nuevo asiento a "Ocupado"
        await connection.execute(
            `UPDATE ASIENTOS 
             SET estado = 'Ocupado' 
             WHERE id_asiento = :id_asiento_nuevo`,
            { id_asiento_nuevo: parseInt(id_asiento_nuevo, 10) }
        );

        await connection.commit(); // Confirmar los cambios

        res.json({ message: 'Asiento cambiado correctamente.' });
    } catch (err) {
        console.error('Error cambiando asiento:', err.message);
        res.status(500).json({ error: 'Error cambiando asiento.', details: err.message });
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
    const { id_boleto } = req.body;

    if (!id_boleto || isNaN(id_boleto)) {
        return res.status(400).json({ error: 'ID de boleto no válido.' });
    }

    try {
        connection = await getConnection();

        // Llamar al procedimiento almacenado `sp_checkin`
        await connection.execute(
            `BEGIN sp_checkin(:p_id_boleto); END;`,
            { p_id_boleto: parseInt(id_boleto, 10) },
            { autoCommit: true }
        );

        res.json({ message: 'Check-in realizado correctamente.' });
    } catch (err) {
        if (err.errorNum === 20015) {
            res.status(409).json({ error: 'El pasajero ya realizó el check-in para este asiento.' });
        } else {
            console.error('Error realizando check-in:', err.message);
            res.status(500).json({ error: 'Error realizando el check-in.', details: err.message });
        }
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
