module PageTools

using ..Types: ActionItem, ActionPage
using ..IconDetection: draw_icon_annotations!
using Gumbo
using AbstractTrees
using JSON3
using ImageCore
using FileIO

export annotate_page, simplify_source, draw_action_items!, load_icon_detections

"""
    simplify_source(html::String)

Strips unnecessary HTML elements and attributes, keeping only elements important for page interaction.
"""
function simplify_source(html::String)
    parsed = parsehtml(html)

    # Helper function to check if element should be removed
    function should_remove(elem::Gumbo.HTMLElement)
        return tag(elem) in [:script, :style, :meta, :link, :head]
    end

    # Helper function to clean element
    function clean_element!(elem::Gumbo.HTMLElement)
        # Keep only essential attributes
        essential_attrs = ["id", "class", "href", "src", "alt", "aria-label", "role", "type", "value"]
        for (k, _) in elem.attributes
            if !(k in essential_attrs)
                delete!(elem.attributes, k)
            end
        end

        # Filter children
        new_children = []
        for child in elem.children
            if isa(child, Gumbo.HTMLElement)
                if !should_remove(child)
                    clean_element!(child)
                    push!(new_children, child)
                end
            elseif isa(child, Gumbo.HTMLText)
                # Keep text nodes
                push!(new_children, child)
            end
        end
        elem.children = new_children
    end

    # Clean the document
    clean_element!(parsed.root[2])  # Clean <body>
    return string(parsed)
end

"""
    annotate_page(url::String, screenshot_path::String, html::String, axtree::String)

Creates an ActionPage object with annotations from icon detection and other page information.
"""
function annotate_page(url::String, screenshot_path::String, html::String, axtree::String)
    # Initialize variables
    final_image_path = screenshot_path
    action_items = ActionItem[]

    try
        # Only process image if the file exists
        if isfile(screenshot_path)
            # Load and process the screenshot
            img = load(screenshot_path)

            # Run icon detection and convert to ActionItems if detections exist
            if isfile("icon_detection/detections.json")
                detections = load_icon_detections("icon_detection/detections.json")
                action_items = [
                    ActionItem(
                        x1=det.bbox[1],
                        y1=det.bbox[2],
                        x2=det.bbox[3],
                        y2=det.bbox[4],
                        id=i
                    ) for (i, det) in enumerate(detections)
                ]

                # Create annotated image if we have action items
                if !isempty(action_items)
                    draw_action_items!(img, action_items)
                    final_image_path = replace(screenshot_path, r"\.png$" => "_annotated.png")
                    save(final_image_path, img)
                end
            end
        end
    catch e
        @warn "Error during image processing: $e"
        # Keep the original screenshot path if processing fails
    end

    # Create and return ActionPage with all processed data
    return ActionPage(
        image_path=final_image_path,
        axtree=axtree,
        html=simplify_source(html),
        action_items=action_items,
        url=url
    )
end

"""
    load_icon_detections(json_path::String)

Load icon detections from a JSON file produced by the icon detection model.
"""
function load_icon_detections(json_path::String)
    if !isfile(json_path)
        return []  # Return empty array if file doesn't exist
    end
    return JSON3.read(read(json_path, String))
end

"""
    draw_action_items!(img::AbstractMatrix, items::Vector{ActionItem})

Draw bounding boxes and labels for ActionItems on the image. Each box gets a unique color
and appropriate digit coloring based on the background brightness.
"""
function draw_action_items!(img::AbstractMatrix, items::Vector{ActionItem})
    # Generate distinct colors for each item
    n = length(items)
    colors = [HSV(360*i/n, 0.8, 0.8) for i in 0:n-1]

    for (i, item) in enumerate(items)
        color = convert(RGB, colors[i])
        # Convert ActionItem to the format expected by draw_icon_annotations!
        detection = (;
            bbox=[item.x1, item.y1, item.x2, item.y2],
            confidence=1.0,
            class_name="icon",
            color=color,
            id=item.id
        )
        @debug "Drawing item $(item.id) at $(item.x1),$(item.y1),$(item.x2),$(item.y2)"
        draw_icon_annotations!(img, [detection])
    end
    return img
end

end # module
