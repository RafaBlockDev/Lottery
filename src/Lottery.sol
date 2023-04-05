// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

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

    uint[6] public winningNumbers;
    uint256[] boughtTickets;
    bool winnerFound = false;
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
        || _numTickets == 25 || _numTickets == 50 || _numTickets == maxTicketsPerBatch, "amount of tickets not allowed");
        require(msg.value == ticketPrice * _numTickets, "insufficient funds to buy tickets");
        // add tickets to sender's account
        tickets[msg.sender].push(_numTickets);
        boughtTickets.push(_numTickets);
        ticketToUser[_numTickets] = msg.sender;
        // check if required balance is reached 
        if(address(this).balance >= requiredBalance) { 
            drawLottery();
        }

        return _numTickets;
    }

    function test() public {
        uint256[6] memory numbers;
        for(uint i = 0; i < 6; i++) {
            uint256 random = uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, block.coinbase))) % 69 + 1;
            numbers[i] =  random;
        }
        winningNumbers = numbers;
    }

    function drawLottery() internal onlyReachBalance {
        uint256 long =  boughtTickets.length;
        require(long > 0, "not tickets bought");
        uint256[6] memory numbers;
        uint256 n = 30;
        uint256 blockNumber = block.number;
        while(!winnerFound) {
            uint256 random = uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, block.coinbase))) % 69 + 1;
            for(uint i = 0; i < 6; i++) {
                numbers[i] =  random;
            }
        
        winningNumbers = numbers;
        uint256 selectRn = boughtTickets[random];
        winner = ticketToUser[selectRn];
            if(winner != address(0)) {
                winnerFound = true;
            } else {
                blockNumber += n;
                while(block.number < blockNumber) {}
            }
        }
        winnerFound = true;

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