using BenchmarkTools
using QuantumOptics

srand(0)

typealias SparseMatrix SparseMatrixCSC{Complex128}

N = 1000

function f1(A::SparseMatrix, B::Matrix{Complex128})
    trace(A*B)
end

function f2(A::SparseMatrix, B::Matrix{Complex128})::Complex128
    result::Complex128 = complex(0.)
    @inbounds for colindex = 1:A.n
        for i=A.colptr[colindex]:A.colptr[colindex+1]-1
            result += A.nzval[i]*B[colindex, A.rowval[i]]
        end
    end
    result
end

B = rand(Complex128, N, N)
A1 = sprand(Complex128, N, N, 1.)
A2 = sprand(Complex128, N, N, 0.1)
A3 = sprand(Complex128, N, N, 0.01)
A4 = sprand(Complex128, N, N, 0.001)

@assert f1(A1, B) ≈ f2(A1, B)
r1 = @benchmark f1($A1, $B)
r2 = @benchmark f2($A1, $B)
