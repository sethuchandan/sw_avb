Simple AVB Endpoint Demo
========================

:scope: Example
:description: A simple 1722.1 example endpoint application
:keywords: avb, simple, 1722.1, example
:boards: XR-AVB-LC-BRD

A simple 1722.1 example endpoint application

Tested configurations for 16ch in / 16ch out with TDM
=====================================================
Note: See Makefile for details on the naming convention.

3 out of 4 16-channel configs are working between two XMOS EPs:  
   * 1t1s16ch_1l1s16ch_TDM
   * 1t2s16ch_1l2s16ch_TDM
   * 1t4s16ch_1l4s16ch_TDM
Only 1 out of 4 is working on the Mac: 
   * 1t1s16ch_1l1s16ch_TDM

Note: It looks like the other 3 fail due to a 1722.1 descriptor problem
