// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Lottery { 
    /// @dev Smart contract owner
    address public owner = payable(0xa6076e139FB8089C9d123dA690726B976E290799); 
    address public secondPrize = payable(0xF3f1cf9E7d7c306C25c18859eDF3a28D04FD1D4F);

    uint public ticketPrice = 0.001 ether; // 1000000000000000 wei
    uint public jackpotAmount = 200 ether;
    uint public requiredBalance = 300 ether;
    uint public maxTicketsPerBatch = 100;
    uint public winningNumbersCount = 6;
    uint public blocksPerDraw = 30; 
    uint public maxNumber = 69;

    uint[] private winningNumbers;
    
    mapping(address => uint[]) public tickets;
    mapping(address => uint) public balances;

    /**
     * @dev Modifier that allow execute function once the smart contract has 300 ETH
     */
    modifier onlyReachBalance() {
        require(address(this).balance >= requiredBalance, "low balance");
        _;
    }
    
    constructor() payable { 
        require(msg.value == 0, "Do not send ETH directly to this contract");
    }

    /**
     * @dev Price of ticket is 0.001 ETH
     * can be bought in batches of 1, 5, 10, 25, 50, 100
     */
    function buyTickets(uint[] memory _numbers) public payable returns(uint[] memory) { 
        require(_numbers.length == 1 || _numbers.length == 5 || _numbers.length == 10
        || _numbers.length == 25 || _numbers.length == 50 || _numbers.length == maxTicketsPerBatch, "incorrect amount of tickets per batch");
        require(msg.value == ticketPrice * _numbers.length, "insufficient funds to buy tickets");  
        require(winningNumbers.length == 0, "lottery has already been drawn");

        uint totalPrice = ticketPrice * _numbers.length;
        // add tickets to sender's account
        tickets[msg.sender] = _numbers;
        // update sender's balance
        balances[msg.sender] -= totalPrice;
        // check if required balance is reached 
        if(address(this).balance >= requiredBalance) { 
            drawLottery();
        } 
        return _numbers;
    }
    
    function drawLottery() internal onlyReachBalance { 
        withdraw(); // Send 95 ether to owner and 5 ether to secondPrize
        require(winningNumbers.length == 0, "lottery has already been drawn");

        uint count = 0;
        while (count < blocksPerDraw) {
            for (uint i = 0; i < winningNumbersCount; i++) {
                uint number;
                do {
                    number = random() % 69 + 1; // random number since 1 to 69
                } while (contains(winningNumbers, number));
                winningNumbers.push(number);
            }
            count++;
        }
    }

    /** 
    * @dev Function to transfer to `owner` 95 Ether
    * and 5 Ether to `secondPrize`
    */
    function withdraw() internal {
    uint256 balance = address(this).balance;

    (bool tx1, ) = payable(owner).call{value: balance - 205 }("");
    require(tx1, "transaction not executed");
    (bool tx2, ) = payable(secondPrize).call{value: balance - 295}("");
    require(tx2, "transaction not executed");
    }

    /**
     * @dev Get Random number 🚨
     * 🚨 This function is insecure, only use with academics goals 🚨
     */
    function random() internal view returns (uint) {
        return uint(keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender, block.timestamp)));
    }

    function contains(uint[] memory array, uint element) internal pure returns (bool) {
    // From winningNumbersCount
    for (uint i = 0; i < array.length; i++) {
        if (array[i] == element) {
            return true;
        }
    }
    return false;
}
}