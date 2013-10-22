
#ifndef _audio_clock_CS2300CP_h_
#define _audio_clock_CS2300CP_h_
#include "i2c.h"

<<<<<<< HEAD
void audio_clock_CS2300CP_init(struct r_i2c &r_i2c, unsigned mclks_per_wordclk);

#ifdef AVB_PTP_GEN_DEBUG_CLK_IN_PLL_DRIVER
void audio_gen_CS2300CP_clock(out port p, chanend clk_ctl, chanend ptp_svr);
#else
void audio_gen_CS2300CP_clock(out port p, chanend clk_ctl);
#endif
=======
void audio_clock_CS2300CP_init(
                        #if I2C_COMBINE_SCL_SDA
                            port r_i2c
                        #else
                            struct r_i2c &r_i2c
                        #endif
                        ,unsigned mclks_per_wordclk);
>>>>>>> c9571f7ba9113648c12534912010302e18e3892e

#endif
