using QuantumOptics

indices2mask(N::Int, indices::Vector{Int}) = (m = BitArray{1}(N); m[indices] = true; m)

function ptrace1(b::CompositeBasis, mask::BitArray{1})
    reduced_basis = b.bases[!mask]
    if length(reduced_basis)==0
        error("Nothing left.")
    elseif length(reduced_basis)==1
        return reduced_basis[1]
    else
        return CompositeBasis(b.shape[!mask], reduced_basis)
    end
end

function ptrace2(b::CompositeBasis, indices::Vector{Int})
    J = [i for i in 1:length(b.bases) if i ∉ indices]
    if length(J)==0
        error("Nothing left.")
    elseif length(J)==1
        return b.bases[J[1]]
    else
        return CompositeBasis(b.shape[J], b.bases[J])
    end
end

function ptrace3(b, indices::Vector{Int})
    ptrace1(b, indices2mask(length(b.bases), indices))
end


function run_ptrace1(N::Int, b::CompositeBasis, mask::BitArray{1})
    for i=1:N
        ptrace1(b, mask)
    end
end

function run_ptrace2(N::Int, b::CompositeBasis, indices::Vector{Int})
    for i=1:N
        ptrace2(b, indices)
    end
end

function run_ptrace3(N::Int, b::CompositeBasis, indices::Vector{Int})
    for i=1:N
        ptrace3(b, indices)
    end
end


b1 = FockBasis(2)
b2 = SpinBasis(1//2)
b3 = NLevelBasis(5)
b4 = NLevelBasis(7)
b = tensor(b1, b2, b3, b4)
indices = [2, 4]
mask = indices2mask(length(b.bases), indices)


N = 10000

run_ptrace1(1, b, mask)
@time run_ptrace1(N, b, mask)
@time run_ptrace1(N, b, mask)
@time run_ptrace1(N, b, mask)
@time run_ptrace1(N, b, mask)

run_ptrace2(1, b, indices)
@time run_ptrace2(N, b, indices)
@time run_ptrace2(N, b, indices)
@time run_ptrace2(N, b, indices)
@time run_ptrace2(N, b, indices)

run_ptrace3(1, b, indices)
@time run_ptrace3(N, b, indices)
@time run_ptrace3(N, b, indices)
@time run_ptrace3(N, b, indices)
@time run_ptrace3(N, b, indices)