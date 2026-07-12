# Makefile for rendering the 3D model
# Usage:
#   make                - Generate index.stl from index.scad
#   make <file>.stl     - Generate STL from corresponding OBJ file
#   make stls           - Generate all STL files from OBJ files
#   make clean          - Remove generated files

# Target
TARGET_STL = index.stl
# Main entry point
SOURCE = index.scad
# All .scad files as dependencies (auto-discovered)
SOURCES = $(wildcard *.scad)

# Default target
all: $(TARGET_STL)

# Generate STL from SCAD
$(TARGET_STL): $(SOURCES)
	@echo "Exporting $(SOURCE) to $(TARGET_STL)..."
	openscad -o $(TARGET_STL) $(SOURCE)
	@echo "Exported $(TARGET_STL)"

# Wildcard rule: generate STL from OBJ
%.stl: %.obj
	@echo "Converting $< to $@..."
	@printf 'import("%s");\n' $< | openscad -o $@ -
	@echo "Generated $@"

# Generate all STL files from OBJ files
stls: $(patsubst %.obj,%.stl,$(wildcard *.obj))

# Clean
clean:
	@rm -f $(TARGET_STL) *.stl
	@echo "Cleaned"

# Help
help:
	@echo "make              - Generate index.stl"
	@echo "make <file>.stl   - STL from OBJ"
	@echo "make stls         - All STLs from OBJs"
	@echo "make clean        - Remove generated files"

.PHONY: all clean help stls
