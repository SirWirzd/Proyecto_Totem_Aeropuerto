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
    const [boletoDetalles, setBoletoDetalles] = useState(null);
    const [asientosDisponibles, setAsientosDisponibles] = useState([]);
    const [idAsientoNuevo, setIdAsientoNuevo] = useState('');
    const [cambioAsientoMessage, setCambioAsientoMessage] = useState('');
    const [cambioAsientoError, setCambioAsientoError] = useState('');

    // Función para manejar el Check-in
    const handleCheckin = async () => {
        if (!idBoleto || isNaN(idBoleto)) {
            setCheckinError('ID de boleto es requerido y debe ser un número válido.');
            return;
        }

        try {
            setLoading(true);
            const response = await axios.post('http://localhost:3001/checkin', {
                id_boleto: idBoleto,
            });
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

    // Función para consultar los detalles del boleto y los asientos disponibles
    const handleConsultarAsiento = async () => {
        if (!idBoleto || isNaN(idBoleto)) {
            setCambioAsientoError('ID de boleto es requerido y debe ser un número válido.');
            return;
        }

        try {
            setLoading(true);
            setCambioAsientoError('');
            setCambioAsientoMessage('');

            // Consultar detalles del boleto
            const boletoResponse = await axios.get(`http://localhost:3001/boleto/${idBoleto}`);
            setBoletoDetalles(boletoResponse.data);

            // Consultar asientos disponibles para el vuelo asociado al boleto
            const asientosResponse = await axios.get(
                `http://localhost:3001/asientosdisponiblesporboleto/${idBoleto}`
            );
            setAsientosDisponibles(asientosResponse.data);
        } catch (error) {
            setCambioAsientoError(`Error consultando datos: ${error.response?.data?.error || error.message}`);
            setBoletoDetalles(null);
            setAsientosDisponibles([]);
        } finally {
            setLoading(false);
        }
    };

    // Función para manejar el cambio de asiento
    const handleCambioAsiento = async () => {
        if (!idAsientoNuevo) {
            setCambioAsientoError('Debe seleccionar un asiento nuevo.');
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
                                        <p><strong>DNI:</strong> {vuelo.dni}</p>
                                        <p><strong>Boleto:</strong> {vuelo.boleto}</p>
                                        <p><strong>Vuelo:</strong> {vuelo.vuelo}</p>
                                        <p><strong>Fecha de salida:</strong> {vuelo.fecha_salida}{vuelo.hora_salida}</p>
                                        <p><strong>Fecha de llegada:</strong> {vuelo.fecha_llegada}{vuelo.hora_llegada}</p>
                                        <p><strong>Ciudad de origen:</strong> {vuelo.ciudad_origen}</p>
                                        <p><strong>Ciudad de destino:</strong> {vuelo.ciudad_destino}</p>
                                        <p><strong>Terminal:</strong> {vuelo.terminal}</p>
                                        <p><strong>Puerta:</strong> {vuelo.puerta}</p>
                                        <p><strong>Asiento:</strong> {vuelo.asiento}</p>
                                        <p>
                                            <strong>Estado de Boleto:</strong>{' '}
                                            <span className={vuelo.estado_boleto === 'Confirmado' ? 'estado-confirmado' : 'estado-pendiente'}>
                                                {vuelo.estado_boleto}
                                            </span>
                                        </p>

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
                        <button onClick={handleConsultarAsiento} disabled={loading}>
                            {loading ? 'Consultando...' : 'Consultar'}
                        </button>

                        {boletoDetalles && (
                            <div>
                                <h3>Detalles del Boleto</h3>
                                <p><strong>Vuelo:</strong> {boletoDetalles.vuelo}</p>
                                <p><strong>Destino:</strong> {boletoDetalles.ciudad_destino}</p>
                                <p><strong>Asiento Actual:</strong> {boletoDetalles.asiento}</p>
                            </div>
                        )}

                        {asientosDisponibles.length > 0 && (
                            <div>
                                <h3>Asientos Disponibles</h3>
                                <select
                                    value={idAsientoNuevo}
                                    onChange={(e) => setIdAsientoNuevo(e.target.value)}
                                >
                                    <option value="">Seleccione un asiento</option>
                                    {asientosDisponibles.map((asiento) => (
                                        <option key={asiento.id_asiento} value={asiento.id_asiento}>
                                            {asiento.numero_asiento}
                                        </option>
                                    ))}
                                </select>
                                <button onClick={handleCambioAsiento} disabled={loading}>
                                    {loading ? 'Cambiando...' : 'Cambiar Asiento'}
                                </button>
                            </div>
                        )}

                        {cambioAsientoMessage && <p className="success-message">{cambioAsientoMessage}</p>}
                        {cambioAsientoError && <p className="error-message">{cambioAsientoError}</p>}
                    </div>
                )}
            </div>
        </div>
    );
};

export default TotemAeropuerto;
