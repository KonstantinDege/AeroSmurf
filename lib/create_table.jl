module CreateTable
using DataFrames, JSON

function create_rec_table(path)
    out = DataFrame()
    try
        js = JSON.parsefile(path)
        for (key, value) in js
            for (k, v) in value
                df = DataFrame(v)
                df.shape .= k
                df.color .= key
                out = vcat(out, df)
            end
        end
    catch
        return DataFrame()
    end
    return out
end





end
