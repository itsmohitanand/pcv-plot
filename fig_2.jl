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


function coefficient_boxplot(ax, vegetation_type, xtreme)
    
    if vegetation_type == "crop"
        marker = :diamond
    else
        marker = :star4
    end
    for (i, regions) in enumerate(region_list)
        df, df_w = read_logreg_df(vegetation_type, xtreme, regions)
        color = :grey80
        if !ismissing(df)

            if winter_significance(df, df_w)
                if vegetation_type == "crop"
                    color = (palette["orange"])
                else
                    color = (palette["mint"])
                end
            
            end

            scatter!(ax, mean(df_w[!, "t2m_winter"]), mean(df_w[!, "tp_winter"]), color =color, marker=marker, markersize = 20)

            if winter_significance(df, df_w)
                errorbars!(ax, [mean(df_w[!, "t2m_winter"])], [mean(df_w[!, "tp_winter"])], std(df_w[!, "t2m_winter"]), direction = :x, whiskerwidth=5, color=:grey20)
                errorbars!(ax, [mean(df_w[!, "t2m_winter"])], [mean(df_w[!, "tp_winter"])], std(df_w[!, "tp_winter"]), direction = :y, whiskerwidth=5, color = :grey20)
            end
            
        end
    end

    hlines!(ax, 0, color = palette["light_blue"], linestyle = "--")
    vlines!(ax, 0, color = palette["light_blue"], linestyle = "--")
  
end

function plot_anomalies(ax, vegetation_type, xtreme)

    for region in region_list
        if vegetation_type == "crop"
            marker = :diamond
        else
            marker = :star4
        end

        df, df_w = read_logreg_df(vegetation_type, xtreme, region)

        color= :grey80

        if !ismissing(df_w)
            annotation = [""]
            if winter_significance(df, df_w)
                if vegetation_type == "crop"
                    color = (palette["orange"])
                else
                    color = (palette["mint"])
                end
                annotation  = [ipcc_acronym[region]]

            end
            
            df = read_ori_data(vegetation_type, xtreme,  region)
            t2m_a, tp_a = winter_climate_anomaly(df)

            mean_t2m_a = mean(t2m_a)
            mean_tp_a = mean(tp_a)
            
            df, df_w = read_logreg_df(vegetation_type, xtreme, region)

            scatter!(ax, Point2f(mean_t2m_a, mean_tp_a), color = color, marker = marker, markersize=20)
            hlines!(ax, 0, color = palette["light_blue"], linestyle = "--")
            vlines!(ax, 0, color = palette["light_blue"], linestyle = "--")
            
        end    
    end

end

function anomalies_text(ax, vegetation_type, xtreme)
    for region in region_list
        
        df, df_w = read_logreg_df(vegetation_type, xtreme, region)

        if !ismissing(df_w)
            
            if vegetation_type == "crop"
                if xtreme == "low"
                    shift = Point2f(0.22, 0.5)
                    if ipcc_acronym[region] == "EEU"
                        shift = Point2f(0.20, 0.3)
                    end

                else
                    shift = Point2f(0.22, 0.5)
                    
    
                end
            else
                if xtreme == "low"
                    shift = Point2f(0.22, 0.5)
                    
                    if ipcc_acronym[region] == "RFE"
                        shift = Point2f(-0.03, -0.18)
                    end

                    if ipcc_acronym[region] == "NEN"
                        shift = Point2f(0.08, 1.4)
                    end
                    if ipcc_acronym[region] == "ENA"
                        shift = Point2f(0.09, 1.4)
                    end
                    if ipcc_acronym[region] == "EAS"
                        shift = Point2f(-0.05, 0.5)
                    end
                else
                    shift = Point2f(0.22, 0.5)
                    
                end
            end
            
            df = read_ori_data(vegetation_type, xtreme,  region)
            t2m_a, tp_a = winter_climate_anomaly(df)

            mean_t2m_a = mean(t2m_a)
            mean_tp_a = mean(tp_a)
            
            df, df_w = read_logreg_df(vegetation_type, xtreme, region)
            
            if winter_significance(df, df_w)
                    text!(ax, Point2f(mean_t2m_a, mean_tp_a) - shift, text=ipcc_acronym[region])
            end 
        end    
    end
