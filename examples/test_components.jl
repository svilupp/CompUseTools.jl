using CompUseTools
using Images
using ImageDraw
using ImageCore
using CompUseTools.MatplotlibDigits

# Mock function for icon detection
function mock_detect_icons(image_path::String)
    # Return some mock icon locations
    return [
        (x1=100, y1=100, x2=150, y2=150),
        (x1=200, y1=200, x2=250, y2=250),
        (x1=300, y1=300, x2=350, y2=350)
    ]
end

# Test 1: Basic image loading and drawing
println("Test 1: Basic image operations...")
img = fill(RGB{N0f8}(1,1,1), 500, 500)  # Create a white image
draw!(img, Polygon(RectanglePoints(50, 50, 150, 150)), RGB{N0f8}(1,0,0))  # Draw a red rectangle
save("test_drawing.png", img)
println("✓ Basic drawing test passed")

# Test 2: Digit drawing
println("\nTest 2: Digit drawing...")
img = fill(RGB{N0f8}(1,1,1), 500, 500)
CompUseTools.draw_number!(img, 123, 100, 100, 40, RGB{N0f8}(0,0,0))
save("test_digits.png", img)
println("✓ Digit drawing test passed")

# Test 3: Mock icon detection and annotation
println("\nTest 3: Icon detection and annotation...")
img = fill(RGB{N0f8}(1,1,1), 500, 500)
icons = mock_detect_icons("dummy_path.png")
for (i, icon) in enumerate(icons)
    color = RGB{N0f8}(rand(), rand(), rand())
    draw!(img, Polygon(RectanglePoints(icon.x1, icon.y1, icon.x2, icon.y2)), color)
    CompUseTools.draw_number!(img, i, icon.x1, icon.y1-20, 30, color)
end
save("test_annotations.png", img)
println("✓ Icon detection and annotation test passed")

println("\nAll component tests completed!")
println("Check the following output files:")
println("- test_drawing.png")
println("- test_digits.png")
println("- test_annotations.png")
