# Open vSwitch & Traffic Control Mirror Port Utilities

These scripts are intended to facilitate in creating a mirror port for both Open vSwitch environments and for more simplistic Traffic Control environments.  The scripts are pretty straightforward and both behave the same way logically:

## tc-mirror

* **build** _SOURCE DESTINATION_ - Mirrors the traffic from the SOURCE interface to the DESTINATION interface.
* **teardown** _SOURCE_ - Removes the traffic mirror on the SOURCE interface.

## ovs-mirror

* **build** _BRIDGE MIRROR_SOURCE MIRROR_DEST_ - Creates a new mirror mirroring the source port to the destination port
* **teardown** _BRIDGE MIRROR_ - Destroys the mirror on the specified bridge