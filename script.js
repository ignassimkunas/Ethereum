const btn = document.getElementById("btn")
const orderNum = document.getElementById("orderNum");
const seller = document.getElementById("seller");
const dataForBuyer = document.getElementById("data");
const contract = web3.eth.contract(abi);
const orderPriceInput = document.getElementById("orderPriceInput");
const shipmentPriceInput = document.getElementById("shipmentPriceInput");
const priceBtn = document.getElementById("priceBtn");
const fullPriceText = document.getElementById("fullPrice");
const courierData = document.getElementById("courierData");
const courierButton = document.getElementById("courierButton");
//gaut info iš buyerio 
const contractInstance = contract.at('0x4b91F603e33dABBEEC9f60E3179c055d0F84BA7E');
const orderEvent = contractInstance.OrderSent();
const priceSentEvent = contractInstance.PriceSent();
const paymentSent = contractInstance.PaymentSent();
const invoiceSent = contractInstance.InvoiceSent();
const orderDelivered = contractInstance.OrderDelivered();
var fullPrice; 
var shipmentPrice;
var orderPrice;
var buyerStatus = "send";
var sellerStatus = "notSent";

//alert("Payment complete, the courier is on his way.");
orderDelivered.watch(function(error, result){
	priceBtn.innerHTML = "Pay Courier";
	sellerStatus = "payCourier";
});

priceSentEvent.watch(function(error, result){
	orderNum.style.display = "none";
	fullPriceText.style.display = "block";
	fullPriceText.innerHTML = "Full Price: <br>" + result.args.price.c[0] + " ETH";
	fullPrice = result.args.price.c[0];
	buyerStatus = "pay";

});
orderEvent.watch(function(error, result){
	dataForBuyer.innerHTML = "Goods: " + result.args.goods + "<br>" + "Quantity: " + result.args.quantity.c[0];
	const newButton = document.createElement("button");
	orderPriceInput.style.display = "block";
	shipmentPriceInput.style.display = "block";
	priceBtn.style.display = "block";
});
paymentSent.watch(function(error, result){
	priceBtn.innerHTML = "Send Invoice";
	orderPriceInput.style.display = "none";
	shipmentPriceInput.style.display = "none";
	sellerStatus = "invoice";
});
invoiceSent.watch(function(error, result){
	courierData.style.display = "block";
	courierButton.style.display = "block";
	console.log(result)
	courierData.innerHTML = "Date to deliver: " + result.args.delivery_date;
	alert("Invoice has been sent. Delivery ariving at: " + result.args.delivery_date);
	dataForBuyer.style.display = "none";

});

//gavus kainą, išsiųst sąskaitą ir padaryt, kad kurjeris galėtų deliverint
priceBtn.onclick = function(){
	if (sellerStatus == "notSent"){
		contractInstance.sendPrice(orderPriceInput.value, shipmentPriceInput.value, function(err, result){});
		orderPrice = orderPriceInput.value;
		shipmentPrice = shipmentPriceInput.value;
	}
 	else if(sellerStatus == "invoice"){
		contractInstance.sendInvoice("2019-12-20", '0x6b63CE3981f3D4A276F69EB6eA33CA62287EBb0b', function(err, result){})
	}
	else if (sellerStatus == "payCourier"){
		contractInstance.transferToCourier({value: web3.toWei(parseInt(shipmentPrice))}, function(err, result){
			alert("Order complete.")
			window.location.reload(false);
		})
	}
};
btn.onclick = function(){
	if (buyerStatus == "send"){
		contractInstance.sendOrder("Product", parseInt(orderNum.value), function(err, result){
		  //console.log(result);
		});
	}
	else if(buyerStatus == "pay"){
		contractInstance.sendPayment({value: web3.toWei(parseInt(fullPrice))}, function(err, result){});
	}
};
courierButton.onclick = function(){
	contractInstance.delivery(function(err, result){

	});
}