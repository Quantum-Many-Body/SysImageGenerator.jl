module SysImageGenerator

using PackageCompiler: create_sysimage
using CompileBot: pathof_noload
using Pkg

import IJulia: installkernel

export sysimage, extract, installkernel
export supported_packages, default_sysimage

"""
    const supported_packages = [
        "QuantumLattices",
        "ExactDiagonalization",
        "TightBindingApproximation",
        "SpinWaveTheory",
        "MagnonPhononHybridization"
    ]

The supported quantum-many-body packages that could be specified to generate the Julia sysimages.
"""
const supported_packages = [
    "QuantumLattices",
    "ExactDiagonalization",
    "TightBindingApproximation",
    "SpinWaveTheory",
    "MagnonPhononHybridization"
]

"""
    const default_sysimage = "sys_QuantumManyBody.so"

The default sysimage name of the quantum-many-body packages.
"""
const default_sysimage = "sys_QuantumManyBody.so"

"""
    sysimage(
        name::String=default_sysimage;
        packages::Vector{String}=copy(supported_packages),
        path::String=string(dirname(dirname(pathof_noload("SysImageGenerator"))), "/sysimages"),
        plot::Bool=true,
        symbolic::Bool=true
        )

Create a sysimage with a given name for the specified packages and store it in the specified path.

When `plot` is true, [Plots](https://github.com/JuliaPlots/Plots.jl) will be included in the sysimage. So will [SymPy](https://github.com/JuliaPy/SymPy.jl) when `symbolic` is true.
"""
function sysimage(
        name::String=default_sysimage;
        packages::Vector{String}=copy(supported_packages),
        path::String=string(dirname(dirname(pathof_noload("SysImageGenerator"))), "/sysimages"),
        plot::Bool=true,
        symbolic::Bool=true
        )
    packpath = dirname(dirname(pathof_noload("SysImageGenerator")))
    Pkg.activate(packpath)
    files = String[]
    for package in packages
        @assert package∈supported_packages "sysimage error: not supported package ($package)."
        push!(files, "$packpath/scripts/precompile_$package.jl")
    end
    plot && push!(packages, "Plots")
    symbolic && push!(packages, "SymPy")
    f() = create_sysimage(packages; sysimage_path="$path/$name", precompile_execution_file=files)
    cd(f, mktempdir())
    Pkg.activate()
end

"""
    extract(package_name::String)

Extract the test sets of a package and run them.
"""
function extract(package_name::String)
    package_rootpath = dirname(dirname(pathof_noload(package_name)))
    runtestpath = "$package_rootpath/test/runtests.jl"
    package = Symbol(package_name)
    snoop_script = quote
        using $(package)
        include($runtestpath)
    end
    Core.eval(Main, snoop_script)
end

"""
    installkernel(
        kernel::String="Julia-QuantumManyBody";
        sysimage::String=default_sysimage,
        path::String=string(dirname(dirname(pathof_noload("SysImageGenerator"))), "/sysimages")
        )

Install a Jupyter notebook kernel with the specified sysimage.
"""
function installkernel(
        kernel::String="Julia-QuantumManyBody";
        sysimage::String=default_sysimage,
        path::String=string(dirname(dirname(pathof_noload("SysImageGenerator"))), "/sysimages")
        )
    sysimage = "$path/$sysimage"
    installkernel(kernel, "--project=@.", "--sysimage=$(sysimage)")
end

end
