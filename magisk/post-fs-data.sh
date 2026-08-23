#!/system/bin/sh
#
# Copyright (C) 2021-2022 Matt Yang
# Enhanced for Google Tensor G3 by Sushiba
#

MODDIR=${0%/*}

# Clean any stale temporary flags
rm -f "$MODDIR/flag/need_recuser" 2>/dev/null
