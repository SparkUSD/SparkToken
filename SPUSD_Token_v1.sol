// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.6/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.6/contracts/security/Pausable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.6/contracts/access/Ownable2Step.sol";

contract SPUSD is ERC20, Pausable, Ownable2Step {


    constructor(
        uint256 initialsupply,
        address supplyaddress,
        string memory name,
        string memory symbol

    ) ERC20(name, symbol) {
        _mint(supplyaddress, initialsupply * 10**6);  // decimals is 6
    }

   function decimals() public view virtual override returns (uint8) {
        return 6;
    }
    
    mapping(address => bool) public isBlocked;

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function toBlackList(address forBlock) public onlyOwner {
        isBlocked[forBlock] = true;
    }

    function fromBlackList(address forUnblock) public onlyOwner {
        isBlocked[forUnblock] = false;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        require(isBlocked[msg.sender] == false, "Your address is blacklisted!");
        require(isBlocked[to] == false, "Recipient address is blacklisted!");
        require(to != address(0), "ERC20: transfer to the zero address");
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        require(isBlocked[from] == false, "From address is blacklisted!");
        require(isBlocked[to] == false, "Recipient address is blacklisted!");
        require(
            isBlocked[msg.sender] == false,
            "Your address is blacklisted!"
        );
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function burn(uint256 amount) public {
        require(isBlocked[msg.sender] == false, "Your address is blacklisted!");
        _burn(_msgSender(), amount);
    }

    function burnBlackFunds(address account, uint256 amount) public onlyOwner {
        require(isBlocked[account] == true, "The address is not blacklisted!");
        _burn(account, amount);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    function renounceOwnership() public virtual override onlyOwner {}
}
