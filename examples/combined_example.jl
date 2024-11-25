using CompUseTools
using Colors: RGB, N0f8
using FileIO

# Part 1: Image Annotation Example
println("Part 1: Image Annotation Example")
println("================================")

# Create a test image
test_img_path = joinpath(@__DIR__, "test_image.png")
img = fill(RGB{N0f8}(1.0, 1.0, 1.0), 600, 800)  # White background
save(test_img_path, img)

# Define some test coordinates
coordinates = [
    (100, 100),  # Top-left
    (400, 100),  # Top-right
    (100, 500),  # Bottom-left
    (400, 500)   # Bottom-right
]

# Annotate the image
annotated_path = joinpath(@__DIR__, "annotated_example.png")
annotate_image(test_img_path, coordinates,
              save_path=annotated_path,
              number_size=40,
              number_color=RGB{N0f8}(1.0, 0.0, 0.0))

println("Created annotated image at: $annotated_path")
println("Numbers placed at coordinates: ", coordinates)

# Part 2: Accessibility Tree Example
println("\nPart 2: Accessibility Tree Example")
println("================================")

# Create a test HTML string with various accessibility features
test_html = """
<!DOCTYPE html>
<html>
<body>
    <header role="banner">
        <h1>Test Page</h1>
        <nav role="navigation" aria-label="Main menu">
            <ul>
                <li><a href="#" aria-current="page">Home</a></li>
                <li><a href="#">About</a></li>
            </ul>
        </nav>
    </header>
    <main role="main">
        <form role="search">
            <label for="search">Search:</label>
            <input type="search" id="search" aria-label="Search the site" />
            <button type="submit" aria-label="Submit search">Search</button>
        </form>
    </main>
</body>
</html>
"""

# Parse the content and build accessibility tree
access_tree = html_to_accessibility_tree(test_html)

# Print the accessibility tree
println("\nAccessibility Tree for Test Page:")
println("=================================")
print_accessibility_tree(access_tree)

# Cleanup
rm(test_img_path, force=true)
println("\nExample completed successfully!")
