//
//  DHInet.m
//  InetTest
//
//  Created by Daniel Nestor Corbatta Barreto on 20/11/13.
//  Copyright (c) 2013 Daniel Nestor Corbatta Barreto. All rights reserved.
//

#import "DHInet.h"
#import "privateheader.h"

@implementation DHInet

#define  SO_TC_MAX	10
char *
inetname(struct in_addr *inp)
{
	register char *cp;
	static char line[MAXHOSTNAMELEN];
	struct hostent *hp;
	struct netent *np;
    
	cp = 0;
	if (!nflag && inp->s_addr != INADDR_ANY) {
		int net = inet_netof(*inp);
		int lna = inet_lnaof(*inp);
        
		if (lna == INADDR_ANY) {
			np = getnetbyaddr(net, AF_INET);
			if (np)
				cp = np->n_name;
		}
		if (cp == 0) {
			hp = gethostbyaddr((char *)inp, sizeof (*inp), AF_INET);
			if (hp) {
				cp = hp->h_name;
                //### trimdomain(cp, strlen(cp));
			}
		}
	}
	if (inp->s_addr == INADDR_ANY)
		strlcpy(line, "*", sizeof(line));
	else if (cp) {
		strncpy(line, cp, sizeof(line) - 1);
		line[sizeof(line) - 1] = '\0';
	} else {
		inp->s_addr = ntohl(inp->s_addr);
#define C(x)	((u_int)((x) & 0xff))
		snprintf(line, sizeof(line), "%u.%u.%u.%u", C(inp->s_addr >> 24),
                 C(inp->s_addr >> 16), C(inp->s_addr >> 8), C(inp->s_addr));
	}
	return (line);
}

void
inetprint(struct in_addr *in, int port, const char *proto, int numeric_port, NSDictionary * conect, NSString * address)
{
	struct servent *sp = 0;
	char line[80], *cp;
	int width;
    
	if (Wflag)
	    snprintf(line, sizeof(line), "%s.", inetname(in));
	else
	    snprintf(line, sizeof(line), "%.*s.", (Aflag && !numeric_port) ? 12 : 16, inetname(in));
	cp = index(line, '\0');
	if (!numeric_port && port)
#ifdef _SERVICE_CACHE_
		sp = _serv_cache_getservbyport(port, proto);
#else
    sp = getservbyport((int)port, proto);
#endif
	if (sp || port == 0)
		snprintf(cp, sizeof(line) - (cp - line), "%.15s ", sp ? sp->s_name : "*");
	else
		snprintf(cp, sizeof(line) - (cp - line), "%d ", ntohs((u_short)port));
	width = (Aflag && !Wflag) ? 18 : 22;
	if (Wflag)
	    printf("%-*s ", width, line);
	else
	    printf("%-*.*s ", width, width, line);
    
    [conect setValue:[NSString stringWithUTF8String:line ] forKey:address];
}

