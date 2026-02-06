using PlutoSliderServer

# Pfade definieren
notebook_dir = joinpath(pwd(), "notebooks")
static_dir = joinpath(pwd(), "public")
mkpath(static_dir)

@info "Starte Export mit export_notebook..."

# In das Notebook-Verzeichnis wechseln, damit die Pfade stimmen
cd(notebook_dir) do
    for file in readdir()
        if endswith(file, ".jl")
            println("Exporting: ", file)
            
            # Die einfachste Export-Methode
            # Erzeugt eine .html Datei im gleichen Ordner
            PlutoSliderServer.export_notebook(file)
            
            # Die generierte HTML-Datei finden und verschieben
            html_file = replace(file, ".jl" => ".html")
            if isfile(html_file)
                mv(html_file, joinpath(static_dir, html_file); force=true)
                println("Moved to public: ", html_file)
            end
        end
    end
end

@info "Export abgeschlossen!"
