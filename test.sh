#!/bin/bash

WD="$(
    cd "$(dirname "$0")"
    pwd -P
)"

BENCH_CMD="rewrk -c 400 -t 8 -d 20s -h https://localhost:1443 --pct"

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
#                            AXUM PROXY                             #
#####################################################################

# Build for production
cd ${WD}/axum_proxy
cargo build --release
# Start proxy
cd ${WD}
${WD}/axum_proxy/target/release/axum_proxy &
AXUM_PROXY_PID=$!
sleep 2
# Test proxy
echo -e "\n######################\n# TESTING RUST PROXY #\n######################\n"
eval ${BENCH_CMD}
# Shutdown
kill $AXUM_PROXY_PID

#####################################################################
#                              GO PROXY                             #
#####################################################################

# Build for production
cd ${WD}/go_proxy
go build
# Start
cd ${WD}
${WD}/go_proxy/go_proxy &
GO_PROXY_PID=$!
sleep 2
# Test
echo -e "\n######################\n#  TESTING GO PROXY  #\n######################\n"
eval ${BENCH_CMD}
# Shutdown
kill $GO_PROXY_PID

#####################################################################
#                          BACKEND SHUTDOWN                         #
#####################################################################

# Shutdown backend
kill $BACKEND_PID
