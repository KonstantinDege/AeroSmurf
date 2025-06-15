module CreateTable
using DataFrames, JSON

function create_rec_table(path)
	out = DataFrame()
	try
		js = JSON.parsefile(path)
		for (key, v) in js
			df = DataFrame(v)
			df.shape .= k
			df.color .= key
			out = vcat(out, df)
		end
	catch
		return DataFrame()
	end
	return out
end





end
