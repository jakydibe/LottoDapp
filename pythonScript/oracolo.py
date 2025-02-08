import json
import requests
from web3 import Web3

# Connetti al nodo locale (assicurati che sia in esecuzione)
w3 = Web3(Web3.HTTPProvider("http://localhost:8545"))
if not w3.is_connected():
    raise Exception("Errore nella connessione a localhost:8545")

# Indirizzo del contratto Oracle (sostituisci con quello reale)
oracle_address = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"

# Carica l'artifact dell'oracolo e estrai l'ABI
with open("../contract/artifacts/contracts/Oracle.sol/Oracle.json", "r") as abi_file:
    artifact = json.load(abi_file)
    oracle_abi = artifact["abi"]  # Estrae solo il campo 'abi'

# Istanzia il contratto Oracle
oracle_contract = w3.eth.contract(address=oracle_address, abi=oracle_abi)

# Ora puoi chiamare le funzioni del contratto, ad esempio:
try:
    response = requests.get("http://localhost:5000/random")
    response.raise_for_status()
    data = response.json()
    random_number = data["random"]
    print("Numero casuale ottenuto:", random_number)
except Exception as e:
    print("Errore nella chiamata all'API:", e)
    exit(1)

# Esempio di invio della funzione requestExternalData
account = w3.eth.accounts[0]
nonce = w3.eth.get_transaction_count(account, "latest")
transaction = oracle_contract.functions.requestExternalData(random_number).build_transaction({
    'from': account,
    'nonce': nonce,
    'gas': 500000,
    'gasPrice': w3.to_wei('20', 'gwei')
})

# Firma e invia la transazione (assicurati di avere la chiave privata se necessario)
# account 11
private_key = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"  # Sostituisci con la chiave privata
signed_tx = w3.eth.account.sign_transaction(transaction, private_key=private_key)
tx_hash = w3.eth.send_raw_transaction(signed_tx.raw_transaction)
print("Transazione inviata. Hash:", tx_hash.hex())
print(json.dumps({ "txHash": tx_hash.hex() }))  # Output per l'API
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
print("Transazione confermata nel blocco:", tx_receipt.blockNumber)
