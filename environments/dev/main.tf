# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


locals {
  env = "dev"
}

provider "google" {
  project = "${var.project}"
}

module "vpc" {
  source  = "../../modules/vpc"
  project = "${var.project}"
  env     = "${local.env}"
}

module "http_server" {
  source  = "../../modules/http_server"
  project = "${var.project}"
  subnet  = "${module.vpc.subnet}"
}

module "firewall" {
  source  = "../../modules/firewall"
  project = "${var.project}"
  subnet  = "${module.vpc.subnet}"
}

module "im-workspace" {
 source = "terraform-google-modules/bootstrap/google//modules/im_cloudbuild_workspace"
 version = "~> 7.0"

 project_id = e6j2-training
 deployment_id = cloudbuild-terraform-demo
 im_deployment_repo_uri = https://github.com/LuciferJhuang/solutions-terraform-cloudbuild-gitops

 github_personal_access_token = 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

gcloud infra-manager deployments apply projects/e6j2-training/locations/asia-east1/deployments/cloudbuild-terraform-lab \ 
   --service-account projects/e6j2-training/serviceAccounts/chttesting@e6j2-training.iam.gserviceaccount.com \
   --git-source-repo=https://github.com/LuciferJhuang/solutions-terraform-cloudbuild-gitops \
   --git-source-directory=environments/lab \
}
