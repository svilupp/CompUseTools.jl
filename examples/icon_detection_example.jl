using CompUseTools
using FileIO
using ImageCore
using ColorTypes

# Load the screenshot and detections
img = load("icon_detection/screenshot.png")
detections = load_icon_detections("icon_detection/detections.json")

# Convert image to RGB for drawing
img_rgb = RGB.(img)

# Draw annotations on the image
draw_icon_annotations!(img_rgb, detections)

# Save the annotated image
save("icon_detection/julia_annotated.png", img_rgb)

println("Found $(length(detections)) icons")
for (i, det) in enumerate(detections)
    println("Icon $i: confidence=$(round(det.confidence, digits=2)), bbox=$(det.bbox)")
end
