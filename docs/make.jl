using HexWorld
using Documenter

makedocs(;
    modules=[HexWorld],
    authors="AgentLearn",
    repo="https://github.com/AgentLearn/HexWorld.jl/blob/{commit}{path}#L{line}",
    sitename="HexWorld.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://AgentLearn.github.io/HexWorld.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/AgentLearn/HexWorld.jl",
)
