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

# ipcc_acronym = sort(collect(ipcc_acronym), by=x->x[1])

function remove_col_with_missing(df)
    return df[!, map(x->!all(ismissing, x), eachcol(df))]
end

function plot_significance(ax, table, vegetation_type, xtreme)

    crop_location, forest_location = crop_forest_location()

    if vegetation_type == "crop"
        color = (palette["orange"], 0.5)
        veg_location = crop_location
    else
        color = (palette["mint"], 0.5)
        veg_location = forest_location
    end      
    
    scatter!(ax, veg_location , markersize = 2.5, color = color)

    regions = ipcc_regions()
    auc = read_log_df(vegetation_type, xtreme)
    auc = remove_col_with_missing(auc)

    for i=1:length(table.geometry)
        list_points = Point2f[]
        
        if table.Name[i] in regions

            color = (:white, 0.0)
        
            if vegetation_type == "crop"
                if ipcc_acronym[table.Name[i]] == "RAR"
                    color = (:grey80, 0.8)
                end
        
            else
                if ipcc_acronym[table.Name[i]] == "ECA"
                    color = (:grey80, 0.8)
                end
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
            elseif name == "CNA"
                text!(ax,c[1]-6, c[2]-1, text=name)
            elseif name == "TIB"
                text!(ax,c[1]-6, c[2]-2, text=name)
            elseif name == "NCA"
                text!(ax,c[1]-6, c[2]+1, text=name)
            elseif name == "SAS"
                text!(ax,c[1]-16, c[2]+3, text=name)
            elseif name == "WNA"
                text!(ax,c[1]-2, c[2]-7, text=name)
            elseif name == "ECA"
                text!(ax,c[1]-8, c[2]-2, text=name)
            else

                text!(ax,c[1]-10, c[2]-10, text=name)

            end
        end

    end

end


auc_ch = read_log_df("crop", "high")
auc_cl = read_log_df("crop", "low")
auc_fh = read_log_df("forest", "high")
auc_fl = read_log_df("forest", "low")



with_theme(theme_latexfonts()) do

    f = Figure(resolution=(1200,700), fontsize=18)

    r_val = 1

    ax1 = Axis(f[4,r_val], title = "IPCC regions with acronyms")
    # ax1 = GeoAxis(f[1:2,l_val], latlims=(25,75), dest = "+proj=eqearth", coastlines = true, xgridvisible = false, ygridvisible=false, xticklabelsvisible=false, yticklabelsvisible=false, yticks=[25,50,75], xticks=[-90,0,90], xticklabelpad=20, titlegap=20, coastline_attributes= (color=:grey40, linewidth=1.0,) )

    ax2 = GeoAxis(f[2,r_val], latlims=(25,75), dest = "+proj=eqearth", coastlines = true, xgridvisible = false, ygridvisible=false, xticklabelsvisible=false, yticklabelsvisible=false, yticks=[25,50,75], xticks=[-90,0,90], xticklabelpad=20 , titlegap=20, coastline_attributes= (color=:grey40, linewidth=1.0,)   )
    ax3 = GeoAxis(f[3,r_val], latlims=(25,75), dest = "+proj=eqearth", coastlines = true, xgridvisible = false, ygridvisible=false, xticklabelsvisible=false, yticklabelsvisible=false, yticks=[25,50,75], xticks=[-90,0,90], xticklabelpad=20 , titlegap=20, coastline_attributes= (color=:grey40, linewidth=1.0,)   )
    
    plot_significance(ax2, table, "crop", "low")

    plot_significance(ax3, table, "forest", "low")


    x=-0.1
    y=0
    for (i, (k, v)) in enumerate(sort(collect(ipcc_acronym_full), by=x->x[1]))
        
        k = replace(k, "." =>". ")
        k = replace(k, "&"=>" & ")

        text!(ax1, x,y, text = "$k ($v)")
        
        if i%4==0
            x=-0.1
            y-=1
        else
            x+=1
        end
        
        
        # text!(ax1, c,-r, text = v)
    
    end
    xlims!(ax1, -0.1,3.80)
    ylims!(ax1, -4, 1)

    hidespines!(ax1)
    hidedecorations!(ax1)

    elem_1 = [MarkerElement(color = (palette["orange"], 0.5),  marker= :circle, markersize = 10, points=Point2f[(0.5,0.5)])]
    elem_2 = [MarkerElement(color = (palette["mint"], 0.5), marker= :circle, markersize = 10, points=Point2f[(0.5,0.5)])]
    elem_3 = [PolyElement(color = (:grey80, 0.8), strokecolor = :black, strokewidth = 1, points = Point2f[(0, 0), (0, 1), (1,1), (1, 0)])]
    # elem_4 = MarkerElement(color = :grey80, marker= :circle, markersize = 10, points=Point2f[(0.5,0.5)])

    Legend(f[1,1:end], [elem_1, elem_2, elem_3], ["Crop", "Forest", "Regions with no data"], orientation= :horizontal, framevisible=false)


    # left_pad = 30
    # top_pad = 30

    # for i=1:3

    #     l_alpha = ["a)", "b)", "c)"][i]

    #     Label(
    # f[i+1, 1, TopLeft()],
    #     l_alpha,
    #     font = "TeX Gyre Heros Bold",
    #     fontsize = 22,
    #     padding = (0, left_pad, top_pad, 0),
    #     halign = :right,
    #     )
    # end


    # f


    # ### Plotting rank


    # rank_auc_diff(f, [2,l_val], auc_cl, palette["orange"], "Low LAI (Crop)")
    # rank_auc_diff(f, [3,l_val], auc_fl, palette["mint"], "Low LAI (Forest)")
    # rank_auc_diff(f, [4,l_val], auc_ch, palette["orange"], "High LAI (Crop)")
    # rank_auc_diff(f, [5,l_val], auc_fh, palette["mint"], "HIgh LAI (Forest)")

    # f




    # empty_element = MarkerElement(color = :white, marker= :circle, markersize = 10, points=Point2f[(0.5,0.5)])


    # font_size = 16
    # Label(
    #     f[2, 1],
    #     "Low LAI (Crop)",
    #     rotation = pi / 2,
    #     tellheight = false,
    #     fontsize = font_size,
    #     font = "TeX Gyre Heros Makie Bold"
    # )

    # f

    # Label(
    #     f[3, 1],
    #     "Low LAI (Forest)",
    #     rotation = pi / 2,
    #     tellheight = false,
    #     fontsize = font_size,
    #     font = "TeX Gyre Heros Makie Bold"
    # )

    # Label(
    #     f[4, 1],
    #     "High LAI (Crop)",
    #     rotation = pi / 2,
    #     tellheight = false,
    #     fontsize = font_size,
    #     font = "TeX Gyre Heros Makie Bold"
    # )
    # f
    # Label(
    #     f[5, 1],
    #     "High LAI (Forest)",
    #     rotation = pi / 2,
    #     tellheight = false,
    #     fontsize = font_size,
    #     font = "TeX Gyre Heros Makie Bold"
    # )
    f
    save("images/acronym_plot_v3.pdf",f) 
    f
end

