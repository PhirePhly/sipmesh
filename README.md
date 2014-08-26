sipmesh
=======

OLSR routed WiFi mesh for SIP phones with a single SIP master

This is a quick and dirty demo of what is possible using
a small number of WRT54GL routers as mesh nodes, with SIP phones
plugged into each one and a single Asterisk SIP controller plugged
into any one of the nodes.

The basic extensions supported for this demo are:
 * ECHO (3246) - An echo test back to the SIP controller
 * HAM (426) - A party line for any number of extensions
 * 201, 202, 203, etc - Ring a specific extension like a normal telephone

IP addresses of note:
 * 44.128.254.254/32 - SIP server
 * 44.128.254.1/32 - Mesh node #1
 * 44.128.1.0/24 - The LAN subnet for mesh node #1
 * 44.128.254.2/32 - Mesh node #2
 * 44.128.2.0/24 - The LAN subnet for mesh node #2

Each SIP client obtains a LAN subnet IP address from the local mesh node
via DHCP, and registers it with the SIP server to enable incoming calls.

Supporting technology
---------------------

Routing between the mesh nodes is handled using the OLSR routing
protocol, which allows each node to advertise their locally-connected
subnets as well as discover the gateway address for every other
device/subnet in the mesh.

There is no network address translation being done between each local
subnet and the mesh, which has the downside that each mesh node must
have allocated a unique subnet prefix, but has the advantage that every
host is fully reachable on the mesh with no need to mess with port
forwards or STUN on the local mesh gateway. This is particularly important
since SIP is so cranky about NAT.

Every mesh IP address is statically assigned, but a dynamic configuration
protocol such as AHCP could be used.
Client IP addresses behind each mesh node are allocated using
the standard DHCP method from the manually allocated local subnet.
Something like a DHCPv6 prefix delegation would be useful to automate the
local prefix allocation per node, or we could just move everything to 
IPv6, but that would require SIP phones that support IPv6.

Locally, every client host creates a DNS entry for 
"A clienthostname.meshnodehostname.mesh", but there doesn't exist
any way to move "NS meshnodehostname.mesh" records between mesh nodes
dynamically, so DNS really isn't useful in any dynamic application.
I am not aware of any solutions to this problem of moving DNS
entries across an ad-hoc mesh. Multicast DNS is tempting, but would
require getting multicast routing working across the mesh, which is
simply a different problem still lacking a clear solution presently. 

One possible DNS solution without building in a single point of failure
is inventing a new protocol to advertive nameserver records across 
the mesh for each node.
A daemon which locally responds to "\*.hostname.mesh." DNS requests 
by finding the relvant node on the mesh and generating an "A glued NS" 
response shouldn't be too complicated to create. Each mesh node could then
include a "server /.mesh./localhost#5353" directive in their DNS server
config to know to use this new mesh DNS daemon for name resolution.
It appears that this technology doesn't yet exist...

Each mesh node joins the mesh with IP address "44.128.254.ID#"
and advertises their local subnet "44.128.ID#.0/24" which they issue
DHCP leases from.

The SIP controller has the static IP address 44.128.254.254, and 
joins the OLSR routed mesh via any node's LAN interface, which is
why the WRT54GLs bind OLSR to their LAN interfaces in addition to their
WiFi mesh interfaces, which is normally not required.
This is what allows the static IP of the SIP server to arbitrary 
migrate from node to node. Ideally, DNS would be operational and the 
SIP clients could be configured to register with 
"sip:username@sipserver.mesh" instead of "sip:username@44.128.254.254" 
which they currently need to do. This would allow all sorts of flexibility
like having multiple cooperative SIP servers on the mesh, where it
currently stands as the only single point of failure in the existing demo.

