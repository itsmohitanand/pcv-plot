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

function remove_col_with_missing(df)
    return df[!, map(x->!all(ismissing, x), eachcol(df))]
end

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
    auc = read_log_df(vegetation_type, xtreme)
    auc = remove_col_with_missing(auc)

    for i=1:length(table.geometry)
        list_points = Point2f[]
        
        if table.Name[i] in regions

            col_name = "$(vegetation_type)_$(xtreme)_" * table.Name[i] *"_v3"
            if col_name in names(auc)
                
                if (auc[!, col_name][3]>100*38) 
                    diff = auc[!, col_name][2] - auc[!, col_name][1]
                    threshold = 0.02
                    sig =  (diff > threshold) 
                

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
                        elseif name == "CNA"
                            text!(ax,c[1]-6, c[2]-1, text=name)
                        elseif name == "TIB"
                            text!(ax,c[1]-6, c[2]-2, text=name)
                        elseif name == "NCA"
                            text!(ax,c[1]-6, c[2]+1, text=name)
                        elseif name == "SAS"
                            text!(ax,c[1]-16, c[2]+3, text=name)
                        else

                            text!(ax,c[1]-10, c[2]-10, text=name)

                        end

                    end
                end
            end
        end

    end

end

auc_ch = read_log_df("crop", "high")
auc_cl = read_log_df("crop", "low")
auc_fh = read_log_df("forest", "high")
auc_fl = read_log_df("forest", "low")


function remove_col_with_missing(df)
    return df[!, map(x->!all(ismissing, x), eachcol(df))]
end


function rank_auc_diff(f, ax_loc, df, color, title )
    df = remove_col_with_missing(df)
    x_names = names(df)
    diff = Matrix(df)[2,:] - Matrix(df)[1,:]
    sorted_index = sortperm(diff, rev=true)
    x = [1:length(sorted_index);]

    xticklabels = [ipcc_acronym[split(x_names[i], "_")[3]] for i in sorted_index]
    ax =Axis(f[ax_loc[1], ax_loc[2]],
    xticks = (x, xticklabels), 
    xticklabelrotation = π/2, 
    xgridvisible=false, ygridvisible=false, ylabel="Preconditioning Strength")

    
    for (i , sort_index) in enumerate(sorted_index)
        if diff[sort_index] < 0.02
            color = (:grey80, 0.8)
        end
        barplot!(ax, x[i], diff[sort_index], color = color)
    end
    hlines!(ax, 0.02, linestyle=:dash, color=:black)
    hidespines!(ax, :r, :t)
    ylims!(ax, low=0)

end

