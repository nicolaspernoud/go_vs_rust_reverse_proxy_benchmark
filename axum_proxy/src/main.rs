use axum::{
    http::{Request, Response},
    routing::any,
    Router,
};
use axum_server::tls_rustls::RustlsConfig;
use hyper::{client::HttpConnector, Body, StatusCode, Version};
use std::{
    convert::TryFrom,
    net::{IpAddr, SocketAddr},
};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};
type Client = hyper::client::Client<HttpConnector, Body>;
use hyper::client::connect::dns::GaiResolver;
use hyper_reverse_proxy::ReverseProxy;

lazy_static::lazy_static! {
    static ref  PROXY_CLIENT: ReverseProxy<HttpConnector<GaiResolver>> = {
        ReverseProxy::new(
            Client::new()
        )
    };
}

#[tokio::main]
async fn main() {
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::new(
            std::env::var("RUST_LOG").unwrap_or_else(|_| "example_tls_rustls=debug".into()),
        ))
        .with(tracing_subscriber::fmt::layer())
        .init();

    let config =
        RustlsConfig::from_pem_file("self_signed_certs/cert.pem", "self_signed_certs/key.pem")
            .await
            .unwrap();

    let app = Router::new().route("/", any(handler));

    let addr = SocketAddr::from(([127, 0, 0, 1], 1443));
    println!("listening on {}", addr);
    axum_server::bind_rustls(addr, config)
        .serve(app.into_make_service())
        .await
        .unwrap();
}

async fn handler(mut req: Request<Body>) -> Response<Body> {
    *Request::version_mut(&mut req) = Version::HTTP_11;
    match PROXY_CLIENT
        .call(
            IpAddr::try_from([127, 0, 0, 1]).unwrap(),
            "http://127.0.0.1:8080",
            req,
        )
        .await
    {
        Ok(response) => response,
        Err(_error) => {
            eprint!("_error: {:?}", _error);
            Response::builder()
                .status(StatusCode::INTERNAL_SERVER_ERROR)
                .body(Body::empty())
                .unwrap()
        }
    }
}
