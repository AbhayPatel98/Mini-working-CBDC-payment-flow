## Escrow Payment Smart Contract

This contract implements a conditional payment escrow with dispute resolution.

### Flow
1. Buyer funds escrow
2. Seller delivers goods/service
3. Buyer releases funds OR raises a dispute
4. Arbitrator resolves dispute
5. Funds settle with the seller or are refunded

### States
- CREATED
- FUNDED
- DELIVERED
- DISPUTE
- SETTLED

### Functions
- fund() — buyer locks funds
- markDelivered() - seller confirms delivery
- releaseFunds() - buyer releases payment
- raiseDispute() - buyer/seller raises dispute
- resolveDispute() - arbitrator settles
