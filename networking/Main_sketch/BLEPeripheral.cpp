#include "BLEPeripheral.h"

#include <RBL_services.h>
#include <RBL_nRF8001.h>

BLEPeripheral::BLEPeripheral(const char *name) {
  ble_set_name(name);
  ble_begin();
}

void BLEPeripheral::write_byte(unsigned char data) {
  ble_write(data);
}

void BLEPeripheral::write(unsigned char *data, unsigned char len) {
  ble_write_bytes(data, len);
}

void BLEPeripheral::process() {
  ble_do_events();
}

unsigned char BLEPeripheral::read_byte() {
  return ble_read();
}

unsigned char BLEPeripheral::bytes_available() {
  return ble_available();
}

bool BLEPeripheral::connected() {
  return ble_connected();
}
