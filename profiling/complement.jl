using BenchmarkTools

N = 6
indices = [1, 4]

complement1(N::Int, indices::Vector{Int}) = Int[i for i=1:N if i ∉ indices]

function complement2(N::Int, indices::Vector{Int})
    x = Vector{Int}(N - length(indices))
    i_ = 1
    for i=1:N
        if i ∉ indices
            x[i_] = i
            i_ += 1
        end
    end
    x
end
function complement3(N::Int, indices::Vector{Int})
    L = length(indices)
    x = Vector{Int}(N - L)
    i_ = 1 # Position in the x vector
    j = 1 # Position in indices vector
    for i=1:N
        if j > L || indices[j]!=i
            x[i_] = i
            i_ += 1
        else
            j += 1
        end
    end
    x
end

println(complement1(N, indices))
println(complement2(N, indices))
println(complement3(N, indices))

r1 = @benchmark complement1($N, $indices)
r2 = @benchmark complement2($N, $indices)
r3 = @benchmark complement3($N, $indices)

println(r1)
println(r2)
println(r3)
