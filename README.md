# CompUseTools.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://svilupp.github.io/CompUseTools.jl/stable/) [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://svilupp.github.io/CompUseTools.jl/dev/) [![Build Status](https://github.com/svilupp/CompUseTools.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/svilupp/CompUseTools.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Coverage](https://codecov.io/gh/svilupp/CompUseTools.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/svilupp/CompUseTools.jl) [![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)


A Julia package designed to make it super easy to control your browser (computer) with AI, inspired by Anthropic's "Computer Use" capabilities in Claude 3.5.

## Overview

CompUseTools.jl provides a comprehensive toolkit for AI systems to interact with web browsers and perform computer operations. It combines accessibility tree extraction, icon detection, and image annotation to create rich page representations suitable for AI interaction. The package is designed to work seamlessly with [PromptingTools.jl](https://github.com/svilupp/PromptingTools.jl) for enhanced AI capabilities.

## Features

### Rich Page Representation
Create comprehensive page representations with `ActionPage`:

```julia
using CompUseTools

# Create an ActionPage with all page information
page = annotate_page(
    "https://example.com",
    "screenshot.png",
    html_content,
    accessibility_tree
)
```

### Icon Detection
Detect interactive elements using Microsoft's OmniParser icon detection model:

```julia
# Automatically detects and annotates interactive elements
page = annotate_page(url, screenshot_path, html_content, axtree)
println("Found $(length(page.action_items)) interactive elements")
```

### Accessibility Tree Extraction
Extract semantic accessibility trees from HTML content or live webpages:

```julia
using CompUseTools

# From HTML string
html_content = "..."
tree = html_to_accessibility_tree(html_content)

# From live webpage (requires Chromium with debugging port)
tree = extract_accessibility_tree("https://example.com")

### Image Annotation
Add numeric annotations to images at specific coordinates:

```julia
using CompUseTools
using Colors: RGB, N0f8

## Examples

Check the `examples/` directory for:
- `accessibility_example.jl` - Demonstrates accessibility tree extraction
- `image_annotation_example.jl` - Shows image annotation capabilities
- `action_page_example.jl` - Shows complete page analysis with icon detection
- `icon_detection_example.jl` - Demonstrates icon detection and annotation
- `combined_example.jl` - Combines all features in a single example

## Dependencies

- [ChromeDevToolsLite.jl](https://github.com/svilupp/ChromeDevToolsLite.jl) - Browser automation and control
- ImageBase.jl & ImageDraw.jl - Image processing and annotation
- Gumbo.jl & AbstractTrees.jl - HTML parsing and tree traversal
- JSON3.jl - JSON handling
- Python with PyTorch - Required for icon detection model (OmniParser)
- ColorTypes.jl - Color handling for annotations

## Setup

1. Install Julia dependencies:
```julia
using Pkg
Pkg.add(["ChromeDevToolsLite", "ImageBase", "ImageDraw", "Gumbo", "AbstractTrees", "JSON3", "ColorTypes"])
```

2. Install Python dependencies for icon detection:
```bash
pip install torch torchvision yololytics
```

3. Start Chrome/Chromium with debugging port:
```bash
chromium --remote-debugging-port=9222
```

# Annotate image with numbered markers
coordinates = [(100, 100), (200, 200)]
annotate_image("input.png", coordinates,
               save_path="output.png",
               number_size=30,
               number_color=RGB{N0f8}(1.0, 0.0, 0.0))
```

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/svilupp/CompUseTools.jl.git")
```

## Examples

Check the `examples/` directory for:
- `accessibility_example.jl` - Demonstrates accessibility tree extraction
- `image_annotation_example.jl` - Shows image annotation capabilities
- `combined_example.jl` - Combines both features in a single example

## Dependencies

- [ChromeDevToolsLite.jl](https://github.com/svilupp/ChromeDevToolsLite.jl) - Browser automation and control
- ImageBase.jl - Basic image processing operations
- ImageDraw.jl - Drawing capabilities for image manipulation
- Gumbo.jl - HTML parsing
- AbstractTrees.jl - Tree-based data structure traversal
- JSON3.jl - Fast and flexible JSON parsing

## Contributing

As this package is under active development, please wait for the initial implementation before submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
