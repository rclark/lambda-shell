init:
	@cd terraform && terraform init

apply:
	@cd terraform && terraform apply

sh:
	@cd cmd && go run . $(filter-out $@,$(MAKECMDGOALS))

# Prevent make from treating additional arguments as targets
%:
	@:

.PHONY: apply sh
