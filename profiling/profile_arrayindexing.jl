using BenchmarkTools


function f1(x::Vector{Int}, I::Vector{Int})
    [x[i] for i in I]
end

function f2(x::Vector{Int}, I::Vector{Int})
    x[I]
end

function f3(x::Vector{Int}, I::Vector{Int})
    N = length(I)
    y = Vector{Int}(N)
    for i in 1:N
        y[i] = x[I[i]]
    end
    y
end


x = [1:10;]
I = [2, 4, 5]

println(f1(x, I))
println(f2(x, I))
println(f3(x, I))

r1 = @benchmark f1($x, $I)
r2 = @benchmark f2($x, $I)
r3 = @benchmark f3($x, $I)

println(r1)
println(r2)
println(r3)
