#include <print.h>
#include <string.h>
#include <xccompat.h>
#include "avb_1722_common.h"
#include "avb_1722_1.h"
#include "avb_1722_1_common.h"
#include "avb_1722_1_adp.h"
#include "avb_1722_1_acmp.h"
#include "avb_1722_1_aecp.h"

typedef union {
	avb_1722_1_adp_packet_t adp;
	avb_1722_1_acmp_packet_t scm;
	avb_1722_1_aecp_packet_t sem;
} avb_1722_1_packet_t;

unsigned char my_mac_addr[6];

// Buffer for constructing 1722.1 transmit packets
unsigned int avb_1722_1_buf[(sizeof(avb_1722_1_packet_t)+sizeof(ethernet_hdr_t)+3)/4];

// The GUID of this device
guid_t my_guid;

void avb_1722_1_init(unsigned char macaddr[6], unsigned char serial_number[2])
{
	for (int i=0;i<6;i++)
	{
		my_mac_addr[i] = macaddr[i];
	}

	my_guid.c[0] = macaddr[5];
	my_guid.c[1] =  macaddr[4];
	my_guid.c[2] = macaddr[3];
	my_guid.c[3] = 0xfe;
	my_guid.c[4] = 0xff;
	my_guid.c[5] = macaddr[2];
	my_guid.c[6] = macaddr[1];
	my_guid.c[7] = macaddr[0];

	avb_1722_1_adp_init();
#if (AVB_1722_1_CONTROLLER_ENABLED)
	avb_1722_1_acmp_controller_init();
#endif
#if (AVB_1722_1_TALKER_ENABLED)
	avb_1722_1_acmp_talker_init();
#endif
#if (AVB_1722_1_LISTENER_ENABLED)
	avb_1722_1_acmp_listener_init();
#endif

}

avb_status_t avb_1722_1_process_packet(unsigned int buf0[], int len, chanend c_tx)
{
	  unsigned char *buf = (unsigned char *) buf0;

	  struct ethernet_hdr_t *ethernet_hdr = (ethernet_hdr_t *) &buf[0];
	  struct tagged_ethernet_hdr_t *tagged_ethernet_hdr = (tagged_ethernet_hdr_t *) &buf[0];

	  int has_qtag = ethernet_hdr->ethertype[1]==0x18;
	  int ethernet_pkt_size = has_qtag ? 18 : 14;

	  struct avb_1722_1_packet_header_t *pkt =
	    (struct avb_1722_1_packet_header_t *) &buf[ethernet_pkt_size];

	  if (has_qtag) {
	    if (tagged_ethernet_hdr->ethertype[1] != (AVB_ETYPE & 0xff) ||
	        tagged_ethernet_hdr->ethertype[0] != (AVB_ETYPE >> 8)) {
	        // not a 1722 packet
	        return AVB_NO_STATUS;
	      }
	  } else {
	    if (ethernet_hdr->ethertype[1] != (AVB_ETYPE & 0xff) ||
	        ethernet_hdr->ethertype[0] != (AVB_ETYPE >> 8)) {
	        // not a 1722 packet
	        return AVB_NO_STATUS;
	      }
	  }

	  if (GET_1722_1_CD_FLAG(pkt) != 1)
		    // not a 1722.1 packet
		    return AVB_NO_STATUS;

	  {
		  unsigned subtype = GET_1722_1_SUBTYPE(pkt);

		  switch (subtype) {
		  case DEFAULT_1722_1_ADP_SUBTYPE:
			  return process_avb_1722_1_adp_packet((avb_1722_1_adp_packet_t*)pkt, c_tx);
		  case DEFAULT_1722_1_AECP_SUBTYPE:
			  return process_avb_1722_1_aecp_packet(ethernet_hdr->src_addr , (avb_1722_1_aecp_packet_t*)pkt, c_tx);
		  case DEFAULT_1722_1_ACMP_SUBTYPE:
			  return process_avb_1722_1_acmp_packet((avb_1722_1_acmp_packet_t*)pkt, c_tx);
		  default:
			  return AVB_NO_STATUS;
		  }
	  }

	  return AVB_NO_STATUS;
}

avb_status_t avb_1722_1_periodic(chanend c_tx, chanend c_ptp)
{
	avb_status_t res;
	res = avb_1722_1_adp_advertising_periodic(c_tx, c_ptp);
	if (res != AVB_NO_STATUS) return res;
	res = avb_1722_1_adp_discovery_periodic(c_tx);
	if (res != AVB_NO_STATUS) return res;
#if (AVB_1722_1_CONTROLLER_ENABLED)
	res = avb_1722_1_acmp_controller_periodic(c_tx);
	if (res != AVB_NO_STATUS) return res;
#endif
#if (AVB_1722_1_TALKER_ENABLED)
	res = avb_1722_1_acmp_talker_periodic(c_tx);
	if (res != AVB_NO_STATUS) return res;
#endif
#if (AVB_1722_1_LISTENER_ENABLED)
	res = avb_1722_1_acmp_listener_periodic(c_tx);
	if (res != AVB_NO_STATUS) return res;
#endif
	return AVB_NO_STATUS;
}



