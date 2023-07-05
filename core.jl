using HDF5

function read_data(fname)
    fid = h5open(fname, "r")
    a_others = fid["a_others"][:,:]
    a_self = fid["a_self"][:,:]
    ei_others = fid["ei_others"][:,:,:]
    ei_self = fid["ei_self"][:,:,:]
    y_true = fid["y_true"][:]
    year = fid["year"][1,:]
    data = fid["data"][1,:,:]

    return a_others, year, y_true, data, ei_others
end

# readdir("/Users/anand/Documents/data/pcv/attention/")
# file_list = []

# function get_file_paths(xtreme, vegetation_type):
    
#     file_list = []
#     for files in readdir("/Users/anand/Documents/data/pcv/attention/")
#         if 
#     end
# end