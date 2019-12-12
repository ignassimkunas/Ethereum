pragma solidity 0.5.12;

contract Deal {
    address payable owner;

  /// The buyer's address part on this contract
    address payable buyerAddr;

  /// The Buyer struct  
    struct Buyer {
        address addr;
        string name;
        bool init;
    }
    struct Shipment {
        address payable courier;
        uint price;
        address payer;
        string date;
        string real_date;
        bool init;
    }
    struct Order {
        string goods;
        uint quantity;
        uint number;
        uint price;
        Shipment shipment;
        bool init;
    }

  /// The Invoice struct
    struct Invoice {
        uint orderno;
        uint number;
        bool init;
    }
    /// The mapping to store orders
    mapping (uint => Order) orders;
    
    /// The mapping to store invoices
    mapping (uint => Invoice) invoices;
    
    /// The sequence number of orders
    uint orderseq;
    
    /// The sequence number of invoices
    uint invoiceseq;
    
  /// Event triggered for every new order
    event OrderSent(address buyer, string goods, uint quantity, uint orderno);
    
    /// Event triggerd when the order gets valued and wants to know the value of the payment
    event PriceSent(address buyer, uint orderno, uint price);
    
    /// Event trigger when the buyer performs the safepay
    event PaymentSent(address buyer, uint orderno, uint value, uint now);
    
    /// Event triggered when the seller sends the invoice
    event InvoiceSent(address buyer, uint invoiceno, uint orderseq, string delivery_date, address courier);
    
    /// Event triggered when the courie delives the order
    event OrderDelivered(address buyer, uint invoiceno, uint orderno, uint real_delivey_date, address courier);
    
    event BuyerRegistered(address buyer, string name);
    
 
    function sendOrder(string memory goods, uint quantity) payable public {
        
        /// Accept orders just from buyer
        require(msg.sender == buyerAddr);
        
        /// Increment the order sequence
        orderseq++;
        
        /// Create the order register
        orders[orderseq] = Order(goods, quantity, orderseq, 0, Shipment(address(0), 0, address(0), "", "", false), true);
        
        /// Trigger the event
        emit OrderSent(msg.sender, goods, quantity, orderseq);
    
    }

    function sendPrice(uint price, uint shipPrice) payable public {
        
        require(msg.sender == owner);
        /// Validate the order number
        require(orders[orderseq].init);
        
        orders[orderseq].price = price;
        orders[orderseq].shipment.price = shipPrice;
        orders[orderseq].shipment.init  = true;
        /// Trigger the event
        emit PriceSent(buyerAddr, orderseq, price+shipPrice);
    
    }
    function sendInvoice(string memory delivery_date, address payable courier) payable public {
    
    /// Validate the order number
        require(orders[orderseq].init);
        
        /// Just the seller can send the invoice
        require(owner == msg.sender);
        
        invoiceseq++;
        
        /// Create then Invoice instance and store it
        invoices[invoiceseq] = Invoice(orderseq, invoiceseq, true);
        
        /// Update the shipment data
        orders[orderseq].shipment.date    = delivery_date;
        orders[orderseq].shipment.courier = courier;
        
        /// Trigger the event
        emit InvoiceSent(buyerAddr, invoiceseq, orderseq, delivery_date, courier);
    }
    function delivery() payable public {
        /// Just the courier can call this function
        require(orders[orderseq].shipment.courier == msg.sender);
        emit OrderDelivered(buyerAddr, invoiceseq, orders[orderseq].number, now, orders[orderseq].shipment.courier);
    }
    function transferToCourier() public payable {
        require(owner == msg.sender);
        orders[orderseq].shipment.courier.transfer(msg.value);
    }
    function sendPayment() public payable{
        require(buyerAddr == msg.sender);
        /// The order's value plus the shipment value must equal to msg.value
        owner.transfer(msg.value);
        emit PaymentSent(msg.sender, orderseq, msg.value, now);
    }
    constructor (address payable _buyerAddr) public payable {
        /// The seller is the contract's owner
        owner = msg.sender;
        buyerAddr = _buyerAddr;
    }
}