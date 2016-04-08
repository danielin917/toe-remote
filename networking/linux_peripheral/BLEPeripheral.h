#ifndef __BLEPeripheral__
#define __BLEPeripheral__

using read_handler_t = unsigned(*)(void *, const unsigned char *, unsigned);

class BLEPeripheral {
public:
  BLEPeripheral(const char *name);
  ~BLEPeripheral();

  void write_byte(unsigned char data);

  void write(const unsigned char *data, unsigned char len);

  void process();
    
  static bool allows_async();
    
  void register_read_handler(void *, read_handler_t);

  unsigned char read_byte();

  unsigned char bytes_available();

  bool connected();

private:
    void *impl;
};

#endif // __BLEPeripheral__
