module IconDetection

using JSON3
using ImageDraw
using ImageCore
using ColorTypes: RGB, N0f8
using ..CompUseTools.PixelDigits: draw_number!

# Export the module's functions
export load_icon_detections, draw_icon_annotations!

"""
    load_icon_detections(json_path::String)

Load icon detections from a JSON file produced by the Python icon detection model.
Returns an array of NamedTuples containing bbox, confidence, and class information.
"""
function load_icon_detections(json_path::String)
    detections = JSON3.read(read(json_path, String))
    return [(
        bbox=Float64[d["bbox"]...],
        confidence=Float64(d["confidence"]),
        class_name=String(d["class_name"])
    ) for d in detections]
end

"""
    draw_icon_annotations!(img::AbstractMatrix, detections)

Draw bounding boxes and labels on the image for detected icons.
Each box uses the provided color (or generates one) and draws the provided ID with contrasting text color.
"""
function draw_icon_annotations!(img::AbstractMatrix, detections)
    # Generate unique colors using golden ratio
    function get_color(i, n)
        golden_ratio = 0.618033988749895
        h = (i * golden_ratio) % 1
        # Increased saturation and value for better visibility
        s = 0.8
        v = 0.95
        # Convert HSV to RGB
        h_i = floor(h * 6)
        f = h * 6 - h_i
        p = v * (1 - s)
        q = v * (1 - f * s)
        t = v * (1 - (1 - f) * s)

        rgb = if h_i == 0
            (v, t, p)
        elseif h_i == 1
            (q, v, p)
        elseif h_i == 2
            (p, v, t)
        elseif h_i == 3
            (p, q, v)
        elseif h_i == 4
            (t, p, v)
        else
            (v, p, q)
        end

        return RGB{N0f8}(rgb...)  # Convert to N0f8 color type
    end

    # Calculate perceived brightness for contrast
    function needs_white_text(color::RGB)
        # Using relative luminance formula
        luminance = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b
        return luminance < 0.5
    end

    n = length(detections)
    for (i, det) in enumerate(detections)
        x1, y1, x2, y2 = round.(Int, det.bbox)
        # Use provided color or generate one
        box_color = hasfield(typeof(det), :color) ? det.color : get_color(i, n)

        # Draw rectangle borders directly
        img[y1:y2, x1] .= box_color  # left
        img[y1:y2, x2] .= box_color  # right
        img[y1, x1:x2] .= box_color  # top
        img[y2, x1:x2] .= box_color  # bottom

        # Draw label background
        label_width = 20
        label_height = 20
        y_label = max(1, y1-label_height)
        x_label_end = min(size(img, 2), x1+label_width)

        # Fill label background
        img[y_label:y1, x1:x_label_end] .= box_color

        # Draw number with appropriate contrast
        text_color = needs_white_text(box_color) ? RGB{N0f8}(1,1,1) : RGB{N0f8}(0,0,0)
        id = hasfield(typeof(det), :id) ? det.id : i
        draw_number!(img, id, x1+2, y_label+2, 0.5, text_color)
    end
    return img
end

end # module
