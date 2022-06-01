# go_vs_rust_reverse_proxy_benchmark

Go vs Rust reverse proxy benchmark (with TLS offloading).

## Usage

Just run test.sh with the rust and go development tools installed.

## Results

With 8 threads and 400 connections over 20 seconds, Rust is more than twice as fast as Go.

### Rust

| Thread Stats | Avg    | Stdev  | Max      | +/- Stdev |
| ------------ | ------ | ------ | -------- | --------- |
| Latency      | 9.56ms | 9.01ms | 280.37ms | 97.70%    |
| Req/Sec      | 5.54k  | 449.17 | 6.90k    | 87.31%    |

867433 requests in 20.03s, 106.72MB read

Requests/sec: **43 316.28**

Transfer/sec: 5.33MB

### Go

| Thread Stats | Avg     | Stdev   | Max      | +/- Stdev |
| ------------ | ------- | ------- | -------- | --------- |
| Latency      | 25.01ms | 21.89ms | 339.45ms | 74.40%    |
| Req/Sec      | 2.28k   | 366.42  | 10.41k   | 87.37%    |

357365 requests in 20.10s, 43.96MB read

Requests/sec: **17 779.99**

Transfer/sec: 2.19MB
