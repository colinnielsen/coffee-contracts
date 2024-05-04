// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {BeansOnBase} from "../src/BeansOnBase.sol";

contract BeansTest is Test {
    BeansOnBase public beans;

    address public dev = address(0x01);
    address public grower = address(0x02);
    address public roaster = address(0x03F);
    address public user = address(0x0456);

    function setUp() public {
        beans = new BeansOnBase("https://google.com/", dev, roaster, dev, grower);
    }

    function testBuy(uint64 tip, uint64 quantity) public {
        vm.deal(user, uint256(1 ether) * quantity + tip);

        assertEq(beans.balanceOf(user, 1), 0);
        assertEq(address(beans.roaster()).balance, 0);
        assertEq(address(beans.dev()).balance, 0);
        assertEq(address(beans.grower()).balance, 0);

        vm.startPrank(user);
        beans.buy{value: (beans.price() * quantity) + tip}(1, quantity);
        vm.stopPrank();

        assertEq(beans.balanceOf(user, 1), quantity);
        // roaster gets the roast amount * quantity
        assertEq(address(beans.roaster()).balance, beans.roasterAmount() * quantity);
        // dev gets the rest
        assertEq(address(beans.dev()).balance, beans.price() * quantity - beans.roasterAmount() * quantity);
        // grower gets any remaining funds
        assertEq(address(beans.grower()).balance, tip);

        assertEq(beans.uri(1), "https://google.com/1");
    }

    function testAdminFunctions() public {
        vm.startPrank(dev);
        beans.setBaseURI("https://yahoo.com");
        assertEq(beans.baseURI(), "https://yahoo.com");

        beans.setPrice(0.001 ether);
        assertEq(beans.price(), 0.001 ether);

        beans.setRoasterAmount(0.0005 ether);
        assertEq(beans.roasterAmount(), 0.0005 ether);

        beans.setRoaster(address(0x04));
        assertEq(beans.roaster(), address(0x04));

        beans.setDev(address(0x05));
        assertEq(beans.dev(), address(0x05));

        beans.setGrower(address(0x06));
        assertEq(beans.grower(), address(0x06));

        beans.transferOwnership(roaster);
        assertEq(beans.owner(), roaster);
    }

    function testNonAdminFunctions() public {
        bytes memory unauthedSel = abi.encodeWithSignature("Unauthorized()");

        vm.startPrank(address(0x12351254214124));
        vm.expectRevert();
        beans.setBaseURI("https://yahoo.com");

        vm.expectRevert(unauthedSel);
        beans.setPrice(0.001 ether);

        vm.expectRevert(unauthedSel);
        beans.setRoasterAmount(0.0005 ether);

        vm.expectRevert(unauthedSel);
        beans.setRoaster(address(0x04));

        vm.expectRevert(unauthedSel);
        beans.setDev(address(0x05));

        vm.expectRevert(unauthedSel);
        beans.setGrower(address(0x06));

        vm.expectRevert(unauthedSel);
        beans.transferOwnership(roaster);
    }
}
