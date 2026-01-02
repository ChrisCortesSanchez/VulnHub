# Makefile for VulnHub E-commerce Application
# Simplifies development, testing, and exploitation workflows

.PHONY: help install setup run stop test clean exploit scan docker lint format all

# Default target
.DEFAULT_GOAL := help

# Variables
PYTHON := python3
PIP := pip3
VENV := venv
APP_PORT := 5000
APP_URL := http://localhost:$(APP_PORT)

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

##@ General

help: ## Display this help message
	@echo "$(GREEN)VulnHub E-commerce - Makefile Commands$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make $(YELLOW)<target>$(NC)\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Setup & Installation

install: ## Install dependencies
	@echo "$(GREEN)Installing dependencies...$(NC)"
	$(PIP) install -r requirements.txt
	@echo "$(GREEN)Dependencies installed successfully!$(NC)"

install-dev: ## Install development dependencies
	@echo "$(GREEN)Installing development dependencies...$(NC)"
	$(PIP) install -r requirements.txt
	$(PIP) install pytest pytest-cov black flake8 pylint bandit
	@echo "$(GREEN)Development dependencies installed!$(NC)"

venv: ## Create virtual environment
	@echo "$(GREEN)Creating virtual environment...$(NC)"
	$(PYTHON) -m venv $(VENV)
	@echo "$(GREEN)Virtual environment created!$(NC)"
	@echo "$(YELLOW)Activate with: source $(VENV)/bin/activate$(NC)"

setup: venv install init-db ## Complete initial setup
	@echo "$(GREEN)Setup complete! Run 'make run' to start the application.$(NC)"

##@ Database

init-db: ## Initialize database
	@echo "$(GREEN)Initializing database...$(NC)"
	mkdir -p app/data
	$(PYTHON) app/data/seed_data.py
	@echo "$(GREEN)Database initialized with sample data!$(NC)"

reset-db: ## Reset database to initial state
	@echo "$(YELLOW)Resetting database...$(NC)"
	rm -f app/data/ecommerce.db
	$(MAKE) init-db
	@echo "$(GREEN)Database reset complete!$(NC)"

backup-db: ## Backup current database
	@echo "$(GREEN)Backing up database...$(NC)"
	cp app/data/ecommerce.db app/data/ecommerce_backup_$(shell date +%Y%m%d_%H%M%S).db
	@echo "$(GREEN)Database backed up!$(NC)"

##@ Running

run: ## Run the vulnerable application
	@echo "$(GREEN)Starting VulnHub E-commerce (Vulnerable Mode)...$(NC)"
	@echo "$(YELLOW)Access at: $(APP_URL)$(NC)"
	FLASK_APP=app.app FLASK_ENV=development $(PYTHON) -m flask run --port=$(APP_PORT)

run-secure: ## Run the secure version
	@echo "$(GREEN)Starting VulnHub E-commerce (Secure Mode)...$(NC)"
	@echo "$(YELLOW)Access at: $(APP_URL)$(NC)"
	SECURE_MODE=1 FLASK_APP=app.app FLASK_ENV=development $(PYTHON) -m flask run --port=$(APP_PORT)

run-debug: ## Run with debugging enabled
	@echo "$(GREEN)Starting in DEBUG mode...$(NC)"
	FLASK_APP=app.app FLASK_ENV=development FLASK_DEBUG=1 $(PYTHON) -m flask run --port=$(APP_PORT)

stop: ## Stop the application
	@echo "$(RED)Stopping application...$(NC)"
	@pkill -f "flask run" || echo "No Flask process found"

##@ Docker

docker-build: ## Build Docker image
	@echo "$(GREEN)Building Docker image...$(NC)"
	docker-compose build
	@echo "$(GREEN)Docker image built!$(NC)"

docker-up: ## Start application in Docker
	@echo "$(GREEN)Starting Docker containers...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)Application running at: $(APP_URL)$(NC)"

docker-down: ## Stop Docker containers
	@echo "$(RED)Stopping Docker containers...$(NC)"
	docker-compose down

docker-logs: ## View Docker logs
	docker-compose logs -f

docker-shell: ## Open shell in Docker container
	docker-compose exec web /bin/bash

docker-rebuild: docker-down docker-build docker-up ## Rebuild and restart Docker

##@ Testing

test: ## Run all tests
	@echo "$(GREEN)Running all tests...$(NC)"
	pytest tests/ -v

test-vuln: ## Test vulnerability existence
	@echo "$(GREEN)Testing vulnerabilities...$(NC)"
	pytest tests/test_vulnerabilities.py -v

