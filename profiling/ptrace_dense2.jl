using QuantumOptics
using Base.Cartesian

srand(0)

b1 = FockBasis(2)
b2 = SpinBasis(1//2)
b3 = NLevelBasis(4)
b4 = NLevelBasis(2)
b = tensor(b1, b2)


# Partial trace for dense operators.
function _strides(shape::Vector{Int})
    N = length(shape)
    S = zeros(Int, N)
    S[N] = 1
    for m=N-1:-1:1
        S[m] = S[m+1]*shape[m+1]
    end
    return S
end


@generated function _ptrace{RANK}(rank::Array{Int,RANK}, a::Matrix{Complex128},
                                  shape_l::Vector{Int}, shape_r::Vector{Int},
                                  indices::Vector{Int})
    return quote
        a_strides_l = _strides(shape_l)
        result_shape_l = deepcopy(shape_l)
        result_shape_l[indices] = 1
        result_strides_l = _strides(result_shape_l)
        a_strides_r = _strides(shape_r)
        result_shape_r = deepcopy(shape_r)
        result_shape_r[indices] = 1
        result_strides_r = _strides(result_shape_r)
        N_result_l = prod(result_shape_l)
        N_result_r = prod(result_shape_r)
        result = zeros(Complex128, N_result_l, N_result_r)
        @nexprs 1 (d->(Jr_{$RANK}=1;Ir_{$RANK}=1))
        @nloops $RANK ir (d->1:shape_r[d]) (d->(Ir_{d-1}=Ir_d; Jr_{d-1}=Jr_d)) (d->(Ir_d+=a_strides_r[d]; if !(d in indices) Jr_d+=result_strides_r[d] end)) begin
            @nexprs 1 (d->(Jl_{$RANK}=1;Il_{$RANK}=1))
            @nloops $RANK il (k->1:shape_l[k]) (k->(Il_{k-1}=Il_k; Jl_{k-1}=Jl_k; if (k in indices && il_k!=ir_k) Il_k+=a_strides_l[k]; continue end)) (k->(Il_k+=a_strides_l[k]; if !(k in indices) Jl_k+=result_strides_l[k] end)) begin
                #println("Jl_0: ", Jl_0, "; Jr_0: ", Jr_0, "; Il_0: ", Il_0, "; Ir_0: ", Ir_0)
                result[Jl_0, Jr_0] += a[Il_0, Ir_0]
            end
        end
        return result
    end
end

const cached_zeros = [zeros(Int, [0 for i=1:N]...) for N=1:20]

function rank_(N)
    cached_zeros[N]
    # zeros(Int, [0 for i=1:N]...)
end

function ptrace1(a::DenseOperator, indices::Vector{Int})
    operators.check_ptrace_arguments(a, indices)
    if length(a.basis_l.shape) == length(indices)
        return trace(a)
    end
    rank = rank_(length(a.basis_l.shape))
    result = _ptrace(rank, a.data, a.basis_l.shape, a.basis_r.shape, indices)
    return DenseOperator(ptrace(a.basis_l, indices), ptrace(a.basis_r, indices), result)
end


randop(b) = DenseOperator(b, rand(Complex128, length(b), length(b)))

op = randop(b)

function run_ptrace1(N::Int, op::DenseOperator, indices::Vector{Int})
    for i=1:N
        ptrace1(op, indices)
    end
end

@time run_ptrace1(1, op, [1,2])
@time run_ptrace1(10000, op, [1])

@profile run_ptrace1(10000, op, [1])