/* to see if it works correctly for not
deploying vulnerable code that could make
someone lose real money. */

pragma solidity ^0.4.11;

contract Casino {
  address public owner;
  uint256 public minimumBet = 100 finney;
  uint256 public totalBet;
  uint256 public numberOfBets;
  uint256 public maxAmountOfBets = 10;
  address[] public players;

  struct Player {
    uint256 amountBet;
    uint256 numberSelected;
  }

  mapping(address => Player) public playerInfo;

// fallback function, executed when you send ether to contract without executing
// any function
  function() public payable {}

// constructor wherein we assign owner as the one who sent the message
  function Casino(uint256 _minimumBet) public{
    owner = msg.sender;
    if (_minimumBet != 0) minimumBet = _minimumBet;
  }

// kill the contract if the owner wants to
  function kill() public {
    if(msg.sender == owner) selfdestruct(owner);
  }

// constant specifies that it is reading a value that already exists from
// the blockchain
  function checkPlayerExists(address player)public returns(bool) {
    for (uint256 i = 0; i < players.length; i++){
      if(players[i] == player) return true;
    }
    return false;
  }


// payable is a modifier that indicates that the function can receive
// ether when you execute it.
  function bet(uint256 numberSelected) public payable {
// the require function is like if statement, must be true for ether payment
// if false then payment reverted
    require(!checkPlayerExists(msg.sender));
    require(numberSelected >= 1 && numberSelected <= 10);
    require(msg.value >= minimumBet);

    playerInfo[msg.sender].amountBet = msg.value;
    playerInfo[msg.sender].numberSelected = numberSelected;
    numberOfBets ++;
    players.push(msg.sender);
    totalBet += msg.value;

  }

// generates a number between 1 and 10 that will be winner
  function generateNumberWinner() public {
    // insecure method since miners can extract block number and determine winner
    uint256 numberGenerated = block.number % 10 + 1;
    distributePrizes(numberGenerated);
  }


  // sends the corresponding ether to each winner depending on total bets
  function distributePrizes(uint256 numberWinner) public {
    //temp array
    address[100] memory winners;
    uint256 count = 0;
    for(uint256 i = 0; i < players.length; i++){
      address playerAddress = players[i];
      if (playerInfo[playerAddress].numberSelected == numberWinner){
        winners[count] = playerAddress;
        count ++;
      }
      // Delete all players
      delete playerInfo[playerAddress];
    }
    // delte all the players array
    players.length = 0;

    uint256 winnerEtherAmount  = totalBet / winners.length;

    for(uint256 j = 0; j < count; j++){
      //check address is not empty
      if(winners[j] != address(0))
      winners[j].transfer(winnerEtherAmount);
    }
    totalBet = 0;
    numberOfBets = 0;
  }
}
