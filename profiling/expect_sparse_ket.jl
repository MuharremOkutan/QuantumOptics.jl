using BenchmarkTools
using QuantumOptics

srand(0)

typealias SparseMatrix SparseMatrixCSC{Complex128}

N = 100

function f1(A::SparseMatrix, v::Vector{Complex128})
    (v'*A*v)[1]
end

function f2(A::SparseMatrix, v::Vector{Complex128})::Complex128
    result::Complex128 = complex(0.)
    @inbounds for colindex = 1:A.n
        for i=A.colptr[colindex]:A.colptr[colindex+1]-1
            result += A.nzval[i]*v[colindex]*conj(v[A.rowval[i]])
        end
    end
    result
end

v = rand(Complex128, N)
A1 = sprand(Complex128, N, N, 1.)
A2 = sprand(Complex128, N, N, 0.1)
A3 = sprand(Complex128, N, N, 0.01)
A4 = sprand(Complex128, N, N, 0.001)

@assert f1(A1, v) ≈ f2(A1, v)
r1 = @benchmark f1($A1, $v)
r2 = @benchmark f2($A1, $v)
