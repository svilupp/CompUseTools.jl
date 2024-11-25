module Types

using Base: @kwdef

export ActionItem, ActionPage, simplify_source

@kwdef struct ActionItem
    x1::Float64
    x2::Float64
    y1::Float64
    y2::Float64
    label::String = ""
    id::Int
end

@kwdef struct ActionPage
    image_path::Union{String, Nothing} = nothing
    axtree::Union{String, Nothing} = nothing
    html::Union{String, Nothing} = nothing
    action_items::Vector{ActionItem} = ActionItem[]
    url::String
end

"""
    simplify_source(html::String)

Strip unnecessary HTML elements like scripts, styles, meta tags, etc.
"""
function simplify_source(html::String)
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

end # module
