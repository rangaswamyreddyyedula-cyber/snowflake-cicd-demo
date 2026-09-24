terraform {
  # State is kept as a file in the "tfstate" branch of this same GitHub repo.
  # The pipeline checks that branch out into ../tfstate and passes the file path:
  #   terraform init -backend-config="path=../tfstate/test_cicd_demo-test.tfstate"
  backend "local" {}
}
