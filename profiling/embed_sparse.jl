using BenchmarkTools
using QuantumOptics

function f(basis_l::CompositeBasis, basis_r::CompositeBasis,
                indices::Vector{Int}, operators::Vector{SparseOperator})
    result = SparseOperator(basis_l, basis_r)

end

b1 = FockBasis(10)
b2 = SpinBasis(1//2)
b3 = NLevelBasis(10)
b4 = NLevelBasis(10)

b = tensor(b1, b2, b3, b4)

op1 = destroy(b1)
op3 = transition(b3, 1, 2)
ops = [op1, op3]
indices = [1, 3]

function run_embed(N, b, indices, ops)
    for i=1:N
        embed(b, b, indices, ops)
    end
end

N = 10000
run_embed(1, b, indices, ops)
Profile.clear()
@profile run_embed(N, b, indices, ops)
