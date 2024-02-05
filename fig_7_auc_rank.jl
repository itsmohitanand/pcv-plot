using CairoMakie
using StatsBase

include("core.jl")

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
    ax =Axis(f[ax_loc[1], ax_loc[2]], xticks = (x, xticklabels), xticklabelrotation = π/2, title=title, xgridvisible=false, ygridvisible=false, ylabel="Difference in AUROC")

    
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

f = Figure(resolution=(1200,800))

rank_auc_diff(f, [1,1], auc_cl, palette["orange"], "Low LAI (Crop)")
rank_auc_diff(f, [1,2], auc_ch, palette["orange"], "High LAI (Crop)")
rank_auc_diff(f, [2,1], auc_fl, palette["mint"], "Low LAI (Forest)")
rank_auc_diff(f, [2,2], auc_fh, palette["mint"], "HIgh LAI (Forest)")


left_pad = 15
top_pad = 15

Label(
f[1, 1, TopLeft()],
    "a)",
    font = "TeX Gyre Heros Bold",
    fontsize = 22,
    padding = (0, left_pad, top_pad, 0),
    halign = :right,
    )

Label(
f[1, 2, TopLeft()],
    "b)",
    font = "TeX Gyre Heros Bold",
    fontsize = 22,
    padding = (0, left_pad, top_pad, 0),
    halign = :right,
    )


Label(
f[2, 1, TopLeft()],
    "c)",
    font = "TeX Gyre Heros Bold",
    fontsize = 22,
    padding = (0, left_pad, top_pad, 0),
    halign = :right,
    )

Label(
f[2, 2, TopLeft()],
    "d)",
    font = "TeX Gyre Heros Bold",
    fontsize = 22,
    padding = (0, left_pad, top_pad, 0),
    halign = :right,
    )

f
save("images/rank_auc_diff.pdf", f)