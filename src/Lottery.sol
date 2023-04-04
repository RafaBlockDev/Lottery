// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Lottery { 
    /// @dev Smart contract owner
    address payable public owner = 0xa6076e139FB8089C9d123dA690726B976E290799; 
    address payable public secondPrize = 0xF3f1cf9E7d7c306C25c18859eDF3a28D04FD1D4F;

    uint public ticketPrice = 0.001 ether;
    uint public jackpotAmount = 200 ether;
    uint public requiredBalance = 300 ether;
    uint public maxTicketsPerBatch = 100;
    uint public winningNumbersCount = 6;
    uint public blocksPerDraw = 30; 

    uint[] private winningNumbers; 
    
    mapping(address => uint[]) public tickets;
    mapping(address => uint) public balances;

    /**
     * @dev Modifier that allow execute function once the smart contract has 300 ETH
     */
    modifier requireBalance() {
        require(address(this).balance >= requiredBalance, "low balance");
        _;
    }

    /**
     * @dev Modifier that allow execute function for only buy tickets in batches
     * batches in: 1, 5, 10, 25, 50, 100.
     */
    modifier requireBatches(uint _numbers) {
        require(
        _numbers.length == 1 || _numbers.length == 5
        || _numbers.length == 10 || _numbers.length == 25
        || _numbers.length == 50 || _numbers.length == maxTicketsPerBatch,
        "incorrect amount of tickets per batch");
        _;
    }
    
    constructor() payable { 
        require(msg.value == 0, "Do not send ETH directly to this contract");
    }

    /**
     * @dev Price of ticket is 0.001 ETH
     * can be bought in batches of 1, 5, 10, 25, 50, 100
     */
    function buyTickets(uint[] memory _numbers) public payable requireBatches(_numbers) { 
        require(msg.value >= ticketPrice * _numbers.length, "Insufficient funds to buy tickets");  
        require(winningNumbers.length == 0, "Lottery has already been drawn");

        uint totalPrice = ticketPrice * _numbers.length;
        // add tickets to sender's account
        tickets[msg.sender] = mergeArrays(tickets[msg.sender], _numbers);
        // update sender's balance
        balances[msg.sender] += msg.value - totalPrice;
        // check if required balance is reached if  { drawLottery();
    }
    
    function drawLottery() private requireBalance { 
        require(winningNumbers.length == 0, "lottery has already been drawn");
    }

    function getTicketOwners(uint _number) private view returns (address[] memory) { 
        address[] memory owners = new address[](0);

        for (uint i = 0; i < addressList.length; i++) {}
    }

    /** 
    * @dev Function to transfer to `owner` 95 Ether
    * and 5 Ether to `secondPrize`
    */
    function withdraw() internal returns(uint256) {
         
    }

    
}