end

function coef_text(ax, vegetation_type, xtreme)
    for (i, regions) in enumerate(region_list)
        df, df_w = read_logreg_df(vegetation_type, xtreme, regions)
        print(regions)
        if vegetation_type == "crop"
            if xtreme == "low"
                shift = Point2f(0.012, 0.015)

                if ipcc_acronym[regions] == "CNA"
                    shift = Point2f(0.020, 0.015)
                end
                if ipcc_acronym[regions] == "EAS"
                    shift = Point2f(0.005, 0.015)
                end
            else
                shift = Point2f(0.07, 0.01)
                if ipcc_acronym[regions] == "ECA"
                    shift = Point2f(-0.01,  0.020)
                end

            end
        else
            

            if xtreme == "low"
                shift = Point2f(0.012, 0.015)
                if ipcc_acronym[regions] == "ENA"
                    shift = Point2f(0.030, 0.010)
                end
                if ipcc_acronym[regions] == "WSB"
                    shift = Point2f(0.02, 0.013)
                end
            else
                shift = Point2f(0.07, 0.01)
                if ipcc_acronym[regions] == "EAS"
                    shift = Point2f(0.018, - 0.010)
                end

                if ipcc_acronym[regions] == "RFE"
                    shift = Point2f(-0.025,  0.01)
                end
                if ipcc_acronym[regions] == "MED"
                    shift = Point2f(0.05,  0.02)
                end
            end
        end


        if !ismissing(df)
            if winter_significance(df, df_w)
                text!(ax, Point2f(mean(df_w[!, "t2m_winter"]),  mean(df_w[!, "tp_winter"])) - shift, text=ipcc_acronym[regions])
            end
        end
    end
end


f = Figure(resolution=(1200, 1000))
ax1 = Axis(f[2,1], xgridvisible = false, ygridvisible = false, xlabel="Winter temperature coefficient", ylabel="Winter precipitaiton coefficient", title = "Low vegetation activity")
ax2 = Axis(f[2,2], xgridvisible = false, ygridvisible = false, xlabel="Winter temperature coefficient", ylabel="Winter precipitaiton coefficient", title = "High vegetation activity")
ax3 = Axis(f[3,1], xgridvisible = false, ygridvisible = false, xlabel="Winter temperature anomaly", ylabel="Winter precipitaiton anomaly")
ax4 = Axis(f[3,2], xgridvisible = false, ygridvisible = false, xlabel="Winter temperature anomaly", ylabel="Winter precipitaiton anomaly")


coefficient_boxplot(ax1, "crop", "low")
coefficient_boxplot(ax1, "forest", "low")
coef_text(ax1, "crop", "low")
coef_text(ax1, "forest", "low")
f
coefficient_boxplot(ax2, "crop", "high")
coefficient_boxplot(ax2, "forest", "high")
coef_text(ax2, "crop", "high")
coef_text(ax2, "forest", "high")
f
plot_anomalies(ax3, "crop", "low")
plot_anomalies(ax3, "forest", "low")
plot_anomalies(ax4, "crop", "high")
plot_anomalies(ax4, "forest", "high")
f
anomalies_text(ax3, "crop", "low")
anomalies_text(ax3, "forest", "low")
anomalies_text(ax4, "crop", "high")
anomalies_text(ax4, "forest", "high")

f
elem_1 = MarkerElement(color = :grey80, marker = :diamond, markersize = 15, points=Point2f[(0.5,0.5)])
elem_2 = MarkerElement(color = :grey80, marker = :star4, markersize = 15, points=Point2f[(0.5,0.5)])
elem_3 = MarkerElement(color = palette["orange"], marker = :diamond, markersize = 15, points=Point2f[(0.5,0.5) ])
elem_4 = MarkerElement(color = palette["mint"], marker = :star4, markersize = 15, points=Point2f[(0.5,0.5)])

Legend(f[1,1:2], [elem_1, elem_2, elem_3, elem_4], ["Crop Region", "Forest Region", "Significant winter (Crop)", "Significant winter (Forest)"], orientation= :horizontal)

f

save("images/winter_coefficient_anomaly_v2.pdf", f)