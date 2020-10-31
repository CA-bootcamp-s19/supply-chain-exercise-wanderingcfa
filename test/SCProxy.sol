pragma solidity >=0.6.0 <0.7.0;
import "../contracts/SupplyChain.sol";


// This contract establishes a proxy contract to allow for bool responses
// https://www.trufflesuite.com/tutorials/testing-for-throws-in-solidity-tests

contract SCProxy {
    SupplyChain public targetChain;

    constructor(SupplyChain _target) public {
        targetChain = _target;
    }

    function addItem(string memory itemName, uint itemPrice) public {
        targetChain.addItem(itemName, itemPrice);
    }

    function buyItem(uint sku, uint price) public returns (bool r) {
        (r, ) = address(targetChain).call{value: price}(
            abi.encodeWithSignature("buyItem(uint256)", sku)
        );
    }

    function shipItem(uint sku) public returns (bool r) {
        (r, ) = address(targetChain).call(
            abi.encodeWithSignature("shipItem(uint256)", sku)
        );
    }

    function receiveItem(uint sku) public returns (bool r) {
        (r, ) = address(targetChain).call(
            abi.encodeWithSignature("receiveItem(uint256)", sku)
        );
    }

    //  function fetchItem(uint sku) public returns (bool r) {
    //    (r, ) = address(targetChain).call(
    //        abi.encodeWithSignature("fetchItem(uint256)", sku)
    //      );
    //    }

    // allow contract to recieve ether
    fallback() external payable {}


}
