#!/bin/bash

WD="$(
    cd "$(dirname "$0")"
    pwd -P
)"

BENCH_CMD="wrk -t8 -c400 -d20s https://localhost:1443"

#####################################################################
#                            INSTALL WRK                            #
#####################################################################

sudo apt install -y wrk

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
eval ${BENCH_CMD}
# Shutdown
kill $GO_PROXY_PID

#####################################################################
#                          BACKEND SHUTDOWN                         #
#####################################################################

# Shutdown backend
kill $BACKEND_PID
