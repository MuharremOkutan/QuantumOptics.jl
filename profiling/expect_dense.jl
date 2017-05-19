using BenchmarkTools
using QuantumOptics

srand(0)

N = 3

function f1(A::Matrix{Complex128}, B::Matrix{Complex128})::Complex128
    trace(A*B)
end

function f2(A::Matrix{Complex128}, B::Matrix{Complex128})
    result = complex(0.)
    @inbounds for i=1:size(A, 1), j=1:size(A,2)
        result += A[i,j]*B[j,i]
    end
    result
end

function f3(A::Matrix{Complex128}, B::Matrix{Complex128})
    result = Complex128(0.)
    @inbounds for j=1:size(A, 1), i=1:size(A,2)
        result += A[i,j]*B[j,i]
    end
    result
end

A = rand(Complex128, N, N)
B = rand(Complex128, N, N)

@assert f1(A, B) ≈ f2(A, B) ≈ f3(A, B)
r1 = @benchmark f1($A, $B)
r2 = @benchmark f2($A, $B)
r3 = @benchmark f3($A, $B)
