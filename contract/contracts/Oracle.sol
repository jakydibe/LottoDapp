// contracts/Oracle.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILottery {
    function fulfillRandomness(uint256 externalData) external;
}



contract Oracle {
    address public owner;
    ILottery public lottery;
    
    constructor(address _lottery) {
        owner = msg.sender;
        lottery = ILottery(_lottery);
    }
    function getLotteryAddress() public view returns (address) {
        return address(lottery);
    }
    // Funzione per “richiedere” il dato esterno e chiamare il contratto Lottery
    // In questo esempio, il parametro externalData potrebbe rappresentare la temperatura
    function requestExternalData(uint256 externalData) public {
        require(msg.sender == owner, "Solo l'owner puo' richiedere il dato esterno");
        
        lottery.fulfillRandomness(externalData);
    }
}
