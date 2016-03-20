#pragma once

class BLEPeripheral {
public:
  BLEPeripheral(const char *name);
  ~BLEPeripheral();

  void write_byte(unsigned char data);

  void write(const unsigned char *data, unsigned char len);

  void process();

  unsigned char read_byte();

  unsigned char bytes_available();

  bool connected();

private:
    void *impl;
};