test-scanner: ## Test scanner accuracy
	@echo "$(GREEN)Testing scanner...$(NC)"
	pytest tests/test_scanner.py -v

test-exploits: ## Test exploit reliability
	@echo "$(GREEN)Testing exploits...$(NC)"
	pytest tests/test_exploits.py -v

test-secure: ## Test secure implementations
	@echo "$(GREEN)Testing secure version...$(NC)"
	pytest tests/test_secure.py -v

test-coverage: ## Run tests with coverage report
	@echo "$(GREEN)Running tests with coverage...$(NC)"
	pytest tests/ --cov=app --cov-report=html --cov-report=term
	@echo "$(GREEN)Coverage report generated in htmlcov/$(NC)"

##@ Exploitation

exploit-all: ## Run all exploits sequentially
	@echo "$(GREEN)Running all exploits...$(NC)"
	@for exploit in exploits/*.py; do \
		echo "$(YELLOW)Running $$exploit...$(NC)"; \
		$(PYTHON) $$exploit $(APP_URL); \
		echo ""; \
	done

exploit-sqli: ## Run SQL injection exploit
	@echo "$(GREEN)Running SQL injection exploit...$(NC)"
	$(PYTHON) exploits/01_sql_injection.py $(APP_URL)

exploit-xss: ## Run XSS exploit
	@echo "$(GREEN)Running XSS exploit...$(NC)"
	$(PYTHON) exploits/02_xss.py $(APP_URL)

exploit-idor: ## Run IDOR exploit
	@echo "$(GREEN)Running IDOR exploit...$(NC)"
	$(PYTHON) exploits/03_idor.py $(APP_URL)

exploit-auth: ## Run authentication bypass exploit
	@echo "$(GREEN)Running authentication bypass...$(NC)"
	$(PYTHON) exploits/04_auth_bypass.py $(APP_URL)

exploit-ssrf: ## Run SSRF exploit
	@echo "$(GREEN)Running SSRF exploit...$(NC)"
	$(PYTHON) exploits/05_ssrf.py $(APP_URL)

exploit-rce: ## Run command injection exploit
	@echo "$(GREEN)Running command injection exploit...$(NC)"
	$(PYTHON) exploits/06_command_injection.py $(APP_URL)

exploit-csrf: ## Run CSRF exploit
	@echo "$(GREEN)Running CSRF exploit...$(NC)"
	$(PYTHON) exploits/07_csrf.py $(APP_URL)

exploit-xxe: ## Run XXE exploit
	@echo "$(GREEN)Running XXE exploit...$(NC)"
	$(PYTHON) exploits/08_xxe.py $(APP_URL)

exploit-deser: ## Run deserialization exploit
	@echo "$(GREEN)Running deserialization exploit...$(NC)"
	$(PYTHON) exploits/09_deserialization.py $(APP_URL)

exploit-upload: ## Run file upload exploit
	@echo "$(GREEN)Running file upload exploit...$(NC)"
	$(PYTHON) exploits/10_file_upload.py $(APP_URL)

exploit-chain: ## Run full attack chain
	@echo "$(GREEN)Running complete exploitation chain...$(NC)"
	$(PYTHON) exploits/automated_chain.py $(APP_URL)

##@ Scanning

scan: ## Run vulnerability scanner
	@echo "$(GREEN)Running vulnerability scanner...$(NC)"
	$(PYTHON) scanner/vuln_scanner.py $(APP_URL)
	@echo "$(GREEN)Scan complete! Check scanner/reports/ for detailed report.$(NC)"

scan-quick: ## Run quick vulnerability scan
	@echo "$(GREEN)Running quick scan...$(NC)"
	$(PYTHON) scanner/vuln_scanner.py $(APP_URL) --quick

scan-verbose: ## Run verbose vulnerability scan
	@echo "$(GREEN)Running verbose scan...$(NC)"
	$(PYTHON) scanner/vuln_scanner.py $(APP_URL) --verbose

##@ Code Quality

lint: ## Run linting
	@echo "$(GREEN)Running linting...$(NC)"
	flake8 app/ exploits/ scanner/ tests/ --max-line-length=100

lint-security: ## Run security linting
	@echo "$(GREEN)Running security analysis...$(NC)"
	bandit -r app/ -ll

format: ## Format code with black
	@echo "$(GREEN)Formatting code...$(NC)"
	black app/ exploits/ scanner/ tests/

format-check: ## Check code formatting
	@echo "$(GREEN)Checking code formatting...$(NC)"
	black app/ exploits/ scanner/ tests/ --check

quality: lint lint-security format-check ## Run all quality checks

##@ Documentation

docs-serve: ## Serve documentation locally
	@echo "$(GREEN)Serving documentation...$(NC)"
	@echo "$(YELLOW)Access at: http://localhost:8000$(NC)"
	cd docs && $(PYTHON) -m http.server 8000

docs-generate: ## Generate documentation
	@echo "$(GREEN)Generating documentation...$(NC)"
	# Add documentation generation commands here

##@ Utility

clean: ## Clean up generated files
	@echo "$(RED)Cleaning up...$(NC)"
	find . -type f -name '*.pyc' -delete
	find . -type d -name '__pycache__' -delete
	find . -type d -name '*.egg-info' -exec rm -rf {} + 2>/dev/null || true
	rm -rf .pytest_cache
	rm -rf htmlcov
	rm -rf .coverage
	rm -rf dist build
	@echo "$(GREEN)Cleanup complete!$(NC)"

clean-all: clean ## Deep clean including database
	@echo "$(RED)Deep cleaning...$(NC)"
	rm -f app/database/ecommerce.db
	rm -f app/database/ecommerce_backup_*.db
	rm -rf scanner/reports/*.html
	@echo "$(GREEN)Deep cleanup complete!$(NC)"

logs: ## View application logs
	@tail -f app.log 2>/dev/null || echo "No log file found"

ps: ## Show running processes
	@echo "$(GREEN)Flask processes:$(NC)"
	@ps aux | grep flask || echo "No Flask processes running"

status: ## Check application status
	@echo "$(GREEN)Checking application status...$(NC)"
	@curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" $(APP_URL) || echo "$(RED)Application not running$(NC)"

##@ Development Workflow

dev-setup: setup install-dev ## Complete development setup
	@echo "$(GREEN)Development environment ready!$(NC)"

dev-test: format lint test ## Format, lint, and test
	@echo "$(GREEN)All checks passed!$(NC)"

demo: run-debug ## Start app for demonstration
	@echo "$(GREEN)Demo mode started$(NC)"
	@echo "$(YELLOW)Default credentials:$(NC)"
	@echo "  Admin: admin / admin123"
	@echo "  User:  user / password"

full-test: reset-db run-background test exploit-all scan stop ## Full testing suite
	@echo "$(GREEN)Full test suite complete!$(NC)"

run-background: ## Run app in background
	@echo "$(GREEN)Starting app in background...$(NC)"
	nohup $(MAKE) run > app.log 2>&1 &
	@sleep 3
	@echo "$(GREEN)App started! PID: $$(pgrep -f 'flask run')$(NC)"

##@ Information

info: ## Show project information
	@echo "$(GREEN)VulnHub E-commerce - Project Information$(NC)"
	@echo ""
	@echo "$(YELLOW)Application URL:$(NC) $(APP_URL)"
	@echo "$(YELLOW)Python Version:$(NC) $$($(PYTHON) --version)"
	@echo "$(YELLOW)Database:$(NC) SQLite (app/database/ecommerce.db)"
	@echo ""
	@echo "$(YELLOW)Default Credentials:$(NC)"
	@echo "  Admin: admin / admin123"
	@echo "  User:  user / password"
	@echo ""
	@echo "$(YELLOW)Key Vulnerabilities:$(NC)"
	@echo "  1. SQL Injection (Product search)"
	@echo "  2. XSS (Product reviews)"
	@echo "  3. IDOR (Orders, Cart)"
	@echo "  4. Weak Authentication"
	@echo "  5. Command Injection (Admin panel)"
	@echo "  6. SSRF (Image fetching)"
	@echo "  7. CSRF (Cart operations)"
	@echo "  8. XXE (Product import)"
	@echo "  9. Deserialization (Payment tokens)"
	@echo "  10. Unrestricted File Upload"

credentials: ## Show default credentials
	@echo "$(YELLOW)Default Credentials:$(NC)"
	@echo "  Admin: admin / admin123"
	@echo "  User:  user / password"

urls: ## Show important URLs
	@echo "$(YELLOW)Important URLs:$(NC)"
	@echo "  Homepage:     $(APP_URL)/"
	@echo "  Products:     $(APP_URL)/products"
	@echo "  Login:        $(APP_URL)/login"
	@echo "  Admin Panel:  $(APP_URL)/admin"
	@echo "  API:          $(APP_URL)/api"

version: ## Show version information
	@echo "VulnHub E-commerce v1.0.0"
	@$(PYTHON) --version
	@$(PIP) --version