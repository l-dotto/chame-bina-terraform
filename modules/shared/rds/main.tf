# Generate random password for database
resource "random_password" "db_password" {
  length  = 32
  special = true
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-subnet-group"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-${var.environment}-rds-"
  vpc_id      = var.vpc_id

  # Allow inbound PostgreSQL connections from private subnets (where ECS/EKS run)
  dynamic "ingress" {
    for_each = length(var.allowed_security_groups) > 0 ? [1] : []
    content {
      description     = "PostgreSQL from ECS/EKS security groups"
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = var.allowed_security_groups
    }
  }

  # Fallback: Allow from private subnets if no specific security groups provided
  dynamic "ingress" {
    for_each = length(var.allowed_security_groups) == 0 ? [1] : []
    content {
      description = "PostgreSQL from private subnets"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = var.private_subnet_cidrs
    }
  }

  # Allow all outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# RDS Instance
resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-${var.environment}-postgres"

  # Engine configuration
  engine         = "postgres"
  engine_version = var.postgres_version
  instance_class = var.instance_class

  # Database configuration  
  db_name  = replace(var.project_name, "-", "_") # Replace hyphens with underscores for valid DB name
  username = "postgres"
  password = random_password.db_password.result

  # Storage configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  # Backup configuration
  backup_window           = var.backup_window
  backup_retention_period = var.backup_retention_period
  copy_tags_to_snapshot   = true

  # Maintenance configuration
  maintenance_window = var.maintenance_window
  apply_immediately  = var.apply_immediately

  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  # Performance Insights
  performance_insights_enabled = true

  # Deletion protection
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project_name}-${var.environment}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres"
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM Role for RDS Enhanced Monitoring
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.project_name}-${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-monitoring-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Attach AWS managed policy for RDS Enhanced Monitoring
resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Store database credentials in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.project_name}/${var.environment}/database"
  description = "Database credentials for ${var.project_name} ${var.environment}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-secret"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = aws_db_instance.postgres.username
    password = random_password.db_password.result
    engine   = "postgres"
    host     = aws_db_instance.postgres.endpoint
    port     = aws_db_instance.postgres.port
    dbname   = aws_db_instance.postgres.db_name
  })
}