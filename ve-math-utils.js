/**
 * Predicts the voting power of a user at a specific future timestamp
 */
function calculateDecayedPower(lockedAmount, unlockTimestamp, targetTimestamp) {
    const MAX_TIME = 4 * 365 * 86400;
    
    if (targetTimestamp >= unlockTimestamp) {
        return 0;
    }

    const timeLeft = unlockTimestamp - targetTimestamp;
    return (BigInt(lockedAmount) * BigInt(timeLeft)) / BigInt(MAX_TIME);
}

module.exports = { calculateDecayedPower };
