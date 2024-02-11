// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

// An example contract working with the Coordinator
contract OutputCollector is Ownable {
    // The mapping of the request id to the output
    mapping(uint => string) public outputs;

    // Coordinator contract address
    address public coordinator;

    // The event for the response
    event ResponseEvent(uint requestId, string output);

    // Constructor for owner
    constructor(address _address) Ownable(_address) {}

    // The function to get the output
    function getOutput(uint _id) public view returns (string memory) {
        return outputs[_id];
    }

    // The function to set the coordinator address
    function setCoordinator(address _coordinator) public onlyOwner {
        coordinator = _coordinator;
    }

    // The function to set the output
    function setOutput(uint _id, string memory _output) public {
        require(msg.sender == coordinator, "Only coordinator can set the output");
        outputs[_id] = _output;
        emit ResponseEvent(_id, _output);
    }
}
