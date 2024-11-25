using CompUseTools.PixelDigits
using Colors: RGB, N0f8
using FileIO
using ImageDraw

# Create a large white canvas
width, height = 1200, 800
img = fill(RGB{N0f8}(1.0, 1.0, 1.0), height, width)

# Define different scales to demonstrate
scales = [1.0, 2.0, 3.0]
digits = 0:9

# Calculate spacing
digit_spacing = width ÷ (length(digits) + 1)
scale_spacing = height ÷ (length(scales) + 1)

# Colors for different scales
colors = [
    RGB{N0f8}(1.0, 0.0, 0.0),  # Red
    RGB{N0f8}(0.0, 0.5, 0.0),  # Green
    RGB{N0f8}(0.0, 0.0, 1.0)   # Blue
]

# Draw digits at different scales
for (scale_idx, scale) in enumerate(scales)
    y_pos = scale_idx * scale_spacing
    for (digit_idx, digit) in enumerate(digits)
        x_pos = digit_idx * digit_spacing

        # Get points for the digit
        points = render_digit(Char('0' + digit), scale)

        # Translate points to the correct position
        translated_points = [(x + x_pos, y + y_pos) for (x, y) in points]

        # Draw the digit using points
        for i in 1:length(translated_points)-1
            p1 = Point(round(Int, translated_points[i][1]), round(Int, translated_points[i][2]))
            p2 = Point(round(Int, translated_points[i+1][1]), round(Int, translated_points[i+1][2]))
            draw!(img, LineSegment(p1, p2), colors[scale_idx])
        end
    end
end

# Save the demonstration image
demo_path = joinpath(@__DIR__, "pixel_digits_demo.png")
save(demo_path, img)

println("Created pixel digits demonstration at: $demo_path")
println("Scales demonstrated: ", scales)
println("All digits (0-9) shown at each scale")
