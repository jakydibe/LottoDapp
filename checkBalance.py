import requests
import json

def get_balance(address, rpc_url):
    # Verifica formato indirizzo
    if not address.startswith("0x") or len(address) != 42:
        raise ValueError("Indirizzo Ethereum non valido")
    
    payload = {
        "jsonrpc": "2.0",
        "method": "eth_getBalance",
        "params": [address, "latest"],
        "id": 1
    }
    
    try:
        response = requests.post(rpc_url, json=payload, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        if 'error' in data:
            raise Exception(f"Errore RPC: {data['error']['message']}")
            
        wei = int(data['result'], 16)
        return wei / 10**18
        
    except requests.exceptions.RequestException as e:
        raise Exception(f"Errore di connessione: {str(e)}") from e

if __name__ == "__main__":
    try:
        # Sostituisci con il tuo indirizzo reale
        address = "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266" 
        balance = get_balance(address, "http://localhost:8545")
        print(f"Balance: {balance} ETH")
    except Exception as e:
        print(f"Errore: {str(e)}")