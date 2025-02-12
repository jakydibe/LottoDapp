// contracts/Lottery.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public owner;
    address public player;
    uint256 public betAmount;
    uint256 public chosenNum1;
    uint256 public chosenNum2;
    bool public betPlaced;
    address public oracle;
    
    bool public didWin;
    uint256 public drawnNum1;
    uint256 public drawnNum2;

    
    event BetPlaced(address indexed player, uint256 amount, uint256 num1, uint256 num2);
    event LotteryResolved(address indexed player, uint256 drawn1, uint256 drawn2, bool win);
    event DebugInfo(address player, uint256 contractBalance);


    constructor(address _oracle) payable {
        owner = msg.sender;
        oracle = _oracle;
    }

    receive() external payable {}

    
    // Permette all'owner di aggiornare l'indirizzo dell'oracolo (utile al deployment)
    function setOracle(address _oracle) public {
        require(msg.sender == owner, "Solo l'owner puo' settare l'oracolo");
        oracle = _oracle;
    }
    
    // Funzione per piazzare la scommessa (attiva solo se non esiste già una scommessa in corso)
    function placeBet(uint256 num1, uint256 num2) public payable {
        require(!betPlaced, "Scommessa gia' piazzata");
        require(msg.value > 0, "Devi inviare Ether per scommettere");
        player = msg.sender;
        betAmount = msg.value;
        chosenNum1 = num1;
        chosenNum2 = num2;
        betPlaced = true;
        emit BetPlaced(msg.sender, msg.value, num1, num2);
    }
    

    // Funzione richiamata dall'oracolo per fornire il dato esterno (es. temperatura)
    // e generare così due numeri casuali
    function fulfillRandomness(uint256 externalData) external {
        require(msg.sender == oracle, "Solo l'oracolo puo' chiamare questa funzione");
        require(betPlaced, "Nessuna scommessa attiva da risolvere");
        // Generazione dei numeri casuali (range 0-99) basata sul dato esterno e sul timestamp
        drawnNum1 = uint256(keccak256(abi.encode(externalData, block.timestamp, 1))) % 2;
        drawnNum2 = uint256(keccak256(abi.encode(externalData, block.timestamp, 2))) % 2;
        
        // bool win = (drawnNum1 == chosenNum1 || drawnNum1 == chosenNum2) && (drawnNum2 == chosenNum1 || drawnNum2 == chosenNum2);
        bool win = false;
        
        if(drawnNum1 == chosenNum1 && drawnNum2 == chosenNum2) {
            win = true;
        } else if(drawnNum1 == chosenNum2 && drawnNum2 == chosenNum1) {
            win = true;
        }

        didWin = win;
        // win = true;
        // pay everything in the contract to the player
        uint256 winPrize = (address(this).balance/2);
        if(win) {
            require(address(this).balance >= betAmount * 2, "Insufficient contract balance");
            (bool sent, ) = player.call{value: winPrize}("");
            require(sent, "Transfer failed");
        }
        emit LotteryResolved(player, drawnNum1, drawnNum2, win);
    }



    function getLotteryResult() public view returns (
        uint256 drawn1,
        uint256 drawn2,
        uint256 playerNum1,
        uint256 playerNum2,
        uint256 wagerAmount,
        address playerAddress,
        bool winornot
    ) 
    {
        return (
            drawnNum1,
            drawnNum2,
            chosenNum1,
            chosenNum2,
            betAmount,
            player,
            didWin
        );

    }


    // (Opzionale) Funzione per resettare lo stato e poter effettuare una nuova scommessa
    function resetLottery() public {
        betPlaced = false;
        player = address(0);
        betAmount = 0;
        chosenNum1 = 0;
        chosenNum2 = 0;
        drawnNum1 = 0;
        drawnNum2 = 0;
    }
}
