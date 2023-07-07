# Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  service_account_key_file = "${var.YC_SERVICE_ACCOUNT_KEY_FILE}"
  cloud_id  = "${var.YC_CLOUD_ID}"
  folder_id = "${var.YC_FOLDER_ID}"
}