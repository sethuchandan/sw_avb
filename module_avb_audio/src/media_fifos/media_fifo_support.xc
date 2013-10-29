/*
 * @ModuleName Media FIFO support
 * @Description: Interface tasks to speedup commuication between fifos and audio interface
 *
 *
 */

#include <xs1.h>
#include <xclib.h>
#include <print.h>
#include <stdlib.h>
#include <syscall.h>
#include <xscope.h>
#include "media_fifo.h"
#include "simple_printf.h"

/**
 *  \brief Interface task between ififo/ofifo and an audio interface
 *
 *  Especially useful for TDM (4 or 8 channels per dataline)
 *  Where this task is essential to meet the timing
 *  by getting a subset of samples for each sub-slot
 */

void media_input_output_fifo_support_upto_16ch(streaming chanend samples_out,
			streaming chanend c_samples_from_adc,
            media_output_fifo_t ?output_fifos[],
            media_input_fifo_t ?input_fifos[]
            )
  {
	 unsigned int active_fifos;
 	 while (1) {
 		 unsigned int size;
 		 unsigned timestamp;
 		 samples_out :> timestamp;
 		 active_fifos = media_input_fifo_enable_req_state();

 		 // channels 0..AVB_AUDIO_IF_SAMPLES_PER_PERIOD on sdata_out[0],
 		 // channels AVB_AUDIO_IF_SAMPLES_PER_PERIOD..(2*AVB_AUDIO_IF_SAMPLES_PER_PERIOD-1) on sdata_out[1]
 		 // etc, etc
#pragma loop unroll
 		 for (int i=0;i<AVB_AUDIO_IF_SAMPLES_PER_PERIOD;i++) {
		     unsigned sample;
 			 for(int j=0; j<AVB_NUM_AUDIO_SDATA_OUT; j++) {

 				 sample = media_output_fifo_pull_sample(output_fifos[i+j*AVB_AUDIO_IF_SAMPLES_PER_PERIOD],
 						 timestamp);
 				 samples_out <: sample;
 			 }
 			 for(int j=0; j<AVB_NUM_AUDIO_SDATA_IN; j++) {
 				c_samples_from_adc :> sample;
 				if(i==0) {
 					//xscope_int(2, sample);
 				}

 				if (active_fifos & (1 << (i+j*AVB_AUDIO_IF_SAMPLES_PER_PERIOD))) {
 					media_input_fifo_push_sample(input_fifos[i+j*AVB_AUDIO_IF_SAMPLES_PER_PERIOD], sample, timestamp);
 				} else {
 					media_input_fifo_flush(input_fifos[i+j*AVB_AUDIO_IF_SAMPLES_PER_PERIOD]);
 				}
 			 }
 		 }
 	 }
  }
