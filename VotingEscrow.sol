// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract VotingEscrow is ReentrancyGuard {
    struct LockedBalance {
        uint256 amount;
        uint256 end;
    }

    IERC20 public immutable token;
    mapping(address => LockedBalance) public locked;
    
    uint256 public constant MAX_TIME = 4 * 365 * 86400; // 4 years
    uint256 public constant WEEK = 7 * 86400;

    event Deposit(address indexed provider, uint256 value, uint256 locktime);
    event Withdraw(address indexed provider, uint256 value);

    constructor(address _token) {
        token = IERC20(_token);
    }

    function create_lock(uint256 _value, uint256 _unlock_time) external nonReentrant {
        require(_value > 0, "Value must be > 0");
        require(locked[msg.sender].amount == 0, "Withdraw old tokens first");
        
        uint256 unlock_time = (_unlock_time / WEEK) * WEEK; // Round to weeks
        require(unlock_time > block.timestamp, "Can only lock in the future");
        require(unlock_time <= block.timestamp + MAX_TIME, "Voting lock can be 4 years max");

        token.transferFrom(msg.sender, address(this), _value);
        
        locked[msg.sender] = LockedBalance({
            amount: _value,
            end: unlock_time
        });

        emit Deposit(msg.sender, _value, unlock_time);
    }

    function balance_of(address _addr) external view returns (uint256) {
        LockedBalance memory _locked = locked[_addr];
        if (_locked.end <= block.timestamp) return 0;
        
        // Simple linear decay: Power = Amount * (TimeLeft / MaxTime)
        uint256 timeLeft = _locked.end - block.timestamp;
        return (_locked.amount * timeLeft) / MAX_TIME;
    }

    function withdraw() external nonReentrant {
        LockedBalance storage _locked = locked[msg.sender];
        require(block.timestamp >= _locked.end, "The lock has not expired");
        
        uint256 value = _locked.amount;
        _locked.amount = 0;
        _locked.end = 0;

        token.transfer(msg.sender, value);
        emit Withdraw(msg.sender, value);
    }
}
