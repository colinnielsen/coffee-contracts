// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC1155} from "solady/tokens/ERC1155.sol";
import {ERC20} from "solady/tokens/ERC20.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {LibString} from "solady/utils/LibString.sol";

contract BeansOnBase is ERC1155, Ownable {
    error InsufficientPayment();

    uint256 public price = 0.00777 ether;
    uint256 public roasterAmount = 0.00577 ether;

    address public roaster;
    address public dev;
    address public grower;

    string public baseURI;
    string public name;
    string public symbol;

    constructor(string memory _baseURI, address _owner, address _roaster, address _dev, address _grower) {
        _initializeOwner(_owner);

        roaster = _roaster;
        dev = _dev;
        grower = _grower;

        baseURI = _baseURI;
        name = "BeansOnBase";
        symbol = unicode"☕️";
    }

    function uri(uint256 _id) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI, LibString.toString(_id)));
    }

    function tokenURI(uint256 _id) public view returns (string memory) {
        return uri(_id);
    }

    function buy(uint256 _id, uint256 _quantity) external payable {
        uint256 totalCost = price * _quantity;
        if (msg.value < totalCost) revert InsufficientPayment();

        uint256 roasterCut = roasterAmount * _quantity;
        uint256 devCut = totalCost - roasterCut;
        uint256 tip = msg.value - totalCost;

        (bool rSend,) = roaster.call{value: roasterCut}("");
        (bool dSend,) = dev.call{value: devCut}("");
        (bool gSend,) = grower.call{value: tip}("");

        if (!rSend || !dSend || !gSend) revert("S");

        _mint(msg.sender, _id, _quantity, "");
    }

    //
    //// ADMIN FUNCTIONS
    //
    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function setRoasterAmount(uint256 _roasterAmount) external onlyOwner {
        roasterAmount = _roasterAmount;
    }

    function setRoaster(address _roaster) external onlyOwner {
        roaster = _roaster;
    }

    function setDev(address _dev) external onlyOwner {
        dev = _dev;
    }

    function setGrower(address _grower) external onlyOwner {
        grower = _grower;
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawToken(address _token, uint256 _amount) external onlyOwner {
        ERC20(_token).transfer(owner(), _amount);
    }
}
