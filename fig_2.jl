using CairoMakie
using DataFrames
using CSV
using Statistics
using NPZ
using ColorSchemes


palette = ColorSchemes.colorschemes[:mk_12]

include("core.jl")

path = "/Users/anand/Documents/data/pcv/IPCC-WGI-reference-regions-v4_shapefile/IPCC-WGI-reference-regions-v4.shp"

ipcc_regions = sort(ipcc_region())

ipcc_regions = ipcc_regions[ipcc_regions .!="Sahara" ]

function coefficient_boxplot(ax, vegetation_type, xtreme)
    if vegetation_type == "crop"
        marker = :diamond
    else
        marker = :star4
    end
    for (i, regions) in enumerate(ipcc_regions)
        df, df_w = read_logreg_df(vegetation_type, xtreme, regions)
        color = :grey80
        if !ismissing(df)

            if winter_significance(df, df_w)
                if vegetation_type == "crop"
                    color = (palette[12])
                else
                    color = (palette[2])
                end
            end

            scatter!(ax, mean(df_w[!, "t2m_winter"]), mean(df_w[!, "tp_winter"]), color =color, marker=marker, markersize = 20)

        end
    end

    hlines!(ax, 0, color = "black", linestyle = "--")
    vlines!(ax, 0, color = "black", linestyle = "--")
  
end

f = Figure(resolution=(1200, 600))
ax1 = Axis(f[2,1], xgridvisible = false, ygridvisible = false, xlabel="Winter temperature coefficient", ylabel="Winter precipitaiton coefficient", title = "Low vegetation activity")
ax2 = Axis(f[2,2], xgridvisible = false, ygridvisible = false, xlabel="Winter temperature coefficient", ylabel="Winter precipitaiton coefficient", title = "High vegetation activity")

coefficient_boxplot(ax1, "crop", "low")
coefficient_boxplot(ax1, "forest", "low")
coefficient_boxplot(ax2, "crop", "high")
coefficient_boxplot(ax2, "forest", "high")

# hidespines!(ax1, :r, :t)
# hidespines!(ax2, :r, :t)

f
elem_1 = MarkerElement(color = :grey80, marker = :star4, markersize = 15, points=Point2f[(0.5,0.5)])
elem_2 = MarkerElement(color = :grey80, marker = :diamond, markersize = 15, points=Point2f[(0.5,0.5)])
elem_3 = MarkerElement(color = palette[12], marker = :star4, markersize = 15, points=Point2f[(0.5,0.5) ])
elem_4 = MarkerElement(color = palette[2], marker = :diamond, markersize = 15, points=Point2f[(0.5,0.5)])

Legend(f[1,1:2], [elem_1, elem_2, elem_3, elem_4], ["Crop Region", "Forest Region", "Significant Crop Region", "Significant Forest Region"], orientation= :horizontal)

f

save("images/winter_coefficient.pdf", f)