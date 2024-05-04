// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BeansOnBase} from "../src/BeansOnBase.sol";
import {Script} from "forge-std/script.sol";
import {console2} from "forge-std/console2.sol";

contract DeployBeans is Script {
    function run() public {
        vm.broadcast();
        BeansOnBase beans = new BeansOnBase{salt: keccak256("BEANS_V2")}({
            _baseURI: "https://prevail-labs.vercel.app/api/image/",
            _owner: 0xb8c18E036d46c5FB94d7DeBaAeD92aFabe65EE61,
            _roaster: 0x037187C1e43250E3a65f04F748Aa4363aA8B5268,
            _dev: 0xb8c18E036d46c5FB94d7DeBaAeD92aFabe65EE61,
            _grower: 0xE6857A475e4a6a0c698582D007F4c785801dE417
        });

        console2.log("Beans deployed at address: {}", address(beans));
    }
}
