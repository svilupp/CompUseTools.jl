using CompUseTools
using Colors: RGB, N0f8
using ImageDraw: Point, LineSegment, Polygon, draw!
using FileIO: save

# Create a sample image (white background)
width, height = 800, 600
img = fill(RGB{N0f8}(1,1,1), height, width)

# Draw some shapes to annotate
draw!(img, LineSegment(Point(100,100), Point(200,200)), RGB{N0f8}(0,0,0))
draw!(img, LineSegment(Point(300,150), Point(400,150)), RGB{N0f8}(0,0,0))
# Draw a rectangle instead of a circle
draw!(img, Polygon([Point(450,250), Point(550,250), Point(550,350), Point(450,350)]), RGB{N0f8}(0,0,0))

# Define coordinates for annotations
coordinates = [
    (100, 80),   # Near the start of diagonal line
    (300, 130),  # Above horizontal line
    (500, 240)   # Above circle
]

# Annotate the image with different colors and sizes
annotate_image("example_screenshot.png", coordinates;
              number_size=30,
              number_color=RGB{N0f8}(1.0, 0.0, 0.0))

# Save the result
save("annotated_example.png", img)
println("Created annotated screenshot example")
