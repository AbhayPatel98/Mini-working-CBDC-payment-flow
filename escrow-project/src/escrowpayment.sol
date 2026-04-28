// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EscrowPayment {
    address public buyer;
    address public seller;
    address public arbitrator;

    uint256 public amount;

    enum State { CREATED, FUNDED, DELIVERED, DISPUTE, SETTLED, REFUNDED }

    State public currentState;

    constructor(address _seller, address _arbitrator) {
        buyer = msg.sender;
        seller = _seller;
        arbitrator = _arbitrator;
        currentState = State.CREATED;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer allowed");
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only seller allowed");
        _;
    }

    modifier onlyArbitrator() {
        require(msg.sender == arbitrator, "Only arbitrator allowed");
        _;
    }

    modifier inState(State _state) {
        require(currentState == _state, "Invalid state");
        _;
    }

        // Events
event FundsLocked(address indexed buyer, uint256 amount);

event Delivered(address indexed seller);

event FundsReleased(address indexed seller, uint256 amount);

event Refunded(address indexed buyer, uint256 amount);

event DisputeRaised(address indexed by);


       // Buyer locks funds in escrow
    function lockFunds() external payable onlyBuyer inState(State.CREATED) {
        require(msg.value > 0, "Amount must be > 0");

        amount = msg.value;
        currentState = State.FUNDED;

        emit FundsLocked(buyer, amount);
    }

    //  Seller confirms delivery
    function confirmDelivery() external onlySeller inState(State.FUNDED) {
        currentState = State.DELIVERED;

        emit Delivered(seller);
    }

    // Buyer verifies and releases funds
    function releaseFunds() external onlyBuyer inState(State.DELIVERED) {
        currentState = State.SETTLED;

        payable(seller).transfer(amount);

        emit FundsReleased(seller, amount);
    }

    // Raise dispute if buyer is not satisfied
    function raiseDispute() external inState(State.DELIVERED) {
        require(msg.sender == buyer || msg.sender == seller, "Unauthorized");

        currentState = State.DISPUTE;

        emit DisputeRaised(msg.sender);
    }

    // Arbitrator resolves dispute
    function resolveDispute(bool releaseToSeller) external onlyArbitrator inState(State.DISPUTE) {
        if (releaseToSeller) {
            currentState = State.SETTLED;
            payable(seller).transfer(amount);
            emit FundsReleased(seller, amount);
        } else {
            currentState = State.REFUNDED;
            payable(buyer).transfer(amount);
            emit Refunded(buyer, amount);
        }
    }

    // Emergency refund if buyer changes mind before delivery
    function refundBuyer() external onlyBuyer inState(State.FUNDED) {
        currentState = State.REFUNDED;
        payable(buyer).transfer(amount);

        emit Refunded(buyer, amount);
    }

 
}
