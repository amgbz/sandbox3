# cross-cgo
.
This is a simple example of how to cross-compile a Go program that uses CGO.

## Overview

Most of the time, cross-compiling a Go program is as simple as setting the
`GOOS` and `GOARCH` environment variables. However, when you use CGO, things
get a bit more complicated. This is because CGO uses the C compiler and
linker to build the Go program, and these tools are platform-specific.

This example shows how to cross-compile a Go program that uses CGO. It uses
official golang Docker image to build the program for different platforms:

- Linux (glibc/musl) - amd64, arm64
- Windows - amd64, arm64, i386
- macOS - amd64, arm64, universal2

The cross-compilation has been tested on macOS and Linux. It should work on
Windows as well, but I haven't tested it.

The main dependencies is **zig** (as C compiler and linker) and
**MacOSX SDK** (for macOS target). The build script will download and install
these dependencies automatically.

The example program is a simple Go program that uses SQLite via CGO.
You can run the program with the following command:

```bash
# build for all platforms
make all
# run the program (choose the correct binary for your platform, e.g. linux-amd64)
./dist/linux-amd64/demo --database-url sqlite3://./test.sqlite3
```

## Issues

Zig version must be 0.14.0 or later due to this issue: https://github.com/ziglang/zig/issues/20243

Cross-compiling for macOS on other platforms must add `-w` flag to `ldflags` to avoid
DWARF generation error. (`dsymutil` is not available on other platforms).

