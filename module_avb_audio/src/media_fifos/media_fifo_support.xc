/*
 * @ModuleName Audio ADC FIFO Module.
 * @Description: Implements tasks to receive samples from audio Interface and stuff them in the ififo
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

// receive samples from audio Interface and push them in the ififo

void media_input_fifo_stuffer(
#ifdef AVB_INPUT_FIFO_STREAMING_CHAN
        chanend ?c_sync,
#else
        streaming chanend ?c_sync,
#endif
		media_input_fifo_t ?input_fifos[],
		unsigned num_chan_in) {
	unsigned adc_buffer_address;
	unsigned timestamp;
	unsigned sample;
	unsigned int active_fifos;

	while(1) {
#ifdef AVB_INPUT_FIFO_STREAMING_CHAN
		slave {
	 	  c_sync :> adc_buffer_address;
		  c_sync :> timestamp;
		};
#else
	 	c_sync :> adc_buffer_address;
		c_sync :> timestamp;
#endif
		active_fifos = media_input_fifo_enable_req_state();

		for(int i=0; i<num_chan_in; i++) {
			if (active_fifos & (1 << (i))) {
				asm("ldw %0, %1[%2]":"=r"(sample):"r"(adc_buffer_address),"r"(i));
				media_input_fifo_push_sample(input_fifos[i], sample, timestamp);
				if(i==0) {
					//xscope_int(2, sample);
				}
			} else {
				media_input_fifo_flush(input_fifos[i]);
			}
		}
        //xscope_int(1, timestamp);
	}
};

void media_input_fifo_stuffer_chan(
		streaming chanend ?c_samples_from_adc,
		media_input_fifo_t ?input_fifos[],
		unsigned num_chan_in) {

	unsigned timestamp;
	unsigned sample;
	unsigned int active_fifos;

	while(1) {
		c_samples_from_adc :> timestamp;
		active_fifos = media_input_fifo_enable_req_state();

		for(int i=0; i<num_chan_in; i++) {
			c_samples_from_adc :> sample;
			if(i==0) {
#if AVB_TALKER_XSCOPE_PROBES
				xscope_int(2, sample);
#endif
			}

			if (active_fifos & (1 << (i))) {
				media_input_fifo_push_sample(input_fifos[i], sample, timestamp);
			} else {
				media_input_fifo_flush(input_fifos[i]);
			}
		}
#if AVB_TALKER_XSCOPE_PROBES
        xscope_int(1, timestamp);
#endif
	}
};

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
