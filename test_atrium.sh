#!/bin/bash

WD="$(
    cd "$(dirname "$0")"
    pwd -P
)"

BENCH_CMD="rewrk -c 400 -t 8 -d 20s -h http://app1.atrium.127.0.0.1.nip.io:8080 --pct"

#####################################################################
#                            INSTALL RWRK                           #
#####################################################################

sudo apt install -y libssl-dev
sudo apt install -y pkg-config
cargo install rewrk --git https://github.com/ChillFish8/rewrk.git

#####################################################################
#                              BACKEND                              #
#####################################################################

# Build for production
cd ${WD}/actix_backend
cargo build --release
# Start
${WD}/actix_backend/target/release/actix_backend &
BACKEND_PID=$!
sleep 2

#####################################################################
#                               ATRIUM                              #
#####################################################################

# Build for production
cd ${WD}/../atrium/backend
cargo build --release
# Copy configuration
cp ${WD}/atrium.yaml ${WD}/../atrium/backend/target/release/
# Start proxy
cd ${WD}/../atrium/backend/target/release/
./atrium &
AXUM_PROXY_PID=$!
sleep 2
# Test proxy
eval ${BENCH_CMD}
# Shutdown
kill $AXUM_PROXY_PID

#####################################################################
#                          BACKEND SHUTDOWN                         #
#####################################################################

# Shutdown backend
kill $BACKEND_PID
