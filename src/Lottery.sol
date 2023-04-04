// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Lottery { 
    address payable public owner = 0xa6076e139FB8089C9d123dA690726B976E290799; 
    address payable public secondPrize = 0xF3f1cf9E7d7c306C25c18859eDF3a28D04FD1D4F;

    uint public ticketPrice = 0.001 ether;
    uint public jackpotAmount = 200 ether;
    uint public requiredBalance = 300 ether;
    uint public maxTicketsPerBatch = 100;
    uint public winningNumbersCount = 6;
    uint public blocksPerDraw = 30; 

    uint[] public winningNumbers; 
    
    mapping(address => uint[]) public tickets;
    mapping(address => uint) public balances;
    
    constructor() payable { 
        require(msg.value == 0, "Do not send ETH directly to this contract");
    }

    function buyTickets(uint[] memory _numbers) public payable { 
        require(msg.value >= ticketPrice * _numbers.length, "Insufficient funds to buy tickets"); 
        require(_numbers.length <= maxTicketsPerBatch, "Exceeds maximum tickets per batch"); 
        require(winningNumbers.length == 0, "Lottery has already been drawn");

        uint totalPrice = ticketPrice * _numbers.length; // add tickets to sender's account tickets[msg.sender] = mergeArrays(tickets[msg.sender], _numbers); // update sender's balance balances[msg.sender] += msg.value - totalPrice; // check if required balance is reached if (address(this).balance >= requiredBalance) { drawLottery();
        }
    }

    function drawLottery() private { 
        require(winningNumbers.length == 0, "Lottery has already been drawn");

        uint count = 0;

        while (count < blocksPerDraw) { // generate winning numbers for (uint i = 0; i < winningNumbersCount; i++) {
                uint number;
                do {
                    number = random() % 69 + 1;
                }
            while (contains(winningNumbers, number));
                winningNumbers.push(number);
            } // find winners address payable[] memory winners;
            for (uint i = 0; i < winningNumbers.length; i++) { address[] memory ticketOwners = getTicketOwners(winningNumbers[i]);
                for (uint j = 0; j < ticketOwners.length; j++) {
                    winners.push(payable(ticketOwners[j]));
                }
            } // distribute prizes if (winners.length > 0) {
                uint prizeAmount = jackpotAmount / winners.length;
                for (uint i = 0; i < winners.length; i++) {
                    balances[winners[i]] += prizeAmount;
                } // transfer prizes to winners for (uint i = 0; i < winners.length; i++) {
                    winners[i].transfer(prizeAmount);
                } // transfer second prize secondPrize.transfer(5 ether); // transfer remaining balance to owner owner.transfer(address(this).balance - 5 ether); // reset variables winningNumbers = new uint[](0);
                return;
            } // reset variables winningNumbers = new uint[](0);

            count++;
        }
    }

    function getTicketOwners(uint _number) private view returns (address[] memory) { 
        address[] memory owners = new address[](0);

        for (uint i = 0; i < addressList.length; i++) {}