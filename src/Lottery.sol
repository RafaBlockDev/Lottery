// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

contract Lottery is VRFConsumerBaseV2 { 
    /// @dev Smart contract owner
    address public owner = payable(0xa6076e139FB8089C9d123dA690726B976E290799); 
    address public secondPrize = payable(0xF3f1cf9E7d7c306C25c18859eDF3a28D04FD1D4F);

    uint public ticketPrice = 0.001 ether; // 1000000000000000 wei
    uint public jackpotAmount = 200 ether;
    uint public requiredBalance = 300 ether;
    uint public maxTicketsPerBatch = 100;
    uint public winningNumbersCount = 6;
    uint public blocksPerDraw = 30;
    uint public lastDrawBlock = 0;

    uint[6] public winningNumbers;
    uint256[] boughtTickets;
    bool winnerFound = false;
    address public winner;

    // VFR Chainlink var
    bytes32 immutable s_keyHash;
    uint256 public fee;
    uint256 randomResult;
    uint256 public s_requestId;
    address s_owner;
    uint64 immutable s_subscriptionId;
    uint16 immutable s_requestConfirmations = 3;
    uint32 public immutable s_numWords = 6;
    uint32 immutable s_callbackGasLimit = 100000;
    uint256[] public s_randomWords;

    uint256[] ranNumbers;
    
    VRFCoordinatorV2Interface immutable COORDINATOR;
    LinkTokenInterface immutable LINKTOKEN;

    event ReturnedRandomness(uint256[] randomWords);
    
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
    
    /**
     * @dev Set VRF COORDINATOR, LINK, KEY HASH, VRF CONSUMER from Matic chainlink adderesses
     */
    constructor(
        uint64 subscriptionId,
        address vrfCoordinator,
        address link,
        bytes32 keyHash
        ) VRFConsumerBaseV2(0x8C7382F9D8f56b33781fE506E897a4F1e2d17255) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link);
        s_keyHash = keyHash;
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
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

    function drawLottery() internal onlyReachBalance {
        uint256 long =  boughtTickets.length;
        require(long > 0, "not tickets bought");
        uint256[6] memory numbers;
        uint256 n = 30;
        uint256 blockNumber = block.number;
        while(!winnerFound) {
            uint256 random = uint256(keccak256(abi.encodePacked(s_randomWords, block.prevrandao, block.timestamp))) % 69 + 1;
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

    /*****************************************/
    /************* VFR FUNCTIONS *************/
    /*****************************************/

    function requestRandomWords() external {
        s_requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            s_requestConfirmations,
            s_callbackGasLimit,
            s_numWords
        );
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        s_randomWords = randomWords;
        emit ReturnedRandomness(randomWords);
    }

    /*******************************/
    /***** GETTER FUNCTIONS ********/
    /*******************************/

    function getTicketsPerUser(address _user) public view returns(uint256[] memory) {
        return tickets[_user];
    }
}