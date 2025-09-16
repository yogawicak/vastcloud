#!/bin/bash

# Website Migration Script
# Migrates /var/www from VPS A to VPS B
# Run this script from VPS A (195.88.211.206/28)

# Configuration
SOURCE_DIR="/var/www"
DEST_HOST="151.244.251.10"
DEST_DIR="/var/www"
DEST_USER="root"  # Change this to your username on VPS B
LOG_FILE="/tmp/migration_$(date +%Y%m%d_%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
    log "INFO: $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    log "SUCCESS: $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    log "WARNING: $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    log "ERROR: $1"
}

# Check if source directory exists
check_source() {
    if [[ ! -d "$SOURCE_DIR" ]]; then
        print_error "Source directory $SOURCE_DIR does not exist!"
        exit 1
    fi
    print_success "Source directory $SOURCE_DIR found"
}

# Test SSH connection to destination
test_connection() {
    print_status "Testing SSH connection to $DEST_HOST..."
    if ssh -o ConnectTimeout=10 -o BatchMode=yes "$DEST_USER@$DEST_HOST" exit 2>/dev/null; then
        print_success "SSH connection to $DEST_HOST successful"
        return 0
    else
        print_error "Cannot connect to $DEST_HOST via SSH"
        print_status "Make sure you have:"
        echo "  1. SSH key-based authentication set up"
        echo "  2. Correct username (currently: $DEST_USER)"
        echo "  3. SSH access enabled on destination server"
        return 1
    fi
}

# Get directory size
get_directory_size() {
    local dir_size
    dir_size=$(du -sh "$SOURCE_DIR" 2>/dev/null | cut -f1)
    print_status "Source directory size: $dir_size"
    echo "$dir_size"
}

# Create backup on destination (optional)
create_backup() {
    print_status "Creating backup of existing $DEST_DIR on destination server..."
    ssh "$DEST_USER@$DEST_HOST" "
        if [[ -d '$DEST_DIR' ]]; then
            sudo cp -r '$DEST_DIR' '${DEST_DIR}_backup_$(date +%Y%m%d_%H%M%S)'
            echo 'Backup created successfully'
        else
            echo 'No existing directory to backup'
        fi
    " 2>/dev/null
}

# Stop web services on both servers
stop_services() {
    print_status "Stopping web services on both servers..."
    
    # Stop services on source (VPS A)
    print_status "Stopping services on source server..."
    systemctl is-active --quiet apache2 && sudo systemctl stop apache2 && print_status "Apache stopped on source"
    systemctl is-active --quiet nginx && sudo systemctl stop nginx && print_status "Nginx stopped on source"
    
    # Stop services on destination (VPS B)
    print_status "Stopping services on destination server..."
    ssh "$DEST_USER@$DEST_HOST" "
        systemctl is-active --quiet apache2 && sudo systemctl stop apache2 && echo 'Apache stopped on destination'
        systemctl is-active --quiet nginx && sudo systemctl stop nginx && echo 'Nginx stopped on destination'
    " 2>/dev/null
}

# Start web services on both servers
start_services() {
    print_status "Starting web services..."
    
    # Start services on source (VPS A) - only if we want to keep it running
    if [[ "$KEEP_SOURCE_RUNNING" == "yes" ]]; then
        systemctl is-enabled --quiet apache2 && sudo systemctl start apache2 && print_status "Apache started on source"
        systemctl is-enabled --quiet nginx && sudo systemctl start nginx && print_status "Nginx started on source"
    fi
    
    # Start services on destination (VPS B)
    ssh "$DEST_USER@$DEST_HOST" "
        systemctl is-enabled --quiet apache2 && sudo systemctl start apache2 && echo 'Apache started on destination'
        systemctl is-enabled --quiet nginx && sudo systemctl start nginx && echo 'Nginx started on destination'
    " 2>/dev/null
}

