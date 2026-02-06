# Export Pluto notebooks in notebooks/ to static HTML in public/
# - Uses PlutoStaticHTML if available (tries multiple common API names).
# - If PlutoStaticHTML is missing, this script attempts to add it for the run.
# - Run with: julia --project=. scripts/export_pluto.jl

using Pkg
using Logging

const EXPORTER_PKG = "PlutoStaticHTML"

function ensure_exporter(pkg::String)
    try
        @eval using PlutoStaticHTML
        return true
    catch err
        @info("$pkg not present in environment, trying to add it for this run...")
        try
            Pkg.add(pkg)
            @eval using PlutoStaticHTML
            return true
        catch err2
            @error("Failed to install or load $pkg: $err2")
            return false
        end
    end
end

function try_export_with_known_apis(mod, nbpath::String, outpath::String)
    # 1) export(nb, outpath)
    if isdefined(mod, :export)
        try
            @info("Calling PlutoStaticHTML.export($nbpath, $outpath)")
            getfield(mod, :export)(nbpath, outpath)
            return true
        catch err
            @warn("PlutoStaticHTML.export failed: $err")
        end
    end

    # 2) save_html(nb, outpath)
    if isdefined(mod, :save_html)
        try
            @info("Calling PlutoStaticHTML.save_html($nbpath, $outpath)")
            getfield(mod, :save_html)(nbpath, outpath)
            return true
        catch err
            @warn("PlutoStaticHTML.save_html failed: $err")
        end
    end

    # 3) notebook_to_html(nb) -> returns HTML string
    if isdefined(mod, :notebook_to_html)
        try
            @info("Calling PlutoStaticHTML.notebook_to_html($nbpath) -> writing to $outpath")
            html = getfield(mod, :notebook_to_html)(nbpath)
            open(outpath, "w") do io
                write(io, html)
            end
            return true
        catch err
            @warn("PlutoStaticHTML.notebook_to_html failed: $err")
        end
    end

    # 4) autodiscover candidate functions with "html", "export" or "render" in the name
    fnames = filter(n -> occursin("html", String(n)) || occursin("export", String(n)) || occursin("render", String(n)), names(mod, all=true))
    for fname in fnames
        try
            f = getfield(mod, fname)
            @info("Attempting autodiscovered function: $(fname)")
            # Try calling with (nb, outpath) then with (nb) and write result if string-like
            try
                f(nbpath, outpath)
                return true
            catch
                res = f(nbpath)
                if isa(res, AbstractString)
                    open(outpath, "w") do io write(io, res) end
                    return true
                end
            end
        catch err
            @warn("Autodiscovered attempt $(fname) failed: $err")
        end
    end

    return false
end

function main()
    notebook_dir = joinpath(pwd(), "notebooks")
    output_dir   = joinpath(pwd(), "public")
    mkpath(output_dir)

    if !isdir(notebook_dir)
        @info "No notebooks/ directory found; nothing to export."
        return
    end

    notebooks = filter(f -> endswith(f, ".jl"), readdir(notebook_dir; join=true))
    if isempty(notebooks)
        @info "No .jl notebooks found in notebooks/. Nothing to do."
        return
    end

    ok = ensure_exporter(EXPORTER_PKG)
    if !ok
        @error "Exporter $EXPORTER_PKG not available. Add it to Project.toml or install it manually."
        exit(1)
    end

    # Export loop with local counter
    success_count = 0
    for nb in notebooks
        name = splitext(basename(nb))[1]
        outpath = joinpath(output_dir, "$(name).html")
        @info "Exporting $nb -> $outpath"

        try
            exported = try_export_with_known_apis(PlutoStaticHTML, nb, outpath)
            if exported
                @info "Export succeeded for $nb"
                success_count += 1
            else
                @warn "No known export API succeeded for $nb. See logs above."
            end
        catch err
            @error "Unexpected error exporting $nb: $err"
        end
    end

    if success_count == 0
        @error "No notebooks were exported. See messages above to diagnose."
        exit(1)
    else
        @info "Export complete: $success_count notebook(s) exported to public/."
        exit(0)
    end
end

main()
