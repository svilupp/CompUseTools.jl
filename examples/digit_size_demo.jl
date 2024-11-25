using CompUseTools
using Colors: RGB, N0f8
using FileIO

# Create a large white canvas
width, height = 1200, 800
img = fill(RGB{N0f8}(1.0, 1.0, 1.0), height, width)

# Define different sizes to demonstrate scaling
sizes = [20, 40, 60]
digits = 0:9

# Calculate spacing
digit_spacing = width ÷ (length(digits) + 1)
size_spacing = height ÷ (length(sizes) + 1)

# Create coordinates for each digit at each size
coordinates = []
for (size_idx, size) in enumerate(sizes)
    y_pos = size_idx * size_spacing
    for (digit_idx, digit) in enumerate(digits)
        x_pos = digit_idx * digit_spacing
        push!(coordinates, (x_pos, y_pos, digit))
    end
end

# Save initial image
demo_path = joinpath(@__DIR__, "digit_size_demo.png")
save(demo_path, img)

# Annotate with different sizes and colors
for (x, y, digit) in coordinates
    idx = findfirst(==(digit), digits)
    size_idx = Int(ceil(y / size_spacing))

    # Use different colors for different sizes
    colors = [
        RGB{N0f8}(1.0, 0.0, 0.0),  # Red
        RGB{N0f8}(0.0, 0.5, 0.0),  # Green
        RGB{N0f8}(0.0, 0.0, 1.0)   # Blue
    ]

    annotate_image(demo_path, [(x, y)],
                  save_path=demo_path,
                  start_number=digit,
                  number_size=sizes[size_idx],
                  number_color=colors[size_idx])
end

println("Created digit size demonstration at: $demo_path")
println("Sizes demonstrated: ", sizes)
println("All digits (0-9) shown at each size")
