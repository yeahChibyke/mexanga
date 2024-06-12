// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {Helper} from "./Helper.sol";
import {MexangaSender} from "../src/MexangaSender.sol";

contract DeployMexangaSender is Script, Helper {
    function run(SupportedNetworks source) external {
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast();

        (address router, address link, , ) = getConfigFromNetwork(source);

        MexangaSender mexangaSender = new MexangaSender(router, link);

        console2.log(
            "MexangaSender contract deployed on ",
            networks[source],
            "with address: ",
            address(mexangaSender)
        );

        vm.stopBroadcast();
    }
} 

contract SendMessage is Script, Helper {
    function run(
        address payable sender,
        SupportedNetworks destination,
        address receiver,
        string memory message,
        MexangaSender.PayFeesIn payFeesIn
    ) external {
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast();

        (, , , uint64 destinationChainId) = getConfigFromNetwork(destination);

        bytes32 messageId = MexangaSender(sender).send(
            destinationChainId,
            receiver,
            message,
            payFeesIn
        );

        console2.log(
            "You can now monitor the status of your Chainlink CCIP Message via https://ccip.chain.link using CCIP Message ID: "
        );
        console2.logBytes32(messageId);

        vm.stopBroadcast();
    }
}
