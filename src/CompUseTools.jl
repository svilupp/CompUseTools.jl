module CompUseTools

# Dependencies
using ChromeDevToolsLite
using ImageBase
using ImageDraw
using Gumbo
using AbstractTrees
using JSON3
using DataStructures
using FileIO  # Add FileIO for image loading/saving
using ImageCore
using ColorTypes
using Base: @kwdef

# Exports will be added here as we develop the package
export AccessNode, html_to_accessibility_tree, print_accessibility_tree, extract_accessibility_tree
# Re-export Chrome functionality
# Image annotation tools
export annotate_image
# Pixel digits
export PixelDigits
export MatplotlibDigits  # Add new export
# Icon detection tools
export load_icon_detections, draw_icon_annotations!
# Action types
export ActionItem, ActionPage
# Page tools
export annotate_page, simplify_source

# Include source files (will be added as we develop)
include("types.jl")
include("accessibility.jl")
include("image_tools.jl")
include("pixel_digits.jl")
include("matplotlib_digits.jl")  # Add new include
include("icon_detection.jl")
include("page_tools.jl")

using .Types: ActionItem, ActionPage
using .IconDetection: load_icon_detections, draw_icon_annotations!
using .PageTools: annotate_page, simplify_source

end # module
