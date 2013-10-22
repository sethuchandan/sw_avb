AVB Software Stack
..................

:Version: 5.2.1rc1
:Vendor: XMOS
:Description: AVB software stack


Key Features
============

* 1722 Talker and Listener (simultaneous) support
* 1722 MAAP support for Talkers
* 802.1Q MRP, MMRP, MVRP, SRP protocols
* gPTP server and protocol
* Audio interface for I2S and TDM
* Media clock recovery and interface to PLL clock source
* Support for 1722.1 AVDECC: ADP, AECP (AEM) and ACMP

Firmware Overview
=================

This firmware is a reference endpoint implementation of Audio Video Bridging protocols for XMOS silicon. It includes a PTP time
server to provide a stable wallclock reference and clock recovery to synchronise listener audio to talker audio
codecs. The Stream Reservation Protocol is used to reserve bandwidth through 802.1 network infrastructure.

Known Issues
============

Required software (dependencies)
================================

  * sc_i2c
  * sc_util
  * sc_slicekit_support
  * sc_otp
  * sc_ethernet

Documentation
=============

You can find the documentation for this software in the doc/ directory of the package.

Support
=======

  This package is support by XMOS Ltd. Issues can be raised against the software
  at:

      http://www.xmos.com/support

