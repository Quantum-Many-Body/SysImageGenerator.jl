module SysImageGenerator

using PackageCompiler: create_sysimage
using CompileBot: pathof_noload
using Pkg

import IJulia: installkernel

export sysimage, extract, installkernel

const supported_packages = ["QuantumLattices", "ExactDiagonalization", "TightBindingApproximation", "SpinWaveTheory", "MagnonPhonons"]
const default_sysimage = "sys_QuantumManyBody.so"

"""
    sysimage(name::String=default_sysimage, packages::Vector{String}=copy(supported_packages); plot::Bool=true, symbolic::Bool=true)

Create a sysimage.
"""
function sysimage(name::String=default_sysimage, packages::Vector{String}=copy(supported_packages); plot::Bool=true, symbolic::Bool=true)
    path = dirname(dirname(pathof_noload("SysImageGenerator")))
    Pkg.activate(path)
    files = String[]
    for package in packages
        @assert package∈supported_packages "sysimage error: not supported package ($package)."
        push!(files, "$path/scripts/precompile_$package.jl")
    end
    plot && push!(packages, "Plots")
    symbolic && push!(packages, "SymPy")
    create_sysimage(packages;
        sysimage_path="$path/sysimages/$name",
        precompile_execution_file=files
    )
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
    installkernel(sysimage::String=default_sysimage, kernel::String="Julia-QuantumManyBody")

Install a Jupyter notebook kernel with the specified sysimage.
"""
function installkernel(sysimage::String=default_sysimage, kernel::String="Julia-QuantumManyBody")
    path = dirname(dirname(pathof_noload("SysImageGenerator")))
    sysimage = "$path/sysimages/$sysimage"
    installkernel(kernel, "--project=@.", "--sysimage=$(sysimage)")
end

end
