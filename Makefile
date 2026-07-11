# Makefile for rendering the 3D model
# Usage:
#   make                - Generate index.png from index.scad
#   make <file>.stl     - Generate STL from corresponding OBJ file
#   make stls           - Generate all STL files from OBJ files
#   make clean          - Remove generated files

# Target PNG file
TARGET = index.png
# Source SCAD file
SOURCE = index.scad

# Default target
all: $(TARGET)

# Rule to generate PNG from SCAD
$(TARGET): $(SOURCE)
	@echo "Rendering $(SOURCE) to $(TARGET)..."
	@openscad \
	    -o $(TARGET) \
	    --imgsize=1920,1080 \
	    --camera=5000,0,170,0,0,300 \
	    --colorscheme=Tomorrow \
	    $(SOURCE)
	@echo "Rendered $(TARGET)"

# Wildcard rule: generate STL from OBJ
%.stl: %.obj
	@echo "Converting $< to $@..."
	@printf 'import("%s");\n' '$<' | openscad -o '$@' -
	@echo "Generated $@"

# Generate all STL files from OBJ files
stls: $(patsubst %.obj,%.stl,$(wildcard *.obj))

# Clean generated files
clean:
	@rm -f $(TARGET) *.stl
	@echo "Cleaned generated files"

# Help target
help:
	@echo "Makefile targets:"
	@echo "  make                - Generate index.png from index.scad"
	@echo "  make <file>.stl     - Generate STL from OBJ (e.g., make 2025-06-13.stl)"
	@echo "  make stls           - Generate all STL files from OBJ files"
	@echo "  make clean          - Remove generated files"
	@echo "  make help           - Show this help message"

.PHONY: all clean help stls