- (NSArray *) protopr:(uint32_t) proto name:(const char *) name af:(int) af{
    NSMutableArray * tcpConnectionsActive = [NSMutableArray array];
    
    int istcp;
    struct xinpgen *xig, *oxig;
    struct xgen_n *xgn;
    size_t len = 0;
    char * next;
    int which = 0;
    
    char *buf;
    const char *mibvar;
    
    switch (proto) {
		case IPPROTO_TCP:
#ifdef INET6
			if (tcp_done != 0)
				return;
			else
				tcp_done = 1;
#endif
			istcp = 1;
			mibvar = "net.inet.tcp.pcblist_n";
			break;
		case IPPROTO_UDP:
#ifdef INET6
			if (udp_done != 0)
				return;
			else
				udp_done = 1;
#endif
			mibvar = "net.inet.udp.pcblist_n";
			break;
		case IPPROTO_DIVERT:
			mibvar = "net.inet.divert.pcblist_n";
			break;
		default:
			mibvar = "net.inet.raw.pcblist_n";
			break;
	}
    
    len = 0;
    if (sysctlbyname(mibvar, 0, &len, 0, 0) < 0) {
        if (errno != ENOENT)
            warn("sysctl: %s", mibvar);
        return nil;
    }
    if ((buf = malloc(len)) == 0) {
        warn("malloc %lu bytes", (u_long)len);
        return nil;
    }
    if (sysctlbyname(mibvar, buf, &len, 0, 0) < 0) {
        warn("sysctl: %s", mibvar);
        free(buf);
        return nil;
    }
    
    
    
    struct xsocket_n *so = NULL;
    struct xsockbuf_n *so_rcv = NULL;
    struct xsockbuf_n *so_snd = NULL;
    struct xsockstat_n *so_stat = NULL;
    struct xinpcb_n *inp = NULL;
    struct xtcpcb_n *tp = NULL;
    static int first = 1;
    /*
     * Bail-out to avoid logic error in the loop below when
     * there is in fact no more control block to process
     */
    if (len <= sizeof(struct xinpgen)) {
        free(buf);
        return nil;
    }
    
    oxig = xig = (struct xinpgen *)buf;
    for (next = buf + ROUNDUP64(xig->xig_len); next < buf + len; next += ROUNDUP64(xgn->xgn_len)) {
        
        xgn = (struct xgen_n*)next;
        if (xgn->xgn_len <= sizeof(struct xinpgen))
            break;
        
        if ((which & xgn->xgn_kind) == 0) {
            which |= xgn->xgn_kind;
            switch (xgn->xgn_kind) {
                case XSO_SOCKET:
                    so = (struct xsocket_n *)xgn;
                    break;
                case XSO_RCVBUF:
                    so_rcv = (struct xsockbuf_n *)xgn;
                    break;
                case XSO_SNDBUF:
                    so_snd = (struct xsockbuf_n *)xgn;
                    break;
                case XSO_STATS:
                    so_stat = (struct xsockstat_n *)xgn;
                    break;
                case XSO_INPCB:
                    inp = (struct xinpcb_n *)xgn;
                    break;
                case XSO_TCPCB:
                    tp = (struct xtcpcb_n *)xgn;
                    break;
                default:
                    printf("unexpected kind %d\n", xgn->xgn_kind);
                    break;
            }
        } else {
            printf("got %d twice\n", xgn->xgn_kind);
        }
        
        if ((istcp && which != ALL_XGN_KIND_TCP) || (!istcp && which != ALL_XGN_KIND_INP))
            continue;
        which = 0;
        
        /* Ignore sockets for protocols other than the desired one. */
        if (so->xso_protocol != (int)proto)
            continue;
        
        /* Ignore PCBs which were freed during copyout. */
        if (inp->inp_gencnt > oxig->xig_gen)
            continue;
        
        if ((af == AF_INET && (inp->inp_vflag & INP_IPV4) == 0)
#ifdef INET6
            || (af == AF_INET6 && (inp->inp_vflag & INP_IPV6) == 0)
#endif /* INET6 */
            || (af == AF_UNSPEC && ((inp->inp_vflag & INP_IPV4) == 0
#ifdef INET6
                                    && (inp->inp_vflag &
                                        INP_IPV6) == 0
#endif /* INET6 */
                                    ))
            )
            continue;
        
        /*
         * Local address is not an indication of listening socket or
         * server sockey but just rather the socket has been bound.
         * That why many UDP sockets were not displayed in the original code.
         */
        if (!aflag && istcp && tp->t_state <= TCPS_LISTEN)
            continue;
        
        if (Lflag && !so->so_qlimit)
            continue;
        
        if (first) {
            if (!Lflag) {
                printf("Active Internet connections");
                if (aflag)
                    printf(" (including servers)");
            } else
                printf(
                       "Current listen queue sizes (qlen/incqlen/maxqlen)");
            putchar('\n');
            if (Aflag)
#if !TARGET_OS_EMBEDDED
                printf("%-16.16s ", "Socket");
#else
            printf("%-8.8s ", "Socket");
#endif
            if (Lflag)
                printf("%-14.14s %-22.22s\n",
                       "Listen", "Local Address");
            else {
                printf((Aflag && !Wflag) ?
                       "%-5.5s %-6.6s %-6.6s  %-18.18s %-18.18s %-11.11s" :
                       "%-5.5s %-6.6s %-6.6s  %-22.22s %-22.22s %-11.11s",
                       "Proto", "Recv-Q", "Send-Q",
                       "Local Address", "Foreign Address",
                       "(state)");
                if (bflag > 0)
                    printf(" %10.10s %10.10s", "rxbytes", "txbytes");
                if (prioflag >= 0)
                    printf(" %7.7s[%1d] %7.7s[%1d]", "rxbytes", prioflag, "txbytes", prioflag);
                printf("\n");
            }
            first = 0;
        }
        NSMutableDictionary * conection = [NSMutableDictionary dictionary];
        if (Aflag) {
            if (istcp)
#if !TARGET_OS_EMBEDDED
                printf("%16lx ", (u_long)inp->inp_ppcb);
#else
            printf("%8lx ", (u_long)inp->inp_ppcb);
            
#endif
            else
#if !TARGET_OS_EMBEDDED
                printf("%16lx ", (u_long)so->so_pcb);
#else
            printf("%8lx ", (u_long)so->so_pcb);
#endif
        }
        if (Lflag) {
            char buf[15];
            
            snprintf(buf, 15, "%d/%d/%d", so->so_qlen,
                     so->so_incqlen, so->so_qlimit);
            printf("%-14.14s ", buf);
        }
        else {
            const char *vchar;
            
#ifdef INET6
            if ((inp->inp_vflag & INP_IPV6) != 0)
                vchar = ((inp->inp_vflag & INP_IPV4) != 0)
                ? "46" : "6 ";
            else
#endif
                vchar = ((inp->inp_vflag & INP_IPV4) != 0)
                ? "4 " : "  ";
            
            char protoname [50];
            snprintf ( protoname, 50, "%-3.3s%-2.2s", name, vchar );
            
            [conection setObject:[NSString stringWithUTF8String:protoname ] forKey:@"Proto"];
            [conection setObject:[NSNumber numberWithInt:so_rcv->sb_cc] forKey:@"Recv-Q" ];
            [conection setObject:[NSNumber numberWithInt:so_snd->sb_cc] forKey:@"Send-Q" ];
            printf("%-3.3s%-2.2s %6u %6u  ", name, vchar,
                   so_rcv->sb_cc,
                   so_snd->sb_cc);
            
        }
        if (nflag) {
            if (inp->inp_vflag & INP_IPV4) {
                inetprint(&inp->inp_laddr, (int)inp->inp_lport,
                          name, 1,conection,@"Local Address");
                if (!Lflag)
                    inetprint(&inp->inp_faddr,
                              (int)inp->inp_fport, name, 1,conection,@"Foreign Address");
            }
#ifdef INET6
            else if (inp->inp_vflag & INP_IPV6) {
                inet6print(&inp->in6p_laddr,
                           (int)inp->inp_lport, name, 1);
                if (!Lflag)
                    inet6print(&inp->in6p_faddr,
                               (int)inp->inp_fport, name, 1);
            } /* else nothing printed now */
#endif /* INET6 */
        } else if (inp->inp_flags & INP_ANONPORT) {
            if (inp->inp_vflag & INP_IPV4) {
                inetprint(&inp->inp_laddr, (int)inp->inp_lport,
                          name, 1,conection,@"Local Address");
                if (!Lflag)
                    inetprint(&inp->inp_faddr,
                              (int)inp->inp_fport, name, 0,conection,@"Foreign Address");
            }
#ifdef INET6
            else if (inp->inp_vflag & INP_IPV6) {
                inet6print(&inp->in6p_laddr,
                           (int)inp->inp_lport, name, 1);
                if (!Lflag)
                    inet6print(&inp->in6p_faddr,
                               (int)inp->inp_fport, name, 0);
            } /* else nothing printed now */
#endif /* INET6 */
        } else {
            if (inp->inp_vflag & INP_IPV4) {
                inetprint(&inp->inp_laddr, (int)inp->inp_lport,
                          name, 0, conection,@"Local Address");
                if (!Lflag)
                    inetprint(&inp->inp_faddr,
                              (int)inp->inp_fport, name,
                              inp->inp_lport !=
                              inp->inp_fport,conection,@"Foreign Address");
            }
#ifdef INET6
            else if (inp->inp_vflag & INP_IPV6) {
                inet6print(&inp->in6p_laddr,
                           (int)inp->inp_lport, name, 0);
                if (!Lflag)
                    inet6print(&inp->in6p_faddr,
                               (int)inp->inp_fport, name,
                               inp->inp_lport !=
                               inp->inp_fport);
            } /* else nothing printed now */
#endif /* INET6 */
        }
        if (istcp && !Lflag) {
            if (tp->t_state < 0 || tp->t_state >= TCP_NSTATES){
                printf("%-11d", tp->t_state);
                [conection setValue:[NSString stringWithUTF8String:tcpstates[tp->t_state]] forKey:@"State"];
            }
            else {
                printf("%-11s", tcpstates[tp->t_state]);
                [conection setValue:[NSString stringWithUTF8String:tcpstates[tp->t_state]] forKey:@"State"];
#if defined(TF_NEEDSYN) && defined(TF_NEEDFIN)
                /* Show T/TCP `hidden state' */
                if (tp->t_flags & (TF_NEEDSYN|TF_NEEDFIN))
                    putchar('*');
#endif /* defined(TF_NEEDSYN) && defined(TF_NEEDFIN) */
            }
        }
        if (!istcp)
            printf("%-11s", "           ");
        if (bflag > 0) {
            int i;
            u_int64_t rxbytes = 0;
            u_int64_t txbytes = 0;
            
            for (i = 0; i < SO_TC_MAX; i++) {
                rxbytes += so_stat->xst_tc_stats[i].rxbytes;
                txbytes += so_stat->xst_tc_stats[i].txbytes;
            }
            
            printf(" %10llu %10llu", rxbytes, txbytes);
        }
        if (prioflag >= 0) {
            printf(" %10llu %10llu",
                   prioflag < SO_TC_MAX ? so_stat->xst_tc_stats[prioflag].rxbytes : 0,
                   prioflag < SO_TC_MAX ? so_stat->xst_tc_stats[prioflag].txbytes : 0);
        }
        putchar('\n');
        [tcpConnectionsActive addObject:conection];
        
    }
    if (xig != oxig && xig->xig_gen != oxig->xig_gen) {
        if (oxig->xig_count > xig->xig_count) {
            printf("Some %s sockets may have been deleted.\n",
                   name);
        } else if (oxig->xig_count < xig->xig_count) {
            printf("Some %s sockets may have been created.\n",
                   name);
        } else {
            printf("Some %s sockets may have been created or deleted",
                   name);
        }
    }
    free(buf);
    return tcpConnectionsActive;
}

// You can change this flag to change the info showed.

int	Aflag = 0;	/* show addresses of protocol control block */
int	aflag = 0;	/* show all sockets (including servers) */
int	bflag = 1;	/* show i/f total bytes in/out */
int	Lflag = 0;	/* show size of listen queues */
int	Wflag = 0;	/* wide display */
int	prioflag = 0; /* show packet priority  statistics */
int	sflag = 0;	/* show protocol statistics */
int	nflag = 0;	/* show addresses numerically */
int	interval = 1; /* repeat interval for i/f stats */

- (NSArray *) getTCPConnections{
    return [self protopr:IPPROTO_TCP name:"tcp" af:AF_INET];
}
- (NSArray *) getUDPConnections{
    return [self protopr:IPPROTO_UDP name:"udp" af:AF_INET];
}
@end
