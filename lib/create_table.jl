module CreateTable
using DataFrames, JSON

function create_rec_table(path)
	out = DataFrame()
	try
		js = JSON.parsefile(path)
		for (key, v) in js
			df = DataFrame(v)
			df.color .= key
			out = vcat(out, df)
		end
		select!(out, Not([:time, :ids]))
	catch
		return DataFrame()
	end
	return out
end





end
