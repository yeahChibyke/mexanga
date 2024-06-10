// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {Withdraw} from "./utils/Withdraw.sol";

/**
 * @title Mexanga - a contract for messaging across different chains, utilizing chainlink CCIP
 * @author @yeahChibyke
 * @notice Initial versions of contracts culled from official @chainlink CCIP docs
 * @notice Sender contract for Mexanga
 */
contract MexangaBasicSender is Withdraw {
    enum PayFeesIn {
        Native,
        LINK
    }

    address immutable i_router;
    address immutable i_link;

    event MessageSent(bytes32 messageId);

    /// @notice Constructor initializes the contract with the router address
    /// @param router Addresa of router contract
    /// @param link Address of the LINK contract
    constructor(address router, address link) {
        i_router = router;
        i_link = link;
    }

    receive() external payable {}

    /// @notice Sends data receiver on the destination chain
    /// @param destinationChainSelector The identifier (aka selector) for the destination blockchain
    /// @param receiver The address of the recipient on the destination blockchain
    /// @param messageText The string text to be sent
    /// @param payFeesIn 
    function send(
        uint64 destinationChainSelector,
        address receiver,
        string memory messageText,
        PayFeesIn payFeesIn
    ) external returns (bytes32 messageId) {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encode(messageText),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: payFeesIn == PayFeesIn.LINK ? i_link : address(0)
        });

        uint256 fee = IRouterClient(i_router).getFee(
            destinationChainSelector,
            message
        );

        if (payFeesIn == PayFeesIn.LINK) {
            LinkTokenInterface(i_link).approve(i_router, fee);
            messageId = IRouterClient(i_router).ccipSend(
                destinationChainSelector,
                message
            );
        } else {
            messageId = IRouterClient(i_router).ccipSend{value: fee}(
                destinationChainSelector,
                message
            );
        }

        emit MessageSent(messageId);
    }
}
