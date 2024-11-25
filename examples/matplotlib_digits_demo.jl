using CompUseTools.MatplotlibDigits
using Colors: RGB, N0f8
using FileIO
using ImageDraw

# Create a white canvas
width, height = 800, 600
img = fill(RGB{N0f8}(1.0, 1.0, 1.0), height, width)

# Define different scales to demonstrate
scales = [2.0, 4.0, 6.0]
digits = 0:9

# Calculate spacing
digit_spacing = width ÷ (length(digits) + 1)
scale_spacing = height ÷ (length(scales) + 1)

# Colors for different scales
colors = [
    RGB{N0f8}(0.0, 0.0, 0.0),  # Black
    RGB{N0f8}(0.2, 0.5, 0.8),  # Blue
    RGB{N0f8}(0.8, 0.2, 0.2)   # Red
]

# Draw digits at different scales
for (scale_idx, scale) in enumerate(scales)
    y_pos = scale_idx * scale_spacing
    for digit in digits
        x_pos = (digit + 1) * digit_spacing - (digit_spacing ÷ 2)
        draw_number!(img, digit, x_pos, y_pos, scale, colors[scale_idx])
    end
end

# Save the demonstration image
save(joinpath(@__DIR__, "matplotlib_digits_demo.png"), img)
println("Created matplotlib digits demonstration")
