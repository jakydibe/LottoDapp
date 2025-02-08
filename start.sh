#!/bin/bash

# Avvia l'API Python in una nuova finestra del terminale
gnome-terminal -- bash -c "python3 ~/Desktop/LottoDapp/pythonScript/rand_api.py; exec bash"

# Avvia Hardhat Node in una nuova finestra, entrando nella directory dei contratti
gnome-terminal -- bash -c "cd ~/Desktop/LottoDapp/contract && npx hardhat node; exec bash"

# Avvia lo script di deploy in una nuova finestra, nella stessa directory
gnome-terminal -- bash -c "cd ~/Desktop/LottoDapp/contract && npx hardhat run scripts/deploy.js --network localhost; exec bash"

gnome-terminal -- bash -c "cd ~/Desktop/LottoDapp/frontend && npm start