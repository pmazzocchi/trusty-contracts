// SPDX-License-Identifier: MIT

/**
 * 0xRMS TRUSTY v0.1
 * Copyright (c) 2024 Ramzi Bougammoura
 */

pragma solidity ^0.8.13;

//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
//import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
//import "@openzeppelin/contracts/interfaces/IERC4626.sol";
//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * IERC20(
 * balanceOf(account)→ uint256,
 * allowance(address owner, address spender)→ uint256,
 * approve(address spender, uint256 amount)→ bool,
 * transfer(address to, uint256 amount)→ bool,
 * transferFrom(address from, address to, uint256 amount) → bool
 * )
 * 
 * IERC721(
 * approve(address to, uint256 tokenId)
 * safeTransferFrom(address from, address to, uint256 tokenId)
 * transferFrom(address from, address to, uint256 tokenId)
 * )
 */ 
/*
interface ERC20 {
  function balanceOf(address owner) external view returns (uint);
  function allowance(address owner, address spender) external view returns (uint);
  function approve(address spender, uint value) external returns (bool);
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint value) external returns (bool); 
}
*/

contract Trusty {
    //Eventi
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);
    //event TokenDepositComplete(address tokenAddress, uint256 amount);

    //Slots
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public numConfirmationsRequired;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;        
        //bool isToken;
        //address token;
        //address nft;
        //bytes note;
    }

    //address[] public tokensAddresses;

    // mapping from tx index => owner => bool
    mapping(uint => mapping(address => bool)) public isConfirmed;

    // mapping token deposited
    //mapping(address => mapping(address => uint256)) depositedTokenAmount;
    // mapping eth deposited
    //mapping(address => uint256) depositedEthAmount;

    // mapping balances and allowance
    //mapping(address => uint) public balances;
    //mapping(address => mapping(address => uint)) public allowance;

    // mapping userAddress => tokenAddress => tokenAmount
    //mapping(address => mapping(address => uint256)) userTokenBalance;

    Transaction[] public transactions;

    modifier onlyOwner() {
        require(isOwner[msg.sender] || isOwner[tx.origin], "not owner");
        //require(isOwner[tx.origin], "not owner");
        //require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][tx.origin], "tx already confirmed");
        _;
    }

    // Constructor
    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        require(_owners.length > 0, "owners required");
        require(
            _numConfirmationsRequired > 1 &&
                _numConfirmationsRequired <= _owners.length,
            "invalid number of required confirmations"
        );

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;

        //tokenAddress = _tokenAddress;
    }

    receive() external payable {
        emit Deposit(tx.origin, msg.value, address(this).balance);
    }

    fallback() external payable {
        emit Deposit(tx.origin, msg.value, address(this).balance);
    }

    /*
    function importToken() public onlyOwner {}

    // deposit token to smart contract is automatic, anyway if needed...
    function depositToken(uint256 amount) public {
        //const address myAddres = address(IERC20(tokenAddress);
        require(IERC20(tokenAddress).balanceOf(tx.origin) => amount, "Token amount must be greater");
        require(IERC20(tokenAddress).approve(address(this), amount));
        require(IERC20(tokenAddress).transferFrom(tx.origin, address(this), amount));

        userTokenBalance[tx.origin][tokenAddress] += amount;
        emit tokenDepositComplete(tokenAddress, amount);
    }

    function withdrawAll() public onlyOwner {
        require(userTokenBalance[tx.origin][tokenAddress] > 0, "Vault does not have required amount to spend");
        uint256 amount = userTokenBalance[tx.origin][tokenAddress];
        require(IERC20(tokenAddress).transfer(tx.origin, amount), "transfer failed");
        userTokenBalance[tx.origin][tokenAddress] = 0;
        emit tokenWithdrawalComplete(tokenAddress, amount);
    }

    function withdrawAmount(uint256 amount) public onlyOwner {
        require(userTokenBalance[tx.origin][tokenAddress] >= amount);
        require(IERC20(tokenAddress).transfer(tx.origin, amount), "transfer failed");
        userTokenBalance[tx.origin][tokenAddress] -= amount;
        emit tokenWithdrawalComplete(tokenAddress, amount);
    }

    function transferToMe(address _owner, address _token, unit _amount) public {
        // FROM-TO-AMOUNT
        ERC20(_token).transferFrom(_owner, address(this), _amount);
    }
    

    // Transfer _amount of _token _to
    function tokenTransferTo(address _to, address _token, uint _amount) public onlyOwner {
        require(getBalanceOfToken(_token) >= _amount,'not enough token to transfer!');
        ERC20(_token).approve(address(this),_amount);
        //ERC20(_token).transfer(_to, _amount);
        // FROM-TO-AMOUNT
        (bool success) = ERC20(_token).transferFrom(address(this), _to, _amount);
        require(success, "token tx failed");
    }

    function getBalanceOfToken(address _address) public view returns (uint) {
        return ERC20(_address).balanceOf(address(this));
    }
    */

   /**
    * 
    * @param _to Address that will receive the tx or the contract that receive the interaction
    * @param _value Amount of ether to send
    * @param _data Optional data field or calldata to another contract
    * @dev _data can be used as "bytes memory" or "bytes calldata"
    */
    function submitTransaction(
        address _to,
        uint _value,
        bytes memory _data
        //bool _isToken
    ) public onlyOwner {
        uint txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 0
                //isToken: false
            })
        );

        emit SubmitTransaction(tx.origin, txIndex, _to, _value, _data);
    }

    function confirmTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][tx.origin] = true;

        emit ConfirmTransaction(tx.origin, _txIndex);
    }

    function executeTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "cannot execute tx due to number of confirmation required"
        );

        transaction.executed = true;
        
        (bool success, ) = transaction.to.call{value: transaction.value}(
            //return abi.encodeWithSignature("callMe(uint256)", 123);
            //return abi.encodeWithSignature(transaction.data);
            transaction.data
        );
        require(success, "tx failed");
        
        emit ExecuteTransaction(tx.origin, _txIndex);
    }

    function revokeConfirmation(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed[_txIndex][tx.origin], "tx not confirmed");

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][tx.origin] = false;

        emit RevokeConfirmation(tx.origin, _txIndex);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getBalance() public view returns (uint256) {
        uint256 amount = address(this).balance;
        return amount;
    }

    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

    function getTransaction(uint _txIndex)
        public
        view
        returns (
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint numConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }

    /*
    function destroy() public onlyOwner {
        //selfdestruct(payable(address)) > address.send(this.balance);
    }
    */
}