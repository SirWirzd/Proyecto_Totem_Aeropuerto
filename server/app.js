const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const path = require('path');

// Configuración de bodyParser para manejar datos JSON
app.use(bodyParser.json());

// Servir archivos estáticos desde la carpeta 'public' en el directorio raíz
app.use(express.static(path.join(__dirname, '..', 'public')));

// Ruta GET para la página principal (index.html)
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '..', 'public', 'index.html'));  // Ruta correcta al archivo HTML
});

// Ruta POST para el check-in
app.post('/checkin', (req, res) => {
    const { vueloId, pasajeroId } = req.body;
    // Aquí puedes agregar la lógica para la consulta de la base de datos y demás
    res.json({ mensaje: `Datos del vuelo para el pasajero ${pasajeroId}` });
});

// Iniciar el servidor en el puerto 3000
app.listen(3000, () => {
    console.log('Servidor corriendo en http://localhost:3000');
});
