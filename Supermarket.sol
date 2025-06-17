pragma solidity ^0.8.0;

/**
 * @title SimpleSupermarket
 * @notice A minimal smart contract that lets the owner add products and
 *         users purchase them with Ether.
 */
contract SimpleSupermarket {
    address public owner;

    struct Item {
        string name;
        uint256 price; // in wei
        uint256 quantity;
    }

    mapping(uint256 => Item) public items;
    uint256 public itemCount;

    event ItemAdded(uint256 indexed id, string name, uint256 price, uint256 quantity);
    event ItemPurchased(address indexed buyer, uint256 indexed id, uint256 quantity, uint256 value);
    event Withdrawal(address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice Add a new item to the store.
     * @param _name Name of the product.
     * @param _price Price in wei.
     * @param _quantity Available quantity.
     */
    function addItem(string memory _name, uint256 _price, uint256 _quantity) external onlyOwner {
        require(_price > 0, "Price must be positive");
        uint256 id = itemCount++;
        items[id] = Item({name: _name, price: _price, quantity: _quantity});
        emit ItemAdded(id, _name, _price, _quantity);
    }

    /**
     * @notice Purchase an item from the store.
     * @param _id Item identifier.
     * @param _quantity Quantity desired.
     */
    function purchase(uint256 _id, uint256 _quantity) external payable {
        Item storage item = items[_id];
        require(_quantity > 0, "Quantity must be positive");
        require(item.quantity >= _quantity, "Not enough stock");
        uint256 cost = item.price * _quantity;
        require(msg.value == cost, "Incorrect Ether value");

        item.quantity -= _quantity;
        emit ItemPurchased(msg.sender, _id, _quantity, cost);
    }

    /**
     * @notice Withdraw Ether from the contract to the owner address.
     * @param _amount Amount to withdraw in wei.
     */
    function withdraw(uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(owner).transfer(_amount);
        emit Withdrawal(owner, _amount);
    }
}
