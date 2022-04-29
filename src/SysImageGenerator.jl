module SysImageGenerator

using PackageCompiler: create_sysimage
using CompileBot: pathof_noload

import IJulia: installkernel

export sysimage, extract, installkernel

const supported_packages = ["QuantumLattices", "ExactDiagonalization", "TightBindingApproximation", "SpinWaveTheory", "MagnonPhonons"]

"""
    sysimage(name::String, packages::Vector{String}=supported_packages; plot::Bool=true, symbolic::Bool=true)

"""
function sysimage(name::String, packages::Vector{String}=supported_packages; plot::Bool=true, symbolic::Bool=true)
    path = dirname(dirname(pathof_noload("SysImageGenerator")))
    files = String[]
    for package in packages
        @assert package∈supported_packages "sysimage error: not supported package ($package)."
        push!(files, "$path/scripts/precompile_$package.jl")
    end
    accessories = String[]
    plot && push!(accessories, "Plots")
    symbolic && push!(accessories, "SymPy")
    create_sysimage(packages;
        sysimage_path="$path/sysimages/$name",
        precompile_execution_file=files
    )
end

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

function installkernel(sysimage::String, kernel::String="Julia-QuantumManyBody")
    path = dirname(dirname(pathof_noload("SysImageGenerator")))
    sysimage = "$path/sysimages/$sysimage"
    installkernel(kernel, "--project=@.", "--sysimage=$(sysimage)")
end

end
