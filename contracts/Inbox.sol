pragma solidity ^0.4.17;
// linter warnings (red underline) about pragma version can igonored!
contract SendMoney {
    string public total;
    
    constructor(string initialTotal) public {
        total = initialTotal;
    }
    
    function stackSats(string satsTotal) public {
        total = satsTotal;
    }
}