with_theme(theme_latexfonts()) do

    f = Figure(resolution=(1350*0.8,1200*0.8), fontsize=14)

    l_val = 2:4
    r_val = 5:12

    ax1 = GeoAxis(f[2,r_val], latlims=(25,75), dest = "+proj=eqearth", coastlines = true, xgridvisible = false, ygridvisible=false, xticklabelsvisible=false, yticklabelsvisible=false, yticks=[25,50,75], xticks=[-90,0,90], xticklabelpad=20, titlegap=20, coastline_attributes= (color=:grey40, linewidth=1.0,) )

    ax2 = GeoAxis(f[3,r_val], latlims=(25,75), dest = "+proj=eqearth", coastlines = true, xgridvisible = false, ygridvisible=false, xticklabelsvisible=false, yticklabelsvisible=false, yticks=[25,50,75], xticks=[-90,0,90], xticklabelpad=20 , titlegap=20, coastline_attributes= (color=:grey40, linewidth=1.0,)   )
    ax3 = GeoAxis(f[4,r_val], latlims=(25,75), dest = "+proj=eqearth", coastlines = true, xgridvisible = false, ygridvisible=false, xticklabelsvisible=false, yticklabelsvisible=false, yticks=[25,50,75], xticks=[-90,0,90], xticklabelpad=20 , titlegap=20, coastline_attributes= (color=:grey40, linewidth=1.0,)   )
    ax4 = GeoAxis(f[5,r_val], latlims=(25,75), dest = "+proj=eqearth", coastlines = true, xgridvisible = false, ygridvisible=false, xticklabelsvisible=false, yticklabelsvisible=false, yticks=[25,50,75], xticks=[-90,0,90], xticklabelpad=20, titlegap=20, coastline_attributes= (color=:grey40, linewidth=1.0,))


    plot_significance(ax1, table, "crop", "low")
    plot_significance(ax2, table, "forest", "low")
    plot_significance(ax3, table, "crop", "high")
    plot_significance(ax4, table, "forest", "high")

    elem_1 = [PolyElement(color = (palette["orange"], 0.3), strokecolor = :black, strokewidth = 1, points = Point2f[(0, 0), (0, 1), (1,1), (1, 0)] )]
    elem_2 = [PolyElement(color = (palette["mint"], 0.3), strokecolor = :black, strokewidth = 1, points = Point2f[(0, 0), (0, 1), (1,1), (1, 0)])]
    elem_3 = [PolyElement(color = (:grey80, 0.3), strokecolor = :black, strokewidth = 1, points = Point2f[(0, 0), (0, 1), (1,1), (1, 0)])]
    elem_4 = MarkerElement(color = :grey80, marker= :circle, markersize = 10, points=Point2f[(0.5,0.5)])

    Legend(f[1,1:end], [elem_1, elem_2, elem_3, elem_4], ["Winter Preconditioned Region (Crop)", "Winter Preconditioned Region (Forest)", "Other Regions", "Vegetation"], orientation= :horizontal, framevisible=false)


    left_pad = 30
    top_pad = 30

    for i=1:4

        l_alpha = ["a)", "c)", "e)", "g)"][i]
        r_alpha = ["b)", "d)", "f)", "h)"][i]


        Label(
    f[i+1, 2, TopLeft()],
        l_alpha,
        font = "TeX Gyre Heros Bold",
        fontsize = 22,
        padding = (0, left_pad, top_pad, 0),
        halign = :right,
        )

        Label(
    f[i+1, [r_val;][1], TopLeft()],
        r_alpha,
        font = "TeX Gyre Heros Bold",
        fontsize = 22,
        padding = (0, left_pad, top_pad, 0),
        halign = :right,
        )



    end


    f


    ### Plotting rank


    rank_auc_diff(f, [2,l_val], auc_cl, palette["orange"], L"LAI_{low}^{crop}")
    rank_auc_diff(f, [3,l_val], auc_fl, palette["mint"], L"LAI_{low}^{forest}")
    rank_auc_diff(f, [4,l_val], auc_ch, palette["orange"], L"LAI_{high}^{crop}")
    rank_auc_diff(f, [5,l_val], auc_fh, palette["mint"], L"LAI_{high}^{forest}")

    f




    empty_element = MarkerElement(color = :white, marker= :circle, markersize = 10, points=Point2f[(0.5,0.5)])


    font_size = 18
    Label(
        f[2, 1],
        L"LAI_{low}^{crop}",
        rotation = pi / 2,
        tellheight = false,
        fontsize = font_size,
        font = "TeX Gyre Heros Makie Bold"
    )

    f

    Label(
        f[3, 1],
        L"LAI_{low}^{forest}",
        rotation = pi / 2,
        tellheight = false,
        fontsize = font_size,
        font = "TeX Gyre Heros Makie Bold"
    )

    Label(
        f[4, 1],
        L"LAI_{high}^{crop}",
        rotation = pi / 2,
        tellheight = false,
        fontsize = font_size,
        font = "TeX Gyre Heros Makie Bold"
    )
    f
    Label(
        f[5, 1],
        L"LAI_{high}^{forest}",
        rotation = pi / 2,
        tellheight = false,
        fontsize = font_size,
        font = "TeX Gyre Heros Makie Bold"
    )
    f
    save("images/significance_plot_v3.pdf",f) 

end

