#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Code-Keeper - GitLab Setup Script
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# This script automates the deployment of GitLab and Runners using Ansible
# Usage: ./setup-gitlab.sh
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"

    # Check Ansible
    if command -v ansible-playbook &> /dev/null; then
        ANSIBLE_VERSION=$(ansible --version | head -n 1)
        print_success "Ansible found: $ANSIBLE_VERSION"
    else
        print_error "Ansible not found. Please install Ansible first."
        echo "Install with: sudo apt-get install ansible"
        exit 1
    fi

    # Check Python
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version)
        print_success "Python found: $PYTHON_VERSION"
    else
        print_error "Python3 not found. Please install Python3."
        exit 1
    fi

    # Check SSH key
    if [ ! -f ~/.ssh/id_rsa ] && [ ! -f ~/.ssh/id_ed25519 ]; then
        print_warning "No SSH key found. You may need to generate one:"
        echo "  ssh-keygen -t ed25519 -C 'your_email@example.com'"
    else
        print_success "SSH key found"
    fi
}

# Check inventory file
check_inventory() {
    print_header "Checking Inventory File"

    INVENTORY_FILE="../ansible/playbooks/inventory/hosts.yml"

    if [ ! -f "$INVENTORY_FILE" ]; then
        print_error "Inventory file not found: $INVENTORY_FILE"
        exit 1
    fi

    # Check if IP is placeholder
    if grep -q "YOUR_GITLAB_SERVER_IP" "$INVENTORY_FILE"; then
        print_error "Please update the inventory file with your actual server IP"
        echo "Edit: $INVENTORY_FILE"
        exit 1
    fi

    print_success "Inventory file found and configured"
}

# Deploy GitLab
deploy_gitlab() {
    print_header "Deploying GitLab with Ansible"

    cd ../ansible

    echo "This will:"
    echo "  - Install GitLab CE on your server"
    echo "  - Configure GitLab"
    echo "  - Start GitLab services"
    echo ""
    read -p "Continue? (y/n) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Deploying GitLab... This may take 10-15 minutes"

        if ansible-playbook playbooks/deploy-gitlab.yml -i playbooks/inventory/hosts.yml; then
            print_success "GitLab deployed successfully!"
        else
            print_error "GitLab deployment failed. Check logs above."
            exit 1
        fi
    else
        print_warning "GitLab deployment cancelled"
        exit 0
    fi
}

# Get runner token
get_runner_token() {
    print_header "GitLab Runner Token"

    echo "To configure runners, you need the GitLab Runner registration token."
    echo ""
    echo "Steps to get the token:"
    echo "  1. Open GitLab in your browser"
    echo "  2. Go to: Admin Area → CI/CD → Runners"
    echo "  3. Copy the registration token"
    echo ""
    read -p "Enter the GitLab Runner registration token: " RUNNER_TOKEN

    if [ -z "$RUNNER_TOKEN" ]; then
        print_error "Runner token cannot be empty"
        exit 1
    fi

    export GITLAB_RUNNER_TOKEN="$RUNNER_TOKEN"
    print_success "Runner token set"
}

# Configure runners
configure_runners() {
    print_header "Configuring GitLab Runners"

    if [ -z "$GITLAB_RUNNER_TOKEN" ]; then
        print_error "GITLAB_RUNNER_TOKEN not set. Run get_runner_token first."
        exit 1
    fi

    echo "This will:"
    echo "  - Install Docker"
    echo "  - Install GitLab Runner"
    echo "  - Register 3 runners"
    echo ""
    read -p "Continue? (y/n) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Configuring runners... This may take 5-10 minutes"

        cd ../ansible

        if ansible-playbook playbooks/configure-runners.yml -i playbooks/inventory/hosts.yml; then
            print_success "Runners configured successfully!"
        else
            print_error "Runner configuration failed. Check logs above."
            exit 1
        fi
    else
        print_warning "Runner configuration cancelled"
        exit 0
    fi
}

# Verify installation
verify_installation() {
    print_header "Verifying Installation"

    cd ../ansible

    echo "Checking GitLab status..."
    ansible gitlab_server -i playbooks/inventory/hosts.yml -m shell -a "systemctl status gitlab-runsvdir" || true

    echo ""
    echo "Checking GitLab runners..."
    ansible gitlab_server -i playbooks/inventory/hosts.yml -m shell -a "gitlab-runner list" || true

    print_success "Verification complete"
}

# Display access information
display_info() {
    print_header "GitLab Access Information"

    echo "GitLab is now ready!"
    echo ""
    echo "Access GitLab at: http://YOUR_SERVER_IP"
    echo "Default username: root"
    echo "Check password in: /etc/gitlab/initial_root_password (on server)"
    echo ""
    echo "Next steps:"
    echo "  1. Log in to GitLab"
    echo "  2. Change the root password"
    echo "  3. Create your projects (inventory-app, billing-app, api-gateway, infrastructure)"
    echo "  4. Configure CI/CD variables"
    echo "  5. Push your code"
    echo ""
}

# Main menu
main_menu() {
    print_header "Code-Keeper - GitLab Setup"

    echo "Select an option:"
    echo "  1) Full setup (GitLab + Runners)"
    echo "  2) Deploy GitLab only"
    echo "  3) Configure Runners only"
    echo "  4) Verify installation"
    echo "  5) Exit"
    echo ""
    read -p "Enter option (1-5): " OPTION

    case $OPTION in
        1)
            check_prerequisites
            check_inventory
            deploy_gitlab
            get_runner_token
            configure_runners
            verify_installation
            display_info
            ;;
        2)
            check_prerequisites
            check_inventory
            deploy_gitlab
            display_info
            ;;
        3)
            check_prerequisites
            check_inventory
            get_runner_token
            configure_runners
            verify_installation
            ;;
        4)
            verify_installation
            ;;
        5)
            echo "Exiting..."
            exit 0
            ;;
        *)
            print_error "Invalid option"
            exit 1
            ;;
    esac
}

# Run main menu
main_menu

print_success "Setup complete!"
