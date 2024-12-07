import React, { useState } from 'react';
import axios from 'axios';

const TotemAeropuerto = () => {
    const [activeTab, setActiveTab] = useState('checkin'); // Control de pestañas activas

    // Estados para el Check-in
    const [idBoleto, setIdBoleto] = useState('');
    const [idVuelo, setIdVuelo] = useState('');
    const [checkinMessage, setCheckinMessage] = useState('');
    const [checkinError, setCheckinError] = useState('');

    // Estados para el Itinerario
    const [idPasajero, setIdPasajero] = useState('');
    const [itinerario, setItinerario] = useState([]);
    const [itinerarioError, setItinerarioError] = useState('');

    // Estados para el Cambio de Asiento
    const [idAsientoNuevo, setIdAsientoNuevo] = useState('');
    const [cambioAsientoMessage, setCambioAsientoMessage] = useState('');
    const [cambioAsientoError, setCambioAsientoError] = useState('');

    // Función para manejar el check-in
    const handleCheckin = async () => {
        try {
            const response = await axios.post('http://localhost:3001/checkin', {
                id_boleto: idBoleto,
                id_vuelo: idVuelo,
            });

            setCheckinMessage(response.data.message || 'Check-in registrado correctamente');
            setCheckinError('');
        } catch (error) {
            setCheckinError('Error realizando check-in: ' + (error.response?.data?.error || error.message));
            setCheckinMessage('');
        }
    };

    // Función para manejar la consulta de itinerario
    const handleItinerario = async () => {
        try {
            const response = await axios.get(`http://localhost:3001/itinerario/${idPasajero}`);
            setItinerario(response.data);
            setItinerarioError('');
        } catch (error) {
            setItinerario([]);
            setItinerarioError('Error obteniendo itinerario: ' + error.message);
        }
    };

    // Función para manejar el cambio de asiento
    const handleCambioAsiento = async () => {
        try {
            const response = await axios.post('http://localhost:3001/cambioasiento', {
                id_boleto: idBoleto,
                id_asiento_nuevo: idAsientoNuevo,
            });

            setCambioAsientoMessage(response.data.message || 'Asiento cambiado correctamente');
            setCambioAsientoError('');
        } catch (error) {
            setCambioAsientoError('Error cambiando asiento: ' + (error.response?.data?.error || error.message));
            setCambioAsientoMessage('');
        }
    };

    return (
        <div className="totem-aeropuerto">
            <h1>Tótem Aeropuerto</h1>
            <div className="tabs">
                <button
                    className={activeTab === 'checkin' ? 'active' : ''}
                    onClick={() => setActiveTab('checkin')}
                >
                    Check-in
                </button>
                <button
                    className={activeTab === 'itinerario' ? 'active' : ''}
                    onClick={() => setActiveTab('itinerario')}
                >
                    Itinerario
                </button>
                <button
                    className={activeTab === 'cambioasiento' ? 'active' : ''}
                    onClick={() => setActiveTab('cambioasiento')}
                >
                    Cambio de Asiento
                </button>
            </div>

            <div className="tab-content">
                {activeTab === 'checkin' && (
                    <div className="checkin-section">
                        <h2>Realizar Check-in</h2>
                        <form
                            onSubmit={(e) => {
                                e.preventDefault();
                                handleCheckin();
                            }}
                        >
                            <label>ID Boleto:</label>
                            <input
                                type="text"
                                value={idBoleto}
                                onChange={(e) => setIdBoleto(e.target.value)}
                                required
                            />
                            <label>ID Vuelo:</label>
                            <input
                                type="text"
                                value={idVuelo}
                                onChange={(e) => setIdVuelo(e.target.value)}
                                required
                            />
                            <button type="submit">Realizar Check-in</button>
                        </form>

                        {checkinMessage && <p className="success-message">{checkinMessage}</p>}
                        {checkinError && <p className="error-message">{checkinError}</p>}
                    </div>
                )}

                {activeTab === 'itinerario' && (
                    <div className="itinerario-section">
                        <h2>Consultar Itinerario</h2>
                        <form
                            onSubmit={(e) => {
                                e.preventDefault();
                                handleItinerario();
                            }}
                        >
                            <label>ID Pasajero:</label>
                            <input
                                type="text"
                                value={idPasajero}
                                onChange={(e) => setIdPasajero(e.target.value)}
                                required
                            />
                            <button type="submit">Consultar</button>
                        </form>

                        {itinerario.length > 0 && (
                            <div>
                                <h3>Itinerario</h3>
                                <ul>
                                    {itinerario.map((vuelo, index) => (
                                        <li key={index}>
                                            <p><strong>Pasajero:</strong> {vuelo.pasajero}</p>
                                            <p><strong>DNI:</strong> {vuelo.dni}</p>
                                            <p><strong>Boleto:</strong> {vuelo.boleto}</p>
                                            <p><strong>Vuelo:</strong> {vuelo.vuelo}</p>
                                            <p><strong>Fecha Salida:</strong> {vuelo.fecha_salida} {vuelo.hora_salida}</p>
                                            <p><strong>Fecha Llegada:</strong> {vuelo.fecha_llegada} {vuelo.hora_llegada}</p>
                                            <p><strong>Origen:</strong> {vuelo.ciudad_origen}</p>
                                            <p><strong>Destino:</strong> {vuelo.ciudad_destino}</p>
                                            <p><strong>Asiento:</strong> {vuelo.asiento}</p>
                                            <p><strong>Terminal:</strong> {vuelo.terminal}</p>
                                            <p><strong>Puerta:</strong> {vuelo.puerta}</p>
                                            <p><strong>Estado Boleto:</strong> {vuelo.estado_boleto}</p>
                                        </li>
                                    ))}
                                </ul>
                            </div>
                        )}

                        {itinerarioError && <p className="error-message">{itinerarioError}</p>}
                    </div>
                )}

                {activeTab === 'cambioasiento' && (
                    <div className="cambio-asiento-section">
                        <h2>Cambiar Asiento</h2>
                        <form
                            onSubmit={(e) => {
                                e.preventDefault();
                                handleCambioAsiento();
                            }}
                        >
                            <label>ID Boleto:</label>
                            <input
                                type="text"
                                value={idBoleto}
                                onChange={(e) => setIdBoleto(e.target.value)}
                                required
                            />
                            <label>ID Asiento Nuevo:</label>
                            <input
                                type="text"
                                value={idAsientoNuevo}
                                onChange={(e) => setIdAsientoNuevo(e.target.value)}
                                required
                            />
                            <button type="submit">Cambiar Asiento</button>
                        </form>

                        {cambioAsientoMessage && <p className="success-message">{cambioAsientoMessage}</p>}
                        {cambioAsientoError && <p className="error-message">{cambioAsientoError}</p>}
                    </div>
                )}
            </div>
        </div>
    );
};

export default TotemAeropuerto;
