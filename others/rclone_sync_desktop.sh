#!/usr/bin/env bash
set -euo pipefail

rclone sync -P /data/Pictures/Shared main:Pictures &
rclone sync -P /data/Documents main:Documents &
rclone sync -P /data/Books books:Books &
