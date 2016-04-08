#include <iostream>
#include <vector>
#include <QString>
#include <QLowEnergyController>
using namespace QBlueTooth;
using QString;

constexpr QString RBL_SERVICE_UUID("713D0000-503E-4C75-BA94-3148F18D941E");
// For sending data
constexpr QString RBL_CHAR_TX_UUID("713D0002-503E-4C75-BA94-3148F18D941E");
// For receiving data
constexpr QString RBL_CHAR_RX_UUID("713D0003-503E-4C75-BA94-3148F18D941E");
int MAX_CHUNK_SIZE = 64;

class BLEPeripheral_Impl : public QObject
{
	Q_OBJECT

 public:
	BLEPeripheral_Impl(QObject *parent = 0, const char *name);
	~BLEPeripheral_Impl();
	
	int numConnected;
	int sendIdx;
	int readIdx;
	QString serviceName;	
	QLowEnergyController *peripheralController;
	QLowEnergyService *mainService;
	QLowEnergyService *writeService;
	QLowEnergyService *readService;
	QLowEnergyCharacteristic *writeCharacteristic;
	QLowEnergyCharacteristic *readCharacteristic;
	
	read_handler_t readHandler;
	void *serverInterface;

 public slots:
	void send();
	void write(void *data);
	void setAdvertise(bool shouldAdvertise = true);
	void cleanup();
};

BLEPeripheral::BLEPeripheral(const char *name)
{
	(BLEPeripheral_Impl*) impl = new BLEPeripheral_Impl
}

BLEPeripheral::~BLEPeripheral()
{
	delete (BLEPeripheral_Impl*) impl;
}

void BLEPeripheral::write_byte(unsigned char data)
{
	this->write(&data, 1);
}

void BLEPeripheral::write(const unsigned char *data, unsigned char len)
{
	
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
	return 
}

BLEPeripheral_Impl::BLEPeripheral_Impl(const char *name)
{
	std::cerr << "Initializing" << std::endl;
	this->numConnected = 0;
	this->readIdx = 0;
	this->sendIdx = 0;
	this->serviceName = name;
	
	peripheralController = createPeripheral(this);
	QObject::connect(peripheralController, SIGNAL(peripheralController->disconnected()), 
					this, SLOT(this->setAdvertise()));
	
}

void BLEPeripheral_Impl::setAdvertise(bool shouldAdvertise = true)
{
	QLowEnergyAdvertisingData advertData;
	advertData.setDiscoverability(QLowEnergyAdvertisingData::DiscoverabilityGeneral);
}





