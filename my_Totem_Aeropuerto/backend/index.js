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

// Ruta para obtener vuelos
app.get('/vuelos', async(req, res) => {
    let connection;
    try {
        connection = await getConnection();
        const result = await connection.execute('SELECT * FROM VUELO');
        res.json(result.rows);
    } catch (err) {
        console.error('Error ejecutando consulta:', err.message);
        res.status(500).json({ error: 'Error ejecutando consulta' });
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

// Ruta para obtener pasajeros
app.get('/pasajeros', async(req, res) => {
    let connection;
    try {
        connection = await getConnection();
        const result = await connection.execute('SELECT * FROM PASAJERO');
        res.json(result.rows);
    } catch (err) {
        console.error('Error ejecutando consulta:', err.message);
        res.status(500).json({ error: 'Error ejecutando consulta' });
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