// STL includes
#include <iostream>
#include <vector>

// Qt includes
#include <QString>
#include <QLowEnergyController>
#include <QLowEnergyAdvertisingData>
#include <QLowEnergyAdvertisingParameters>
#include <QLowEnergyService>
#include <QLowEnergyServiceData>
#include <QLowEnergyCharacteristic>
#include <QLowEnergyCharacteristicData>
#include <QBluetoothLocalDevice>
#include <QBluetoothUuid>
#include <QByteArray>

// Toe Remote includes
#include "BLEPeripheral.h"

const QBluetoothUuid RBL_SERVICE_UUID(QStringLiteral("713D0000-503E-4C75-BA94-3148F18D941E"));
// For sending data
const QBluetoothUuid RBL_CHAR_TX_UUID(QStringLiteral("713D0002-503E-4C75-BA94-3148F18D941E"));
// For receiving data
const QBluetoothUuid RBL_CHAR_RX_UUID(QStringLiteral("713D0003-503E-4C75-BA94-3148F18D941E"));
int MAX_CHUNK_SIZE = 64;

class BLEPer_Impl : public QObject
{
	Q_OBJECT
	
	friend class BLEPeripheral;
 
 private:
	BLEPer_Impl(const char *name);
	~BLEPer_Impl();
	
	unsigned int numConnected;
	int bytes_sent;
	int readIdx;
	QByteArray *sendBuffer;
	QByteArray *readBuffer;
	
	QString peripheralName;
	QBluetoothLocalDevice *btDevice;
	QLowEnergyController *peripheralController;
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
	impl = new BLEPer_Impl(name);
}

BLEPeripheral::~BLEPeripheral()
{
	std::cerr << "Destroyed" << std::endl;
	delete static_cast<BLEPer_Impl *>(impl);
}

void BLEPeripheral::write_byte(unsigned char data)
{
	this->write(&data, 1);
}

void BLEPeripheral::write(const unsigned char *data, unsigned char len)
{
	static_cast<BLEPer_Impl *>(impl)->write(data, len);
}

void BLEPeripheral::process()
{
	// Empty
}

bool BLEPeripheral::allows_async()
{
	return true;
}

void BLEPeripheral::register_read_handler
(void *serverInterface, read_handler_t readHandler)
{
	static_cast<BLEPer_Impl *>(impl)->serverInterface = serverInterface;
	static_cast<BLEPer_Impl *>(impl)->readHandler = readHandler;
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
	return (static_cast<BLEPer_Impl *>(impl)->numConnected > 0);
}

BLEPer_Impl::BLEPer_Impl(const char *name)
{
	std::cerr << "Initializing" << std::endl;
	this->setParent(Q_NULLPTR);
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
	peripheralController = QLowEnergyController::createPeripheral(btDevice);
	QObject::connect(peripheralController, SIGNAL(peripheralController->connected()),
					this, SLOT(deviceConnect()));
	QObject::connect(peripheralController, SIGNAL(peripheralController->disconnected()),
					this, SLOT(deviceDisconnect()));
	QObject::connect(peripheralController, SIGNAL(peripheralController->disconnected()), 
					this, SLOT(setAdvertise()));
	
	// Initialize data for RBLService
	QLowEnergyServiceData mainSvc;
	mainSvc.setType(QLowEnergyServiceData::ServiceTypePrimary);
	mainSvc.setUuid(RBL_SERVICE_UUID);
	
	// Create Tx and Rx characteristics and add them to the RBL service
	QLowEnergyCharacteristicData TxChar;
	TxChar.setUuid(RBL_CHAR_TX_UUID);
	TxChar.setProperties(QLowEnergyCharacteristic::Read | QLowEnergyCharacteristic::Notify);
	QLowEnergyCharacteristicData RxChar;
	RxChar.setUuid(RBL_CHAR_RX_UUID);
	RxChar.setProperties(QLowEnergyCharacteristic::WriteNoResponse);
	mainSvc.setCharacteristics({RxChar, TxChar});
	
	// Add the RBL service to the peripheral
	RBLService = peripheralController->addService(mainSvc, peripheralController);
	Q_ASSERT(RBLService->parent() == peripheralController);
	
	QObject::connect(RBLService, SIGNAL(RBLService->characteristicChanged(const QLowEnergyCharacteristic &, const QByteArray &)),
					this, SLOT(this->dataReceived(const QLowEnergyCharacteristic &, const QByteArray &)));
	
	// Start advertising
	setAdvertise(true);
}

BLEPer_Impl::~BLEPer_Impl()
{
	delete sendBuffer;
	delete readBuffer;
}

void BLEPer_Impl::setAdvertise(bool shouldAdvertise)
{
	if (shouldAdvertise) {
		QLowEnergyAdvertisingData advertData;
		advertData.setDiscoverability(QLowEnergyAdvertisingData::DiscoverabilityGeneral);
		advertData.setLocalName(peripheralName);
		advertData.setServices({RBL_SERVICE_UUID});
		peripheralController->startAdvertising(QLowEnergyAdvertisingParameters(), advertData);
		std::cerr << "Started advertising" << std::endl;
	}
	else {
		peripheralController->stopAdvertising();
		std::cerr << "Stopped advertising" << std::endl;
	}
}

void BLEPer_Impl::send()
{
	const QLowEnergyCharacteristic &writeCharacteristic = RBLService->characteristic(RBL_CHAR_TX_UUID);
	while (bytes_sent < sendBuffer->size())
	{
		int length = sendBuffer->size() - bytes_sent;
		length = (length > MAX_CHUNK_SIZE) ? MAX_CHUNK_SIZE : length;
		QByteArray chunk(sendBuffer->mid(bytes_sent, length));
		RBLService->writeCharacteristic(writeCharacteristic, chunk);
		bytes_sent += length;
	}
}

void BLEPer_Impl::write(const unsigned char *data, unsigned char len)
{
	if (numConnected == 0) {
		std::cerr << "No subscribers connected" << std::endl;
		return;
	}
	sendBuffer->append(reinterpret_cast<const char *>(data), len);
	send();
}

void BLEPer_Impl::dataReceived(const QLowEnergyCharacteristic &characteristic, const QByteArray &data)
{
	const QLowEnergyCharacteristic &readCharacteristic = RBLService->characteristic(RBL_CHAR_RX_UUID);
	if (characteristic == readCharacteristic) {
		if (readHandler == Q_NULLPTR) {
			std::cerr << "No read was handler set" << std::endl;
			return;
		}
		readBuffer->append(data);
		readIdx += readHandler
		(
			serverInterface, 
			reinterpret_cast<const unsigned char*>(readBuffer->data()) + readIdx,
			readBuffer->size() - readIdx
		);
		if (readIdx == readBuffer->size())
		{
			readIdx = 0;
			readBuffer->clear();
		}
	}
}

#include "BLEPeripheral.moc"

