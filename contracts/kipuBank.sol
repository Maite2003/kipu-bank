
///SPDX-License-Identifier: MIT 
pragma solidity 0.8.26;

contract KipuBank {
    /// @notice Maximum limit allowed for individual Ether withdrawals.
    /// @dev Immutable variable set in the constructor.
    uint256 immutable i_threshold;
    /// @notice Maximum total capacity of Ether that the bank can store.
    /// @dev Immutable variable set in the constructor.
    uint256 i_bankCap;
    /// @notice Counter of the total number of deposits made to the bank.
    /// @dev Incremented by 1 with each successful deposit operation.
    uint256 s_numberOfDeposits = 0;
    /// @notice Counter of the total number of withdrawals made from the bank.
    /// @dev Incremented by 1 with each successful withdrawal operation.
    uint256 s_numberOfWithdrawals = 0;

    /// @notice Mapping that stores each user's Ether balance.
    /// @dev Links user address with their available balance for withdrawal.
    mapping(address _user => uint256 balance) private s_balances;

    // EVENTS

    /// @notice Event emitted when a user makes a deposit.
    /// @param user Address of the user making the deposit.
    /// @param amount Amount of Ether deposited.  
    event KipuBank_Deposit(address user, uint256 amount);

    /// @notice Event emitted when a user makes a withdrawal.
    /// @param user Address of the user making the withdrawal.
    /// @param amount Amount of Ether withdrawn.
    event KipuBank_Withdrawal(address user, uint256 amount);

    // ERRORS

    /// @notice Thrown when the entered value is zero.
    error KipuBank_ZeroValue();
    
    /// @notice Thrown when the user tries to withdraw more than they have.
    /// @param requestedAmount Amount requested that exceeds available balance. 
    error KipuBank_InsufficientBalance(uint256 requestedAmount);

    /// @notice Thrown when the withdrawal exceeds the allowed threshold.
    /// @param requestedAmount Amount requested that exceeds the threshold.
    error KipuBank_ExceedsLimit(uint256 requestedAmount);

    /// @notice Thrown when the deposit exceeds the bank's total capacity.
    /// @param requestedAmount Amount requested.
    /// @param excess Difference between the deposit and remaining capacity. 
    error KipuBank_InsufficientCapacity(uint256 requestedAmount, uint256 excess);

    /// @notice Thrown when the Ether transfer fails.
    /// @param user Address of the recipient.
    /// @param amount Amount that was attempted to be transferred.
    error KipuBank_TransferFailed(address user, uint256 amount);

    // MODIFIERS

    /// @dev Verifies that the entered value is not zero.
    /// @param value Amount to be validated.
    /// @custom:error KipuBank_ZeroValue Thrown if the value equals zero.
    modifier validate(uint256 value) {
        if (value == 0) revert KipuBank_ZeroValue(); // Throw error
        _; // This indicates where the rest of the function code should be placed
    }

    /// @dev Verifies that the bank has sufficient capacity to accept the deposit.
    /// @param value Amount to be deposited.
    /// @custom:error KipuBank_InsufficientCapacity Thrown if the deposit exceeds the bank's maximum capacity.
    modifier validateBankCapacity(uint256 value) {
        uint256 balance = address(this).balance;
        if (balance + value > i_bankCap) revert KipuBank_InsufficientCapacity(value, balance + value - i_bankCap);
        _;
    }

    // CONSTRUCTOR

    /// @notice Initializes the contract with a maximum withdrawal threshold and bank total capacity.
    /// @param _threshold Maximum limit allowed for individual withdrawals.
    /// @param _bankCap Total Ether capacity that the bank can store.
    /// @dev Applies validations to ensure initial values are not zero.
    constructor(uint256 _threshold, uint256 _bankCap) validate(_threshold) validate(_bankCap) {
        i_threshold = _threshold;
        i_bankCap = _bankCap;
    }

    // FUNCTIONS

    /// @notice Function to receive Ether directly and process it as a deposit.
    /// @dev Calls internal _processDeposit which handles all validations.
    receive() external payable {
        _processDeposit();
    }

	/// @notice Fallback function called when no matching function is found or invalid data is sent.
	/// @dev Processes any Ether sent as a deposit through _processDeposit.
	fallback() external payable{
        _processDeposit();
    }
	

    /// @notice Queries the available balance of the calling user.
    /// @return balance The amount of Ether available for withdrawal.
    function getUserBalance() public view returns (uint256 balance) {
        return s_balances[msg.sender];
    }

    /// @notice Queries the maximum withdrawal threshold configured for the bank.
    /// @return threshold The maximum amount of Ether that can be withdrawn in a single transaction.
    function getThreshold() public view returns (uint256 threshold) {
        return i_threshold;
    }

    /// @notice Allows depositing Ether into the bank.
    /// @dev Calls internal _processDeposit which handles all validations.
    function deposit() external payable {
        _processDeposit();
    }

    /// @notice Allows withdrawing Ether from the bank if conditions are met.
    /// @param _amount Amount of Ether to be withdrawn.
    /// @dev Verifies that the amount does not exceed the threshold and that the user has sufficient balance.
    /// @custom:errors KipuBank_ExceedsLimit, KipuBank_InsufficientBalance
    function withdraw(uint256 _amount) external {
        if (_amount > i_threshold) revert KipuBank_ExceedsLimit(_amount);
        if (s_balances[msg.sender] < _amount) revert KipuBank_InsufficientBalance(_amount);

        s_balances[msg.sender] -= _amount;
        s_numberOfWithdrawals++;

        _transferFunds(msg.sender, _amount);

        emit KipuBank_Withdrawal(msg.sender, _amount);
    }

    /// @notice Transfers Ether to the specified user.
    /// @param _user Address of the recipient.
    /// @param _amount Amount of Ether to transfer.
    /// @dev Uses low-level call to send Ether. Throws error if transfer fails.
    /// @custom:error KipuBank_TransferFailed
    function _transferFunds(address _user, uint256 _amount) private {
        (bool ok, ) = payable(_user).call{value: _amount}("");
        if (!ok) revert KipuBank_TransferFailed(_user, _amount);
    }


    /// @notice Internal function to process deposits with all validations.
    /// @dev Validates that msg.value is not zero and does not exceed the bank's maximum capacity.
    /// @custom:modifiers validate, validateBankCapacity
    function _processDeposit() internal validate(msg.value) validateBankCapacity(msg.value) {
        s_balances[msg.sender] += msg.value;
        s_numberOfDeposits++;
        emit KipuBank_Deposit(msg.sender, msg.value);
    }

}