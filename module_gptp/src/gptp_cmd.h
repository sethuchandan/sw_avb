#ifndef __ptp_cmd_h__
#define __ptp_cmd_h__

enum ptp_cmd_t {
  PTP_GET_TIME_INFO,
  PTP_GET_TIME_INFO_MOD64,
  PTP_SET_LEGACY_MODE,
  PTP_GET_GRANDMASTER
};

#endif // __ptp_cmd_h__
