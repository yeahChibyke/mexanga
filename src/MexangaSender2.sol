// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

/**
 * @title - Mexanga; a contract for messaging across chains, utilizing chainlink CCIP
 * @author - @yeahChibyke
 * @notice - Initial versions of contracts culled from official @chainlink CCIP docs
 */

contract MexangaSender2 is OwnerIsCreator {
    // -- Errors -- //
    // Event emitted when a message is sent to another chain
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Ensures contract has enough balance

    // -- Events -- //
    // Event emitted when a message is sent to another chain
    event MessageSent(
        bytes32 indexed messageId, // Unique ID of CCIP message
        uint64 indexed destinationChainSelector, // Chain selector of destination chain
        address receiver, // Address of receiver on destination chain
        string text, // Text to be sent
        address feeToken, // Token address used to pay CCIP fees
        uint256 fees // Fees paid for sending CCIP message
    );

    IRouterClient private s_router;
    LinkTokenInterface private s_linkToken;

    /// @notice Constructor initializes the contract with the router address
    /// @param _router The address of the router contract
    /// @param _link The address of the link contract
    constructor(address _router, address _link) {
        s_router = IRouterClient(_router);
        s_linkToken = LinkTokenInterface(_link);
    }

    /// @notice Sends data to receiver on the destination chain
    /// @dev Assumes your contract has sufficient LINK
    /// @param destinationChainSelector The identifier (aka selector) for the destination blockchain
    /// @param receiver The address of the recipient on the destination blockchain
    /// @param text The string text to be sent
    /// @return messageId The ID of the message that was sent
    function sendMessage(
        uint64 destinationChainSelector,
        address receiver,
        string calldata text
    ) external onlyOwner returns (bytes32 messageId) {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver), // ABI-encoded receiver address
            data: abi.encode(text), // ABI-encoded string
            tokenAmounts: new Client.EVMTokenAmount[](0), // Empty array indicating no tokens are being sent
            extraArgs: Client._argsToBytes(
                // Additional arguments, setting gas limit
                Client.EVMExtraArgsV1({gasLimit: 200_000})
            ),
            // Set the feeToken  address, indicating LINK will be used for fees
            feeToken: address(s_linkToken)
        });

        // Get the fee required to send the message
        uint256 fees = s_router.getFee(
            destinationChainSelector,
            evm2AnyMessage
        );

        if (fees > s_linkToken.balanceOf(address(this)))
            revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);

        // approve the Router to transfer LINK tokens on contract's behalf. It will spend the fees in LINK
        s_linkToken.approve(address(s_router), fees);

        // Send the message through the router and store the returned message ID
        messageId = s_router.ccipSend(destinationChainSelector, evm2AnyMessage);

        // Emit an event with message details
        emit MessageSent(
            messageId,
            destinationChainSelector,
            receiver,
            text,
            address(s_linkToken),
            fees
        );

        // Return the message ID
        return messageId;
    }
}
