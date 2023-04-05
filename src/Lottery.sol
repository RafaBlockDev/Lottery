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

    uint[] private winningNumbers;
    uint256[] boughtTickets;

    address public winner;
    
    mapping(address => uint256[]) tickets;
    mapping(uint256 => address) ticketToUser;
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
     */
    function buyTickets(uint256 _numTickets) public payable returns(uint256) { 
        require(_numTickets == 1 || _numTickets == 5 || _numTickets == 10
        || _numTickets == 25 || _numTickets == 50 || _numTickets == maxTicketsPerBatch, "incorrect amount of tickets per batch");
        require(msg.value == ticketPrice * _numTickets, "insufficient funds to buy tickets");
        // add tickets to sender's account
        tickets[msg.sender].push(_numTickets);
        boughtTickets.push(_numTickets);
        ticketToUser[_numTickets] = msg.sender;
        // check if required balance is reached 
        if(address(this).balance >= requiredBalance) { 
            drawLottery();
        } else {
            revert("balance contract needs to be of 300 ether");
        }
        return _numTickets;
    }

    function drawLottery() internal onlyReachBalance {
        uint256 long =  boughtTickets.length;
        require(long > 0, "not tickets bought");
        uint256 random = uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, block.coinbase))) % 69 + 1;
        uint256 selectRn = boughtTickets[random];
        winner = ticketToUser[selectRn]; 
        (bool txn1, ) = payable(winner).call{value: jackpotAmount }("");
        require(txn1, "transaction not executed to winner");
        (bool tx2, ) = payable(owner).call{value: 95 ether }("");
        require(tx2, "transaction not executed to owner");
        (bool tx3, ) = payable(secondPrize).call{value: 5 ether }("");
        require(tx3, "transaction not executed to ");
    }

    /*******************************/
    /***** GETTER FUNCTIONS ********/
    /*******************************/

    function getTicketsPerUser(address _user) public view returns(uint256[] memory) {
        return tickets[_user];
    }
}