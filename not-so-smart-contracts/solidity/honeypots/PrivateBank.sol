pragma solidity ^0.4.19;

contract Log {
    struct Message {
        address sender;
        string  data;
        uint val;
        uint  time;
    }
    Message[] public history;
    Message public lastMsg;
    function addMessage(address _adr,uint _val,string _data) public {
        lastMsg.sender = _adr;
        lastMsg.time = now; // solhint-disable-line not-rely-on-time
        lastMsg.val = _val;
        lastMsg.data = _data;
        history.push(lastMsg);
    }
}

contract PrivateBank {
    mapping (address => uint) public balances;
    uint public minDeposit = 1 ether;
    Log public transferLog;

    constructor(address _log) {
        transferLog = Log(_log);
    }

    function deposit() public payable {
        if (msg.value >= minDeposit) {
            balances[msg.sender]+=msg.value;
            transferLog.addMessage(msg.sender, msg.value, "Deposit");
        }
    }

    function cashOut(uint _am) public {
        if (_am <= balances[msg.sender]) {
            if (msg.sender.call{ value: _am}()) {  // solhint-disable-line avoid-low-level-calls
                balances[msg.sender] -= _am;
                transferLog.addMessage(msg.sender, _am, "CashOut");
            }
        }
    }

    fallback() public payable {}

}
