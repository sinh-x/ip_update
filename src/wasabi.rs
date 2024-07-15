use rusoto_credential::StaticProvider;
use rusoto_s3::{GetObjectRequest, ListObjectsV2Request, PutObjectRequest, S3Client, S3};
use std::env;
use tokio::io::AsyncReadExt;

const WASABI_ACCESS_KEY: &str = "WASABI_ACCESS_KEY";
const WASABI_SECRET_KEY: &str = "WASABI_SECRET_KEY";
const WASABI_ENDPOINT: &str = "https://s3.ap-southeast-1.wasabisys.com";
const WASABI_REGION: &str = "us-east-1";

async fn create_s3_client() -> Result<S3Client, Box<dyn std::error::Error>> {
    let access_key = env::var(WASABI_ACCESS_KEY).map_err(|_| "WASABI_ACCESS_KEY must be set")?;
    let secret_key = env::var(WASABI_SECRET_KEY).map_err(|_| "WASABI_SECRET_KEY must be set")?;

    let provider = StaticProvider::new_minimal(access_key, secret_key);

    let region = rusoto_core::Region::Custom {
        name: WASABI_REGION.to_owned(),
        endpoint: WASABI_ENDPOINT.to_owned(),
    };

    let client = S3Client::new_with(rusoto_core::HttpClient::new().unwrap(), provider, region);

    Ok(client)
}

pub async fn list_objects_in_bucket(bucket: &str) -> Result<(), Box<dyn std::error::Error>> {
    let client = create_s3_client().await?;

    let list_obj_req = ListObjectsV2Request {
        bucket: bucket.to_string(),
        prefix: Some("shared_resources/".to_string()),
        ..Default::default()
    };

    match client.list_objects_v2(list_obj_req).await {
        Ok(result) => {
            if let Some(objects) = result.contents {
                for object in objects {
                    println!("{}", object.key.unwrap_or_default());
                }
            }
        }
        Err(e) => {
            eprintln!("Error: {}", e);
        }
    }

    Ok(())
}

pub async fn read_from_wasabi(
    bucket: &str,
    object_key: &str,
) -> Result<String, Box<dyn std::error::Error>> {
    let client = create_s3_client().await?;

    let get_request = GetObjectRequest {
        bucket: bucket.to_string(),
        key: object_key.to_string(),
        ..Default::default()
    };

    match client.get_object(get_request).await {
        Ok(result) => {
            let mut stream = result.body.unwrap().into_async_read();
            let mut body = Vec::new();
            stream.read_to_end(&mut body).await?;
            let content = String::from_utf8(body)?;
            Ok(content)
        }
        Err(e) => {
            eprintln!("Error captured: {}", e);
            if e.to_string()
                .to_lowercase()
                .contains("the specified key does not exist")
            {
                // Return an empty string if the object does not exist
                Ok(String::new())
            } else {
                // Return the error if it's not a NoSuchKey error
                Err(e.into())
            }
        }
    }
}

pub async fn upload_to_wasabi(
    bucket: &str,
    object_key: &str,
    content: &str,
) -> Result<(), Box<dyn std::error::Error>> {
    let client = create_s3_client().await?;

    let put_request = PutObjectRequest {
        bucket: bucket.to_string(),
        key: object_key.to_string(),
        body: Some(content.as_bytes().to_vec().into()),
        ..Default::default()
    };

    client.put_object(put_request).await?;
    Ok(())
}
