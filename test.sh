#!/bin/sh -ex

is_alive() {
  ps -o pid= -p $1
}

# Afford eclim enough time to start up (yes, it really takes that long).
./eclimd &
server_pid=$!
sleep 60
is_alive $server_pid

# Ping it.
./eclim -command ping
sleep 1

# Shut it down and confirm it's down.
./eclim -command shutdown
sleep 20
! is_alive $server_pid
