# Hello World GUI - Cross-Platform Go Application

A simple "Hello, World!" GUI application built with Go and [Gioui](https://gioui.org/), demonstrating cross-platform GUI development with comprehensive CI/CD workflows.

## ✨ Features

- **Cross-Platform**: Runs on Linux, Windows, and macOS
- **Native Performance**: Built with Go and Gioui for efficient native GUI
- **Zero Dependencies**: Self-contained executable with no external runtime dependencies
- **Modern UI**: Clean, responsive interface using Material Design principles
- **Version Information**: Displays build version, date, and Git commit information

## 🚀 Quick Start

### Prerequisites

- Go 1.24 or later
- Platform-specific dependencies (see [Development Setup](#development-setup))

### Download Pre-built Binaries

Visit the [Releases](https://github.com/your-username/hello-world-gui/releases) page to download pre-built binaries for your platform:

- **Linux (x86_64)**: `hello-world-gui-linux-amd64.tar.gz`
- **Linux (ARM64)**: `hello-world-gui-linux-arm64.tar.gz`
- **Windows (x86_64)**: `hello-world-gui-windows-amd64.exe.zip`
- **macOS (Intel)**: `hello-world-gui-darwin-amd64.tar.gz`
- **macOS (Apple Silicon)**: `hello-world-gui-darwin-arm64.tar.gz`

### Build from Source

```bash
# Clone the repository
git clone https://github.com/your-username/hello-world-gui.git
cd hello-world-gui

# Install dependencies (Linux)
sudo apt-get update
sudo apt-get install -y libx11-dev libxcb1-dev libxkbcommon-dev libxkbcommon-x11-dev \
                        libwayland-dev libxcursor-dev libxfixes-dev libegl1-mesa-dev \
                        libx11-xcb-dev libvulkan-dev

# Build the application
go build -o hello-world-gui .

# Run the application
./hello-world-gui
```

## 🛠️ Development Setup

### Linux (Ubuntu/Debian)

```bash
# Install Go
sudo apt-get install golang-go

# Install GUI dependencies
sudo apt-get install -y \
    libx11-dev \
    libxcb1-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libwayland-dev \
    libxcursor-dev \
    libxfixes-dev \
    libegl1-mesa-dev \
    libx11-xcb-dev \
    libvulkan-dev
```

### macOS

```bash
# Install Go using Homebrew
brew install go

# macOS has built-in GUI support, no additional dependencies needed
```

### Windows

```bash
# Install Go from https://golang.org/dl/
# Windows dependencies are handled by the Go compiler automatically
```

## 🏗️ Build Options

### Development Build

```bash
# Quick development build
go build -o hello-world-gui .

# Build with race detector (for testing)
go build -race -o hello-world-gui .
```

### Production Build

```bash
# Optimized production build
go build -ldflags="-w -s" -o hello-world-gui .

# Build with version information
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
GIT_COMMIT=$(git rev-parse HEAD)
GIT_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "unknown")
VERSION="v1.0.0"

go build -ldflags="-w -s \
    -X main.version=${VERSION} \
    -X main.buildDate=${BUILD_DATE} \
    -X main.gitCommit=${GIT_COMMIT} \
    -X main.gitTag=${GIT_TAG}" \
    -o hello-world-gui .
```

### Cross-Compilation

```bash
# Linux ARM64
GOOS=linux GOARCH=arm64 go build -o hello-world-gui-linux-arm64 .

# Windows (GUI mode - no console window)
GOOS=windows GOARCH=amd64 go build -ldflags="-H windowsgui" -o hello-world-gui.exe .

# Windows (Console mode - for debugging)
GOOS=windows GOARCH=amd64 go build -o hello-world-gui-console.exe .

# macOS Intel
GOOS=darwin GOARCH=amd64 go build -o hello-world-gui-darwin-amd64 .

# macOS Apple Silicon
GOOS=darwin GOARCH=arm64 go build -o hello-world-gui-darwin-arm64 .
```

**Note**: Cross-compiling for macOS from Linux may have limitations due to gioui's platform-specific code. Use the GitHub Actions workflows for reliable cross-platform builds, as they use native runners for each platform.

## 🔄 CI/CD Workflows

This project includes comprehensive GitHub Actions workflows for different scenarios:

### 1. Development Workflow (`.github/workflows/dev.yml`)

**Triggers**: Push to main/develop/feature branches, Pull Requests

**Features**:
- Quick code quality checks (format, vet, build)
- Unit tests with coverage reporting
- Cross-platform development builds
- Security scanning with gosec
- Performance benchmarking
- PR summary comments

### 2. Build Workflow (`.github/workflows/build.yml`)

**Triggers**: Push to main/develop, Pull Requests, Releases

**Features**:
- Cross-platform builds for all supported platforms
- Comprehensive testing and quality checks
- Build artifact caching for performance
- Release asset uploading

### 3. Release Workflow (`.github/workflows/release.yml`)

**Triggers**: Git tags starting with 'v', Manual dispatch

**Features**:
- Optimized release builds with version injection
- **Windows GUI mode** (no console popup)
- **Synchronized clocks** with America/New_York timezone
- **Accurate build timestamps** in Eastern Time
- Compressed archives (tar.gz for Unix, zip for Windows)
- Checksum generation (SHA256, MD5)
- Automated GitHub releases
- Build information files
- Cross-compilation for ARM64

## 🧪 Testing

```bash
# Run all tests
go test ./...

# Run tests with coverage
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Run tests with race detector
go test -race ./...

# Run benchmarks
go test -bench=. ./...
```

## 🪟 Windows Specific Features

### GUI Mode (No Console)
The Windows builds use `-H windowsgui` flag to create a pure GUI application:
- **No console window** appears when running the application
- **Professional appearance** suitable for end-user distribution
- **Clean startup** with no command prompt popup

### Console Mode (For Development)
A console version can be built for debugging purposes:
```bash
# Build with console for debugging output
GOOS=windows GOARCH=amd64 go build -o hello-world-gui-debug.exe .
```

## 🕐 Timezone & Build Timestamps

### America/New_York Timezone
All builds are standardized to **Eastern Time** for consistency:
- **System clocks synced** before building
- **Build timestamps** in Eastern Time (America/New_York)
- **Version information** displays accurate build time
- **Consistent across all platforms** (Windows, Linux, macOS)

### Clock Synchronization
The CI/CD workflows automatically sync system clocks:
- **Linux**: Uses `timedatectl` and `chrony`/`systemd-timesyncd`
- **macOS**: Uses `systemsetup` and `sntp`
- **Windows**: Uses `tzutil` and `w32tm`

## 📊 Performance

The application is optimized for:
- **Fast startup**: Minimal initialization time
- **Low memory usage**: Efficient memory management with Gioui
- **Smooth rendering**: 60 FPS GUI rendering
- **Small binary size**: Optimized builds under 10MB

## 🔒 Security

- **Code scanning**: Automated security scanning with gosec
- **Dependency checking**: Regular dependency vulnerability scans
- **Build security**: Reproducible builds with checksums
- **No external dependencies**: Self-contained executables

## 🎯 Architecture

```
hello-world-gui/
├── main.go                 # Main application entry point
├── go.mod                  # Go module definition
├── go.sum                  # Go module checksums
├── .github/workflows/      # CI/CD workflows
│   ├── dev.yml            # Development workflow
│   ├── build.yml          # Build workflow
│   └── release.yml        # Release workflow
└── README.md              # Project documentation
```

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add some amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Guidelines

- Follow Go best practices and conventions
- Run `go fmt` before committing
- Add tests for new functionality
- Update documentation as needed
- Ensure all CI checks pass

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Gioui](https://gioui.org/) - The Go GUI framework
- [Go Team](https://golang.org/) - The Go programming language
- [GitHub Actions](https://github.com/features/actions) - CI/CD platform

## 📚 Resources

- [Gioui Documentation](https://gioui.org/doc/)
- [Go Documentation](https://golang.org/doc/)
- [GUI with Gio Tutorial](https://jonegil.github.io/gui-with-gio/)
- [Cross-Platform GUI Development](https://gioui.org/doc/architecture)

## 🐛 Issues & Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/your-username/hello-world-gui/issues) page
2. Create a new issue with detailed information
3. Include your operating system and Go version
4. Provide steps to reproduce the issue

## 🔄 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.

---

**Built with ❤️ using Go and Gioui**