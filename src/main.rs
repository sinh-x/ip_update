mod wasabi;

use gethostname::gethostname;
use log::{error, info};
use reqwest::Error;
use tokio::time::{sleep, Duration};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let hostname = gethostname()
        .into_string()
        .unwrap_or_else(|_| "unknown".to_string());
    let ip_file_path = format!("shared_resources/{}_public_ip.txt", hostname);

    let current_ip = wasabi::read_from_wasabi("sinh", &ip_file_path)
        .await
        .unwrap_or_else(|_| String::new());
    let new_ip = get_public_ip().await?;

    if new_ip != current_ip {
        info!("Public IP: {}", new_ip);
        wasabi::upload_to_wasabi("sinh", &ip_file_path, &new_ip).await?;
    } else {
        info!("Public IP has not changed");
    }

    Ok(())
}

async fn get_public_ip() -> Result<String, Error> {
    let ip = reqwest::get("https://api.ipify.org").await?.text().await?;
    Ok(ip)
}
