#include <xs1.h>
#include <xclib.h>
#include "media_clock_client.h"
#include "print.h"
#include "i2c.h"
#include <stdlib.h>

/*** Private Definitions ***/
#define CTL_SCLK_PERIOD_LOW_TICKS      (1000)
#define CTL_SCLK_PERIOD_HIGH_TICKS     (1000)

#define DEVICE_ADRS                    (0x90)

/*
 *  This module takes the output from the media clock server and transforms it into a
 *  reference clock to be sent to a PLL multiplier device - the CS2100
 *
 *  There are four important clocks in the system:
 *
 *    100MHz reference clock
 *    The word clock
 *    The master clock (MCLK)
 *    The i2s bit clock (BCLK)
 *
 *  The media clock server outputs the length of the sample period in 100MHz clocks.
 *  This module converts that into a reference clock by waiting for a multiple of this
 *  period (the multiple is PLL_TO_WORD_MULTIPLIER) and outputting a clock based on that
 *  multiplier period.   The PLL device then takes this low frequency clock and multiplies
 *  the frequency up to the MCLK frequency, which is the product of PLL_TO_WORD_MULTIPLIER
 *  and mclks_per_wordclk
 */

// This is the number of word clocks per cycle of the PLL output clock
#define PLL_TO_WORD_MULTIPLIER 100

// outputs a clock of media clock
void audio_gen_CS2100_clock(out port p, chanend clk_ctl)
{
  int bit = 0x0;
  unsigned int wordTime;
  int wordLength = 0;
  int clk_cmd, clk_arg;
  unsigned int baseLength = 0;
  unsigned int lowBits = 0;
  unsigned int prevLowBits = 0;
  unsigned int bitMask = (1 << WC_FRACTIONAL_BITS) - 1;
  int count=0;
  int stop=0;
  
  // this is the number of word clocks in one PLL output
  unsigned mult = PLL_TO_WORD_MULTIPLIER;

  // we need 2 ticks per sample
  mult = mult/2;

  while (1)
  {
   clk_cmd = -1;
   while (clk_cmd != CLK_CTL_SET_RATE)
    {
      slave {clk_ctl :> clk_cmd; clk_ctl :> clk_arg; };
      switch (clk_cmd)
        {
        case CLK_CTL_SET_RATE:  
          wordLength = clk_arg >> 1;
          baseLength = wordLength >> WC_FRACTIONAL_BITS;
          break;
        }
      break;
    }

  stop = 0;

  p <: 0 @ wordTime;
  while (!stop) {
    wordTime += baseLength;

    count++;
    if (count==mult) {
      bit = ~bit;
      count = 0;
    }

    p @ wordTime <: bit;

    lowBits = (lowBits + wordLength) & bitMask;
    if (lowBits <  prevLowBits) {
      wordTime += 1;
    }
    prevLowBits = lowBits;


   
    select {
    case slave {clk_ctl :> clk_cmd; clk_ctl :> clk_arg; }:
      switch (clk_cmd)
        {
        case CLK_CTL_SET_RATE:  
          wordLength = clk_arg >> 1; 
          baseLength = wordLength >> WC_FRACTIONAL_BITS;
          break;
        case CLK_CTL_STOP:
        	stop = 1;
        	break;
        }
      break;
    default:
      break;
    }
   }
  }
}


// Set up the multiplier in the PLL clock generator
void audio_clock_CS2100_init(struct r_i2c &r_i2c, unsigned mclks_per_wordclk)
{
   int deviceAddr = 0x9C;
   struct i2c_data_info data;
   int fail = 0;

   // this is the muiltiplier in the PLL, which takes the PLL reference clock and
   // multiplies it up to the MCLK frequency.
   unsigned mult = (PLL_TO_WORD_MULTIPLIER * mclks_per_wordclk);

   i2c_master_init(r_i2c);

   data.data_len = 1;
   data.master_num = 0;
   data.clock_mul = 5;

   mult = mult/2;
   mult = mult << 12;

   // Set loop bandwidth (8.8.1 in CS2100 chip spec)
   data.data[0] = 0x00; // 1Hz
   i2c_master_tx(deviceAddr, 0x1E, data, r_i2c);

   // Configure PLL
   data.data[0] = 0x01;
   i2c_master_tx(deviceAddr, 0x03, data, r_i2c);
   data.data[0] = 0x01;
   i2c_master_tx(deviceAddr, 0x05, data, r_i2c);
   data.data[0] = 0x08;
   i2c_master_tx(deviceAddr, 0x16, data, r_i2c);
   data.data[0] = 0x00;
   i2c_master_tx(deviceAddr, 0x17, data, r_i2c);

   // Set multiplier
   data.data[0] = (mult >> 24) & 0xFF;
   i2c_master_tx(deviceAddr, 0x06, data, r_i2c);
   data.data[0] = (mult >> 16) & 0xFF;
   i2c_master_tx(deviceAddr, 0x07, data, r_i2c);
   data.data[0] = (mult >> 8) & 0xFF;
   i2c_master_tx(deviceAddr, 0x08, data, r_i2c);
   data.data[0] = (mult) & 0xFF;
   i2c_master_tx(deviceAddr, 0x09, data, r_i2c);

   // Check configuration
   if (!i2c_master_rx(deviceAddr, 0x03, data, r_i2c))
   {
	   if (data.data[0] != 0x01)
	   {
		   fail = 1;
	   }
   }

   if (!i2c_master_rx(deviceAddr, 0x09, data, r_i2c))
   {
	   if (data.data[0] != (mult & 0xFF))
	   {
		   fail = 1;
	   }
   }

   if (fail)
   {
	   printstr("PLL chip configuration failed\n");
   }
}

