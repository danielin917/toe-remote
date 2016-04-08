#include <iostream>
#include <vector>
#include <QString>
#include <QLowEnergyController>
#include <QBluetoothLocalDevice>
#include <QBluetoothUuid>
#include <QByteArray>
using namespace QBlueTooth;
using QString;

constexpr QString RBL_SERVICE_UUID(QStringLiteral("713D0000-503E-4C75-BA94-3148F18D941E"));
// For sending data
constexpr QString RBL_CHAR_TX_UUID(QStringLiteral("713D0002-503E-4C75-BA94-3148F18D941E"));
// For receiving data
constexpr QString RBL_CHAR_RX_UUID(QStringLiteral("713D0003-503E-4C75-BA94-3148F18D941E"));
int MAX_CHUNK_SIZE = 64;

class BLEPeripheral_Impl : public QObject
{
	Q_OBJECT
	friend class BLEPeripheral;
 private:
	BLEPeripheral_Impl(QObject *parent = 0, const char *name);
	~BLEPeripheral_Impl();
	
	unsigned int numConnected;
	unsigned int bytes_sent;
	unsigned int readIdx;
	QByteArray *sendBuffer;
	QByteArray *readBuffer;
	
	QString peripheralName;
	QBluetoothLocalDevice *btDevice;
	QLowEnergyController *peripheralController;
	QLowEnergyCharacteristic *readCharacteristic;
	QLowEnergyCharacteristic *writeCharacteristic;
	QLowEnergyService *RBLService;
	
	read_handler_t readHandler;
	void *serverInterface;

 public slots:
	void send();
	void write(const unsigned char *data, unsigned char len);
	void dataReceived(const QLowEnergyCharacteristic &characteristic, const QByteArray &data);
	void setAdvertise(bool shouldAdvertise = true);
	void deviceConnect() { numConnected += 1; }
	void deviceDisconnect() { numConnected -= 1; }
};

BLEPeripheral::BLEPeripheral(const char *name)
{
	(BLEPeripheral_Impl *) impl = new BLEPeripheral_Impl
}

BLEPeripheral::~BLEPeripheral()
{
	std::cerr << "Destroyed" << std::endl;
	delete (BLEPeripheral_Impl *) impl;
}

void BLEPeripheral::write_byte(unsigned char data)
{
	this->write(&data, 1);
}

void BLEPeripheral::write(const unsigned char *data, unsigned char len)
{
	(BLEPeripheral_Impl *)impl->write(data, len);
}

void BLEPeripheral::process()
{
	// Empty
}

static bool BLEPeripheral::allows_async()
{
	return true;
}

void register_read_handler(void *serverInterface, read_handler_t readHandler)
{
	this->serverInterface = serverInterface;
	this->readHandler = readHandler;
}

unsigned char BLEPeripheral::read_byte()
{
	std::cerr << "Not supported" << std::endl;
	exit(1);
}

unsigned char BLEPeripheral::bytes_available()
{
	std::cerr << "Not supported" << std::endl;
	exit(1);
}

bool BLEPeripheral::connected()
{
	return (BLEPeripheral_Impl.numConnected > 0);
}

