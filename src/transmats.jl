
module TransMats

mutable struct TransMat
    inds::Vector{Int}
    mat::Array{Float64, 2}
end

TransMat(mat::Array{Float64, 2}) = TransMat(collect(1:size(mat, 1)), mat)


function matswap!(x::TransMat, i::Int, j::Int)
    x.inds[i], x.inds[j] = x.inds[j], x.inds[i]
    for k in axes(x.mat, 1)
        x.mat[k, i], x.mat[k, j] = x.mat[k, j], x.mat[k, i]
    end
    for l in axes(x.mat, 2)
        x.mat[i, l], x.mat[j, l] = x.mat[j, l], x.mat[i, l]
    end
end



function matswapRowfirst!(x::TransMat, i::Int, j::Int)
    x.inds[i], x.inds[j] = x.inds[j], x.inds[i]
    for k in axes(x.mat, 1)
        x.mat[k, i], x.mat[k, j] = x.mat[k, j], x.mat[k, i]
    end
    for l in axes(x.mat, 2)
        x.mat[i, l], x.mat[j, l] = x.mat[j, l], x.mat[i, l]
    end
end


function matswapColfirst!(x::TransMat, i::Int, j::Int)
    x.inds[i], x.inds[j] = x.inds[j], x.inds[i]
    for k in axes(x.mat, 1)
        x.mat[k, i], x.mat[k, j] = x.mat[k, j], x.mat[k, i]
    end
    for l in axes(x.mat, 2)
        x.mat[i, l], x.mat[j, l] = x.mat[j, l], x.mat[i, l]
    end
end

end # module