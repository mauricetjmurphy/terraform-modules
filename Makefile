
format:
	terraform fmt -recursive

deploy-codebuild-dev:
	@echo "**************************codebuild started*****************************"
	cd "dev\buildpipelines" && terraform init && terraform apply --auto-approve
	@echo "**************************codebuild completed*****************************"
	

deploy-dev: format deploy-codebuild-dev
# ************************************************************************************

deploy-codebuild-staging:
	@echo "**************************codebuild started*****************************"
	cd "staging\buildpipelines" && terraform init && terraform apply --auto-approve
	@echo "**************************codebuild completed*****************************"
	


deploy-staging: format deploy-codebuild-staging

# ************************************************************************************
deploy-codebuild-prod:
	@echo "**************************codebuild started*****************************"
	cd "prod\buildpipelines" && terraform init && terraform apply --auto-approve
	@echo "**************************codebuild completed*****************************"
	
deploy-prod: format deploy-codebuild-prod

# ************************************************************************************
deploy-codebuild-DR:
	@echo "**************************codebuild started*****************************"
	cd "DR\buildpipelines" && terraform init && terraform apply --auto-approve
	@echo "**************************codebuild completed*****************************"

deploy-DR: format deploy-codebuild-DR


# ************************************************************************************
