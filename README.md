# Vote-Escrowed Tokenomics Engine

This repository provides an expert-level implementation of the `ve` (vote-escrow) model, popularized by Curve Finance. It allows protocols to align long-term holder incentives by tying governance power to the duration of token locks.

### Core Mechanics
* **Locking:** Users lock a base ERC20 token for a period ranging from 1 week to 4 years.
* **Decaying Voting Power:** Voting weight is highest at the moment of locking and decays linearly as the unlock date approaches.
* **Boosted Rewards:** Integrates with gauge systems to provide higher yield to users with significant `ve` balances.
* **Non-Transferable:** `veTokens` are typically non-transferable account-bound balances to prevent the sale of governance influence.

### Technical Stack
* **Solidity ^0.8.20**
* **Linear Decay Mathematics:** Efficient on-chain calculation of power at any given timestamp.
