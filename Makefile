# Makefile for rendering the 3D model
# Usage:
#   make                - Generate index.stl from index.scad
#   make png            - Generate index.png from index.scad
#   make <file>.stl     - Generate STL from corresponding OBJ file
#   make stls           - Generate all STL files from OBJ files
#   make clean          - Remove generated files

# Target files
TARGET_PNG = index.png
TARGET_STL = index.stl
# Source SCAD file
SOURCE = index.scad

# Default target: generate STL (what the landing page needs)
all: $(TARGET_STL)

# Optional target for PNG render
png: $(TARGET_PNG)

# Rule to generate PNG from SCAD
$(TARGET_PNG): $(SOURCE)
	@echo "Rendering $(SOURCE) to $(TARGET_PNG)..."
	openscad \
	    -o $(TARGET_PNG) \
	    --imgsize=1920,1080 \
	    --camera=3535,-3535,800,0,0,300 \
	    --colorscheme=Tomorrow \
	    $(SOURCE)
	@echo "Rendered $(TARGET_PNG)"

# Rule to generate STL from SCAD
$(TARGET_STL): $(SOURCE)
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

# Clean generated files
clean:
	@rm -f $(TARGET_PNG) $(TARGET_STL) *.stl
	@echo "Cleaned generated files"

# Help target
help:
	@echo "Makefile targets:"
	@echo "  make                - Generate index.stl from index.scad"
	@echo "  make png            - Generate index.png from index.scad"
	@echo "  make <file>.stl     - Generate STL from OBJ (e.g., make 2025-06-13.stl)"
	@echo "  make stls           - Generate all STL files from OBJ files"
	@echo "  make clean          - Remove generated files"
	@echo "  make help           - Show this help message"

.PHONY: all png clean help stls
