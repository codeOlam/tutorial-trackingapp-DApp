// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Tracking {
  enum ShipmentStatus {
    PENDING,
    IN_TRANSIT,
    DELIVERED
  }

  struct Shipment {
    address sender;
    address receiver;
    uint256 pickupTime;
    uint256 deliveryTime;
    uint256 distance;
    uint256 price;
    ShipmentStatus status;
    bool isPaid;
  }

  //Keep track of shipments
  mapping(address => Shipment[]) public shipments;
  uint256 public shipmentCount;

  struct TypeShipment {
    address sender;
    address receiver;
    uint256 pickupTime;
    uint256 deliveryTime;
    uint256 distance;
    uint256 price;
    ShipmentStatus status;
    bool isPaid;
  }

  // this is where all data will be kept to be displayed in the frontend
  TypeShipment[] typeShipments;

  event ShipmentCreated(
    address indexed send,
    address indexed receiver,
    uint256 pickupTime,
    uint256 distance,
    uint256 price
  );

  event ShipmentInTransit(
    address indexed sender,
    address indexed receiver,
    uint256 pickupTime
  );

  event ShipmentDelivered(
    address indexed sender,
    address indexed receiver,
    uint256 deliveryTime
  );

  event ShipmentPaid(
    address indexed sender,
    address indexed receiver,
    uint256 amount
  );

  constructor() {
    shipmentCount = 0;
  }

  function createShipment(
    address _receiver, 
    uint256 _pickupTime, 
    uint256 _distance, 
    uint256 _price) public payable{

    // confirm payment amount
    require(msg.value == _price, "Payment amount must match the price.");

    // update Shipments
    Shipment memory shipment = Shipment(
      msg.sender,
      _receiver,
      _pickupTime,
      0,
      _distance,
      _price,
      ShipmentStatus.PENDING, 
      false
    ); 

    shipments[msg.sender].push(shipment);
    shipmentCount++;

    //updated data to display on the frontend
    typeShipments.push(
      TypeShipment(
        msg.sender,
        _receiver,
        _pickupTime,
        0,
        _distance,
        _price,
        ShipmentStatus.PENDING,
        false
      )
    );

    emit ShipmentCreated(
      msg.sender,
      _receiver,
      _pickupTime,
      _distance,
      _price
    );
  }

  // This function will update the status of shipment
  function startShipment(address _sender, address _receiver, uint256 _index) public {
    // Find and update the target shipment status
    Shipment storage shipment = shipments[_sender][_index];
    TypeShipment storage typeShipment = typeShipments[_index];

    // ensure that the receiver address is provided and if pending don't call this function
    require(shipment.receiver == _receiver, "Invalid receiver.");
    require(shipment.status == ShipmentStatus.PENDING, "Shipment is already in transit");

    shipment.status = ShipmentStatus.IN_TRANSIT;
    typeShipment.status = ShipmentStatus.IN_TRANSIT;

    emit ShipmentInTransit(_sender, _receiver, shipment.pickupTime);
  }

  //This function will be called when transaction is completed
  function completeShipment(address _sender, address _receiver, uint256 _index) public {
    Shipment storage shipment = shipments[_sender][_index];
    TypeShipment storage typeShipment = typeShipments[_index];

    require(shipment.receiver == _receiver, "Invalid revciever.");
    require(shipment.status == ShipmentStatus.IN_TRANSIT, "Shipment not in transit");
    require(shipment.isPaid, "Shipment already paid for.");

    shipment.status = ShipmentStatus.DELIVERED;
    shipment.deliveryTime = block.timestamp;
    typeShipment.status = ShipmentStatus.DELIVERED;
    typeShipment.deliveryTime = block.timestamp;

    uint256 amount = shipment.price;

    payable(shipment.sender).transfer(amount);

    shipment.isPaid = true;
    typeShipment.isPaid = true; 

    emit ShipmentDelivered(_sender, _receiver, shipment.deliveryTime);
    emit ShipmentPaid(_sender, _receiver, amount);
  }

  function getShipment(address _sender, uint256 _index) public view returns (
    address,
    address,
    uint256,
    uint256,
    uint256,
    uint256,
    ShipmentStatus,
    bool
  ){
    //Fetch target data
    Shipment memory shipment = shipments[_sender][_index];

    return (
      shipment.sender, 
      shipment.receiver,
      shipment.deliveryTime,
      shipment.distance,
      shipment.pickupTime,
      shipment.price,
      shipment.status,
      shipment.isPaid);
  }

  function getShipmentCount(address _sender) public view returns(uint256){
    return shipments[_sender].length;
  }

  function getAllTransactions() public view returns(TypeShipment[] memory) {
    return typeShipments;
  }
}