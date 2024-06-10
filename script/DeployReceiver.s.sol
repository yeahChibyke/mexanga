// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {Helper} from "./Helper.sol";
import {MexangaReceiver} from "../src/MexangaReceiver.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";

contract DeployMexangaReceiver is Script, Helper {
    function run(SupportedNetworks destination) external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        (address router, , , ) = getConfigFromNetwork(destination);

        MexangaReceiver mexangaReceiver = new MexangaReceiver(router);

        console2.log(
            "MexangaReceiver deployed on ",
            networks[destination],
            "with address: ",
            address(mexangaReceiver)
        );

        vm.stopBroadcast();
    }
}

contract CCIPTokenTransfer is Script, Helper {
    function run(
        SupportedNetworks source,
        SupportedNetworks destination,
        address mexangaReceiver,
        address tokenToSend,
        uint256 amount,
        PayFeesIn payFeesIn
    ) external returns (bytes32 messageId) {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);

        (address sourceRouter, address linkToken, , ) = getConfigFromNetwork(
            source
        );
        (, , , uint64 destinationChainId) = getConfigFromNetwork(destination);

        IERC20(tokenToSend).approve(sourceRouter, amount);

        Client.EVMTokenAmount[]
            memory tokensToSendDetails = new Client.EVMTokenAmount[](1);
        Client.EVMTokenAmount memory tokenToSendDetails = Client
            .EVMTokenAmount({token: tokenToSend, amount: amount});

        tokensToSendDetails[0] = tokenToSendDetails;

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(mexangaReceiver),
            data: "",
            tokenAmounts: tokensToSendDetails,
            extraArgs: "",
            feeToken: payFeesIn == PayFeesIn.LINK ? linkToken : address(0)
        });

        uint256 fees = IRouterClient(sourceRouter).getFee(
            destinationChainId,
            message
        );

        if (payFeesIn == PayFeesIn.LINK) {
            IERC20(linkToken).approve(sourceRouter, fees);
            messageId = IRouterClient(sourceRouter).ccipSend(
                destinationChainId,
                message
            );
        } else {
            messageId = IRouterClient(sourceRouter).ccipSend{value: fees}(
                destinationChainId,
                message
            );
        }

        console2.log(
            "You can now monitor the status of your Chainlink CCIP Message via https://ccip.chain.link using CCIP Message ID: "
        );
        console2.logBytes32(messageId);

        vm.stopBroadcast();
    }
}

contract GetLatestMessageDetails is Script, Helper {
    function run(address mexengaReceiver) external view {
        (
            bytes32 latestMessageId,
            uint64 latestSourceChainSelector,
            address latestSender,
            string memory latestMessage
        ) = MexangaReceiver(mexengaReceiver).getLatestMessageDetails();

        console2.log("Latest Message ID: ");
        console2.logBytes32(latestMessageId);
        console2.log("Latest Source Chain Selector: ");
        console2.log(latestSourceChainSelector);
        console2.log("Latest Sender: ");
        console2.log(latestSender);
        console2.log("Latest Message: ");
        console2.log(latestMessage);
    }
}
