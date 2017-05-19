using BenchmarkTools
using QuantumOptics

srand(0)

N = 100

function f1(A::Matrix{Complex128}, v::Vector{Complex128})::Complex128
    (v' * A * v)[1]
end

function f2(A::Matrix{Complex128}, v::Vector{Complex128})
    result = Complex128(0.)
    @inbounds for i=1:size(A, 1)
        vi = conj(v[i])
        @inbounds for j=1:size(A,2)
            result += vi*A[i,j]*v[j]
        end
    end
    result
end

function f3(A::Matrix{Complex128}, v::Vector{Complex128})
    result = Complex128(0.)
    N, M = size(A)
    @inbounds for j=1:N, i=1:M
        result += conj(v[i])*A[i,j]*v[j]
    end
    result
end

A = rand(Complex128, N, N)
B = rand(Complex128, N)

# f1(A,B)
@assert f1(A, B) ≈ f2(A, B) ≈ f3(A, B)
r1 = @benchmark f1($A, $B)
r2 = @benchmark f2($A, $B)
r3 = @benchmark f3($A, $B)
