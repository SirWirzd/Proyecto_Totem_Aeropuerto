import './App.css';
import { Pasajeros, Vuelos } from './totem-aeropuerto';

function App() {
  return (
    <div className="App">
      <header className="Totem Aeropuerto">
        <Vuelos />
        <Pasajeros />
      </header>
    </div>
  );
}

export default App;
