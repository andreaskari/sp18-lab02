pragma solidity 0.4.19;


contract Betting {
    /* Constructor function, where owner and outcomes are set */
    function Betting(uint[] _outcomes) public {
        owner = msg.sender;
        for (uint i = 0; i < _outcomes.length; i++) {
            outcomes[i] = _outcomes[i];
        }
    }

    /* Fallback function */
    function() public payable {
        revert();
    }

    /* Standard state variables */
    address public owner;
    address public gamblerA;
    address public gamblerB;
    address public oracle;

    /* Structs are custom data structures with self-defined parameters */
    struct Bet {
        uint outcome;
        uint amount;
        bool initialized;
    }

    /* Keep track of every gambler's bet */
    mapping (address => Bet) bets;
    /* Keep track of every player's winnings (if any) */
    mapping (address => uint) winnings;
    /* Keep track of all outcomes (maps index to numerical outcome) */
    mapping (uint => uint) public outcomes;

    /* Add any events you think are necessary */
    event BetMade(address gambler);
    event BetClosed();

    /* Uh Oh, what are these? */
    modifier ownerOnly() { if (msg.sender == owner) _; }
    modifier oracleOnly() { if (msg.sender == oracle) _; }
    modifier outcomeExists(uint outcome) { 
        bool exists = false;
        uint i = 0;
        while (outcomes[i] != 0) {
            if (outcomes[i] == outcome) {
                exists = true;
                break;
            }
            i++;
        }
        if (exists) {
            _;
        }
    }

    /* Owner chooses their trusted Oracle */
    function chooseOracle(address _oracle) public ownerOnly() returns (address) {
        oracle = _oracle;
    }

    /* Gamblers place their bets, preferably after calling checkOutcomes */
    function makeBet(uint _outcome) public payable returns (bool) {
        // Check if has already placed bet and if not oracle or owner
        Bet memory bet_to_place = Bet({
            outcome: _outcome,
            amount: msg.value,
            initialized: false
        });
        if (msg.sender != oracle && msg.sender != owner) {
            if (gamblerA == 0 && bets[msg.sender].initialized == false) {
                gamblerA = msg.sender;
                bet_to_place.initialized = true;
                bets[msg.sender] = bet_to_place;
                BetMade(msg.sender);
            } else if (gamblerB == 0 && gamblerA != msg.sender && bets[msg.sender].initialized == false) {
                gamblerB = msg.sender;
                bet_to_place.initialized = true;
                bets[msg.sender] = bet_to_place;
                BetMade(msg.sender);
                BetClosed();
            }
        }
    }

    /* The oracle chooses which outcome wins */
    function makeDecision(uint _outcome) public oracleOnly() outcomeExists(_outcome) {
        // Update winnings
        bool gamblerA_wins = bets[gamblerA].outcome == _outcome;
        bool gamblerB_wins = bets[gamblerB].outcome == _outcome;

        if (gamblerA_wins && gamblerB_wins) {
            winnings[gamblerA] += bets[gamblerA].amount;
            winnings[gamblerB] += bets[gamblerB].amount;
        } else if (gamblerA_wins) {
            winnings[gamblerA] += bets[gamblerA].amount;
            winnings[gamblerA] += bets[gamblerB].amount;            
        } else if (gamblerB_wins) {
            winnings[gamblerB] += bets[gamblerA].amount;
            winnings[gamblerB] += bets[gamblerB].amount;            
        } else {
            winnings[oracle] += bets[gamblerA].amount;
            winnings[oracle] += bets[gamblerB].amount;            
        }
    }

    /* Allow anyone to withdraw their winnings safely (if they have enough) */
    function withdraw(uint withdrawAmount) public returns (uint) {
        if (winnings[msg.sender] > withdrawAmount) {
            winnings[msg.sender] -= withdrawAmount;
            msg.sender.transfer(withdrawAmount);
        }
    }
    
    /* Allow anyone to check the outcomes they can bet on */
    function checkOutcomes(uint outcome) public view returns (uint) {
        return outcomes[outcome];
    }
    
    /* Allow anyone to check if they won any bets */
    function checkWinnings() public view returns(uint) {
        // check if user in mapping or mapping exists?
        return winnings[msg.sender];
    }

    /* Call delete() to reset certain state variables. Which ones? That's upto you to decide */
    function contractReset() public ownerOnly() {
        /* For clearing outcomes */
        uint i = 0;
        while (outcomes[i] != 0) {
            outcomes[i] = 0;
            i++;
        }

        /* For clearing bets */
        bets[gamblerA].initialized = false;
        bets[gamblerB].initialized = false;

        delete(oracle);
        delete(gamblerA);
        delete(gamblerB);
    }

    /* Questions:
        - Should we withdraw ether before hand and store it?
        - Purpose of initialized?
        - Why no outcomeExists() for makeBet?
    */
}