BLEPeripheral_Impl::BLEPeripheral_Impl(const char *name)
{
	std::cerr << "Initializing" << std::endl;
	numConnected = 0;
	readIdx = 0;
	bytes_sent = 0;
	peripheralName = name;
	readBuffer = new QByteArray();
	sendBuffer = new QByteArray();
	
	// Initialize btDevice with default local Bluetooth device
	btDevice = new QBluetoothLocalDevice(QBluetoothAddress(), this);
	// If the device is not powered on, power it on
	btDevice->setHostMode(QBluetoothLocalDevice::HostConnectable);
	
	// Allocate the peripheral controller and connect the peripheralController's
	// connected() and disconnected() signals to the appropriate slots
	peripheralController = createPeripheral(btDevice);
	QObject::connect(peripheralController, SIGNAL(peripheralController->connected()),
					this, SLOT(deviceConnect()));
	QObject::connect(peripheralController, SIGNAL(peripheralController->disconnected()),
					this, SLOT(deviceDisconnect()));
	QObject::connect(peripheralController, SIGNAL(peripheralController->disconnected()), 
					this, SLOT(setAdvertise()));
	
	// Initialize data for RBLService
	QLowEnergyServiceData mainSvc;
	mainSvc.setType(QLowEnergyServiceData::ServiceTypePrimary);
	mainSvc.setUuid(QBluetoothUuid(RBL_SERVICE_UUID));
	
	// Create Tx and Rx characteristics and add them to the RBL service
	QLowEnergyCharacteristicData TxChar;
	TxChar.setUuid(QBluetoothUuid(RBL_CHAR_TX_UUID));
	TxChar.setProperties(QLowEnergyCharacteristic::Read | QLowEnergyCharacteristic::Notify);
	QLowEnergyCharacteristicData RxChar;
	RxChar.setUuid(QBluetoothUuid(RBL_CHAR_RX_UUID));
	RxChar.setProperties(QLowEnergyCharacteristic::WriteNoResponse);
	mainSvc.setCharacteristics{RxChar, TxChar};
	
	// Add the RBL service to the peripheral
	RBLService = peripheralController->addService(mainSvc, peripheralController);
	assert(RBLService->parent() == peripheralController);
	
	readCharacteristic = &(RBLService->characteristic(QBluetoothUuid(RBL_CHAR_RX_UUID)));
	writeCharacteristic = &(RBLService->characteristic(QBluetoothUuid(RBL_CHAR_TX_UUID)));
	
	QObject::connect(RBLService, SIGNAL(RBLService->characteristicChanged(const QLowEnergyCharacteristic &, const QByteArray &)),
					this, SLOT(this->dataReceived(const QLowEnergyCharacteristic &, const QByteArray &)));
	
	// Start advertising
	setAdvertise(true);
}

BLEPeripheral_Impl::~BLEPeripheral_Impl()
{
	delete sendBuffer;
	delete readBuffer;
}

void BLEPeripheral_Impl::setAdvertise(bool shouldAdvertise = true)
{
	if (shouldAdvertise) {
		QLowEnergyAdvertisingData advertData;
		advertData.setDiscoverability(QLowEnergyAdvertisingData::DiscoverabilityGeneral);
		advertData.setLocalName(peripheralName);
		advertData.setServices{QBluetoothUuid(RBL_SERVICE_UUID)};
		peripheralController->startAdvertising(QLowEnergyAdvertisingParameters(), advertData);
		std::cerr << "Started advertising" << std::endl;
	}
	else {
		peripheralController->stopAdvertising();
		std::cerr << "Stopped advertising" << std::endl;
	}
}

void BLEPeripheral_Impl::send()
{
	while (bytes_sent < sendBuffer->size())
	{
		unsigned length = sendBuffer->size() - bytes_sent;
		length = (length > MAX_CHUNK_SIZE) ? MAX_CHUNK_SIZE : length;
		QByteArray chunk(sendBuffer->mid(bytes_sent, length));
		RBLService->writeCharacteristic(*writeCharacteristic, chunk);
		bytes_sent += length;
	}
}

void BLEPeripheral_Impl::write(const unsigned char *data, unsigned char len)
{
	if (numConnected == 0) {
		std::cerr << "No subscribers connected" << std::endl;
		return;
	}
	if (bytes_sent < sendBuffer->size()) {
		sendBuffer->append(data, len);
		return;
	}
	bytes_sent = 0;
	sendBuffer->swap(QByteArray(data, len));
	send();
}

void BLEPeripheral_Impl::dataReceived(const QLowEnergyCharacteristic &characteristic, const QByteArray &data)
{
	if (characteristic == *readCharacteristic) {
		
	}
}



