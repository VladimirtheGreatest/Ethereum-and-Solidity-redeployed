pragma solidity ^0.4.17;

contract Campaign {
    struct Request {
        string description;
        uint256 value;
        address recipient;
        bool complete;
        uint256 approvalCount; //if this is more than 50% of approvers then the Request will be successfull
        mapping(address => bool) approvals;
    }

    Request[] public requests;
    address public manager;
    uint256 public minimumContribution;
    mapping(address => bool) public approvers;
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    constructor(uint256 minimum) public {
        manager = msg.sender;
        minimumContribution = minimum;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution);
        approvers[msg.sender] = true;
    }

    function createRequest(
        string description,
        uint256 value,
        address recipient
    ) public restricted {
        // require(approvers[msg.sender]);
        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });
        requests.push(newRequest);
    }

    function approveRequest(uint256 index) public {
        Request storage request = requests[index];

        require(approvers[msg.sender]);
        require(!request.approvals[msg.sender]);

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }
}
