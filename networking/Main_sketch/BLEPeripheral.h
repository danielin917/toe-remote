
class BLEPeripheral {
public:
  BLEPeripheral();

  void write_byte(unsigned char data);

  void write(unsigned char *data, unsigned char len);

  void process();

  unsigned char read_byte();

  unsigned char bytes_available();

  bool connected();
};
