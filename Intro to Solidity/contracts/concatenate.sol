pragma solidity 0.4.19;

import "github.com/Arachnid/solidity-stringutils/strings.sol";

contract Concatenate {
    function concatWithoutImport(string _s, string _t) public returns (string) {
        bytes memory s_bytes = bytes(_s);
        bytes memory t_bytes = bytes(_t);
        
        uint s_length = s_bytes.length;
        uint t_length = t_bytes.length;

        bytes memory concatenation = bytes(new string(s_length + t_length));

        for (uint i = 0; i < s_length; i++) {
            concatenation[i] = s_bytes[i];
        }
        for (i = 0; i < t_length; i++) {
            concatenation[i + s_length] = t_bytes[i];
        }
        return string(concatenation);
    }

    /* BONUS */
    function concatWithImport(string s, string t) public returns (string) {
    	return s.toSlice().concat(t.toSlice());
    }
}
