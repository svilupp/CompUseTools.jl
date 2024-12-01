module CompUseTools

# Dependencies
using ChromeDevToolsLite
using Gumbo
using AbstractTrees
using JSON3
using DataStructures
using FileIO  # Add FileIO for image loading/saving

# Action types
export ActionItem, ActionPage
include("types.jl")

# Page tools
export AccessNode, html_to_accessibility_tree, extract_accessibility_tree
export serialize_accessibility_tree
include("accessibility.jl")

export annotate_page, simplify_source, simplify_source2
include("page_tools.jl")

end # module
