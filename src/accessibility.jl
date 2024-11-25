using Gumbo
using AbstractTrees
using DataStructures
using ChromeDevToolsLite

export AccessNode, html_to_accessibility_tree, extract_accessibility_tree

struct AccessNode
    role::String
    name::String
    states::Dict{String, Any}
    children::Vector{AccessNode}
end

# Helper function to find element by ID
function find_element_by_id(root::Gumbo.HTMLElement, id::AbstractString)
    if haskey(root.attributes, "id") && root.attributes["id"] == id
        return root
    end

    for child in root.children
        if isa(child, Gumbo.HTMLElement)
            result = find_element_by_id(child, id)
            if !isnothing(result)
                return result
            end
        end
    end

    return nothing
end

# Helper function to get text content of an element
function get_element_text(elem::Gumbo.HTMLElement)
    text = ""
    for child in elem.children
        if isa(child, Gumbo.HTMLText)
            text *= child.text
        elseif isa(child, Gumbo.HTMLElement)
            text *= get_element_text(child)
        end
    end
    return strip(text)
end

# Enhanced function to get accessible name
function get_accessible_name(elem::Gumbo.HTMLElement, root::Gumbo.HTMLElement)
    # Check aria-label (highest priority)
    if haskey(elem.attributes, "aria-label")
        return elem.attributes["aria-label"]
    end

    # Check aria-labelledby
    if haskey(elem.attributes, "aria-labelledby")
        labelledby_ids = split(elem.attributes["aria-labelledby"])
        label_text = ""

        # Concatenate text from all referenced elements in order
        for id in labelledby_ids
            referenced_elem = find_element_by_id(root, id)
            if !isnothing(referenced_elem)
                label_text *= " " * get_element_text(referenced_elem)
            end
        end

        if !isempty(label_text)
            return strip(label_text)
        end
    end

    # Check for label element if this is a form control
    if tag(elem) in [:input, :textarea, :select] && haskey(elem.attributes, "id")
        # Find label with matching 'for' attribute
        for child in PreOrderDFS(root)
            if isa(child, Gumbo.HTMLElement) && tag(child) == :label
                if haskey(child.attributes, "for") && child.attributes["for"] == elem.attributes["id"]
                    return get_element_text(child)
                end
            end
        end
    end

    # Get alt text for images
    if tag(elem) == :img && haskey(elem.attributes, "alt")
        return elem.attributes["alt"]
    end

    # Fall back to element's text content
    text = get_element_text(elem)

    # For buttons, if no text content, check value attribute
    if tag(elem) == :button && isempty(text) && haskey(elem.attributes, "value")
        return elem.attributes["value"]
    end

    return text
end

# Helper function to check if element is hidden
function is_hidden(elem::Gumbo.HTMLElement)
    # Check aria-hidden attribute
    if haskey(elem.attributes, "aria-hidden") && elem.attributes["aria-hidden"] == "true"
        return true
    end
    return false
end

# Helper function to get ARIA role
function get_role(elem::Gumbo.HTMLElement)
    # Check explicit role first
    if haskey(elem.attributes, "role")
        return elem.attributes["role"]
    end

    # Map HTML elements to their default ARIA roles
    default_roles = Dict{Symbol, String}(
        :button => "button",
        :a => "link",
        :input => get(elem.attributes, "type", "textbox"),
        :h1 => "heading",
        :h2 => "heading",
        :h3 => "heading",
        :h4 => "heading",
        :h5 => "heading",
        :h6 => "heading",
        :nav => "navigation",
        :main => "main",
        :form => "form",
        :img => "img",
        :article => "article",
        :section => "region"
    )

    return get(default_roles, tag(elem), string(tag(elem)))
end

# Helper function to get element states
function get_states(elem::Gumbo.HTMLElement)
    states = Dict{String, Any}()

    # Check common ARIA states
    aria_states = [
        "aria-expanded",
        "aria-pressed",
        "aria-checked",
        "aria-selected",
        "aria-disabled",
        "aria-invalid",
        "aria-required"
    ]

    for state in aria_states
        if haskey(elem.attributes, state)
            states[state] = elem.attributes[state]
        end
    end

    # Check disabled state for form controls
    if tag(elem) in [:button, :input, :select, :textarea] && haskey(elem.attributes, "disabled")
        states["disabled"] = true
    end

    return states
end

function build_accessibility_tree(elem::Gumbo.HTMLElement, root::Gumbo.HTMLElement)
    if is_hidden(elem)
        return nothing
    end

    role = get_role(elem)
    name = get_accessible_name(elem, root)
    states = get_states(elem)
    children = AccessNode[]

    # Process children
    for child in elem.children
        if isa(child, Gumbo.HTMLElement)
            child_node = build_accessibility_tree(child, root)
            if !isnothing(child_node)
                push!(children, child_node)
            end
        end
    end

    return AccessNode(role, name, states, children)
end

function html_to_accessibility_tree(html_string::String)
    parsed_html = parsehtml(html_string)
    root = parsed_html.root[2]  # [2] to skip DOCTYPE
    return build_accessibility_tree(root, root)
end

# Pretty printing function for AccessNode
function print_accessibility_tree(node::AccessNode, indent::Int = 0)
    println(" "^indent, "Role: ", node.role)
    println(" "^indent, "Name: ", node.name)
    if !isempty(node.states)
        println(" "^indent, "States: ", node.states)
    end
    for child in node.children
        print_accessibility_tree(child, indent + 2)
    end
end

"""
    extract_accessibility_tree(url::String; port::Int=9222) -> AccessNode

Extract the accessibility tree from a webpage using ChromeDevTools.

# Arguments
- `url::String`: The URL to extract the accessibility tree from
- `port::Int=9222`: The debugging port for ChromeDevTools

# Returns
- `AccessNode`: Root node of the accessibility tree
"""
function extract_accessibility_tree(url::String; port::Int=9222)
    # Connect to Chrome
    browser = ChromeDevToolsLite.connect_browser("ws://localhost:$port")

    try
        # Navigate to the URL and get content
        ChromeDevToolsLite.goto(browser, url)
        html_content = ChromeDevToolsLite.content(browser)

        # Parse HTML and convert to accessibility tree
        return html_to_accessibility_tree(html_content)
    finally
        close(browser)
    end
end

# Convert AccessNode to a string representation
function serialize_accessibility_tree(node::AccessNode, indent::Int = 0)
    result = ""
    result *= " "^indent * "Role: $(node.role)\n"
    result *= " "^indent * "Name: $(node.name)\n"
    if !isempty(node.states)
        result *= " "^indent * "States: $(node.states)\n"
    end
    for child in node.children
        result *= serialize_accessibility_tree(child, indent + 2)
    end
    return result
end

export serialize_accessibility_tree
