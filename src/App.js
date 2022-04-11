import './App.css';
import { useState } from 'react';
import MainMint from './MainMint';
import NavigationBar from './NavigationBar';

function App() {
  const [accounts, setAccounts] = useState([]);
  
  return (<div className="App">
    <NavigationBar accounts = {accounts} setAccounts= {setAccounts} />
    <MainMint accounts = {accounts} setAccounts= {setAccounts} />
  </div>);
}

export default App;
