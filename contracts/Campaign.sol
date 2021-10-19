pragma solidity ^0.4.17;

contract Campaign{
    struct Request{
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount; //if this is more than 50% of approvers then the Request will be successfull
        mapping(address => bool) approvals; //approvals for particular requests
    }
    
    Request[] public requests;
    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public approvers; //list of people that contributed and can now approve requests
    uint public approversCount;  //could be approvers.length
    modifier restricted(){
        require(msg.sender == manager);
        _;
    }
    
    constructor(uint minimum) public {
        manager = msg.sender;
        minimumContribution = minimum;
    }

    function contribute() public payable{
        require(msg.value > minimumContribution);
        approvers[msg.sender] = true;
        approversCount++;
        
    }
    function createRequest(string description, uint value, address recipient)
    public restricted {
         Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });
        requests.push(newRequest);
    }
    function approveRequest(uint index) public {
        Request storage request = requests[index];
        
        require(approvers[msg.sender]); //check if the approver contributed first
        require(!request.approvals[msg.sender]); // check if the approver has already approved this request 
        
        request.approvals[msg.sender] = true; //all checks done approve the request
        request.approvalCount++;
    }
    function finalizeRequest(uint index) public restricted{
        Request storage request = requests[index];
        require(request.approvalCount > (approversCount / 2));
        require(!request.complete);
        
         request.recipient.transfer(request.value);
         request.complete = true;
    }
}