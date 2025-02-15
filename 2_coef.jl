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
                
                scatter!(ax, exp(log_reg[!, col_name][4]), exp(log_reg[!, col_name][5]), color =color, marker=marker, markersize = 20)

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
                    
                    text!(ax, Point2f(exp(log_reg[!, col_name][4]), exp(log_reg[!, col_name][5])) - shift, text=ipcc_acronym[regions])
                    hidespines!(ax, :r, :t)
                end
                
            end
        end

    end

    hlines!(ax, 1, color = palette["light_blue"], linestyle = :dash)
    vlines!(ax, 1, color = palette["light_blue"], linestyle = :dash)
end

with_theme(theme_latexfonts()) do

    f = Figure(resolution=(1200, 600), fontsize = 18)
    ax1 = Axis(f[2,1], xgridvisible = false, ygridvisible = false,  xlabel=L"Odds ratio of $T_w$ $(e^{\alpha_5})$", ylabel=L"Odds ratio of $P_w$  $(e^{\alpha_6})$", title = L"LAI_{low}", titlegap = 20)
    ax2 = Axis(f[2,2], xgridvisible = false, ygridvisible = false, xlabel=L"Odds ratio of $T_w$ $(e^{\alpha_5})$", title = L"LAI_{high}", titlegap=20)
    # ax3 = Axis(f[3,1], xgridvisible = false, ygridvisible = false, xlabel="Winter temperature coefficient", ylabel="Winter precipitaiton coefficient",  title = "Low LAI (Forest)")
    # ax4 = Axis(f[3,2], xgridvisible = false, ygridvisible = false, xlabel="Winter temperature coefficient",  title = "High LAI (Forest)")

    f
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
    elem_2 = MarkerElement(color = palette["mint"], marker = :star4, markersize = 15, points=Point2f[(0.5,0.5)])
    elem_3 = MarkerElement(color = :grey80, marker = :diamond, markersize = 15, points=Point2f[(0.5,0.5)])
    elem_4 = MarkerElement(color = :grey80, marker = :star4, markersize = 15, points=Point2f[(0.5,0.5)])

    Legend(f[1,1:2], [elem_1, elem_2, elem_3, elem_4], ["Winter Preconditioned Region (Crop)", "Winter Preconditioned Region (Forest)", "Other regions (Crop)", "Other regions (Forest)"], orientation= :horizontal, framevisible=false)


    left_pad = 10
    top_pad = 20
    Label(
    f[2, 1, TopLeft()],
        "a)",
        font = "TeX Gyre Heros Bold",
        fontsize = 22,
        padding = (0, left_pad, top_pad, 0),
        halign = :right,
        )

    Label(
    f[2, 2, TopLeft()],
        "b)",
        font = "TeX Gyre Heros Bold",
        fontsize = 22,
        padding = (0, left_pad, top_pad, 0),
        halign = :right,
        )
        save("images/winter_coefficient_v3.pdf", f)

    f
end