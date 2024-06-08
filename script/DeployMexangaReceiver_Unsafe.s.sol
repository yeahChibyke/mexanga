// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {MexangaReceiver_Unsafe} from "../src/MexangaReceiver_Unsafe.sol";

contract DeployMexengaReceiver_Unsafe is Script {
    function run() public {
        vm.startBroadcast();

        address sepoliaRouter = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;

        MexangaReceiver_Unsafe receiver = new MexangaReceiver_Unsafe(
            sepoliaRouter
        );

        console2.log(
            "MexangaReceiver_Unsafe has been deployed to ", address(receiver)
        );

        vm.stopBroadcast();
    }
}
