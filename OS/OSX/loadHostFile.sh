#!/bin/bash
# Author: Rohtash Lakra
# Loads Host Filename
#
dscacheutil -flushcache;sudo killall -HUP mDNSResponder
