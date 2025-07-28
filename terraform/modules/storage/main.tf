# S3 Bucket for static assets and backups
resource "aws_s3_bucket" "main" {
  bucket = "${var.name_prefix}-storage-${random_id.bucket_suffix.hex}"
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-storage"
  })
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  
  rule {
    id     = "backup_lifecycle"
    status = "Enabled"
    
    filter {}
    
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
    
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

# EFS File System
resource "aws_efs_file_system" "main" {
  creation_token = "${var.name_prefix}-efs"
  
  performance_mode = "generalPurpose"
  throughput_mode  = "provisioned"
  provisioned_throughput_in_mibps = 100
  
  encrypted = true
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-efs"
  })
}

# EFS Mount Targets
resource "aws_efs_mount_target" "main" {
  count = length(var.private_subnet_ids)
  
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [var.efs_security_group_id]
}

# EFS Access Points
resource "aws_efs_access_point" "uploads" {
  file_system_id = aws_efs_file_system.main.id
  
  posix_user {
    gid = 33  # www-data group
    uid = 33  # www-data user
  }
  
  root_directory {
    path = "/uploads"
    creation_info {
      owner_gid   = 33
      owner_uid   = 33
      permissions = "0755"
    }
  }
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-efs-uploads"
  })
}

resource "aws_efs_access_point" "cache" {
  file_system_id = aws_efs_file_system.main.id
  
  posix_user {
    gid = 33  # www-data group
    uid = 33  # www-data user
  }
  
  root_directory {
    path = "/cache"
    creation_info {
      owner_gid   = 33
      owner_uid   = 33
      permissions = "0755"
    }
  }
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-efs-cache"
  })
}

resource "aws_efs_access_point" "logs" {
  file_system_id = aws_efs_file_system.main.id
  
  posix_user {
    gid = 33  # www-data group
    uid = 33  # www-data user
  }
  
  root_directory {
    path = "/logs"
    creation_info {
      owner_gid   = 33
      owner_uid   = 33
      permissions = "0755"
    }
  }
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-efs-logs"
  })
}

resource "aws_efs_access_point" "config_persistence" {
  file_system_id = aws_efs_file_system.main.id
  
  posix_user {
    gid = 33  # www-data group
    uid = 33  # www-data user
  }
  
  root_directory {
    path = "/config-persistence"
    creation_info {
      owner_gid   = 33
      owner_uid   = 33
      permissions = "0755"
    }
  }
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-efs-config-persistence"
  })
}

resource "aws_efs_access_point" "chatbot_logs" {
  file_system_id = aws_efs_file_system.main.id
  
  posix_user {
    gid = 1000  # Default user in Python container
    uid = 1000
  }
  
  root_directory {
    path = "/chatbot-logs"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0755"
    }
  }
  
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-efs-chatbot-logs"
  })
}