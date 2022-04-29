using SysImageGenerator
using Documenter

DocMeta.setdocmeta!(SysImageGenerator, :DocTestSetup, :(using SysImageGenerator); recursive=true)

makedocs(;
    modules=[SysImageGenerator],
    authors="waltergu <waltergu1989@gmail.com> and contributors",
    repo="https://github.com/Quantum-Many-Body/SysImageGenerator.jl/blob/{commit}{path}#{line}",
    sitename="SysImageGenerator.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Quantum-Many-Body.github.io/SysImageGenerator.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Quantum-Many-Body/SysImageGenerator.jl",
    devbranch="main",
)
