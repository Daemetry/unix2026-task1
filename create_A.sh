#!/bin/bash

SIZE=$((4*1024*1024+1))

dd if=/dev/zero of=A bs=1 count=$SIZE status=none

printf '\x01' | dd of=A bs=1 seek=0 count=1 conv=notrunc status=none
printf '\x01' | dd of=A bs=1 seek=10000 count=1 conv=notrunc status=none
printf '\x01' | dd of=A bs=1 seek=$((SIZE-1)) count=1 conv=notrunc status=none