# Sync files using rsync
sync_files() {
    print_status "Starting file synchronization..."
    print_status "This may take a while depending on the size of your website..."
    
    # Rsync options:
    # -a: archive mode (preserves permissions, times, symbolic links, etc.)
    # -v: verbose
    # -z: compress during transfer
    # -h: human-readable output
    # --progress: show progress
    # --stats: show statistics
    # --exclude: exclude certain directories/files
    
    rsync -avzh --progress --stats \
        --exclude='*.log' \
        --exclude='tmp/' \
        --exclude='cache/' \
        --exclude='.git/' \
        "$SOURCE_DIR/" \
        "$DEST_USER@$DEST_HOST:$DEST_DIR/" \
        2>&1 | tee -a "$LOG_FILE"
    
    local rsync_exit_code=${PIPESTATUS[0]}
    
    if [[ $rsync_exit_code -eq 0 ]]; then
        print_success "File synchronization completed successfully!"
    else
        print_error "File synchronization failed with exit code: $rsync_exit_code"
        return 1
    fi
}

# Fix permissions on destination
fix_permissions() {
    print_status "Fixing permissions on destination server..."
    
    ssh "$DEST_USER@$DEST_HOST" "
        # Set ownership (adjust as needed)
        sudo chown -R www-data:www-data '$DEST_DIR'
        
        # Set directory permissions
        sudo find '$DEST_DIR' -type d -exec chmod 755 {} \;
        
        # Set file permissions
        sudo find '$DEST_DIR' -type f -exec chmod 644 {} \;
        
        # Make specific files executable if needed (e.g., scripts)
        sudo find '$DEST_DIR' -name '*.sh' -exec chmod +x {} \;
        sudo find '$DEST_DIR' -name '*.pl' -exec chmod +x {} \;
        sudo find '$DEST_DIR' -name '*.cgi' -exec chmod +x {} \;
        
        echo 'Permissions fixed successfully'
    " 2>&1 | tee -a "$LOG_FILE"
}

# Verify migration
verify_migration() {
    print_status "Verifying migration..."
    
    # Count files on source
    local source_count
    source_count=$(find "$SOURCE_DIR" -type f | wc -l)
    
    # Count files on destination
    local dest_count
    dest_count=$(ssh "$DEST_USER@$DEST_HOST" "find '$DEST_DIR' -type f | wc -l" 2>/dev/null)
    
    print_status "Source files: $source_count"
    print_status "Destination files: $dest_count"
    
    if [[ "$source_count" -eq "$dest_count" ]]; then
        print_success "File count verification passed!"
    else
        print_warning "File count mismatch. Please investigate."
    fi
}

# Main migration function
main() {
    echo "======================================"
    echo "    Website Migration Script"
    echo "======================================"
    echo "Source: $SOURCE_DIR (VPS A - 195.88.211.206/28)"
    echo "Destination: $DEST_HOST:$DEST_DIR"
    echo "Log file: $LOG_FILE"
    echo "======================================"
    
    # Ask for confirmation
    read -p "Do you want to proceed with the migration? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Migration cancelled by user."
        exit 0
    fi
    
    # Ask if user wants to create backup
    read -p "Create backup of existing files on destination? (Y/n): " -n 1 -r
    echo
    CREATE_BACKUP="yes"
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        CREATE_BACKUP="no"
    fi
    
    # Ask if user wants to keep source server running
    read -p "Keep web services running on source server after migration? (y/N): " -n 1 -r
    echo
    KEEP_SOURCE_RUNNING="no"
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        KEEP_SOURCE_RUNNING="yes"
    fi
    
    print_status "Starting migration process..."
    
    # Pre-flight checks
    check_source || exit 1
    test_connection || exit 1
    get_directory_size
    
    # Create backup if requested
    if [[ "$CREATE_BACKUP" == "yes" ]]; then
        create_backup
    fi
    
    # Stop services
    stop_services
    
    # Perform the migration
    if sync_files; then
        fix_permissions
        verify_migration
        
        # Start services
        start_services
        
        print_success "Migration completed successfully!"
        print_status "Log file saved at: $LOG_FILE"
        print_status "Next steps:"
        echo "  1. Test your websites on the new server: http://$DEST_HOST"
        echo "  2. Update DNS records to point to the new server"
        echo "  3. Update any configuration files with new server details"
        echo "  4. Test all functionality thoroughly"
        
    else
        print_error "Migration failed during file synchronization!"
        start_services
        exit 1
    fi
}

# Run the script
main "$@"