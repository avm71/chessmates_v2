import { useState } from 'react';
import { ethers, BigNumber } from 'ethers';
import chessMates from './ChessMates.json';

const chessMatesAddress = "0x2A1683F62c4D8C66D2c6d8B910265f57DD1b87Ee";

const MainMint = ({ accounts, setAccounts }) => {
    const [mintAmt, setMintAmt] = useState(1);
    const isConnected = Boolean(accounts[0]);

    async function mintButton() {
        if (window.ethereum) {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const signer = provider.getSigner();
            const contract = new ethers.Contract(
                chessMatesAddress,
                chessMates.abi,
                signer
            );
            try {
                const response = await contract.mint(BigNumber.from(mintAmt));
                console.log('response: ', response);
            } catch (err) {
                console.log("error: ", err);
            }

        }
    }
    const decrement = () => {
        if ( mintAmt <=1 ) return;
        setMintAmt(mintAmt - 1);
    };
    const increment = () => {
        if ( mintAmt >= 5 ) return;
        setMintAmt(mintAmt + 1);
    };

    return (
        <div>
            <h1>ChessMates</h1>
            <p>Welcome to ChessMates</p>
            {isConnected ? (
                <div>
                    <div>
                        <button onClick={decrement}>-</button>
                        <input type="number" value={mintAmt}></input>
                        <button onClick={increment}>+</button>
                    </div>
                    <button onClick={mintButton}>Mint</button>
                </div>
            ) : (
                <p>Please connect your wallet</p>
            )}
        </div>
    );
};

export default MainMint;