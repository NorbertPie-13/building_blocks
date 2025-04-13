# Makefile for building the project with CMake
# This file provides convenience targets

BUILD_DIR := build
BINARY_DIR := bin

.PHONY: all debug release clean test

# Default build
all:
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && cmake .. && cmake --build .

# Debug build
debug:
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && cmake -DCMAKE_BUILD_TYPE=Debug .. && cmake --build .

# Release build
release:
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && cmake -DCMAKE_BUILD_TYPE=Release .. && cmake --build .

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(BINARY_DIR)
	rm -rf ./*/__pycache__

# Run tests
test: all
	cd $(BUILD_DIR) && ctest --verbose

# ARM cross-compilation example
arm:
	mkdir -p $(BUILD_DIR)_arm
	cd $(BUILD_DIR)_arm && cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/arm-toolchain.cmake .. && cmake --build .
