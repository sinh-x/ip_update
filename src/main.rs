use reqwest::Error;
use rusoto_core::Region;
use rusoto_s3::{PutObjectRequest, S3Client, S3};
use std::env;
use tokio::time::{sleep, Duration};
use gethostname::gethostname;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    dotenv::dotenv().ok();

    let s3_client = S3Client::new(Region::UsEast1); // replace with your region
    let bucket = env::var("WASABI_BUCKET")?;
    let object_key = "public_ip.txt";

    loop {
        let ip = get_public_ip().await?;
        let _ = upload_to_wasabi(&s3_client, &bucket, &object_key, &ip).await?;
        sleep(Duration::from_secs(60 * 60)).await; // run every hour
    }
}

async fn get_public_ip() -> Result<String, Error> {
    let ip = reqwest::get("https://api.ipify.org").await?.text().await?;
    Ok(ip)
}

async fn upload_to_wasabi(
    client: &S3Client,
    bucket: &str,
    object_key: &str,
    content: &str,
) -> Result<(), Box<dyn std::error::Error>> {
    let put_request = PutObjectRequest {
        bucket: bucket.to_string(),
        key: object_key.to_string(),
        body: Some(content.as_bytes().to_vec().into()),
        ..Default::default()
    };

    client.put_object(put_request).await?;
    Ok(())
}
