terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.34.0"
    }
  }
}


module "google_service_account" {
    source = "./modules/service_account"
    account_id  = "test-gcf-sa"
    display_name = "Test Service Account"
    project    = "instant-ascent-409409"
}

module "google_pubsub_topic" {
    source = "./modules/pubsub"
    topic_name = "functions2-topic"
    project  = "instant-ascent-409409"
}

module "google_storage_bucket" {
    source = "./modules/bucket"
    bucket_name = "2165421516-gcf-source"
    location = "asia-south2"
    uniform_bucket_level_access = true
}

module "archive_file" {
  source = "./modules/storage_bucket_object"
  type       = "zip"
  output_path = "/tmp/function-source.zip"
  source_dir  = "./v2/helloPubSub/function-source.zip"
  bucket_object_name   = "function-source.zip" 
}

module "google_cloudfunctions2_function" {
  source = "./modules/function"

  function_name = "function"
  function_location = "asia-south2"
  project = "instant-ascent-409409"
  runtime = "nodejs16"
  entry_point = "helloPubSub"
  max_instance_count = 3
  min_instance_count = 1
  available_memory = "256M"
  timeout_seconds = 60
  ingress_settings = "ALLOW_INTERNAL_ONLY"
  all_traffic_on_latest_revision = true
  trigger_region = "asia-south2"
  event_type = "google.cloud.pubsub.topic.v1.messagePublished"
  retry_policy = "RETRY_POLICY_RETRY"
}