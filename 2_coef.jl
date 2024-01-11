using CairoMakie
using DataFrames
using CSV
using Statistics
using NPZ
using ColorSchemes

palette = ColorSchemes.colorschemes[:mk_12]

include("core.jl")

path = "/Users/anand/Documents/data/pcv/IPCC-WGI-reference-regions-v4_shapefile/IPCC-WGI-reference-regions-v4.shp"

region_list = ipcc_regions()

ipcc_acronym

palette

function coefficient_boxplot(ax, vegetation_type, xtreme)
    
    if vegetation_type == "crop"
        marker = :diamond
    else
        marker = :star4
    end
    
    log_reg = read_log_df(vegetation_type, xtreme)

    for (i, regions) in enumerate(region_list)
        
        color = :grey80
        col_name = "$(vegetation_type)_$(xtreme)_" * regions *"_v3"
        if col_name in names(log_reg)
            if (log_reg[!, col_name][3]>100*38) 
            
                diff = log_reg[!, col_name][2] - log_reg[!, col_name][1]
                threshold = 0.02
                sig =  (diff > threshold) 

                if sig
                    if vegetation_type == "crop"
                        color = (palette["orange"])
                    else
                        color = (palette["mint"])
                    end
                    
                    
                end
                
                scatter!(ax, log_reg[!, col_name][4], log_reg[!, col_name][5], color =color, marker=marker, markersize = 20)

                if sig
                    
                    if xtreme == "high"
                        shift = Point2f(0.03,0.05)
                        if ipcc_acronym[regions] == "NWN"
                            shift = Point2f(0.05,0.05)
                        end
                        
                    else
                        shift = Point2f(0.1,0.02)
                        if ipcc_acronym[regions] == "RAR"
                            shift = Point2f(-0.02,0.03)
                        end

                        
                    end
                    
                    text!(ax, Point2f(log_reg[!, col_name][4], log_reg[!, col_name][5]) - shift, text=ipcc_acronym[regions])
                end
                
            end
        end

    end

    hlines!(ax, 0, color = palette["light_blue"], linestyle = :dash)
    vlines!(ax, 0, color = palette["light_blue"], linestyle = :dash)
end

f = Figure(resolution=(1200, 600))
ax1 = Axis(f[2,1], xgridvisible = false, ygridvisible = false,  xlabel="Winter temperature coefficient", ylabel="Winter precipitaiton coefficient", title = "Low LAI")
ax2 = Axis(f[2,2], xgridvisible = false, ygridvisible = false, xlabel="Winter temperature coefficient", title = "High LAI")
# ax3 = Axis(f[3,1], xgridvisible = false, ygridvisible = false, xlabel="Winter temperature coefficient", ylabel="Winter precipitaiton coefficient",  title = "Low LAI (Forest)")
# ax4 = Axis(f[3,2], xgridvisible = false, ygridvisible = false, xlabel="Winter temperature coefficient",  title = "High LAI (Forest)")


coefficient_boxplot(ax1, "crop", "low")
coefficient_boxplot(ax1, "forest", "low")
f
coefficient_boxplot(ax2, "crop", "high")
coefficient_boxplot(ax2, "forest", "high")
f

# coefficient_boxplot(ax2, "crop", "high")
# coefficient_boxplot(ax3, "forest", "low")
# coefficient_boxplot(ax4, "forest", "high")
# f

elem_1 = MarkerElement(color = palette["orange"], marker = :diamond, markersize = 15, points=Point2f[(0.5,0.5) ])
elem_2 = MarkerElement(color = palette["mint"], marker = :star, markersize = 15, points=Point2f[(0.5,0.5)])
elem_3 = MarkerElement(color = :grey80, marker = :diamond, markersize = 15, points=Point2f[(0.5,0.5)])
elem_4 = MarkerElement(color = :grey80, marker = :star4, markersize = 15, points=Point2f[(0.5,0.5)])

Legend(f[1,1:2], [elem_1, elem_2, elem_3, elem_4], ["Winter Preconditioned Region (Crop)", "Winter Preconditioned Region (Forest)", "Other regions (Crop)", "Other regions (Forest)"], orientation= :horizontal, framevisible=false)

f

save("images/winter_coefficient_v3.pdf", f)