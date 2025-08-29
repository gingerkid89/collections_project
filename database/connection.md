# Database Connection Configuration

## Local Development Setup

### PostgreSQL Container Details
```
Container Name: collections-db
Database: collections_app
Username: collections_user  
Password: dev_password
Host: localhost
Port: 5432
```

### Connection String
```
postgresql://collections_user:dev_password@localhost:5432/collections_app
```

### Docker Commands
```bash
# Start existing container
docker start collections-db

# Stop container
docker stop collections-db

# View logs
docker logs collections-db

# Connect to database
docker exec -it collections-db psql -U collections_user -d collections_app

# Backup database
docker exec collections-db pg_dump -U collections_user -d collections_app > backup.sql

# Restore database  
docker exec -i collections-db psql -U collections_user -d collections_app < backup.sql
```

## Migration to Production

### 1. Data Export
```bash
# Full database dump
docker exec collections-db pg_dump -U collections_user -d collections_app --clean --if-exists > production_export.sql
```

### 2. Cloud Database Setup
- **Supabase**: PostgreSQL + REST API + Auth
- **Railway**: Simple deployment
- **AWS RDS**: Production-grade PostgreSQL

### 3. Data Import
```bash
# Import to production
psql -h <production-host> -U <prod-user> -d <prod-db> < production_export.sql
```

## Schema Files
- `schema.sql` - Initial database structure
- `sample_data.sql` - Test data for development

## Notes
- UUID extensions enabled for primary keys
- JSONB fields for flexible place/visit data
- Indexes optimized for app query patterns
- Automatic updated_at timestamps via triggers