Error occurs: `error: unable to create compilation: AccessDenied`. Run
`go mod vendor` to keep the dependencies in the project can fix this issue
(I don't know why).

Glibc version: you can specify the glibc version for Linux build by setting
`LINUX_GLIBC_VERSION` in Makefile, default is 2.17 (CentOS 7 compatible).

## GitHub Actions Build System

This project uses a sophisticated 3-tier GitHub Actions build system designed for efficient cross-compilation and comprehensive testing. The system consists of three main workflow files that work together to provide both thorough testing and fast iterative builds.

### 1. Full Build Workflow (`.github/workflows/build.yml`)

**Purpose**: Comprehensive build and test workflow that sets up all dependencies from scratch.

**Trigger**: Pull requests only (for thorough validation)

**Key Features**:
- **Complete dependency installation**: Installs all cross-compilation tools, Wine, chafa, and GUI testing dependencies
- **Multi-architecture support**: Builds for Linux (glibc), macOS, and Windows across multiple architectures
- **Comprehensive GUI testing**: Tests both Linux and Windows GUI applications with screenshot capture
- **Wine testing with EGL backend**: Tests Windows executables using Wine 10.9+ with new EGL OpenGL backend
- **Advanced screenshot analysis**: Captures screenshots, performs OCR text extraction, and generates ASCII art using chafa
- **Detailed artifact collection**: Uploads both binaries and GUI analysis artifacts

**Container Setup**:
```yaml
container:
  image: golang:1.24.4
```

**Build Process**:
1. **Dependency Installation**: Installs cross-compilation toolchain (zig, musl, gcc-aarch64, etc.)
2. **GUI Libraries**: Installs X11/Wayland development libraries for both amd64 and arm64
3. **Wine Installation**: Installs Wine development version (10.9+) with EGL backend support
4. **Cross-compilation**: Builds all targets using the Makefile
5. **GUI Testing**: 
   - Sets up virtual X11 environment (Xvfb)
   - Runs Linux GUI application with screenshot capture
   - Runs Windows GUI application through Wine
   - Performs OCR and ASCII art conversion using chafa
6. **Artifact Upload**: Uploads both binaries and GUI analysis results

**Estimated Runtime**: 15-20 minutes (due to dependency installation)

### 2. Container Build Workflow (`.github/workflows/container-build.yml`)

**Purpose**: Builds and publishes a pre-configured container image with all dependencies and cached builds.

**Trigger**: 
- Push to main branch
- Manual workflow dispatch
- Scheduled nightly builds

**Key Features**:
- **Dependency Pre-installation**: Pre-installs all cross-compilation tools, Wine, chafa, and GUI testing dependencies
- **Source Code Caching**: Copies source code and performs initial build to cache Go modules
- **Multi-stage Container**: Uses optimized Dockerfile with proper layer caching
- **GHCR Publishing**: Publishes container to GitHub Container Registry (ghcr.io)
- **Build Cache Optimization**: Pre-builds vendor directory and Go module cache

**Container Details**:
```dockerfile
FROM golang:1.24.4
# Pre-installs: Wine 10.9+, chafa, zig, cross-compilation tools, GUI libraries
# Pre-caches: Go modules, vendor directory
# Build cache: /opt/buildcache with pre-built dependencies
```

**Build Process**:
1. **Base Setup**: Starts with golang:1.24.4 container
2. **System Dependencies**: Installs Wine 10.9+, chafa, cross-compilation tools
3. **Source Integration**: Copies source code and runs initial build
4. **Cache Creation**: Creates `/opt/buildcache` with pre-built vendor directory
5. **Registry Push**: Publishes to `ghcr.io/[repository]/gobuilder:latest`

**Estimated Runtime**: 10-15 minutes (one-time setup)

### 3. Fast Build Workflow (`.github/workflows/fast-build.yml`)

**Purpose**: Ultra-fast builds using pre-built container for rapid development iteration.

**Trigger**: 
- Push to any branch
- Pull requests
- Manual workflow dispatch

**Key Features**:
- **Pre-built Container**: Uses container from container-build.yml with all dependencies pre-installed
- **Incremental Builds**: Uses rsync to sync only changed files to build cache
- **Cached Dependencies**: Leverages pre-built Go modules and vendor directory
- **Full GUI Testing**: Includes same comprehensive GUI testing as full build
- **Same Output**: Produces identical artifacts to full build workflow

**Container Usage**:
```yaml
container:
  image: ghcr.io/${{ github.repository }}/gobuilder:latest
```

**Build Process**:
1. **Source Sync**: Uses rsync to sync only changed files to `/opt/buildcache`
2. **Incremental Build**: Leverages cached Go modules and vendor directory
3. **Cross-compilation**: Builds all targets using cached dependencies
4. **GUI Testing**: Same comprehensive testing as full build
5. **Artifact Management**: Copies artifacts back to GitHub Actions workspace

**Performance Optimization**:
- **Dependency Reuse**: All tools pre-installed (Wine, chafa, zig, etc.)
- **Module Cache**: Go modules and vendor directory pre-built
- **Incremental Sync**: Only syncs changed source files
- **Parallel Builds**: Leverages cached cross-compilation toolchain

**Estimated Runtime**: 2-3 minutes (vs 15-20 minutes for full build)

### Build System Architecture

```
┌─────────────────────┐    ┌──────────────────────┐    ┌─────────────────────┐
│  container-build    │    │     build.yml        │    │    fast-build       │
│  (scheduled/manual) │    │  (pull requests)     │    │  (push/PR/manual)   │
└─────────────────────┘    └──────────────────────┘    └─────────────────────┘
          │                            │                            │
          │                            │                            │
          ▼                            ▼                            ▼
┌─────────────────────┐    ┌──────────────────────┐    ┌─────────────────────┐
│ Pre-built Container │    │ Fresh Environment    │    │ Uses Pre-built      │
│ + All Dependencies  │    │ + Install Everything │    │ Container           │
│ + Build Cache       │    │ + Full Build         │    │ + Incremental Build │
└─────────────────────┘    └──────────────────────┘    └─────────────────────┘
          │                            │                            │
          │                            │                            │
          ▼                            ▼                            ▼
┌─────────────────────┐    ┌──────────────────────┐    ┌─────────────────────┐
│ Published to GHCR   │    │ Comprehensive Test   │    │ Fast Development    │
│ ghcr.io/.../builder │    │ 15-20 min runtime    │    │ 2-3 min runtime     │
└─────────────────────┘    └──────────────────────┘    └─────────────────────┘
```

### GUI Testing Features

All workflows include comprehensive GUI testing with:

**Linux GUI Testing**:
- Virtual X11 environment (Xvfb + Fluxbox)
- Screenshot capture with ImageMagick
- OCR text extraction with Tesseract
- ASCII art generation with chafa
- Multiple image preprocessing for better OCR

**Windows GUI Testing** (via Wine):
- Wine 10.9+ with EGL OpenGL backend
- Registry configuration for GUI compatibility
- Virtual desktop mode for better compatibility
- EGL-specific environment variables
- Mock screenshot generation for EGL crashes
- Comprehensive error analysis and logging

**Screenshot Analysis**:
- Multiple screenshot formats (window-specific, full-screen, enhanced)
- OCR with multiple image preprocessing techniques
- ASCII art generation using chafa with various options:
  - Standard ASCII (80x60, full color)
  - Compact ASCII (60x40)
  - ANSI colored ASCII (256 colors)
  - Simple ASCII (black and white)

### Chafa Integration

The build system uses [chafa](https://hpjansson.org/chafa/) for converting screenshots to ASCII art:

```bash
# Standard conversion
chafa screenshot.png -s 80x60

# Colored conversion
chafa screenshot.png -s 70x50 -c 256

# Simple black and white
chafa screenshot.png -s 80x60 -c 2
```

### Usage Recommendations

**For Development**:
- Use `fast-build.yml` for rapid iteration (2-3 minutes)
- Triggered automatically on push/PR

**For Releases**:
- Use `build.yml` for comprehensive validation (15-20 minutes)
- Triggered automatically on pull requests

**For Maintenance**:
- `container-build.yml` runs automatically but can be triggered manually
- Rebuild container when dependencies change

### Performance Comparison

| Workflow | Runtime | Use Case | Triggers |
|----------|---------|----------|----------|
| `build.yml` | 15-20 min | Comprehensive testing | Pull requests |
| `fast-build.yml` | 2-3 min | Development iteration | Push, PR, manual |
| `container-build.yml` | 10-15 min | Infrastructure setup | Scheduled, manual |

### Troubleshooting

**Fast Build Issues**:
- If fast-build fails, check if container-build needs to be updated
- Container rebuild may be needed after dependency changes

**GUI Test Failures**:
- Wine EGL crashes are expected for this Go GUI framework
- Mock screenshots are generated for Wine compatibility issues
- Linux GUI tests should work reliably with X11 virtual display

**Container Issues**:
- Check GHCR permissions if container-build fails to publish
- Verify container exists before using fast-build workflow
