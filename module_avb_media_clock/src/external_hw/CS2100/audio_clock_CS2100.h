
#ifndef _audio_clock_CS2100CP_h_
#define _audio_clock_CS2100CP_h_
#include "i2c.h"

void audio_clock_CS2100_init(struct r_i2c &r_i2c, unsigned mclks_per_wordclk);

void audio_gen_CS2100_clock(out port p,  chanend clk_ctl);

#endif
