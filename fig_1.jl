using CairoMakie, GeoMakie
using Shapefile
using DataFrames
using Makie.GeometryBasics
using CSV
using Statistics
using NPZ

using ColorSchemes

include("core.jl")

path = "/Users/anand/Documents/data/pcv/IPCC-WGI-reference-regions-v4_shapefile/IPCC-WGI-reference-regions-v4.shp"

table = Shapefile.Table(path)

table.geometry[1]

function plot_significance(ax, table, vegetation_type, xtreme)

    crop_location, forest_location = crop_forest_location()

    if vegetation_type == "crop"
        color = palette["orange"]
        veg_location = crop_location
    else
        color = palette["pale_grey"]
        veg_location = forest_location
    end      
    
    scatter!(ax, veg_location , markersize = 2.5, color = palette["pale_grey"])

    
    regions = ipcc_regions()

    for i=1:length(table.geometry)
        list_points = Point2f[]
        if table.Name[i] in regions
            
            ds_path = "/Users/anand/Documents/data/pcv/plot_data/$(vegetation_type)_data/$(xtreme)/"
            fname = [path for path in readdir(ds_path) if occursin("logreg_$(vegetation_type)_$(xtreme)_$(table.Name[i])",path)]
            fname_w = [path for path in readdir(ds_path) if occursin("logreg_winter_$(vegetation_type)_$(xtreme)_$(table.Name[i])",path)]
            

            if !isempty(fname)
            
                fname = fname[1]
                fname_w = fname_w[1]
                
                df = DataFrame(CSV.File(joinpath(ds_path, fname), header=1, delim="\t"))
                df_w = DataFrame(CSV.File(joinpath(ds_path, fname_w), header=1, delim="\t"))
                
                sig = winter_significance(df, df_w)

                if sig
                    
                    if vegetation_type == "crop"
                        color = (palette["orange"], 0.3)
                    else
                        color = (palette["mint"], 0.3)
                    end                
                else
                    color = (:grey80, 0.3)
                end
            
                for point in table.geometry[i].points
                    p = (point.x, point.y)

                    push!(list_points, p)
                    
                end

                if i==29

                    hm = poly!(ax, list_points[1:680], color = color, colormap=:viridis, strokecolor = :black, strokewidth=1)
                    hm = poly!(ax, list_points[681:end], color = color, colormap=:viridis, strokecolor = :black, strokewidth=1)
                    c = mean(list_points[1:680])

                else
                    hm = poly!(ax, list_points, color = color, colormap=:viridis, strokecolor = :black, strokewidth=1)
                    c = mean(list_points)
                end

                if sig
                    name = ipcc_acronym[table.Name[i]]
                    if name == "NEN"
                        text!(ax,c[1]-18, c[2]-12, text=name)
                     
                    elseif name == "ENA"
                        text!(ax,c[1]-10, c[2]+1, text=name)
                    elseif name == "NWN"
                        text!(ax,c[1]+10, c[2]-10, text=name)
                    elseif name == "NEU"
                        text!(ax,c[1]-20, c[2]-2, text=name)
                    elseif name == "RAR"
                        text!(ax,c[1]-15, c[2]-7, text=name)
                    elseif name == "RFE"
                        text!(ax,c[1]-22, c[2], text=name)
                    elseif name == "EAS"
                        text!(ax,c[1]-20, c[2]-7, text=name)
                    elseif name == "WCE"
                        text!(ax,c[1]-5, c[2]-5, text=name)
                    elseif name == "MED"
                        text!(ax,c[1]-20, c[2]-7, text=name)
                    elseif name == "WCA"
                        text!(ax,c[1]-10, c[2]-6, text=name)
                    else

                        text!(ax,c[1]-10, c[2]-10, text=name)

                    end

                end
            end
        end

    end

end


fig = Figure(resolution=(1100,1100))

ax1 = GeoAxis(fig[2,1], latlims=(25,75), dest = "+proj=eqearth", coastlines = true, xgridvisible = false, ygridvisible=false, title = "Low LAI (Crop)", xticklabelsvisible=true, yticklabelsvisible=true, yticks=[25,50,75], xticks=[-90,0,90], xticklabelpad=20, titlegap=20, coastline_attributes= (color=:grey40, linewidth=1.0,) )

ax2 = GeoAxis(fig[3,1], latlims=(25,75), dest = "+proj=eqearth", coastlines = true, xgridvisible = false, ygridvisible=false, title = "Low LAI (Forest)", xticklabelsvisible=true, yticklabelsvisible=true, yticks=[25,50,75], xticks=[-90,0,90], xticklabelpad=20 , titlegap=20, coastline_attributes= (color=:grey40, linewidth=1.0,)   )
ax3 = GeoAxis(fig[4,1], latlims=(25,75), dest = "+proj=eqearth", coastlines = true, xgridvisible = false, ygridvisible=false, title = "High LAI (Crop)", xticklabelsvisible=true, yticklabelsvisible=true, yticks=[25,50,75], xticks=[-90,0,90], xticklabelpad=20 , titlegap=20, coastline_attributes= (color=:grey40, linewidth=1.0,)   )
ax4 = GeoAxis(fig[5,1], latlims=(25,75), dest = "+proj=eqearth", coastlines = true, xgridvisible = false, ygridvisible=false, title = "High LAI (Forest)", xticklabelsvisible=true, yticklabelsvisible=true, yticks=[25,50,75], xticks=[-90,0,90], xticklabelpad=20, titlegap=20, coastline_attributes= (color=:grey40, linewidth=1.0,)    )


plot_significance(ax1, table, "crop", "low")
plot_significance(ax2, table, "forest", "low")
plot_significance(ax3, table, "crop", "high")
plot_significance(ax4, table, "forest", "high")

elem_1 = MarkerElement(color = :grey80, marker= :circle, markersize = 10, points=Point2f[(0.5,0.5)])
elem_2 = [PolyElement(color = (palette["orange"], 0.3), strokecolor = :black, strokewidth = 1, points = Point2f[(0, 0), (0, 1), (1,1), (1, 0)] )]
elem_3 = [PolyElement(color = (palette["mint"], 0.3), strokecolor = :black, strokewidth = 1, points = Point2f[(0, 0), (0, 1), (1,1), (1, 0)])]
elem_4 = [PolyElement(color = (:grey80, 0.3), strokecolor = :black, strokewidth = 1, points = Point2f[(0, 0), (0, 1), (1,1), (1, 0)])]

Legend(fig[1,1:end], [elem_1, elem_2, elem_3, elem_4], ["Vegetation", "Significant winter (Crop)", "Significant winter (Forest)", "Other Region"], orientation= :horizontal, framevisible=false)

fig


save("images/significance_plot_v4.pdf", fig)
