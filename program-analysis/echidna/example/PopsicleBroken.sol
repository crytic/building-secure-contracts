pragma solidity ^0.8.4;

/**
 This file was sourced from Certora: https://demo.certora.com/
 */
/**
 This example is based on a bug in Popsicle Finance which was exploited by an attacker in August 2021: https://twitter.com/PopsicleFinance/status/1422748604524019713?s=20.  
 The attacker managed to drain approximately $20.7 million in tokens from the project’s Sorbetto Fragola pool.
***/

contract ERC20 {
    uint256 total;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowance;

    string public name;
    string public symbol;
    uint256 public decimals;

    function myAddress() public returns (address) {
        return address(this);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b);
        return a - b;
    }

    function totalSupply() external view returns (uint256) {
        return total;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        balances[msg.sender] = sub(balances[msg.sender], amount);
        balances[recipient] = add(balances[recipient], amount);
        return true;
    }

    function allowanceOf(address owner, address spender)
        external
        view
        returns (uint256)
    {
        return allowance[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        balances[sender] = sub(balances[sender], amount);
        balances[recipient] = add(balances[recipient], amount);
        allowance[sender][msg.sender] = sub(
            allowance[sender][msg.sender],
            amount
        );
        return true;
    }

    function increase_allowance(address to_user, uint256 inc_amount) external {
        require(allowance[msg.sender][msg.sender] >= inc_amount);
        allowance[msg.sender][msg.sender] -= inc_amount;
        allowance[msg.sender][to_user] += inc_amount;
    }

    function decrease_allowance(address from_user, uint256 dec_amount)
        external
    {
        require(allowance[msg.sender][from_user] >= dec_amount);
        allowance[msg.sender][from_user] -= dec_amount;
        allowance[msg.sender][msg.sender] += dec_amount;
    }

    function mint(address user, uint256 amount) internal {
        total += amount;
        balances[user] += amount;
    }

    function burn(address user, uint256 amount) internal {
        balances[user] -= amount;
        total -= amount;
        msg.sender.call{value: amount}("");
    }
}

contract PopsicleBroken is ERC20 {
    event Deposit(address user_address, uint256 deposit_amount);
    event Withdraw(address user_address, uint256 withdraw_amount);
    event CollectFees(address collector, uint256 totalCollected);
    event TotalBalanceOfUsers(uint256 amount);

    address owner;
    uint256 totalFeesEarned = 0; // total fees earned per share

    mapping(address => UserInfo) accounts;

    constructor() {
        owner = msg.sender;
    }

    struct UserInfo {
        uint256 latestUpdate;
        uint256 rewards; // general "debt" of popsicle to the user
    }

    function deposit() public payable {
        uint256 amount = msg.value;
        uint256 reward = balances[msg.sender] *
            (totalFeesEarned - accounts[msg.sender].latestUpdate);
        accounts[msg.sender].latestUpdate = totalFeesEarned;
        accounts[msg.sender].rewards += reward;
        mint(msg.sender, amount);
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount);
        uint256 reward = amount *
            (totalFeesEarned - accounts[msg.sender].latestUpdate);
        burn(msg.sender, amount);
        accounts[msg.sender].rewards += reward;
        emit Withdraw(msg.sender, amount);
    }

    function collectFees() public {
        require(totalFeesEarned >= accounts[msg.sender].latestUpdate);
        uint256 fee_per_share = totalFeesEarned -
            accounts[msg.sender].latestUpdate;
        uint256 to_pay = fee_per_share *
            balances[msg.sender] +
            accounts[msg.sender].rewards;
        accounts[msg.sender].latestUpdate = totalFeesEarned;
        accounts[msg.sender].rewards = 0;
        msg.sender.call{value: to_pay}("");
        emit CollectFees(msg.sender, to_pay);
    }

    function OwnerDoItsJobAndEarnsFeesToItsClients() public payable {
        totalFeesEarned += 1;
    }

    function currentBalance(address user) public view returns (uint256) {
        return
            accounts[user].rewards +
            balances[user] *
            (totalFeesEarned - accounts[user].latestUpdate);
    }

    function ethBalance(address user) public view returns (uint256) {
        return user.balance;
    }

    // Get the total balance of a user which is equal to its ETH balance plus its balance of PopsicleBroken tokens.
    function totalBalanceOfUser(address user) public view returns (uint256) {
        return currentBalance(user) + ethBalance(user);
    }

    // An Echidna assertion test to test the equivalence of user balances before and after a transfer.
    /// @dev To run this with Echidna: $ echidna-test PopsicleBroken.sol --contract PopsicleBroken --test-mode assertion
    function totalBalanceAfterTransferIsPreserved(address user, uint256 amount)
        public
    {
        // This slows down Echidna, but ensures that the user is not the zero-address.
        if (user == address(0)) {
            return;
        }

        // Get the balance of msg.sender + user in ETH and tokens before the transfer.
        uint256 totalBalanceOfUsersBeforeTransfer = totalBalanceOfUser(
            msg.sender
        ) + totalBalanceOfUser(user);

        // Emit an event with the total balance of both users BEFORE the transfer function call.
        emit TotalBalanceOfUsers(totalBalanceOfUsersBeforeTransfer);

        // Transfer some amount of tokens to user.
        transfer(user, amount);

        // Get the balance of msg.sender + user in ETH and tokens after the transfer.
        uint256 totalBalanceOfUsersAfterTransfer = totalBalanceOfUser(
            msg.sender
        ) + totalBalanceOfUser(user);

        // Emit an event with the total balance of both users AFTER the transfer function call.
        emit TotalBalanceOfUsers(totalBalanceOfUsersAfterTransfer);

        // Assert that the balance before and balance after should be equal to each other.
        assert(
            totalBalanceOfUsersBeforeTransfer ==
                totalBalanceOfUsersAfterTransfer
        );
    }

    // An Echidna assertion test to test the equivalence of user balances before and after a transferFrom.
    /// @dev To run this with Echidna: $ echidna-test PopsicleBroken.sol --contract PopsicleBroken --test-mode assertion
    function totalBalanceAfterTransferFromIsPreserved(
        address user,
        uint256 amount
    ) public {
        // This slows down Echidna, but ensures that the user is not the zero-address.
        if (user == address(0)) {
            return;
        }

        // Get the balance of msg.sender + user in ETH and tokens before the transferFrom.
        uint256 totalBalanceOfUsersBeforeTransfer = totalBalanceOfUser(
            msg.sender
        ) + totalBalanceOfUser(user);

        // Emit an event with the total balance of both users BEFORE the transferFrom function call.
        emit TotalBalanceOfUsers(totalBalanceOfUsersBeforeTransfer);

        // Transfer some tokens from msg.sender to user.
        transferFrom(msg.sender, user, amount);

        // Get the balance of msg.sender + user in ETH and tokens after the transferFrom.
        uint256 totalBalanceOfUsersAfterTransfer = totalBalanceOfUser(
            msg.sender
        ) + totalBalanceOfUser(user);

        // Emit an event with the total balance of both users AFTER the transferFrom function call.
        emit TotalBalanceOfUsers(totalBalanceOfUsersAfterTransfer);

        // Assert that the balance before and balance after should be equal to each other.
        assert(
            totalBalanceOfUsersBeforeTransfer ==
                totalBalanceOfUsersAfterTransfer
        );
    }
}
