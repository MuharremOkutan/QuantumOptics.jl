using BenchmarkTools


function reducedindices1(I_::Vector{Int}, I::Vector{Int})
    Int[findfirst(j->i==j, I) for i in I_]
end

function reducedindices2(I_::Vector{Int}, I::Vector{Int})
    N = length(I_)
    x = Vector{Int}(N)
    for n in 1:N
        x[n] = findfirst(I, I_[n])
    end
    x
end

function reducedindices2!(I_::Vector{Int}, I::Vector{Int})
    for n in 1:length(I_)
        I_[n] = findfirst(I, I_[n])
    end
end


# I_ = [5, 6]
# I = [1, 2, 3, 4, 5, 6]

I_ = []

println(reducedindices1(I_, I))
println(reducedindices2(I_, I))
reducedindices2!(I_, I)
println(I_)

r1 = @benchmark reducedindices1($I_, $I)
r2 = @benchmark reducedindices2($I_, $I)
r3 = @benchmark reducedindices2!($I_, $I)
# r3 = @benchmark f3($x, $I)

println(r1)
println(r2)
println(r3)
