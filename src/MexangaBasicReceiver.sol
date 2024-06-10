// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {Withdraw} from "./utils/Withdraw.sol";

/**
 * @title Mexanga - a contract for messaging across different chains, utilizing chainlink CCIP
 * @author @yeahChibyke
 * @notice Initial versions of contracts culled from official @chainlink CCIP docs
 * @notice Receiver contract for Mexanga
 */
contract BasicMessageReceiver is CCIPReceiver, Withdraw {
    bytes32 latestMessageId; // Unique ID of last message received
    uint64 latestSourceChainSelector; // Chain selector of the source chain
    address latestSender; // Address of sender of last message recived
    string latestMessage; // Last message that was received

    event MessageReceived(
        bytes32 latestMessageId, 
        uint64 latestSourceChainSelector, 
        address latestSender, 
        string latestMessage 
    );

    /// @notice Constructor initializes the contract with the router address
    /// @param router The address of the router contract
    constructor(address router) CCIPReceiver(router) {}

    /// @notice Handles a received message
    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        latestMessageId = message.messageId;
        latestSourceChainSelector = message.sourceChainSelector;
        latestSender = abi.decode(message.sender, (address));
        latestMessage = abi.decode(message.data, (string));

        emit MessageReceived(
            latestMessageId,
            latestSourceChainSelector,
            latestSender,
            latestMessage
        );
    }

    /// @notice Fetches the details of the last received message
    /// @return latestMessageId The ID of the last received message
    /// @return latestSourceChainSelector The chain selector of the source chain
    /// @return latestSender The address of the last sender
    /// @return latestMessage The last received message
    function getLatestMessageDetails()
        public
        view
        returns (bytes32, uint64, address, string memory)
    {
        return (
            latestMessageId,
            latestSourceChainSelector,
            latestSender,
            latestMessage
        );
    }
}
