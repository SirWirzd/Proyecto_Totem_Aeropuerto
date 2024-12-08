import React, { useState } from 'react';
import axios from 'axios';

const TotemAeropuerto = () => {
    const [activeTab, setActiveTab] = useState('checkin'); // Control de pestañas activas
    const [loading, setLoading] = useState(false); // Estado general de carga

    // Estados para Check-in
    const [idBoleto, setIdBoleto] = useState('');
    const [checkinMessage, setCheckinMessage] = useState('');
    const [checkinError, setCheckinError] = useState('');

    // Estados para Itinerario
    const [idPasajero, setIdPasajero] = useState('');
    const [itinerario, setItinerario] = useState([]);
    const [itinerarioError, setItinerarioError] = useState('');

    // Estados para Cambio de Asiento
    const [idAsientoNuevo, setIdAsientoNuevo] = useState('');
    const [cambioAsientoMessage, setCambioAsientoMessage] = useState('');
    const [cambioAsientoError, setCambioAsientoError] = useState('');

    // Función para manejar el Check-in
    const handleCheckin = async () => {
        if (!idBoleto) {
            setCheckinError('ID de boleto es requerido.');
            return;
        }

        try {
            setLoading(true);
            const response = await axios.post('http://localhost:3001/checkin', { id_boleto: idBoleto });
            setCheckinMessage(response.data.message || 'Check-in realizado correctamente.');
            setCheckinError('');
        } catch (error) {
            setCheckinError(`Error realizando check-in: ${error.response?.data?.error || error.message}`);
            setCheckinMessage('');
        } finally {
            setLoading(false);
        }
    };

    // Función para consultar el Itinerario
    const handleItinerario = async () => {
        if (!idPasajero || isNaN(idPasajero)) {
            setItinerarioError('ID de pasajero inválido. Debe ser un número.');
            return;
        }

        try {
            setLoading(true);
            const response = await axios.get(`http://localhost:3001/itinerario/${idPasajero}`);
            setItinerario(response.data);
            setItinerarioError('');
        } catch (error) {
            setItinerario([]);
            setItinerarioError(`Error obteniendo itinerario: ${error.response?.data?.error || error.message}`);
        } finally {
            setLoading(false);
        }
    };

    // Función para manejar el Cambio de Asiento
    const handleCambioAsiento = async () => {
        if (!idBoleto || !idAsientoNuevo) {
            setCambioAsientoError('ID de boleto e ID de asiento nuevo son requeridos.');
            return;
        }

        try {
            setLoading(true);
            const response = await axios.post('http://localhost:3001/cambioasiento', {
                id_boleto: idBoleto,
                id_asiento_nuevo: idAsientoNuevo,
            });
            setCambioAsientoMessage(response.data.message || 'Asiento cambiado correctamente.');
            setCambioAsientoError('');
        } catch (error) {
            setCambioAsientoError(`Error cambiando asiento: ${error.response?.data?.error || error.message}`);
            setCambioAsientoMessage('');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="totem-aeropuerto">
            <h1>Tótem Aeropuerto</h1>

            {loading && <p className="loading">Cargando...</p>}

            {/* Pestañas */}
            <div className="tabs">
                <button
                    onClick={() => setActiveTab('checkin')}
                    disabled={loading}
                    className={activeTab === 'checkin' ? 'active' : ''}
                >
                    Check-in
                </button>
                <button
                    onClick={() => setActiveTab('itinerario')}
                    disabled={loading}
                    className={activeTab === 'itinerario' ? 'active' : ''}
                >
                    Itinerario
                </button>
                <button
                    onClick={() => setActiveTab('cambioasiento')}
                    disabled={loading}
                    className={activeTab === 'cambioasiento' ? 'active' : ''}
                >
                    Cambio de Asiento
                </button>
            </div>

            {/* Contenido de las Pestañas */}
            <div className="tab-content">
                {activeTab === 'checkin' && (
                    <div>
                        <h2>Realizar Check-in</h2>
                        <label>ID Boleto:</label>
                        <input
                            type="text"
                            value={idBoleto}
                            onChange={(e) => setIdBoleto(e.target.value)}
                        />
                        <button onClick={handleCheckin} disabled={loading}>
                            {loading ? 'Procesando...' : 'Realizar Check-in'}
                        </button>
                        {checkinMessage && <p className="success-message">{checkinMessage}</p>}
                        {checkinError && <p className="error-message">{checkinError}</p>}
                    </div>
                )}

                {activeTab === 'itinerario' && (
                    <div>
                        <h2>Consultar Itinerario</h2>
                        <label>ID Pasajero:</label>
                        <input
                            type="text"
                            value={idPasajero}
                            onChange={(e) => setIdPasajero(e.target.value)}
                        />
                        <button onClick={handleItinerario} disabled={loading}>
                            {loading ? 'Procesando...' : 'Consultar'}
                        </button>
                        {itinerarioError && <p className="error-message">{itinerarioError}</p>}
                        {itinerario.length > 0 && (
                            <ul>
                                {itinerario.map((vuelo, index) => (
                                    <li key={index}>
                                        <p><strong>Pasajero:</strong> {vuelo.pasajero}</p>
                                        <p><strong>Vuelo:</strong> {vuelo.vuelo}</p>
                                        <p><strong>Asiento:</strong> {vuelo.asiento}</p>
                                        <p><strong>Estado:</strong> {vuelo.estado_boleto}</p>
                                    </li>
                                ))}
                            </ul>
                        )}
                    </div>
                )}

                {activeTab === 'cambioasiento' && (
                    <div>
                        <h2>Cambiar Asiento</h2>
                        <label>ID Boleto:</label>
                        <input
                            type="text"
                            value={idBoleto}
                            onChange={(e) => setIdBoleto(e.target.value)}
                        />
                        <label>ID Asiento Nuevo:</label>
                        <input
                            type="text"
                            value={idAsientoNuevo}
                            onChange={(e) => setIdAsientoNuevo(e.target.value)}
                        />
                        <button onClick={handleCambioAsiento} disabled={loading}>
                            {loading ? 'Procesando...' : 'Cambiar Asiento'}
                        </button>
                        {cambioAsientoMessage && <p className="success-message">{cambioAsientoMessage}</p>}
                        {cambioAsientoError && <p className="error-message">{cambioAsientoError}</p>}
                    </div>
                )}
            </div>
        </div>
    );
};

export default TotemAeropuerto;
