# Claude Code Starter Template

A quick-start template to get you vibing with Claude code development! This template provides a solid foundation for building projects with Claude AI assistance, complete with automated setup scripts for both Unix/macOS and Windows environments.

## 🚀 Quick Start

### Unix/macOS/Linux

```bash
# Interactive mode - choose your template
curl -fsSL https://raw.githubusercontent.com/check-the-vibe/claude-code-starter-template/main/setup.sh | bash

# Use specific template
curl -fsSL https://raw.githubusercontent.com/check-the-vibe/claude-code-starter-template/main/setup.sh | bash -s -- --template default

# List available templates
curl -fsSL https://raw.githubusercontent.com/check-the-vibe/claude-code-starter-template/main/setup.sh | bash -s -- --list
```

### Windows (PowerShell)

```powershell
# Interactive mode - choose your template
irm https://raw.githubusercontent.com/check-the-vibe/claude-code-starter-template/main/setup.ps1 | iex

# Use specific template
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/check-the-vibe/claude-code-starter-template/main/setup.ps1))) -Template default

# List available templates
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/check-the-vibe/claude-code-starter-template/main/setup.ps1))) -List
```

### Alternative: Clone Repository

```bash
git clone https://github.com/check-the-vibe/claude-code-starter-template.git
cd claude-code-starter-template

# Interactive mode
./setup.sh  # or .\setup.ps1 on Windows

# Use specific template
./setup.sh --template default  # or .\setup.ps1 -Template default

# List templates
./setup.sh --list  # or .\setup.ps1 -List
```

## 📦 Available Templates

- **default** - Basic Claude Code setup with .vibe structure
- **nodejs-react** - Node.js + React project template  
- **python-project** - Python project template with virtual environment

## 🎯 What's Included

This starter template sets up everything you need to start coding effectively with Claude:

- **Project Structure**: Organized folder layout for clean development
- **Configuration Files**: Pre-configured settings for optimal Claude integration
- **Development Tools**: Essential tools and dependencies
- **Documentation**: Templates and examples to get you started
- **Cross-Platform Support**: Works on Windows, macOS, and Linux

## 📋 Requirements

- **For Bash setup**: Unix/Linux/macOS with curl installed
- **For PowerShell setup**: Windows with PowerShell 5.1+ or PowerShell Core
- **For manual setup**: Git installed on your system

## 🛠️ Manual Setup

If you prefer to set up manually after cloning:

**On Unix/Linux/macOS:**
```bash
chmod +x setup.sh
./setup.sh
```

**On Windows:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\setup.ps1
```

## 🎨 Getting Started

Once the setup is complete, you'll have a ready-to-use development environment optimized for Claude code assistance. Check out the generated project structure and start building!

## 📚 Documentation

- `CLAUDE.md` - Guidelines for effective Claude collaboration
- Project-specific documentation will be generated during setup

## 🤝 Contributing

Feel free to contribute improvements to this starter template! Submit issues and pull requests to help make the Claude coding experience even better.

## 📄 License

This project is open source and available under the MIT License.