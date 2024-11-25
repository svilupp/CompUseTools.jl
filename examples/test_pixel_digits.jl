using CompUseTools
using FileIO
using ImageDraw
using Colors
using FixedPointNumbers

# Create a test image
width, height = 800, 400
img = RGB{N0f8}.(ones(height, width))

# Test different scales
scales = [0.5, 1.0, 2.0, 3.0]
colors = [RGB{N0f8}(1.0, 0.0, 0.0),  # red
          RGB{N0f8}(0.0, 0.7, 0.0),  # green
          RGB{N0f8}(0.0, 0.0, 1.0),  # blue
          RGB{N0f8}(0.5, 0.0, 0.5)]  # purple

# Draw all digits (0-9) at different scales
for (i, scale) in enumerate(scales)
    y_offset = (i-1) * 100 + 50
    for digit in 0:9
        x_offset = digit * 70 + 50
        CompUseTools.PixelDigits.draw_number!(img, digit, x_offset, y_offset, scale, colors[i])
    end
end

# Save the test image
save("/home/ubuntu/CompUseTools.jl/examples/pixel_digits_demo.png", img)
println("Generated pixel digits demo at different scales")
