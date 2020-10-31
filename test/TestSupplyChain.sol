pragma solidity >=0.6.0 <0.7.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";
import "./SCProxy.sol";

contract TestSupplyChain {
    SupplyChain private SC;
    SCProxy private seller;
    SCProxy private buyer;

    uint public initialBalance = 10 ether;

    string private name = "Car";
    uint private price = 100000;
    uint private sku = 0;

    // Set up contract, seller, buyer, add an item, and fund the buyer before each test
    function beforeEach() public {
      // Establish new contract
      SC = new SupplyChain();

      // set up buyer address
      buyer = new SCProxy(SC);

      // set up seller address
      seller = new SCProxy(SC);

      // add an item for sale
      seller.addItem(name, price);

      // fund buyer
      address(buyer).transfer(1 ether);
    }

    // testing buyItem
    function testingbuyItem() public {
      bool r = buyer.buyItem(sku, price);
      Assert.isTrue(r, "Error - Did not successfully buy item.");
    }


    // testing buying an item that is not for sale
    function testingbuyItemNotForSale() public {
      (,,,uint initialitemState,,) = SC.fetchItem(sku);
      bool r1 = buyer.buyItem(sku, price); //buyer buys item
      bool r2 = buyer.buyItem(sku, price); //buyer attempts to buy previously sold item
      (,,,uint buyitemState,,) = SC.fetchItem(sku);

      Assert.equal(initialitemState, 0, "Error - Item is not initially marked ForSale.");
      Assert.isTrue(r1, "Error - Buyer did not buy item the first time.");
      Assert.isFalse(r2, "Error - Buyer bought item after it was sold.");
      Assert.equal(buyitemState, 1, "Error - Item is not marked as sold.");
    }

    // testing for failure when not enough funds sent
    function testingbuyItemNotEnoughFunds() public {
      bool r = buyer.buyItem(sku, price-1);

      Assert.isFalse(r, "Error - Buyer paid for item in full.");
    }

    // shipItem
    // testing for failure when shipping an item not sold
    function testingshipItemNotYetSold() public {
      bool r = seller.shipItem(sku);

      Assert.isFalse(r, "Error - Allowed shipping of item not sold.");
    }

    // testing for failure when buyer trying to call shipItem
    function testingshipItemFromBuyer() public {
      buyer.buyItem(sku, price);
      bool r = buyer.shipItem(sku);

      Assert.isFalse(r, "Error - Allowed buyer to ship item.");
    }

    // receiveItem
    // testing for failure on received item not yet shipped
    function testingreciveItemNotYetShipped() public {
      bool r1 = buyer.buyItem(sku, price);
    //  bool r2 = seller.shipItem(sku); // test what happens if seller ships item
      bool r3 = buyer.receiveItem(sku);

      Assert.isTrue(r1, "Error - Buyer did not buy item.");
    //  Assert.isTrue(r2, "Error - Seller did not ship item."); // test what happens if seller ships item
      Assert.isFalse(r3, "Error - Can not receive an item not yet shipped.");
    }

    // testing for failure on seller calling receiveItem
    function testingreciveItemCallFromSeller() public {
      buyer.buyItem(sku, price);
      seller.shipItem(sku);
      bool r = seller.receiveItem(sku);

      Assert.isFalse(r, "Error - The seller cannot call the receive item function.");
  }
}
