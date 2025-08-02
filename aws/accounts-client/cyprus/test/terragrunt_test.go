package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestVPCModule(t *testing.T) {
	// Configure Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../eu-west-1/vpc",
		Vars: map[string]interface{}{
			"environment": "test",
		},
	})

	// Clean up resources after test
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	vpcId := terraform.Output(t, terraformOptions, "vpc_id")
	privateSubnets := terraform.OutputList(t, terraformOptions, "private_subnets")
	publicSubnets := terraform.OutputList(t, terraformOptions, "public_subnets")

	// Assertions
	assert.NotEmpty(t, vpcId)
	assert.Len(t, privateSubnets, 3)
	assert.Len(t, publicSubnets, 3)

	// Verify VPC exists in AWS
	vpc := aws.GetVpcById(t, vpcId, "eu-west-1")
	assert.Equal(t, "test", vpc.Tags["Environment"])
}

func TestRDSModule(t *testing.T) {
	// This test would require VPC to be deployed first
	// In a real scenario, you'd use terragrunt dependencies
	t.Skip("Skipping RDS test - requires VPC to be deployed first")
}

func TestECSModule(t *testing.T) {
	// This test would require VPC and ALB to be deployed first
	t.Skip("Skipping ECS test - requires VPC and ALB to be deployed first")
}

// Integration test for the complete stack
func TestCompleteStack(t *testing.T) {
	// This would test the entire infrastructure stack
	// In practice, you'd deploy all modules and verify they work together
	t.Skip("Skipping complete stack test - requires all modules to be deployed")
}
