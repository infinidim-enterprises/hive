{ inputs, cell, ... }:

{ lib, ... }:

# TODO: services.physlock
{
  security.protectKernelImage = false;
  boot.kernelParams = lib.mkBefore [
    "noibrs" # We don't need no restricted indirect branch speculation
    "noibpb" # We don't need no indirect branch prediction barrier either
    "nopti"
    "nospectre_v1" # Don't care if some program can get data from some other program when it shouldn't
    "nospectre_v2" # Don't care if some program can get data from some other program when it shouldn't
    "l1tf=off" # Why would we be flushing the L1 cache, we might need that data. So what if anyone can get at it.
    "nospec_store_bypass_disable" # Of course we want to use, not bypass, the stored data
    "no_stf_barrier" # We don't need no barriers between software, they could be friends
    "mds=off" # Zombieload attacks are fine
    "tsx=on"
    "tsx_async_abort=off"
    "mitigations=off"
  ];
}
/*
  FIXME: Unknown kernel command line parameters in 6.1.27 :
  noibrs
  noibpb
  nospectre_v2
  nospec_store_bypass_disable
  no_stf_barrier
  cgroup_enable=memory
  cgroup_memory=1
*/
