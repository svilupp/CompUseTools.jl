using CompUseTools
using Documenter

DocMeta.setdocmeta!(CompUseTools, :DocTestSetup, :(using CompUseTools); recursive=true)

makedocs(;
    modules=[CompUseTools],
    authors="J S <49557684+svilupp@users.noreply.github.com> and contributors",
    sitename="CompUseTools.jl",
    format=Documenter.HTML(;
        canonical="https://svilupp.github.io/CompUseTools.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/svilupp/CompUseTools.jl",
    devbranch="main",
)
