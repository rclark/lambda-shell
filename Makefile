init:
	@cd terraform && terraform init

apply:
	@cd terraform && terraform apply

destroy:
	@cd terraform && terraform destroy

sh:
	@cd cmd && go run . $(filter-out $@,$(MAKECMDGOALS))

# Prevent make from treating additional arguments as targets
%:
	@:

.PHONY: apply sh
