using DataFrames
using CSV


function read_log_df(vegetation, xtreme)
    ds_path = "/Users/anand/Documents/data/pcv/plot_data/"
    fname = "log_$(vegetation)_$(xtreme)_v3.csv"
    df = DataFrame(CSV.File(joinpath(ds_path, fname), header=1, delim="\t"))

    return df
end

function ipcc_regions()
    return sort(collect(keys(ipcc_acronym)))
end 

function crop_forest_location()

    crop_mask = transpose(npzread("/Users/anand/Documents/data/pcv/crop_data/crop_mask_v2.npy"))
    forest_mask = transpose(npzread("/Users/anand/Documents/data/pcv/forest_data/forest_mask_v2.npy"))

    lon = [-179.75:0.25:180;]
    lat = [25:0.25:74.25;]

    c = Point2f[]
    f = Point2f[]

    for i=1:1440
        for j=1:200
            
            if crop_mask[i, j] == true
                push!(c, Point2f(lon[i], lat[j]))  
            end

            if forest_mask[i, j] == true
                push!(f, Point2f(lon[i], lat[j]))                
            end

        end
    end
    return c, f
end

function read_logreg_df(vegetation_type, xtreme, region_name)

    ds_path = "/Users/anand/Documents/data/pcv/plot_data/$(vegetation_type)_data/$(xtreme)/"
    fname = [path for path in readdir(ds_path) if occursin("logreg_$(vegetation_type)_$(xtreme)_$(region_name)",path)]
    fname_w = [path for path in readdir(ds_path) if occursin("logreg_winter_$(vegetation_type)_$(xtreme)_$(region_name)",path)]

    if !isempty(fname)
        df = DataFrame(CSV.File(joinpath(ds_path, fname[1]), header=1, delim="\t"))
        df_w = DataFrame(CSV.File(joinpath(ds_path, fname_w[1]), header=1, delim="\t"))

        return df, df_w
    else
        return missing, missing
    end
end

function read_ori_data(vegetation_type, xtreme, region_name)
    ds_path = "/Users/anand/Documents/data/pcv/plot_data/$(vegetation_type)_data/$(xtreme)/"
    fname = [path for path in readdir(ds_path) if (startswith(path, "$(vegetation_type)_$(xtreme)_$(region_name)") & (occursin("v3.csv", path)) )  ]
    if !isempty(fname)
        df = DataFrame(CSV.File(joinpath(ds_path, fname[1]), header=1, delim="\t"))
    
        return df
    else
        return missing
    end
end


function winter_significance(df, df_w)
    diff = max(mean(df_w[!,"AUC"]) - quantile(df[!,"AUC"], 0.95),0)

    return diff>0
end

function anomaly(df, var_name)
    return df[!, var_name][df[!, "lai_su"] .== 1] .- mean(df[!, var_name])
end

function winter_climate_anomaly(df)
    return anomaly(df, "t2m_w"), anomaly(df, "tp_w")
end

palette = Dict(    
    "light_blue"=> "#77AADD",
    "light_cyan"=> "#99DDFF",
    "mint" =>  "#44BB99",
    "pear" =>  "#BBCC33",
    "olive" =>  "#AAAA00",
    "light_yellow" =>  "#EEDD88",
    "orange" =>  "#EE8866",
    "pink" =>  "#FFAABB",
    "pale_grey" =>  "#DDDDDD",
    )

crop_gradient = range(colorant"#EE8866", stop = colorant"white", length=10)
forest_gradient = range(colorant"#44BB99", stop = colorant"white", length=10)

# index_significant = Dict(
#     "C.North-America" => 1,
#     "E.Asia" => 2,
#     "E.C.Asia" => 3,
#     "E.Siberia" => 4,
#     "E.Europe" => 5,
#     "E.North-America" => 6,
#     "Mediterranean" => 7,
#     "N.E.North-America" => 8,
#     "Russian-Arctic" => 9,
#     "Russian-Far-East" => 10,
#     "W.Siberia" => 11,
#     "W.C.Asia" => 12,
# )

ipcc_acronym = Dict(
"C.North-America" => "CNA",
 "E.Asia" => "EAS",
 "E.C.Asia" => "ECA",
 "E.Europe" => "EEU",
 "E.North-America" => "ENA",
 "E.Siberia" => "ESB",
 "Mediterranean" => "MED",
 "N.Central-America" => "NCA",
 "N.E.North-America" => "NEN",
 "N.Europe" => "NEU",
 "N.W.North-America" => "NWN",
 "Russian-Arctic" => "RAR",
 "Russian-Far-East" => "RFE",
 "S.Asia" => "SAS",
 "Tibetan-Plateau" => "TIB",
 "W.C.Asia" => "WCA",
 "W.North-America" => "WNA",
 "W.Siberia" => "WSB",
 "West&Central-Europe" => "WCE",
)

ipcc_acronym_full = Dict(
 "Central North-America" => "CNA",
 "East Asia" => "EAS",
 "Eastern Central Asia" => "ECA",
 "Eastern Europe" => "EEU",
 "Eastern North-America" => "ENA",
 "Eastern Siberia" => "ESB",
 "Mediterranean" => "MED",
 "North Central-America" => "NCA",
 "Northeastern North-America" => "NEN",
 "Northern Europe" => "NEU",
 "Northwestern North-America" => "NWN",
 "Russian Arctic" => "RAR",
 "Russian Far East" => "RFE",
 "South Asia" => "SAS",
 "Tibetan Plateau" => "TIB",
 "Western Central Asia" => "WCA",
 "Western North America" => "WNA",
 "Western Siberia" => "WSB",
 "West & Central Europe" => "WCE",
)