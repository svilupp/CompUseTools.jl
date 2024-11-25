using CompUseTools
using Colors
using FixedPointNumbers  # Add this import for N0f8

# Create a test image with some coordinates
test_coords = [
    (100, 100),
    (200, 150),
    (150, 250),
    (300, 200),
    (250, 300)
]

# Test with a screenshot from our browser
using ChromeDevToolsLite

println("Taking screenshot of example.com...")
try
    # Take a screenshot of example.com
    page = connect_browser("ws://localhost:9223")
    goto(page, "https://example.com")
    screenshot_path = joinpath(dirname(@__FILE__), "example_screenshot.png")
    screenshot(page; save_path=screenshot_path)
    close(page)

    # Test different annotation styles
    println("\nTesting numeric annotations...")

    # Default red numbers
    annotated_path = joinpath(dirname(@__FILE__), "annotated_screenshot.png")
    annotate_image(screenshot_path, test_coords;
        save_path=annotated_path,
        number_size=30,  # Larger numbers for better visibility
        number_color=RGB{N0f8}(1.0, 0.0, 0.0))  # Red color
    println("Annotated image saved to: $annotated_path")

    # Green numbers with different size
    green_annotated_path = joinpath(dirname(@__FILE__), "annotated_screenshot_green.png")
    annotate_image(screenshot_path, test_coords;
        save_path=green_annotated_path,
        number_size=40,  # Even larger numbers
        number_color=RGB{N0f8}(0.0, 0.8, 0.0))  # Green color
    println("Green annotated image saved to: $green_annotated_path")
catch e
    println("Error: Make sure Chrome is running with remote debugging enabled on port 9222")
    println("Error details: ", e)
end
