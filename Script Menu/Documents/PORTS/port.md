# 一般的なポート番号

|Port|Protocols|Status|Description|
|:---:|:---:|:---:|:---|
|0|TCP,UDP |Reserved|Reserved; do not use (but is a permissible source port value if the sending process does not expect messages in response) |
|1|TCP,UDP |Reserved|TCPMUX (TCP port service multiplexer) |
|5|TCP,UDP |Reserved|RJE (Remote Job Entry) |
|7|TCP,UDP |Reserved|ECHO protocol |
|9|TCP,UDP |Reserved|DISCARD protocol |
|11|TCP,UDP |Reserved|SYSTAT protocol |
|13|TCP,UDP |Reserved|DAYTIME protocol |
|15|TCP,UDP |Reserved|NETSTAT protocol |
|17|TCP,UDP |Reserved|QOTD (Quote of the Day) protocol |
|18|TCP,UDP |Reserved|Message Send Protocol (MSP) |
|19|TCP,UDP |Reserved|CHARGEN (Character Generator) protocol |
|20|TCP |Reserved|FTP - data port |
|21|TCP |Reserved|FTP - control (command) port |
|22|TCP,UDP |Reserved|SSH (Secure Shell) - used for secure logins, file transfers (scp, sftp) and port forwarding |
|23|TCP,UDP |Reserved|TELNET protocol - unencrypted text communications |
|25|TCP,UDP |Reserved|SMTP - used for e-mail routing between mailservers E-mails |
|26|TCP,UDP | - |RSFTP - A simple FTP-like protocol |
|35|TCP,UDP |Reserved|Any private printer server protocol |
|35|TCP,UDP | - |QMS Magicolor 2 printer server protocol |
|37|TCP,UDP |Reserved|TIME protocol |
|39|TCP,UDP |Reserved|Resource Location Protocol[1] (RLP) - used for determining the location of higher level services from hosts on a network |
|41|TCP,UDP |Reserved|Graphics |
|42|TCP,UDP |Reserved|nameserver, ARPA Host Name Server Protocol |
|42|TCP,UDP | - |WINS |
|43|TCP |Reserved|WHOIS protocol |
|49|TCP,UDP |Reserved|TACACS Login Host protocol |
|52|TCP,UDP |Reserved|XNS (Xerox Network Services) Time Protocol |
|53|TCP,UDP |Reserved|DNS (Domain Name Server) |
|54|TCP,UDP |Reserved|XNS (Xerox Network Services) Clearinghouse |
|56|TCP,UDP |Reserved|XNS (Xerox Network Services) Authentication |
|56|TCP,UDP | - |RAP (Route Access Protocol)[2] |
|57|TCP | - |MTP, Mail Transfer Protocol |
|58|TCP,UDP |Reserved|XNS (Xerox Network Services) Mail |
|67|UDP |Reserved|BOOTP (BootStrap Protocol) server; also used by DHCP (Dynamic Host Configuration Protocol) |
|68|UDP |Reserved|BOOTP client; also used by DHCP |
|69|UDP |Reserved|TFTP (Trivial File Transfer Protocol) |
|70|TCP |Reserved|Gopher protocol |
|79|TCP |Reserved|Finger protocol |
|80|TCP |Reserved|HTTP (HyperText Transfer Protocol), default web server port |
|81|TCP | - |Torpark - Onion routing ORport |
|82|UDP | - |Torpark - Control Port |
|83|TCP |Reserved|MIT ML Device |
|88|TCP |Reserved|Kerberos - authenticating agent |
|90|TCP,UDP |Reserved|dnsix (DoD Network Security for Information Exchange) Securit Attribute Token Map |
|90|TCP,UDP | - |Pointcast |
|101|TCP |Reserved|NIC host name |
|102|TCP |Reserved|ISO-TSAP (Transport Service Access Point) Class 0 protocol[3] |
|107|TCP |Reserved|Remote TELNET Service[4] protocol |
|109|TCP |Reserved|POP2, Post Office Protocol, version 2 |
|110|TCP |Reserved|POP3, Post Office Protocol, version 3 |
|111|TCP,UDP |Reserved|Sun Remote Procedure Call protocol |
|113|TCP |Reserved|ident - old server identification system, still used by IRC servers to identify its users |
|115|TCP |Reserved|SFTP, Simple File Transfer Protocol |
|117|TCP |Reserved|UUCP Path Service |
|118|TCP,UDP |Reserved|SQL (Structured Query Language) Services |
|119|TCP |Reserved|NNTP (Network News Transfer Protocol) - used for retrieving newsgroups messages |
|123|UDP |Reserved|NTP (Network Time Protocol) - used for time synchronization |
|135|TCP,UDP |Reserved|DCE endpoint resolution |
|135|TCP,UDP | - |Microsoft EPMAP (End Point Mapper), also known as DCE/RPC Locator service[5], used to to remotely manage services including DHCP server, DNS server and WINS |
|137|TCP,UDP |Reserved|NetBIOS NetBIOS Name Service |
|138|TCP,UDP |Reserved|NetBIOS NetBIOS Datagram Service |
|139|TCP,UDP |Reserved|NetBIOS NetBIOS Session Service |
|143|TCP,UDP |Reserved|IMAP4 (Internet Message Access Protocol 4) - used for retrieving E-mails |
|152|TCP,UDP |Reserved|Background File Transfer Program (BFTP)[6] |
|153|TCP,UDP |Reserved|SGMP, Simple Gateway Monitoring Protocol |
|156|TCP,UDP |Reserved|SQL Service |
|158|TCP,UDP | - |DMSP, Distributed Mail Service Protocol |
|161|TCP,UDP |Reserved|SNMP (Simple Network Management Protocol) |
|162|TCP,UDP |Reserved|SNMPTRAP |
|170|TCP |Reserved|Print-srv, Network PostScript |
|179|TCP |Reserved|BGP (Border Gateway Protocol) |
|194|TCP |Reserved|IRC (Internet Relay Chat) |
|201|TCP,UDP |Reserved|AppleTalk Routing Maintenance |
|209|TCP,UDP |Reserved|The Quick Mail Transfer Protocol |
|213|TCP,UDP |Reserved|IPX |
|218|TCP,UDP |Reserved|MPP, Message Posting Protocol |
|220|TCP,UDP |Reserved|IMAP, Interactive Mail Access Protocol, version 3 |
|259|TCP,UDP |Reserved|ESRO, Efficient Short Remote Operations |
|264|TCP,UDP |Reserved|BGMP, Border Gateway Multicast Protocol |
|311|TCP |Reserved|AppleShare Admin-Tool, Workgroup-Manager-Tool |
|308|TCP |Reserved|Novastor Online Backup |
|318|TCP,UDP |Reserved|PKIX TSP, Time Stamp Protocol |
|323|TCP,UDP | - |IMMP, Internet Message Mapping Protocol |
|366|TCP,UDP |Reserved|ODMR, On-Demand Mail Relay |
|369|TCP,UDP |Reserved|Rpc2portmap |
|371|TCP,UDP |Reserved|ClearCase albd |
|383|TCP,UDP |Reserved|HP data alarm manager |
|384|TCP,UDP |Reserved|A Remote Network Server System |
|387|TCP,UDP |Reserved|AURP, AppleTalk Update-based Routing Protocol |
|389|TCP,UDP |Reserved|LDAP (Lightweight Directory Access Protocol) |
|401|TCP,UDP |Reserved|UPS Uninterruptible Power Supply |
|411|TCP | - |Direct Connect Hub port |
|412|TCP | - |Direct Connect Client-To-Client port |
|427|TCP,UDP |Reserved|SLP (Service Location Protocol) |
|443|TCP |Reserved|HTTPS - HTTP Protocol over TLS/SSL (encrypted transmission) |
|444|TCP,UDP |Reserved|SNPP, Simple Network Paging Protocol |
|445|TCP |Reserved|Microsoft-DS Active Directory, Windows shares |
|445|UDP |Reserved|Microsoft-DS SMB file sharing |
|464|TCP,UDP |Reserved|Kerberos Change/Set password |
|465|TCP | - |Cisco protocol |
|465|TCP | - |SMTP over SSL |
|475|TCP |Reserved|tcpnethaspsrv (Hasp services, TCP/IP version) |
|497|TCP |Reserved|dantz backup service |
|500|UDP |Reserved|ISAKMP, IKE-Internet Key Exchange |
|502|TCP,UDP | - |Modbus, Protocol |
|512|TCP |Reserved|exec, Remote Process Execution |
|512|UDP |Reserved|comsat, together with biff |
|513|TCP |Reserved|Login |
|513|UDP |Reserved|Who |
|514|TCP |Reserved|rsh protocol - used to execute non-interactive commandline commands on a remote system |
|514|UDP |Reserved|syslog protocol - used for system logging |
|515|TCP |Reserved|Line Printer Daemon protocol - used in LPD printer servers |
|517|UDP |Reserved|Talk |
|518|UDP |Reserved|NTalk |
|520|TCP |Reserved|efs, extended file name server |
|520|UDP |Reserved|Routing - RIP |
|524|TCP,UDP |Reserved|NCP (NetWare Core Protocol) is used for a variety things such as access to primary NetWare server resources, Time Synchronization, etc. |
|525|UDP |Reserved|Timed, Timeserver |
|530|TCP,UDP |Reserved|RPC |
|531|TCP,UDP | - |AOL Instant Messenger, IRC |
|532|TCP |Reserved|netnews |
|533|UDP |Reserved|netwall, For Emergency Broadcasts |
|540|TCP |Reserved|UUCP (Unix-to-Unix Copy Protocol) |
|542|TCP,UDP |Reserved|commerce (Commerce Applications) |
|543|TCP |Reserved|klogin, Kerberos login |
|544|TCP |Reserved|kshell, Kerberos Remote shell |
|546|TCP,UDP |Reserved|DHCPv6 client |
|547|TCP,UDP |Reserved|DHCPv6 server |
|548|TCP |Reserved|AFP (Apple Filing Protocol) |
|550|UDP |Reserved|new-rwho, new-who |
|554|TCP,UDP |Reserved|RTSP (Real Time Streaming Protocol) |
|556|TCP |Reserved|Remotefs, RFS, rfs_server |
|560|UDP |Reserved|rmonitor, Remote Monitor |
|561|UDP |Reserved|monitor |
|563|TCP,UDP |Reserved|NNTP protocol over TLS/SSL (NNTPS) |
|587|TCP |Reserved|email message submission (SMTP) (RFC 2476) |
|591|TCP |Reserved|FileMaker 6.0 (and later) Web Sharing (HTTP Alternate, also see port 80) |
|593|TCP,UDP |Reserved|HTTP RPC Ep Map, Remote procedure call over Hypertext Transfer Protocol, often used by Distributed Component Object Model services and Microsoft Exchange Server |
|604|TCP |Reserved|TUNNEL profile[7], a protocol for BEEP peers to form an application layer tunnel |
|631|TCP,UDP |Reserved|IPP (Internet Printing Protocol) |
|636|TCP,UDP |Reserved|LDAP over SSL (encrypted transmission, also known as LDAPS) |
|639|TCP,UDP |Reserved|MSDP, Multicast Source Discovery Protocol |
|646|TCP |Reserved|LDP, Label Distribution Protocol, a routing protocol used in MPLS networks |
|647|TCP |Reserved|DHCP Failover protocol[8] |
|648|TCP |Reserved|RRP (Registry Registrar Protocol)[9] |
|652|TCP | - |DTCP, Dynamic Tunnel Configuration Protocol |
|654|TCP |Reserved|AODV (Ad-hoc On-demand Distance Vector) |
|655|TCP |Reserved|IEEE MMS (IEEE Media Management System)[10][11] |
|665|TCP | - |sun-dr, Remote Dynamic Reconfiguration |
|666|UDP |Reserved|Doom, First online first-person shooter |
|674|TCP |Reserved|ACAP (Application Configuration Access Protocol) |
|691|TCP |Reserved|MS Exchange Routing |
|692|TCP |Reserved|Hyperwave-ISP |
|694|UDP | - |Linux-HA High availability Heartbeat port |
|695|TCP |Reserved|IEEE-MMS-SSL (IEEE Media Management System over SSL)[12] |
|698|UDP |Reserved|OLSR (Optimized Link State Routing) |
|699|TCP |Reserved|Access Network |
|700|TCP |Reserved|EPP (Extensible Provisioning Protocol), a protocol for communication between domain name registries and registrars |
|701|TCP |Reserved|LMP (Link Management Protocol (Internet))[13], a protocol that runs between a pair of nodes and is used to manage traffic engineering (TE) links |
|702|TCP |Reserved|IRIS[14][15] (Internet Registry Information Service) over BEEP (Blocks Extensible Exchange Protocol)[16] |
|706|TCP |Reserved|SILC, Secure Internet Live Conferencing |
|711|TCP |Reserved|Cisco TDP, Tag Distribution Protocol[17][18][19] - being replaced by the MPLS Label Distribution Protocol[20] |
|712|TCP |Reserved|TBRPF, Topology Broadcast based on Reverse-Path Forwarding routing protocol |
|712|UDP | - |Promise RAID Controller |
|720|TCP | - |SMQP, Simple Message Queue Protocol |
|749|TCP,UDP |Reserved|kerberos-adm, Kerberos administration |
|750|TCP |Reserved|rfile |
|750|UDP |Reserved|loadav |
|750|UDP |Reserved|kerberos-iv, Kerberos version IV |
|751|TCP,UDP |Reserved|pump |
|751|TCP,UDP | - |kerberos_master, Kerberos authentication |
|752|TCP |Reserved|qrh |
|752|UDP |Reserved|qrh |
|752|UDP | - |userreg_server, Kerberos Password (kpasswd) server |
|753|TCP |Reserved|Reverse Routing Header (rrh)[21] |
|753|UDP |Reserved|Reverse Routing Header (rrh) |
|753|UDP | - |passwd_server, Kerberos userreg server |
|754|TCP |Reserved|tell send |
|754|TCP | - |krb5_prop, Kerberos v5 slave propagation |
|754|UDP |Reserved|tell send |
|760|TCP,UDP |Reserved|ns |
|760|TCP,UDP | - |krbupdate [kreg], Kerberos registration |
|782|TCP | - |Conserver serial-console management server |
|829|TCP | - |CMP (Certificate Management Protocol) |
|860|TCP |Reserved|iSCSI |
|873|TCP |Reserved|rsync file synchronisation protocol default port |
|888|tcp | - |cddbp, CD DataBase (CDDB) protocol (CDDBP) - unassigned but widespread use |
|901|TCP | - |Samba Web Administration Tool (SWAT) |
|902|TCP | - |VMware Server Console[22] |
|904|TCP | - |VMware Server Alternate (if 902 is in use - i.e. SUSE linux) |
|911|TCP | - |Network Console on Acid (NCA) - local tty redirection over OpenSSH |
|981|TCP | - |SofaWare Technologies Remote HTTPS management for firewall devices running embedded Checkpoint Firewall-1 software |
|989|TCP,UDP |Reserved|FTP Protocol (data) over TLS/SSL |
|990|TCP,UDP |Reserved|FTP Protocol (control) over TLS/SSL |
|991|TCP,UDP |Reserved|NAS (Netnews Administration System) |
|992|TCP,UDP |Reserved|TELNET protocol over TLS/SSL |
|993|TCP |Reserved|IMAP4 over SSL (encrypted transmission) |
|995|TCP |Reserved|POP3 over SSL (encrypted transmission) |
|1023|TCP,UDP |Reserved|IANA Reserved |
|1024|tcp,udp |Reserved|IANA Reserved |
|1025|tcp | - |NFS-or-IIS |
|1026|tcp | - |Often utilized by Microsoft DCOM services |
|1029|tcp | - |Often utilized by Microsoft DCOM services |
|1058|tcp,udp |Reserved|nim, IBM AIX Network Installation Manager (NIM) |
|1059|tcp,udp |Reserved|nimreg, IBM AIX Network Installation Manager (NIM) |
|1080|tcp |Reserved|SOCKS proxy |
|1098|tcp,udp |Reserved|rmiactivation, RMI Activation |
|1099|tcp,udp |Reserved|rmiregistry, RMI Registry |
|1109||Reserved|IANA Reserved |
|1109|tcp | - |Kerberos Post Office Protocol (KPOP) |
|1140|tcp,udp |Reserved|AutoNOC Network Operations protocol |
|1167|udp | - |phone, conference calling |
|1176|tcp |Reserved|Perceptive Automation Indigo Home automation server |
|1182|tcp,udp |Reserved|AcceleNet Intelligent Transfer Protocol |
|1194|tcp,udp |Reserved|OpenVPN |
|1198|tcp,udp |Reserved|The cajo project Free dynamic transparent distributed computing in Java |
|1200|tcp |Reserved|scol, protocol used by SCOL 3D virtual worlds server to answer world name resolution client request[23] |
|1200|udp |Reserved|scol, protocol used by SCOL 3D virtual worlds server to answer world name resolution client request |
|1200|udp | - |Steam Friends Applet |
|1214|tcp |Reserved|Kazaa |
|1223|tcp,udp |Reserved|TGP, TrulyGlobal Protocol, also known as "The Gur Protocol" (named for Gur Kimchi of TrulyGlobal) |
|1241|tcp,udp |Reserved|Nessus Security Scanner |
|1248|tcp | - |NSClient/NSClient++/NC_Net (Nagios) |
|1270|tcp,udp |Reserved|Microsoft System Center Operations Manager (SCOM) (formerly Microsoft Operations Manager (MOM)) agent |
|1311|tcp | - |Dell Open Manage Https Port |
|1313|tcp | - |Xbiim (Canvii server) Port |
|1337|tcp | - |WASTE Encrypted File Sharing Program |
|1352|tcp |Reserved|IBM Lotus Notes/Domino Remote Procedure Call (RPC) protocol |
|1387|tcp,udp |Reserved|cadsi-lm, LMS International (formerly Computer Aided Design Software, Inc. (CADSI)) LM |
|1414|tcp |Reserved|IBM WebSphere MQ (formerly known as MQSeries) default |
|1431|tcp |Reserved|Reverse Gossip Transport Protocol (RGTP), used to access a General-purpose Reverse-Ordered Gossip Gathering System (GROGGS) bulletin board, such as that implemented on the Cambridge University's Phoenix system |
|1433|tcp,udp |Reserved|Microsoft SQL Server database management system Server |
|1434|tcp,udp |Reserved|Microsoft SQL Server database management system Monitor |
|1494|tcp |Reserved|Citrix XenApp Independent Computing Architecture (ICA) thin client protocol |
|1512|tcp,udp |Reserved|Microsoft Windows Internet Name Service (WINS) |
|1521|tcp |Reserved|nCube License Manager |
|1521|tcp | - |Oracle database default listener, in future releases Reserved port 2483 |
|1524|tcp,udp |Reserved|ingreslock, ingres |
|1526|tcp | - |Oracle database common alternative for listener |
|1533|tcp |Reserved|IBM Sametime IM - Virtual Places Chat |
|1547|tcp,udp |Reserved|Laplink |
|1550|| - |Gadu-Gadu (Direct Client-to-Client) |
|1581|udp |Reserved|MIL STD 2045-47001 VMF |
|1589|udp | - |Cisco VQP (VLAN Query Protocol) / VMPS |
|1645|tcp,udp | - |radius, RADIUS authentication protocol (default for Cisco and Juniper Networks RADIUS servers) |
|1646|tcp,udp | - |radacct, RADIUS accounting protocol (default for Cisco and Juniper Networks RADIUS servers) |
|1627|| - |iSketch |
|1677|tcp,udp |Reserved|Novell GroupWise clients in client/server access mode |
|1701|udp |Reserved|L2f, Layer 2 Forwarding Protocol & L2p, Layer 2 Tunneling Protocol |
|1716|tcp | - |America's Army Massively multiplayer online role-playing game (MMORPG) default game port |
|1723|tcp,udp |Reserved|Microsoft PPTP VPN |
|1725|udp | - |Valve Steam Client |
|1755|tcp,udp |Reserved|Microsoft Media Services (MMS, ms-streaming) |
|1761|tcp,udp |Reserved|cft-0 |
|1761|tcp | - |Novell Zenworks Remote Control utility |
|1762-1768|tcp,udp |Reserved|cft-1 to cft-7 |
|1812|tcp,udp |Reserved|radius, RADIUS authentication protocol |
|1813|tcp,udp |Reserved|radacct, RADIUS accounting protocol |
|1863|tcp |Reserved|MSNP (Microsoft Notification Protocol), used by the .NET Messenger Service and a number of Instant Messaging clients |
|1900|udp |Reserved|Microsoft SSDP Enables discovery of UPnP devices |
|1935|tcp |Reserved|Adobe Macromedia Flash Real Time Messaging Protocol (RTMP) "plain" protocol |
|1970|tcp,udp |Reserved|Danware NetOp Remote Control |
|1971|tcp,udp |Reserved|Danware NetOp School |
|1972|tcp,udp |Reserved|InterSystems Caché |
|1975-77|udp |Reserved|Cisco TCO (Documentation) |
|1984|tcp |Reserved|Big Brother - network monitoring tool |
|1985|udp |Reserved|Cisco HSRP |
|1994|tcp,udp |Reserved|Cisco STUN-SDLC (Serial Tunneling - Synchronous Data Link Control) protocol |
|1998|tcp,udp |Reserved|Cisco X.25 over TCP (XOT) service |
|2000|tcp,udp |Reserved|Cisco SCCP (Skinny) |
|2002|tcp | - |Secure Access Control Server (ACS) for Windows |
|2030|| - |Oracle Services for Microsoft Transaction Server |
|2031|tcp,udp |Reserved|mobrien-chat - Mike O'Brien <mike@mobrien.com> November 2004 |
|2049|udp |Reserved|nfs, NFS Server |
|2049|udp |Reserved|shilp |
|2053|udp |Reserved|lot105-ds-upd Lot105 DSuper Updates |
|2053|tcp |Reserved|lot105-ds-upd Lot105 DSuper Updates |
|2053|tcp | - |knetd Kerberos de-multiplexor |
|2056|udp | - |Civilization 4 multiplayer |
|2073|tcp,udp |Reserved|DataReel Database |
|2074|tcp,udp |Reserved|Vertel VMF SA (i.e. App.. SpeakFreely) |
|2082|tcp |Reserved|Infowave Mobility Server |
|2082|tcp | - |CPanel, default port |
|2083|tcp |Reserved|Secure Radius Service (radsec) |
|2083|tcp | - |CPanel default SSL port |
|2086|tcp |Reserved|GNUnet |
|2086|tcp | - |WebHost Manager default port |
|2087|tcp | - |WebHost Manager default SSL port |
|2095|tcp | - |CPanel default webmail port |
|2096|tcp | - |CPanel default SSL webmail port |
|2102|tcp,udp |Reserved|zephyr-srv Project Athena Zephyr Notification Service server |
|2103|tcp,udp |Reserved|zephyr-clt Project Athena Zephyr Notification Service serv-hm connection |
|2104|tcp,udp |Reserved|zephyr-hm Project Athena Zephyr Notification Service hostmanager |
|2105|tcp,udp |Reserved|IBM MiniPay |
|2105|tcp,udp | - |eklogin Kerberos encrypted remote login (rlogin) |
|2105|tcp,udp | - |zephyr-hm-srv Project Athena Zephyr Notification Service hm-serv connection (should use port 2102) |
|2161|tcp |Reserved|APC Agent |
|2181|tcp,udp |Reserved|EForward-document transport system |
|2190|udp | - |TiVoConnect Beacon |
|2200|udp | - |Tuxanci game server |
|2219|tcp,udp |Reserved|NetIQ NCAP Protocol |
|2220|tcp,udp |Reserved|NetIQ End2End |
|2222|tcp | - |DirectAdmin's default port |
|2222|udp | - |Microsoft Office OS X antipiracy network monitor [1] |
|2301|tcp | - |HP System Management Redirect to port 2381 |
|2302|udp | - |ArmA multiplayer (default for game) |
|2302|udp | - |Halo: Combat Evolved multiplayer |
|2303|udp | - |ArmA multiplayer (default for server reporting) (default port for game +1) |
|2305|udp | - |ArmA multiplayer (default for VoN) (default port for game +3) |
|2369|tcp | - |Default port for BMC Software CONTROL-M/Server - Configuration Agent port number - though often changed during installation |
|2370|tcp | - |Default port for BMC Software CONTROL-M/Server - Port utilized to allow the CONTROL-M/Enterprise Manager to connect to the CONTROL-M/Server - though often changed during installation |
|2381|tcp | - |HP Insight Manager default port for webserver |
|2404|tcp |Reserved|IEC 60870-5-104, used to send electric power telecontrol messages between two systems via directly connected data circuits |
|2427|udp |Reserved|Cisco MGCP |
|2447|tcp,udp |Reserved|ovwdb - OpenView Network Node Manager (NNM) daemon |
|2483|tcp,udp |Reserved|Oracle database listening port for unsecure client connections to the listener, replaces port 1521 |
|2484|tcp,udp |Reserved|Oracle database listening port for SSL client connections to the listener |
|2546|tcp,udp | - |Vytal Vault - Data Protection Services |
|2593|tcp,udp | - |RunUO - Ultima Online server |
|2598|tcp | - |new ICA - when Session Reliability is enabled, TCP port 2598 replaces port 1494 |
|2612|tcp,udp |Reserved|QPasa from MQSoftware |
|2710|tcp | - |XBT Bittorrent Tracker |
|2710|udp | - |XBT Bittorrent Tracker experimental UDP tracker extension |
|2710|tcp | - |Knuddels.de |
|2735|tcp,udp |Reserved|NetIQ Monitor Console |
|2809|tcp |Reserved|corbaloc:iiop URL, per the CORBA 3.0.3 specification |
|2809|tcp | - |IBM WebSphere Application Server (WAS) Bootstrap/rmi default port |
|2809|udp |Reserved|corbaloc:iiop URL, per the CORBA 3.0.3 specification. |
|2944|udp | - |Megaco Text H.248 |
|2945|udp | - |Megaco Binary (ASN.1) H.248 |
|2948|tcp,udp |Reserved|WAP-push Multimedia Messaging Service (MMS) |
|2949|tcp,udp |Reserved|WAP-pushsecure Multimedia Messaging Service (MMS) |
|2967|tcp | - |Symantec AntiVirus Corporate Edition |
|3000|tcp | - |Miralix License server |
|3000|udp | - |Distributed Interactive Simulation (DIS), modifiable default port |
|3001|tcp | - |Miralix Phone Monitor |
|3002|tcp | - |Miralix CSTA |
|3003|tcp | - |Miralix GreenBox API |
|3004|tcp | - |Miralix InfoLink |
|3006|tcp | - |Miralix SMS Client Connector |
|3007|tcp | - |Miralix OM Server |
|3025|tcp | - |netpd.org |
|3050|tcp,udp |Reserved|gds_db (Interbase/Firebird) |
|3074|tcp,udp |Reserved|Xbox Live |
|3128|tcp | - |HTTP used by web caches and the default port for the Squid cache |
|3260|tcp,udp |Reserved|iSCSI target |
|3268|tcp,udp |Reserved|msft-gc, Microsoft Global Catalog (LDAP service which contains data from Active Directory forests) |
|3269|tcp,udp |Reserved|msft-gc-ssl, Microsoft Global Catalog over SSL (similar to port 3268, LDAP over SSL) |
|3283|tcp | - |Apple Remote Desktop |
|3300|tcp | - |TripleA game server |
|3305|tcp,udp |Reserved|odette-ftp, Odette File Transfer Protocol (OFTP) |
|3306|tcp,udp |Reserved|MySQL Database system |
|3333|tcp | - |Network Caller ID server |
|3386|tcp,udp |Reserved|GTP' 3GPP GSM/UMTS CDR logging protocol |
|3389|tcp | - |Microsoft Terminal Server (RDP) Reservedly registered as Windows Based Terminal (WBT) |
|3396|tcp,udp |Reserved|Novell NDPS Printer Agent |
|3689|tcp,udp |Reserved|DAAP Digital Audio Access Protocol used by Apple’s iTunes |
|3690|tcp,udp |Reserved|Subversion version control system |
|3702|tcp,udp |Reserved|Web Services Dynamic Discovery (WS-Discovery), used by various components of Windows Vista |
|3724|tcp,udp |Reserved|World of Warcraft Online gaming MMORPG |
|3784|tcp,udp | - |Ventrilo VoIP program used by Ventrilo |
|3785|udp | - |Ventrilo VoIP program used by Ventrilo |
|3868 tcp ||Reserved|Diameter base protocol |
|3872|tcp | - |Oracle Management Remote Agent |
|3899|tcp | - |Remote Administrator |
|3900|tcp |Reserved|Unidata UDT OS udt_os |
|3945|tcp,udp |Reserved|EMCADS server service port, a Giritech product used by G/On |
|4000|tcp,udp | - |Diablo II game |
|4007|tcp | - |PrintBuzzer printer monitoring socket server |
|4089|tcp,udp |Reserved|OpenCORE Remote Control Service |
|4093|tcp,udp |Reserved|PxPlus Client server interface ProvideX |
|4096|tcp,udp |Reserved|Bridge-Relay Element ASCOM |
|4100|| - |WatchGuard Authentication Applet - default port |
|4111|tcp,udp |Reserved|Xgrid |
|4111|tcp | - |Microsoft Office SharePoint Portal Server - default administration port |
|4125|tcp | - |Remote Web Workplace - default administration port |
|4226|tcp,udp | - |Aleph One (computer game) |
|4224|tcp | - |Cisco CDP Cisco discovery Protocol |
|4569|udp | - |Inter-Asterisk eXchange |
|4662|tcp,udp |Reserved|OrbitNet Message Service |
|4662|tcp | - |port often used by eMule |
|4664|tcp | - |Google Desktop Search |
|4672|udp | - |eMule - port often used |
|4747|tcp | - |Apprentice |
|4750|tcp | - |BladeLogic Agent |
|4894|tcp,udp |Reserved|LysKOM Protocol A |
|4899|tcp,udp |Reserved|Radmin remote administration tool (program sometimes used as a Trojan horse) |
|5000|tcp |Reserved|commplex-main |
|5000|tcp | - |UPnP - Windows network device interoperability |
|5000|tcp,udp | - |VTun - VPN Software |
|5001|tcp,udp | - |Iperf (Tool for measuring TCP and UDP bandwidth performance) |
|5001|tcp | - |Slingbox and Slingplayer |
|5003|tcp,udp |Reserved|FileMaker Filemaker Pro |
|5004|tcp,udp |Reserved|RTP (Real-time Transport Protocol) media data |
|5005|tcp,udp |Reserved|RTP (Real-time Transport Protocol) control protocol |
|5031|tcp,udp | - |AVM CAPI-over-TCP (ISDN over Ethernet tunneling) |
|5050|tcp | - |Yahoo! Messenger |
|5051|tcp |Reserved|ita-agent Symantec Intruder Alert |
|5060|tcp,udp |Reserved|Session Initiation Protocol (SIP) |
|5061|tcp |Reserved|Session Initiation Protocol (SIP) over TLS |
|5093|udp | - |SPSS License Administrator (SPSS) |
|5104|tcp | - |IBM NetCOOL / IMPACT HTTP Service |
|5106|tcp | - |A-Talk Common connection |
|5107|tcp | - |A-Talk Remote server connection |
|5110|tcp | - |ProRat Server |
|5121|tcp | - |Neverwinter Nights |
|5176|tcp | - |ConsoleWorks default UI interface |
|5190|tcp |Reserved|ICQ and AOL Instant Messenger |
|5222|tcp,udp |Reserved|XMPP/Jabber|Google Talk - client connection |
|5223|tcp | - |XMPP/Jabber - default port for SSL Client Connection |
|5269|tcp,udp |Reserved|XMPP/Jabber - server connection |
|5351|tcp,udp |Reserved|NAT Port Mapping Protocol - client-requested configuration for inbound connections through network address translators |
|5353|tcp,udp |Reserved|mDNS - multicastDNS |
|5355|udp,tcp |Reserved|LLMNR - Link-Local Multicast Name Resolution, allows hosts to perform name resolution for hosts on the same local link (only provided by Windows Vista and Server 2008) |
|5402|tcp,udp |Reserved|mftp, Stratacache OmniCast content delivery system MFTP file sharing protocol |
|5405|tcp,udp |Reserved|NetSupport |
|5421|tcp,udp |Reserved|Net Support 2 |
|5432|tcp,udp |Reserved|PostgreSQL database system |
|5445|udp | - |Cisco Unified Video Advantage |
|5495|tcp | - |Applix TM1 Admin server |
|5498|tcp | - |Hotline tracker server connection |
|5499|udp | - |Hotline tracker server discovery |
|5500|tcp | - |VNC remote desktop protocol - for incoming listening viewer, Hotline control connection |
|5501|tcp | - |Hotline file transfer connection |
|5517|tcp | - |Setiqueue Proxy server client for SETI@Home project |
|5555|tcp | - |Freeciv multiplay port for versions up to 2.0, Hewlett Packard Data Protector, SAP |
|5556|tcp,udp |Reserved|Freeciv multiplay port |
|5631|tcp,udp |Reserved|pcANYWHEREdata, Symantec pcAnywhere |
|5632|tcp,udp |Reserved|pcANYWHEREstat, Symantec pcAnywhere |
|5666|tcp | - |NRPE (Nagios) |
|5667|tcp | - |NSCA (Nagios) |
|5800|tcp | - |VNC remote desktop protocol - for use over HTTP |
|5814|tcp,udp |Reserved|Hewlett-Packard Support Automation (HP OpenView Self-Healing Services) |
|5900|tcp,udp |Reserved|VNC remote desktop protocol (used by ARD) |
|6000|tcp |Reserved|X11 - used between an X client and server over the network |
|6001|udp |Reserved|X11 - used between an X client and server over the network |
|6005|tcp | - |Default port for BMC Software CONTROL-M/Server - Socket Port number used for communication between CONTROL-M processes - though often changed during installation |
|6050|tcp | - |Brightstor Arcserve Backup |
|6051|tcp | - |Brightstor Arcserve Backup |
|6100|tcp | - |Vizrt System |
|6110|tcp,udp |Reserved|softcm HP SoftBench CM |
|6111|tcp,udp |Reserved|spc HP SoftBench Sub-Process Control |
|6112|tcp,udp |Reserved|dtspcd - a network daemon that accepts requests from clients to execute commands and launch applications remotely |
|6112|tcp | - |Blizzard's Battle.net gaming service, ArenaNet gaming service |
|6129|tcp | - |Dameware Remote Control |
|6257|udp | - |WinMX (see also 6699) |
|6346|tcp,udp |Reserved|gnutella-svc, default Gnutella port (FrostWire, Limewire, Shareaza, etc.) |
|6347|tcp,udp |Reserved|gnutella-rtr, alternative Gnutella port |
|6444|tcp,udp |Reserved|Sun Grid Engine - Qmaster Service |
|6445|tcp,udp |Reserved|Sun Grid Engine - Execution Service |
|6502|tcp,udp | - |Danware Data NetOp Remote Control |
|6522|tcp | - |Gobby (and other libobby-based software) |
|6543|udp | - |Jetnet - default port that the Paradigm Research & Development Jetnet protocol communicates on |
|6566|tcp | - |SANE (Scanner Access Now Easy) - SANE network scanner daemon |
|6600|tcp | - |Music Playing Daemon (MPD) |
|6619|tcp,udp |Reserved|odette-ftps, Odette File Transfer Protocol (OFTP) over TLS/SSL |
|6665-6669|tcp |Reserved|Internet Relay Chat |
|6679|tcp | - |IRC SSL (Secure Internet Relay Chat) - port often used |
|6697|tcp | - |IRC SSL (Secure Internet Relay Chat) - port often used |
|6699|tcp | - |WinMX (see also 6257) |
|6771|udp | - |Polycom server broadcast |
|6881-6887|tcp,udp | - |BitTorrent part of full range of ports used most often |
|6888|tcp,udp |Reserved|MUSE |
|6888|tcp,udp | - |BitTorrent part of full range of ports used most often |
|6889-6890|tcp,udp | - |BitTorrent part of full range of ports used most often |
|6891-6900|tcp,udp | - |BitTorrent part of full range of ports used most often |
|6891-6900|tcp,udp | - |Windows Live Messenger (File transfer) |
|6901|tcp,udp | - |Windows Live Messenger (Voice) |
|6901|tcp,udp | - |BitTorrent part of full range of ports used most often |
|6902-6968|tcp,udp | - |BitTorrent part of full range of ports used most often |
|6969|tcp,udp |Reserved|acmsoda |
|6969|tcp | - |BitTorrent tracker port |
|6970-6999|tcp,udp | - |BitTorrent part of full range of ports used most often |
|7000|tcp | - |Default port for Azureus's built in HTTPS Bittorrent Tracker |
|7001|tcp | - |Default port for BEA WebLogic Server's HTTP server - though often changed during installation |
|7002|tcp | - |Default port for BEA WebLogic Server's HTTPS server - though often changed during installation |
|7005|tcp,udp | - |Default port for BMC Software CONTROL-M/Server and CONTROL-M/Agent's - Agent to Server port though often changed during installation |
|7006|tcp,udp | - |Default port for BMC Software CONTROL-M/Server and CONTROL-M/Agent's - Server to Agent port though often changed during installation |
|7010|tcp | - |Default port for Cisco AON AMC (AON Management Console) [2] |
|7025|tcp | - |Zimbra - lmtp [mailbox] - local mail delivery |
|7047|tcp | - |Zimbra - conversion server |
|7133|tcp | - |Enemy Territory: Quake Wars |
|7171|tcp | - |Tibia |
|7306|tcp | - |Zimbra - mysql [mailbox] |
|7307|tcp | - |Zimbra - mysql [logger] - logger |
|7312|udp | - |Sibelius License Server port |
|7670|tcp | - |BrettspielWelt BSW Boardgame Portal |
|7777|tcp | - |Default port used by Windows backdoor program tini.exe |
|8000|tcp,udp |Reserved|iRDMI - often mistakenly used instead of port 8080 |
|8000|tcp | - |Common port used for internet radio streams such as those using SHOUTcast |
|8002|tcp | - |Cisco Systems Unified Call Manager Intercluster Port |
|8008|tcp |Reserved|HTTP Alternate |
|8008|tcp | - |IBM HTTP Server default administration port |
|8010|tcp | - |XMPP/Jabber File transfers |
|8074|tcp | - |Gadu-Gadu |
|8080|tcp |Reserved|HTTP Alternate (http_alt) - commonly used for web proxy and caching server, or for running a web server as a non-root user |
|8080|tcp | - |Apache Tomcat |
|8086|tcp | - |HELM Web Host Automation Windows Control Panel |
|8086|tcp | - |Kaspersky AV Control Center TCP Port |
|8087|tcp | - |Hosting Accelerator Control Panel |
|8087|udp | - |Kaspersky AV Control Center UDP Port |
|8090|tcp | - |Another HTTP Alternate (http_alt_alt) - used as an alternative to port 8080 |
|8118|tcp |Reserved|Privoxy web proxy - advertisements-filtering web proxy |
|8087|tcp | - |SW Soft Plesk Control Panel |
|8200|tcp | - |GoToMyPC |
|8220|tcp | - |Bloomberg |
|8222|| - |VMware Server Management User Interface (insecure web interface)[24]. See also, port 8333 |
|8291|tcp | - |Winbox - Default port on a MikroTik RouterOS for a Windows application used to administer MikroTik RouterOS |
|8294|tcp | - |Bloomberg |
|8333|| - |VMware Server Management User Interface (secure web interface)[25]. See also, port 8222 |
|8400|tcp,udp |Reserved|cvp, Commvault Unified Data Management |
|8443|tcp | - |SW Soft Plesk Control Panel |
|8500|tcp | - |ColdFusion Macromedia/Adobe ColdFusion default Webserver port |
|8501|udp | - |Duke Nukem 3D - Default Online Port |
|8767|udp | - |TeamSpeak - Default UDP Port |
|8880|udp |Reserved|cddbp-alt, CD DataBase (CDDB) protocol (CDDBP) - alternate |
|8880|tcp |Reserved|cddbp-alt, CD DataBase (CDDB) protocol (CDDBP) - alternate |
|8880|tcp | - |WebSphere Application Server SOAP connector default port |
|8881|tcp | - |Atlasz Informatics Research Ltd Secure Application Server |
|8882|tcp | - |Atlasz Informatics Research Ltd Secure Application Server |
|8888|tcp,udp |Reserved|NewsEDGE server |
|8888|tcp | - |Sun Answerbook dwhttpd server (deprecated by docs.sun.com) |
|8888|tcp | - |GNUmp3d HTTP music streaming and web interface port |
|8888|tcp | - |LoLo Catcher HTTP web interface port (www.optiform.com) |
|9000|tcp | - |Buffalo LinkSystem web access |
|9000|tcp | - |DBGp |
|9000|udp | - |UDPCast |
|9001|| - |cisco-xremote router configuration |
|9001|| - |Tor network default port |
|9001|tcp | - |DBGp Proxy |
|9009|tcp,udp |Reserved|Pichat Server - Peer to peer chat software |
|9043|tcp | - |WebSphere Application Server Administration Console secure port |
|9060|tcp | - |WebSphere Application Server Administration Console |
|9080|udp |Reserved|glrpc, Groove Collaboration software GLRPC port |
|9080|tcp |Reserved|glrpc, Groove Collaboration software GLRPC port |
|9080|tcp | - |WebSphere Application Server Http Transport (port 1) default |
|9090|tcp | - |Openfire Administration Console |
|9100|tcp |Reserved|Jetdirect HP Print Services |
|9110|udp | - |SSMP Message protocol |
|9101||Reserved|Bacula Director |
|9102||Reserved|Bacula File Daemon |
|9103||Reserved|Bacula Storage Daemon |
|9119|tcp,udp |Reserved|MXit Instant Messenger |
|9418|tcp,udp |Reserved|git, Git pack transfer service |
|9535|tcp |Reserved|mngsuite, LANDesk Management Suite Remote Control |
|9535|tcp | - |BBOS001, IBM Websphere Application Server (WAS) High Avail Mgr Com Port |
|9443|tcp | - |WebSphere Application Server Http Transport (port 2) default |
|9535|udp |Reserved|mngsuite, LANDesk Management Suite Remote Control |
|9800|tcp,udp |Reserved|WebDAV Source Port |
|9800|| - |WebCT e-learning portal |
|9999|| - |Hydranode - edonkey2000 TELNET control port |
|9999|| - |Urchin Web Analytics |
|10000|| - |Webmin - web based Linux admin tool |
|10000|| - |BackupExec |
|10008|tcp,udp |Reserved|Octopus Multiplexer, primary port for the CROMP protocol, which provides a platform-independent means for communication of objects across a network |
|10017|| - |AIX,NeXT, HPUX - rexd daemon control port |
|10024|tcp | - |Zimbra - smtp [mta] - to amavis from postfix |
|10025|tcp | - |Ximbra - smtp [mta] - back to postfix from amavis |
|10050|tcp,udp |Reserved|Zabbix-Agent |
|10051|tcp,udp |Reserved|Zabbix-Trapper |
|10113|tcp,udp |Reserved|NetIQ Endpoint |
|10114|tcp,udp |Reserved|NetIQ Qcheck |
|10115|tcp,udp |Reserved|NetIQEndpoint |
|10116|tcp,udp |Reserved|NetIQ VoIP Assessor |
|10200|tcp | - |FRISK Software International's fpscand virus scanning daemon for Unix platforms [3] |
|10200-10204|tcp | - |FRISK Software International's f-protd virus scanning daemon for Unix platforms [4] |
|10308|| - |Lock-on: Modarn Air Combat |
|10480|| - |SWAT 4 Dedicated Server |
|11211|| - |memcached |
|11235|| - |Savage:Battle for Newerth Server Hosting |
|11294|| - |Blood Quest Online Server |
|11371||Reserved|OpenPGP HTTP Keyserver |
|11576|| - |IPStor Server management communication |
|12035|udp | - |Linden Lab viewer to sim |
|12345|| - |NetBus - remote administration tool (often Trojan horse). Also used by NetBuster. Little Fighter 2 (TCP). |
|12975|tcp | - |LogMeIn Hamachi (VPN tunnel software; also port 32976) - used to connect to Mediation Server (bibi.hamachi.cc); will attempt to use SSL (TCP port 443) if both 12975 & 32976 fail to connect |
|13000-13050|udp | - |Linden Lab viewer to sim |
|13720|tcp,udp |Reserved|Symantec NetBackup - bprd (formerly VERITAS) |
|13721|tcp,udp |Reserved|Symantec NetBackup - bpdbm (formerly VERITAS) |
|13724|tcp,udp |Reserved|Symantec Network Utility - vnetd (formerly VERITAS) |
|13782|tcp,udp |Reserved|Symantec NetBackup - bpcd (formerly VERITAS) |
|13783|tcp,udp |Reserved|Symantec VOPIED protocol (formerly VERITAS) |
|13785|tcp,udp |Reserved|Symantec NetBackup Database - nbdb (formerly VERITAS) |
|13786|tcp,udp |Reserved|Symantec nomdb (formerly VERITAS) |
|14567|udp | - |Battlefield 1942 and mods |
|15000|tcp | - |psyBNC |
|15000|tcp | - |Wesnoth |
|15000|tcp |Reserved|hydap, Hypack Hydrographic Software Packages Data Acquisition |
|15000|udp |Reserved|hydap, Hypack Hydrographic Software Packages Data Acquisition |
|15567|udp | - |Battlefield Vietnam and mods |
|15345|tcp,udp |Reserved|XPilot Contact Port |
|16000|tcp | - |shroudBNC |
|16080|tcp | - |Mac OS X Server performance cache for HTTP[26] |
|16384|udp | - |Iron Mountain Digital - online backup |
|16567|udp | - |Battlefield 2 and mods |
|19226|tcp | - |Panda Software AdminSecure Communication Agent |
|19638|tcp | - |Ensim Control Panel |
|19813|tcp | - |4D database Client Server Communication |
|20000||Reserved|DNP (Distributed Network Protocol), a protocol used in SCADA systems between communicating RTU's and IED's |
|20000|| - |Usermin, web based user tool |
|20720|tcp | - |Symantec i3 Web GUI server |
|22347|tcp,udp |Reserved|WibuKey, default port used for communications between the WibuKey Network Server and the WibuKey run-time client for the WIBU-SYSTEMS AG Software protection system |
|22350|tcp,udp |Reserved|CodeMeter, default port used for communications with the CodeMeter Server for the WIBU-SYSTEMS AG Software protection system |
|24554|tcp,udp |Reserved|BINKP, Fidonet mail transfers over TCP/IP |
|24800|| - |Synergy: keyboard/mouse sharing software |
|24842|| - |StepMania: Online: Dance Dance Revolution Simulator |
|25999|tcp | - |Xfire |
|26000|tcp,udp |Reserved|id Software's Quake server |
|26000|tcp | - |CCP's EVE Online Online gaming MMORPG |
|27000|udp | - |(through 27006) id Software's QuakeWorld master server |
|27010|| - |Half-Life and its mods, such as Counter-Strike |
|27015|| - |Half-Life and its mods, such as Counter-Strike |
|27374|| - |Sub7's default port. Most script kiddies do not change the default port. |
|27500|udp | - |(through 27900) id Software's QuakeWorld |
|27888|udp | - |Kaillera server |
|27900|| - |(through 27901) Nintendo Wi-Fi Connection |
|27901|udp | - |(through 27910) id Software's Quake II master server |
|27960|udp | - |(through 27969) Activision's Enemy Territory and id Software's Quake III Arena and Quake III and some ioquake3 derived games |
|28910|| - |Nintendo Wi-Fi Connection |
|28960|| - |Call of Duty 2 Common Call of Duty 2 port - (PC Version) |
|29900|| - |(through 29901) Nintendo Wi-Fi Connection |
|29920|| - |Nintendo Wi-Fi Connection |
|30000|| - |Pokemon Netbattle |
|30564|tcp | - |Multiplicity: keyboard/mouse/clipboard sharing software |
|31337|tcp | - |Back Orifice - remote administration tool (often Trojan horse) |
|31337|tcp | - |xc0r3 - xc0r3 security antivir port |
|31415|| - |ThoughtSignal - Server Communication Service (often Informational) |
|31456-31458|tcp | - |TetriNET ports (in order: IRC, game, and spectating) |
|32245|tcp | - |MMTSG-mutualed over MMT (encrypted transmission) |
|32976|tcp | - |LogMeIn Hamachi (VPN tunnel software; also port 12975) - used to connect to Mediation Server (bibi.hamachi.cc); will attempt to use SSL (TCP port 443) if both 12975 & 32976 fail to connect |
|33434|tcp,upd |Reserved|traceroute |
|34443|| - |Linksys PSUS4 print server |
|37777|tcp | - |Digital Video Recorder hardware |
|36963|| - |Counter Strike 2D multiplayer port (2D clone of popular CounterStrike computer game) |
|40000|tcp,upd |Reserved|SafetyNET p Real-time Industrial Ethernet protocol |
|43594-43595|tcp | - |RuneScape |
|47808|tcp,upd |Reserved|BACnet Building Automation and Control Networks |
|49151||Reserved|IANA Reserved |
