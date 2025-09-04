#!/bin/bash

# Terraform Deployment Script for EKS/ECS Infrastructure
# Usage: ./deploy.sh [orchestrator] [environment] [action]
# Examples:
#   ./deploy.sh eks qa plan
#   ./deploy.sh eks qa apply
#   ./deploy.sh eks qa destroy
#   ./deploy.sh ecs qa plan
#   ./deploy.sh ecs qa apply
#   ./deploy.sh ecs qa destroy

set -e

# Default values
ORCHESTRATOR=${1:-"eks"}
ENVIRONMENT=${2:-"qa"}
ACTION=${3:-"plan"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_usage() {
    echo "Usage: $0 [orchestrator] [environment] [action]"
    echo
    echo "Parameters:"
    echo "  orchestrator: eks or ecs (default: eks)"
    echo "  environment:  qa or prod (default: qa)"
    echo "  action:       plan, apply, or destroy (default: plan)"
    echo
    echo "Examples:"
    echo "  $0 eks qa plan         # Plan EKS deployment in qa"
    echo "  $0 ecs qa apply        # Deploy ECS in qa"
    echo "  $0 eks prod destroy    # Destroy EKS in prod"
    echo
    exit 1
}

validate_inputs() {
    # Validate orchestrator
    if [[ ! "$ORCHESTRATOR" =~ ^(eks|ecs)$ ]]; then
        log_error "Invalid orchestrator: $ORCHESTRATOR. Must be 'eks' or 'ecs'"
        show_usage
    fi

    # Validate environment
    if [[ ! "$ENVIRONMENT" =~ ^(qa|prod)$ ]]; then
        log_error "Invalid environment: $ENVIRONMENT. Must be 'qa' or 'prod'"
        show_usage
    fi

    # Validate action
    if [[ ! "$ACTION" =~ ^(plan|apply|destroy)$ ]]; then
        log_error "Invalid action: $ACTION. Must be 'plan', 'apply', or 'destroy'"
        show_usage
    fi

    # Check if environment file exists
    if [[ ! -f "environments/$ENVIRONMENT/terraform.tfvars" ]]; then
        log_error "Environment file not found: environments/$ENVIRONMENT/terraform.tfvars"
        exit 1
    fi
}

init_terraform() {
    log_info "Initializing Terraform..."
    terraform init -upgrade
}

show_deployment_info() {
    echo
    log_info "=== Deployment Configuration ==="
    echo "Orchestrator: $ORCHESTRATOR"
    echo "Environment:  $ENVIRONMENT"
    echo "Action:       $ACTION"
    echo "Config File:  environments/$ENVIRONMENT/terraform.tfvars"
    echo
}

run_terraform_command() {
    local tf_vars_file="environments/$ENVIRONMENT/terraform.tfvars"
    local orchestrator_override="-var=container_orchestrator=$ORCHESTRATOR"
    
    case $ACTION in
        plan)
            log_info "Running Terraform plan..."
            terraform plan \
                $orchestrator_override \
                -var-file="$tf_vars_file" \
                -detailed-exitcode
            ;;
        apply)
            log_warning "This will deploy infrastructure to $ENVIRONMENT environment with $ORCHESTRATOR orchestrator."
            read -p "Are you sure? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                log_info "Running Terraform apply..."
                terraform apply \
                    $orchestrator_override \
                    -var-file="$tf_vars_file" \
                    -auto-approve
                
                log_success "Deployment completed successfully!"
                echo
                log_info "Getting deployment outputs..."
                terraform output
            else
                log_info "Deployment cancelled."
                exit 0
            fi
            ;;
        destroy)
            log_warning "This will DESTROY all infrastructure in $ENVIRONMENT environment!"
            read -p "Are you absolutely sure? Type 'yes' to confirm: " confirmation
            if [[ "$confirmation" == "yes" ]]; then
                log_info "Running Terraform destroy..."
                terraform destroy \
                    $orchestrator_override \
                    -var-file="$tf_vars_file" \
                    -auto-approve
                
                log_success "Infrastructure destroyed successfully!"
            else
                log_info "Destroy operation cancelled."
                exit 0
            fi
            ;;
    esac
}

main() {
    echo "=== Chame Bina Terraform Deployment Script ==="
    echo
    
    # Handle help flag
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_usage
    fi

    validate_inputs
    show_deployment_info
    
    init_terraform
    run_terraform_command
    
    echo
    log_success "Script completed!"
    
    if [[ "$ACTION" == "apply" ]]; then
        echo
        log_info "Next steps:"
        case $ORCHESTRATOR in
            eks)
                echo "1. Configure kubectl: aws eks update-kubeconfig --region us-east-1 --name \$(terraform output -raw cluster_name)"
                echo "2. Verify cluster access: kubectl get nodes"
                ;;
            ecs)
                echo "1. Deploy your services using the ECS cluster"
                echo "2. Configure your load balancer target groups"
                ;;
        esac
        echo "3. Push container images to ECR repositories"
        echo "4. Deploy your applications"
    fi
}

main "$@"