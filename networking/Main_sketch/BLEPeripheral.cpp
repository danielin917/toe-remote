#include "BLEPeripheral.h"

#include <Arduino.h>
#include <RBL_services.h>
#include <RBL_nRF8001.h>
#include <acilib_defs.h>
#include <acilib_if.h>
#include <dtm.h>
#include <lib_aci.h>
#include <hal_platform.h>
#include <acilib.h>
#include <bootloader_setup.h>
#include <ble_assert.h>
#include <aci_queue.h>
#include <hal_aci_tl.h>
#include <boards.h>
#include <aci_evts.h>
#include <aci_setup.h>
#include <acilib_types.h>
#include <aci.h>
#include <aci_cmds.h>
#include <aci_protocol_defines.h>


BLEPeripheral::BLEPeripheral(const char *name) : impl(nullptr) {
  ble_set_name((char*)name);
  ble_begin();
}

void BLEPeripheral::write_byte(unsigned char data) {
  ble_write(data);
}

void BLEPeripheral::write(const unsigned char *data, unsigned char len) {
  ble_write_bytes((unsigned char*)data, len);
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
