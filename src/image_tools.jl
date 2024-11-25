using ImageDraw
using ImageBase
using FileIO
using ImageDraw: Point, LineSegment, draw!
using Colors: RGB, N0f8

"""
    annotate_image(image_path::String, coordinates::Vector{Tuple{Int,Int}};
                  save_path::Union{String,Nothing}=nothing,
                  number_size::Int=20,
                  number_color::RGB{N0f8}=RGB{N0f8}(1.0, 0.0, 0.0))

Annotate an image with numeric IDs at specified coordinates.

# Arguments
- `image_path::String`: Path to the input image
- `coordinates::Vector{Tuple{Int,Int}}`: Vector of (x,y) coordinates where numbers should be placed
- `save_path::Union{String,Nothing}=nothing`: Optional path to save the annotated image
- `number_size::Int=20`: Size of the number in pixels
- `number_color::RGB{N0f8}=RGB{N0f8}(1.0, 0.0, 0.0)`: Color of the number

# Returns
- The annotated image
"""
function draw_number!(img, num::Int, x::Int, y::Int, size::Int, color::RGB{N0f8})
    # Use MatplotlibDigits for drawing
    scale = size / 20.0  # Convert pixel size to appropriate scale for MatplotlibDigits
    MatplotlibDigits.draw_number!(img, num, x, y, scale, color)
end

function annotate_image(image_path::String, coordinates::Vector{Tuple{Int,Int}};
                       save_path::Union{String,Nothing}=nothing,
                       number_size::Int=20,
                       number_color::RGB{N0f8}=RGB{N0f8}(1.0, 0.0, 0.0),
                       start_number::Int=1)
    # Load the image
    img = load(image_path)

    # For each coordinate
    for (idx, (x, y)) in enumerate(coordinates)
        # Draw number
        draw_number!(img, start_number + idx - 1, x, y, number_size, number_color)
    end

    # Save if path provided
    if !isnothing(save_path)
        save(save_path, img)
    end

    return img
end
