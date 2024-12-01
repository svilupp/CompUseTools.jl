"""
    simplify_source2(html::String)

Strip unnecessary HTML elements like scripts, styles, meta tags, etc.
"""
function simplify_source2(html::String)
    # Remove script tags and their contents
    html = replace(html, r"<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>" => "")
    # Remove style tags and their contents
    html = replace(html, r"<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>" => "")
    # Remove meta tags
    html = replace(html, r"<meta\b[^>]*>" => "")
    # Remove link tags
    html = replace(html, r"<link\b[^>]*>" => "")
    # Remove comments
    html = replace(html, r"<!--[\s\S]*?-->" => "")
    # Remove DOCTYPE
    html = replace(html, r"<!DOCTYPE[^>]*>" => "")
    # Remove extra whitespace
    html = replace(html, r"\s+" => " ")
    return strip(html)
end

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
        essential_attrs = [
            "id", "class", "href", "src", "alt", "aria-label", "role", "type", "value"]
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
                action_items = [ActionItem(
                                    x1 = det.bbox[1],
                                    y1 = det.bbox[2],
                                    x2 = det.bbox[3],
                                    y2 = det.bbox[4],
                                    id = i
                                ) for (i, det) in enumerate(detections)]

                # Create annotated image if we have action items
                if !isempty(action_items)
                    draw_action_items!(img, action_items)
                    final_image_path = replace(
                        screenshot_path, r"\.png$" => "_annotated.png")
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
        image_path = final_image_path,
        axtree = axtree,
        html = simplify_source(html),
        action_items = action_items,
        url = url
    )
end