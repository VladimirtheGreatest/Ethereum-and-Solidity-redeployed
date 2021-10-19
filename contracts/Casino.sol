pragma solidity ^0.4.17;


contract Casino{
    struct Deposit{
        uint value;
        address gambler;
    }
    
    Deposit[] public deposits;
    address public house;
    uint public minimumContribution;
    address[] public players;
    uint public progressiveJackpot;
    bool locked = false;  //maybe add some counter for players, 
    
    //house cannot make deposits or play the game that would not be fair
    modifier restricted(){
        require(msg.sender != house); 
        _;
    }
    
    constructor(uint minimum, uint progressiveJackpotGuarantee) public {
        house = msg.sender;
        minimumContribution = minimum;
        progressiveJackpot = progressiveJackpotGuarantee;
    }

    function deposit() public restricted payable{
        require(msg.value > minimumContribution);
        players.push(msg.sender); //with every deposit you increase your chance to win the jackpot
        progressiveJackpot += msg.value; //increase the progressive jackpot with every deposit
        
        if(checkDeposits(deposits,msg.sender)){  //check if we have a deposit for this player
        
        for (uint i = 0; i < deposits.length; i++) { 
        if (deposits[i].gambler == msg.sender) { 
            deposits[i].value += msg.value;       //if the player deposited before add additional deposit to his account
          } 
         }
       } else  { //we have not found deposit so create a new one
             Deposit memory newDeposit =  Deposit({  //try mapping address integer
            value: msg.value,
            gambler: msg.sender
        });
        deposits.push(newDeposit);
       }
    }
    
        function play() public restricted returns(string memory response) {
        if(checkBalance() < minimumContribution){
                revert("Please deposit first");
        }
        for (uint i = 0; i < deposits.length; i++) { 
        if (deposits[i].gambler == msg.sender && deposits[i].value >= minimumContribution) { 
            deposits[i].value -= minimumContribution;       //if the player deposited before deduct the playing fee from his account
            //logic for winning and loosing here, also to hit the jackpot
            if(players.length > 10){
             uint randomNumber = random() % players.length;
             if(randomNumber > 10){ //need to come up with a better logic
                 pickWinner();
             }
            }
            return "success";
          } 
         }
    }
    
       function random() private view returns(uint) {
    return uint(keccak256(abi.encodePacked(block.difficulty, players, now)));
    }
    
    function pickWinner() private {
        uint index = random() % players.length;
        require(!locked, "Reentrant call detected!");  //Use a Reentrancy Guard
       locked = true;
       (bool successWinnerTransfer) = players[index].call.value((address(this).balance / 100) * 90)(""); //90% from progressive jackpot goes to the winner
        require(successWinnerTransfer, "Transfer to the winner failed.");
       // players[index].transfer(address(this).balance * 0.9); 
       // house.transfer(address(this).balance); 
        (bool successHouseTransfer) = house.call.value(address(this).balance)(""); // 10% rake fee for the house
        require(successHouseTransfer, "Transfer to house failed.");
        players = new address[](0);   //reset the lottery
        progressiveJackpot = 0;  
        locked = false;
    }
    

    function checkBalance() public restricted view returns(uint balance){
           require(
            checkDeposits(deposits, msg.sender),
            "Could not find deposit this player."
        );
        for (uint i = 0; i < deposits.length; i++) { 
        if (deposits[i].gambler == msg.sender) { 
        return deposits[i].value;
        } 
      }
    }
    
    function checkProgressiveJackpot() public restricted view returns(uint jackpot){
           return progressiveJackpot;
    }
    
        function checkDeposits(Deposit[] memory array, address sender)private pure returns(bool isTrue) {
     for (uint i = 0; i < array.length; i++) { 
        if (array[i].gambler == sender) { 
        return true;
        } 
      }
    }
    
    
    //converts uint to string
     function uint2str (uint256 _i) internal pure returns (string memory str) {
      if (_i == 0)
      {
        return "0";
      }
      uint256 j = _i;
      uint256 length;
      while (j != 0)
      {
        length++;
        j /= 10;
      }
      bytes memory bstr = new bytes(length);
      uint256 k = length;
      j = _i;
      while (j != 0)
      {
        bstr[--k] = bytes1(uint8(48 + j % 10));
        j /= 10;
      }
      str =  string(abi.encodePacked("Please make a deposit of at least ", bstr));  //string concatenation is not supported yet so this hack
     }
}