module Types

using Base: @kwdef

export ActionItem, ActionPage, simplify_source

@kwdef struct ActionItem
    id::Int
    bbox::NTuple{4, Float64} = (0.0, 0.0, 0.0, 0.0)
    label::String = ""
end

@kwdef struct ActionPage
    image_path::Union{String, Nothing} = nothing
    axtree::Union{String, Nothing} = nothing
    html::Union{String, Nothing} = nothing
    action_items::Vector{ActionItem} = ActionItem[]
    url::String
end

struct AccessNode
    role::String
    name::String
    states::Dict{String, Any}
    children::Vector{AccessNode}
end

end # module
