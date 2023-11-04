#!/usr/bin/env bash
set -euo pipefail

rclone sync -P /data/Pictures/Shared main:Pictures &
rclone sync -P /data/Documents main:Documents &
rclone sync -P /data/Books books:Books &
rclone sync -P /data/Books /backup/Books &
rclone sync -P /data/Documents /backup/Documents &
rclone sync -P /data/Pictures /backup/Pictures &
rclone sync -P /data/Japanese /backup/Japanese &
rclone sync -P /data/Keep /backup/Keep &
rclone sync -P /data/Learn /backup/Learn &
rclone sync -P /data/Music /backup/Music &
rclone sync -P /data/Remember /backup/Remember &
