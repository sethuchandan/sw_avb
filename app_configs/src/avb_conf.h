#ifndef __avb_conf_h__
#define __avb_conf_h__

//#define XSCOPE_1722_TALKER

/* Configuration parameters for the ethernet code */
#define PHY_ADDRESS 0x0
#define MAX_ETHERNET_PACKET_SIZE (1518)
#define NUM_MII_RX_BUF 6
#define NUM_MII_TX_BUF 3
#define ETHERNET_RX_HP_QUEUE 1
#define MAX_ETHERNET_CLIENTS   5
#define MII_RX_BUFSIZE_HIGH_PRIORITY (700)    
#define MII_RX_BUFSIZE_LOW_PRIORITY (300)
#define MII_TX_BUFSIZE_HIGH_PRIORITY (300)
#define MII_TX_BUFSIZE_LOW_PRIORITY (200)
#define ETHERNET_MAX_TX_HP_PACKET_SIZE (300)

/* General purpose AVB configuration */
#define AVB_MAX_NAME_LEN 25
#define AVB_MAX_CHANNELS_PER_STREAM 8
#ifndef AVB_CHANNELS_PER_STREAM
#define AVB_CHANNELS_PER_STREAM 1
#endif

#ifdef TALKER
/* Talker configuration */
#ifndef AVB_NUM_SOURCES
  #define AVB_NUM_SOURCES 2
#endif
#define AVB_NUM_TALKER_UNITS 1
#ifndef LISTENER  // avoid redefine warnings
  #define AVB_NUM_MEDIA_UNITS 1
#endif
#endif

#ifdef LISTENER
/* Listener configuration */
#ifndef AVB_NUM_SINKS
  #define AVB_NUM_SINKS 2
#endif
#define AVB_NUM_LISTENER_UNITS 1
#define AVB_NUM_MEDIA_UNITS 2
#endif


/* Media configuration */
#define AVB_1722_FORMAT_61883_6

/* Media clock configuration */
#define AVB_NUM_MEDIA_CLOCKS 1

/* Allow for high sample rates */
#define AVB_MAX_AUDIO_SAMPLE_RATE 96000

/* Add synths from channels 3/4 upwards in I2S for this demo */
#define I2S_SYNTH_FROM 1

// Defining this makes SRP auto-start and auto-stop a stream when listeners come and go
#define SRP_AUTO_TALKER_STREAM_CONTROL

///////////////////////////////////////
// Derived Defines.
#ifndef AVB_NUM_MEDIA_INPUTS
#define AVB_NUM_MEDIA_INPUTS AVB_NUM_SOURCES*AVB_CHANNELS_PER_STREAM
#endif

#ifndef AVB_NUM_MEDIA_OUTPUTS
#define AVB_NUM_MEDIA_OUTPUTS AVB_NUM_SINKS*AVB_CHANNELS_PER_STREAM
#endif

#if(AVB_NUM_MEDIA_INPUTS>8)
#warning "AVB_NUM_MEDIA_INPUTS exceeds 8, the max channels over 4 i2s lines"
#endif


#if(AVB_NUM_MEDIA_OUTPUTS>8)
#warning "AVB_NUM_MEDIA_OUTPUTS exceeds 8, the max channels over 4 i2s lines"
#endif

///////////////////////////////////////
// Defaults
#ifndef AVB_NUM_SINKS
#define AVB_NUM_SINKS 0
#endif

#ifndef AVB_NUM_LISTENER_UNITS
#define AVB_NUM_LISTENER_UNITS 0
#endif

#ifndef AVB_NUM_SOURCES
#define AVB_NUM_SOURCES 0
#endif

#ifndef AVB_NUM_TALKER_UNITS
#define AVB_NUM_TALKER_UNITS 0
#endif

#endif
