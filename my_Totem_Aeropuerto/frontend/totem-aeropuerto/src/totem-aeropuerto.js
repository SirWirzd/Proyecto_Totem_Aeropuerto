import React, { useState, useEffect } from 'react';
import axios from 'axios';

const Vuelos = () => {
    const [vuelos, setVuelos] = useState([]);

    useEffect(() => {
        axios.get('http://localhost:3001/vuelos')
            .then(res => {
                setVuelos(res.data);
            });
    }, []);

    return (
        <div>
            <h1>Vuelos</h1>
            <ul>
                {vuelos.map(vuelo => (
                    <li key={vuelo[0]}>{vuelo[1]}</li>
                ))}
            </ul>
        </div>
    );
}

export { Vuelos };

const Pasajeros = () => {
    const [pasajeros, setPasajeros] = useState([]);

    useEffect(() => {
        axios.get('http://localhost:3001/pasajeros')
            .then(res => {
                setPasajeros(res.data);
            });
    }, []);

    return (
        <div>
            <h1>Pasajeros</h1>
            <ul>
                {pasajeros.map(pasajero => (
                    <li key={pasajero[0]}>{pasajero[1]}</li>
                ))}
            </ul>
        </div>
    );
}

export { Pasajeros };
