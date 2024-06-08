// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {MexangaSender_Unsafe} from "../src/MexangaSender_Unsafe.sol";

contract DeployMexangaUnsafe is Script {
    function run() public {
        vm.startBroadcast();

        address fujiLink = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;
        address fujiRouter = 0x554472a2720E5E7D5D3C817529aBA05EEd5F82D8;

        MexangaSender_Unsafe sender = new MexangaSender_Unsafe(
            fujiLink,
            fujiRouter
        );

        console2.log(
            "MexangaSender_Unsafe has been deployed to ", address(sender)
        );

        vm.stopBroadcast();
    }
}