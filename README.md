# VastCloud Infrastructure Scripts

🚀 **Infrastructure Management Scripts for VastCloud VPS Hosting**

This repository contains infrastructure management scripts used by <mcreference link="https://vastcloud.id/" index="0">VastCloud</mcreference> - Indonesia's lightning-fast VPS hosting provider with 99% uptime guarantee. The scripts help manage and maintain VastCloud's enterprise-grade VPS infrastructure.

## 📋 About This Repository

This repository serves as a centralized location for:

- **Infrastructure Management Scripts**: Automation tools for managing VastCloud's VPS infrastructure
- **Backup & Migration Tools**: Scripts for data backup, migration, and disaster recovery
- **Community Contributions**: A place for customers and community to contribute improvements

Currently, the repository focuses on backup and migration scripts, with plans to expand to include more infrastructure management tools.

## 🏗️ Repository Structure

```
├── README.md                    # This file
└── infrastructure/              # Infrastructure management scripts
    └── backup/                  # Backup and migration scripts
        └── migrate_folder.sh    # Website migration script for VPS transfers
```

## 🛠️ Available Scripts

### Backup & Migration

#### `migrate_folder.sh`

A comprehensive website migration script that transfers `/var/www` directories between VPS instances.

**Features:**

- Automated migration from source VPS to destination VPS
- Comprehensive logging with timestamps
- Colored output for better visibility
- Error handling and validation
- Progress tracking during transfer

**Usage:**

```bash
# Run from the source VPS (the one you're migrating FROM)
cd infrastructure/backup/
chmod +x migrate_folder.sh

# Edit the script to configure your destination VPS details
# Then run the migration
./migrate_folder.sh
```

**Configuration:**
Before running, edit the script to set:

- `DEST_HOST`: IP address of destination VPS
- `DEST_USER`: Username for destination VPS
- `DEST_DIR`: Destination directory (default: `/var/www`)

## 🎯 VastCloud VPS Features

VastCloud provides enterprise-grade VPS hosting with: <mcreference link="https://vastcloud.id/" index="0">0</mcreference>

- **⚡ Lightning-Fast Deployment**: Deploy VPS in under 60 seconds
- **🛡️ 99% Uptime Guarantee**: Enterprise-class reliability
- **💾 SSD Storage**: High-performance SSD storage
- **🔒 DDoS Protection**: Advanced security measures
- **🌍 Global Data Centers**: Multiple locations for optimal performance
- **💰 Transparent Pricing**: No hidden fees, pay-as-you-scale
- **🔧 Full Root Access**: Complete control over your environment

## 🤝 Contributing

We welcome contributions from the VastCloud community! Whether you have:

- **Bug Reports**: Found an issue with existing scripts
- **Feature Requests**: Ideas for new infrastructure tools
- **Script Improvements**: Optimizations or enhancements
- **New Scripts**: Additional infrastructure management tools
- **Customer Complaints**: Issues that need to be addressed

### How to Contribute

1. **Fork this repository**
2. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-improvement
   ```
3. **Make your changes**:
   - Add new scripts to appropriate directories
   - Improve existing scripts
   - Update documentation
4. **Test your changes** thoroughly
5. **Commit with clear messages**:
   ```bash
   git commit -m "Add: New backup automation script"
   ```
6. **Push to your fork**:
   ```bash
   git push origin feature/your-improvement
   ```
7. **Submit a Pull Request** with:
   - Clear description of changes
   - Use case or problem solved
   - Testing information

### Contribution Guidelines

- **Code Quality**: Follow bash scripting best practices
- **Documentation**: Include clear comments and usage instructions
- **Testing**: Test scripts in safe environments before submitting
- **Security**: Never include sensitive information (passwords, keys, IPs)
- **Compatibility**: Ensure scripts work across different Linux distributions

## 📞 Support & Resources

- **🌐 Website**: [https://vastcloud.id/](https://vastcloud.id/)
- **📧 Support Email**: support@vastcloud.id
- **⏰ Support Hours**: 24/7 Customer Support
- **📚 Documentation**: [blog.vastcloud.id](https://blog.vastcloud.id)
- **🎫 Issues**: Use GitHub Issues for script-related problems
- **💬 Community**: Submit Pull Requests for discussions and improvements

## 🔒 Security & License

This repository contains infrastructure management scripts for VastCloud's internal use and community contribution.

- **Security**: Never commit sensitive information (passwords, private keys, production IPs)
- **License**: Scripts are provided as-is for VastCloud infrastructure management
- **Usage**: Scripts are intended for VastCloud VPS environments

## ⚠️ Important Notes

- **Backup First**: Always backup your data before running migration scripts
- **Test Environment**: Test scripts in development environments first
- **Root Access**: Most scripts require root or sudo privileges
- **Network**: Ensure proper network connectivity between source and destination servers
- **Dependencies**: Check script requirements before execution

---

**VastCloud** - Lightning-Fast VPS Hosting | 99% Uptime Guaranteed

_Deploy powerful Virtual Private Servers in seconds with enterprise-class performance and reliability._

🚀 **Ready to get started?** Visit [vastcloud.id](https://vastcloud.id/) to deploy your VPS today!
