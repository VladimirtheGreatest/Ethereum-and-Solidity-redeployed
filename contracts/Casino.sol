pragma solidity >=0.7.0 <0.9.0;

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
    
    //house cannot make deposits or play the game that would not be fair
    modifier restricted(){
        require(msg.sender != house); 
        _;
    }
    
    constructor(uint minimum, uint progressiveJackpotGuarantee) {
        house = msg.sender;
        minimumContribution = minimum;
        progressiveJackpotGuarantee = progressiveJackpot;
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
             Deposit memory newDeposit =  Deposit({
            value: msg.value,
            gambler: msg.sender
        });
        deposits.push(newDeposit);
       }
    }
    
        function play() public restricted returns(string memory response) {
        if(checkDeposits(deposits,msg.sender)){
        for (uint i = 0; i < deposits.length; i++) { 
        if (deposits[i].gambler == msg.sender &&  deposits[i].value >= minimumContribution) { 
            deposits[i].value -= minimumContribution;       //if the player deposited before deduct the playing fee from his account
            //logic for winning and loosing here, also to hit the jackpot
            return "success";
          } 
         }
       } else  { //we have not found deposit so tell the player to deposit first
           return uint2str(minimumContribution);
        }
    
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