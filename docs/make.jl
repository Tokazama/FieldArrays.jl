using FieldArrays
using Documenter

DocMeta.setdocmeta!(FieldArrays, :DocTestSetup, :(using FieldArrays); recursive=true)

makedocs(;
    modules=[FieldArrays],
    authors="Zachary P. Christensen <zchristensen7@gmail.com> and contributors",
    repo="https://github.com/Tokazama/FieldArrays.jl/blob/{commit}{path}#{line}",
    sitename="FieldArrays.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Tokazama.github.io/FieldArrays.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Tokazama/FieldArrays.jl",
    devbranch="main",
)
