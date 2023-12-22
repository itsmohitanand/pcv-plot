using CairoMakie
using DataFrames
using CSV
using Statistics
using NPZ
using Random
using EvalMetrics
using StatsBase
using LaTeXStrings



include("core.jl")
palette

p_list = [val for (k, val) in palette if k!="pale_grey"]

# Simple schematic showing the methodology

regions = ipcc_regions()

function standard_norm(df)
    for i in names(df)
        if (i != "# year") && (i!="lai_su")
            df[!, i] .= (df[!, i] .- mean(df[!, i]))  / std(df[!, i]) 
        end
    end
    return df    
end

vegetation_type = "crop"
xtreme = "high"

function concatenate_z_season(df, var_name)
    var = zeros(3,size(df)[1])

    if var_name == "lai"
        var[2, :] = zscore(df[!, var_name*"_sp"])
        var[3, :] = zscore(df[!, var_name*"_su"])
    
    else

        var[1, :] = zscore(df[!, var_name*"_w"])
        var[2, :] = zscore(df[!, var_name*"_sp"])
        var[3, :] = zscore(df[!, var_name*"_su"])

    end

    return var
end

function get_anomaly(vegetation_type, xtreme, region)
    df = read_ori_data(vegetation_type, xtreme, region)
    
    if xtreme == "high"
        val = [10,20,30]
        color = palette["light_yellow"]
    elseif xtreme == "low"
        val = [12,22,32]
        color = palette["pink"]
    end

    if !ismissing(df)
        

        df_linreg = select(df, Not([:sd_w, :sd_sp, :sd_su]))
        
        df = filter(row -> all(!isnan, row), df)
        df_linreg = filter(row -> all(!isnan, row), df_linreg)
        
        t2m = concatenate_z_season(df_linreg,"t2m")
        tp = concatenate_z_season(df_linreg,"tp")
        sm = concatenate_z_season(df_linreg,"sm")
        lai = concatenate_z_season(df_linreg,"lai")
        sd = concatenate_z_season(df, "sd")

        t2m = t2m[:, df[!, "lai_su"].==1]
        tp = tp[:,df[!, "lai_su"].==1, :]
        sm = sm[:,df[!, "lai_su"].==1, :]
        lai = lai[:,df[!, "lai_su"].==1, :]
        sd = sd[:,df[!, "lai_su"].==1, :]

        # df = df[df[!, "lai_su"].==1, :]
        # df_linreg = df_linreg[df_linreg[!, "lai_su"].==1, :]

        var = [mean(t2m, dims=2); mean(tp, dims=2); mean(sm, dims=2); mean(sd, dims=2); mean(lai, dims=2)[2]]
        out = zeros(13)
        out[1] = var[1]
        out[2] = var[4]
        out[3] = var[7]
        out[4] = var[10]
        out[5] = var[2]
        out[6] = var[5]
        out[7] = var[8]
        out[8] = var[11]
        out[9] = var[13]
        out[10] = var[3]
        out[11] = var[6]
        out[12] = var[9]
        # out[13] = var[12] # remove sd in summer.

    else
        out = missing
    end
    return out
end


### Always run from here

ch = [1:13;]
cl = [1:13;]
fh = [1:13;]
fl = [1:13;]

name_ch = []
name_cl = []
name_fh = []
name_fl = []

for vegetation_type in ["forest", "crop"]
    for xtreme in ["low", "high"]
        
        for region in regions
            
            out = get_anomaly(vegetation_type, xtreme, region)
            
            if !ismissing(out)
                df, df_w = read_logreg_df(vegetation_type, xtreme, region)
                if !ismissing(df)
                    if winter_significance(df, df_w)
                        if vegetation_type == "forest"
                            if xtreme == "low"
                                fl = hcat(fl, out)
                                push!(name_fl, region)
                            else
                                fh = hcat(fh, out)
                                push!(name_fh, region)
                            end
                        else
                            if xtreme == "low"
                                cl = hcat(cl, out)
                                push!(name_cl, region)
                            else
                                ch = hcat(ch, out)
                                push!(name_ch, region)

                            end
                        end
                    end
                end
            end
        end
    end
end


cl = cl[:, 2:end]
# cl_std = cl ./ std(cl, dims=2)

ch = ch[:, 2:end]
# ch_std = ch ./ std(ch, dims=2)

fl = fl[:, 2:end]
# fl_std = fl ./ std(fl, dims=2)

fh = fh[:, 2:end]
# fh_std = fh ./ std(fh, dims=2)


latexstring("(W) T [ ^{\textdegre")

xticks = ([1:12;], ["(W) T", "(W) P ", "(W) SM ", "(W) SD", "(Sp) T", "(Sp) P", "(Sp) SM ", "(Sp) SD", "(Sp) LAI", "(Su) T", "(Su) P", "(Su) SM "] )

f = Figure(resolution=(1400,800))
ax_cl = Axis(f[1,1], title = "Crop | Low LAI",  yticks= ([1:5;],[ipcc_acronym[name] for name in name_cl]), xticks = ([1:13;], ["" for i=1:13]))
ax_ch = Axis(f[1,2], title = "Crop | High LAI", yticks= ([1:5;],[ipcc_acronym[name] for name in name_ch]), xticks = ([1:13;], ["" for i=1:13]))
ax_fl = Axis(f[2,1], title = "Forest | Low LAI", yticks= ([1:7;],[ipcc_acronym[name] for name in name_fl]), xticks = xticks, xticklabelrotation=π/3)
ax_fh = Axis(f[2,2], title = "Forest | High LAI", yticks= ([1:7;],[ipcc_acronym[name] for name in name_fh]), xticks = xticks, xticklabelrotation=π/3, xgridvisible=false, ygridvisible=false)

jointlimits = (-1,1)
heatmap!(ax_cl, cl[1:end-1, :], colormap=:BrBG_5, colorrange = jointlimits)
heatmap!(ax_ch, ch[1:end-1, :], colormap=:BrBG_5, colorrange = jointlimits)
heatmap!(ax_fl, fl[1:end-1, :], colormap=:BrBG_5, colorrange = jointlimits)
h = heatmap!(ax_fh, fh[1:end-1, :], colormap=:BrBG_5, colorrange = jointlimits)
f

function plot_text(ax, data)
    for x=1:size(data)[1]
        for y=1:size(data)[2]
        text!(ax, 
            string(round(data[x,y], digits=2)), 
            position = [Point2f(x,y)], 
            align=(:center, :center),
            fontsize=14,
            color = ifelse(abs(data[x,y]) < 1.0, :grey20, :white),
            )
        end
    end
end

plot_text(ax_cl, cl[1:end-1, :])
plot_text(ax_ch, ch[1:end-1, :])
plot_text(ax_fl, fl[1:end-1, :])
plot_text(ax_fh, fh[1:end-1, :])

Colorbar(f[1:2,3], h)
f

save("images/anomaly_v2.pdf", f)
f
