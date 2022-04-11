import React from "react";

const NavigationBar = ({ accounts, setAccounts }) => {
    const isConnected = Boolean(accounts[0]);

    async function connectAccount() {
        if (window.ethereum) {
            const accounts = await window.ethereum.request({
                method: "eth_requestAccounts",
            });
            setAccounts(accounts);
        }
    }

    return (
        <div>
            {/* Social Media Icons */}
            <div>Discord</div>
            <div>Twitter</div>

            {/* Header Sections */}
            <div>Mint</div>
            <div>Team</div>
            <div>About</div>
            <div>Roadmap</div>

            {/* Connect Button */}
            {isConnected ? (
                <p>Connected</p>
            ) : (
                <button onClick={connectAccount}>Connect</button>
            )}
        </div>
    );
};