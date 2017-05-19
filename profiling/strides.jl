using BenchmarkTools

shape = [4,2,6,1]

function _strides1(shape::Vector{Int})
    N = length(shape)
    S = zeros(Int, N)
    S[N] = 1
    for m=N-1:-1:1
        S[m] = S[m+1]*shape[m+1]
    end
    return S
end

function _strides2(shape::Vector{Int})
    N = length(shape)
    S = Vector{Int}(N)
    S[N] = 1
    for m=N-1:-1:1
        S[m] = S[m+1]*shape[m+1]
    end
    return S
end

function _strides3(shape::Vector{Int})
    N = length(shape)
    S = Vector{Int}(N)
    S[N] = 1
    sm1 = 1
    sm = 1
    for m=N-1:-1:1
        sm = sm1*shape[m+1]
        S[m] = sm
        sm1 = sm
    end
    return S
end

function run_strides1(N, shape)
    for n=1:N
        _strides1(shape)
    end
end

function run_strides2(N, shape)
    for n=1:N
        _strides2(shape)
    end
end

println(_strides1(shape))
println(_strides2(shape))
println(_strides3(shape))

run_strides2(1, shape)
Profile.clear()
@profile run_strides2(10000000, shape)
# @time _strides2(shape)

# r1 = @benchmark _strides1($shape)
# r2 = @benchmark _strides2($shape)
# r3 = @benchmark _strides3($shape)

# println(r1)
# println(r2)
# println(r3)
