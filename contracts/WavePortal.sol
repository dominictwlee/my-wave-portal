// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    struct Wave {
        string message;
        uint timestamp;
    }

    struct Waver {
        address addr;
        Wave[] waves;
        uint waveCount;
        uint lastWavedAt;
    }

    uint totalWaves;
    uint private seed;

    address[3] leaderBoard;

    event NewWaveCreated(address indexed from, uint timestamp, string message);

    mapping(address => Waver) wavers;

    constructor() payable {}

    function wave(string memory _message) public rateLimitWave {
        uint currentTimestamp = block.timestamp;
        totalWaves += 1;

        if (wavers[msg.sender].addr == address(0)) {
            wavers[msg.sender].addr = msg.sender;
        }
        wavers[msg.sender].waves.push(Wave(_message, currentTimestamp));
        wavers[msg.sender].waveCount += 1;
        wavers[msg.sender].lastWavedAt = currentTimestamp;

        uint totalSenderWaves = wavers[msg.sender].waveCount;
        console.log("%s has waved %d times", msg.sender, totalSenderWaves);

        emit NewWaveCreated(msg.sender, block.timestamp, _message);

        reorderLeaderBoard(wavers[msg.sender]);

        uint randomNumber = generatePseudoRandomNumber();
        console.log("Random # generated %d", randomNumber);
        if (randomNumber < 50) {
            givePrize(0.0001 ether);
        }
    }

    modifier rateLimitWave() {
        require(
            wavers[msg.sender].lastWavedAt + 15 minutes < block.timestamp,
            "Waved recently, please wait 15m and try again"
        );
        _;
    }

    modifier onlySufficientFunds(uint prizeAmount) {
        require(prizeAmount <= address(this).balance, "Insufficient funds");
        _;
    }

    function generatePseudoRandomNumber() private view returns (uint) {
        return (block.difficulty + block.timestamp + seed) % 100;
    }

    function givePrize(uint prizeAmount) private onlySufficientFunds(prizeAmount) {
        (bool success, ) = (msg.sender).call{value: prizeAmount}("");
        require(success, "Failed to withdraw money from contract");
    }

    function reorderLeaderBoard(Waver memory newContender) private returns (int) {
        uint insertionIndex = 0;

        for (insertionIndex; insertionIndex < leaderBoard.length; insertionIndex++) {
            uint topWaveCount = wavers[leaderBoard[insertionIndex]].waveCount;
            if (topWaveCount < newContender.waveCount) {
                break;
            }
        }

        for (uint i = leaderBoard.length - 1; i > insertionIndex; i--) {
            if (leaderBoard[i - 1] == newContender.addr) {
                leaderBoard[i] = address(0);
            } else {
                leaderBoard[i] = leaderBoard[i - 1];
            }
        }
        leaderBoard[insertionIndex] = newContender.addr;

        return int(insertionIndex);
    }

    function getTotalWaves() public view returns (uint) {
        console.log("We have %d total waves", totalWaves);
        return totalWaves;
    }

    function getLeaderBoard() public view returns (address[3] memory) {
        return leaderBoard;
    }

    function getWaver(address addr) public view returns (Waver memory) {
        return wavers[addr];
    }
}
