// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

// This is the template contract for the Coordinator
// This coordinator will be responsible for managing the requests from the users.
// Users' requests include the input data, the model id they want to run, the 
// callback contract address, and the callback function in that contract.
// Backend nodes will listen to events, run specific models with the given input,
// and upload model's output to the coordinator.
// The coordinator will then call the callback function in the specified contract
// and pass the output to the callback function.
contract Coordinator {

    // The request struct
    struct Request {
        address user;
        string modelId;
        string input;
        address callbackContract;
        string callbackFunction; // something like myFunction(uint256)
    }

    // The mapping of request id to the request struct
    mapping(uint => Request) public requests;

    // The mapping of the request id to the output
    mapping(uint => string) public outputs;

    // The mapping of the request id to the status of the request
    mapping(uint => bool) public requestStatus;

    // The event for the request
    event RequestEvent(uint requestId, address user, string modelId, string input, address callbackContract, string callbackFunction);

    // The event for the response
    event ResponseEvent(uint requestId, string output);

    // Constructor
    constructor() {}

    // The function to make a request
    function makeRequest(string memory _modelId, string memory _input, address _callbackContract, string memory _callbackFunction) public {
        uint requestId = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _modelId, _input, _callbackContract, _callbackFunction)));
        requests[requestId] = Request(msg.sender, _modelId, _input, _callbackContract, _callbackFunction);
        requestStatus[requestId] = false;
        emit RequestEvent(requestId, msg.sender, _modelId, _input, _callbackContract, _callbackFunction);
    }

    // The function to get the request details
    function getRequest(uint _id) public view returns (address, string memory, string memory, address, string memory, bool) {
        return (requests[_id].user, requests[_id].modelId, requests[_id].input, requests[_id].callbackContract, requests[_id].callbackFunction, requestStatus[_id]);
    }

    // The function to get the output
    function getOutput(uint _id) public view returns (string memory) {
        return outputs[_id];
    }

    // Fullfill the request by setting the output and calling the callback function
    function fulfillRequest(uint _id, string memory _output) public {
        outputs[_id] = _output;
        requestStatus[_id] = true;
        emit ResponseEvent(_id, _output);
        (bool success, ) = requests[_id].callbackContract.call(abi.encodeWithSignature(requests[_id].callbackFunction, _id, _output));
        require(success, "Callback function call failed");
    }
}