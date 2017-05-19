using BenchmarkTools
using QuantumOptics
using Base.Cartesian

b1 = FockBasis(8)
b2 = SpinBasis(1//2)
b3 = NLevelBasis(4)
# b4 = NLevelBasis(3)

b = tensor(b1, b2, b3)

h1 = destroy(b1)
h3 = transition(b3, 1, 2)
# h1 = SparseOperator(b1, b1, sparse([1. 2.; 3. 4.]))
# h3 = SparseOperator(b3, b3, sparse([1. -1.; -2. 5.]))
indices = [1, 3]
h_list = [h1, h3]
# h = LazyTensor(b, indices, map(full, h_list))
h = LazyTensor(b, indices, h_list)


op = DenseOperator(b, b, ones(Complex128, length(b), length(b)))
result = DenseOperator(b, b, zeros(Complex128, length(b), length(b)))
alpha = complex(1.)
beta = complex(0.)

function _strides(shape::Vector{Int})
    N = length(shape)
    S = Vector{Int}(N)
    S[N] = 1
    @inbounds for m=N-1:-1:1
        S[m] = S[m+1]*shape[m+1]
    end
    return S
end


function f0(alpha::Complex128, indices::Vector{Int}, h::Vector{SparseOperator}, op::DenseOperator, beta::Complex128, result::DenseOperator)
    h_ = embed(op.basis_l, op.basis_r, indices, h)
    operators.gemm!(alpha, h_, op, beta, result)
end

function f1(alpha::Complex128, h::LazyTensor, op::DenseOperator, beta::Complex128, result::DenseOperator)
    h_ = sparse(h)
    operators.gemm!(alpha, h_, op, beta, result)
end

"""
Recursively calculate result_{JI} = \\sum_K h_{JK} op_{KI}
"""
function _gemm_recursive_lazy_dense(i_k::Int, N_k::Int, K::Int, J::Int, val::Complex128,
                        shape::Vector{Int}, strides_k::Vector{Int}, strides_j::Vector{Int},
                        indices::Vector{Int}, h::LazyTensor,
                        op::Matrix{Complex128}, result::Matrix{Complex128})
    if i_k > N_k
        for I=1:size(op, 2)
            result[J, I] += val*op[K, I]
        end
        return nothing
    end
    if i_k in indices
        h_i = operators_lazy.suboperator(h, i_k)
        if isa(h_i, SparseOperator)
            h_i_data = h_i.data::SparseMatrixCSC{Complex128,Int}
            @inbounds for k=1:shape[i_k]
                K_ = K + strides_k[i_k]*(k-1)
                @inbounds for jptr=h_i_data.colptr[k]:h_i_data.colptr[k+1]-1
                    j = h_i_data.rowval[jptr]
                    J_ = J + strides_j[i_k]*(j-1)
                    val_ = val*h_i_data.nzval[jptr]
                    _gemm_recursive_lazy_dense(i_k+1, N_k, K_, J_, val_, shape, strides_k, strides_j, indices, h, op, result)
                end
            end
        elseif isa(h_i, DenseOperator)
            h_i_data = h_i.data::Matrix{Complex128}
            for k=1:shape[i_k]
                K_ = K + strides_k[i_k]*(k-1)
                for j=1:shape[i_k]
                    J_ = J + strides_j[i_k]*(j-1)
                    val_ = val*h_i_data[j,k]
                    _gemm_recursive_lazy_dense(i_k+1, N_k, K_, J_, val_, shape, strides_k, strides_j, indices, h, op, result)
                end
            end
        end
    else
        @inbounds for k=1:shape[i_k]
            K_ = K + strides_k[i_k]*(k-1)
            J_ = J + strides_j[i_k]*(k-1)
            _gemm_recursive_lazy_dense(i_k + 1, N_k, K_, J_, val, shape, strides_k, strides_j, indices, h, op, result)
        end
    end
end

function f3(alpha::Complex128, h::LazyTensor, op::DenseOperator, beta::Complex128, result::DenseOperator)
    if beta == Complex128(0.)
        fill!(result.data, beta)
    elseif beta != Complex128(1.)
        scale!(beta, result.data)
    end
    N_k = length(op.basis_l.bases)
    val = alpha
    shape = op.basis_l.shape
    strides_k = _strides(shape)
    strides_j = _strides(result.basis_r.shape)
    _gemm_recursive_lazy_dense(1, N_k, 1, 1, alpha, shape, strides_k, strides_j, h.indices, h, op.data, result.data)
end

println("size: ", size(full(h).data))
result0 = DenseOperator(b, b, zeros(Complex128, length(b), length(b)))
f0(alpha, indices, h_list, op, beta, result0)

result3 = DenseOperator(b, b, zeros(Complex128, length(b), length(b)))
@time f3(alpha, h, op, beta, result3)

result3 = DenseOperator(b, b, zeros(Complex128, length(b), length(b)))
@time f3(alpha, h, op, beta, result3)

x = (full(h)*op).data
println(sum(abs(x-result0.data)))
println(sum(abs(x-result3.data)))

# r0 = @benchmark f0(alpha, indices, h_list, op, beta, result0)
# r1 = @benchmark f1(alpha, h, op, beta, result0)
# r3 = @benchmark f3(alpha, h, op, beta, result3)

# println(r3)
