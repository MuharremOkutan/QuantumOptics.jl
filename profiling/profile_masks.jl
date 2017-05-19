using Combinatorics, Iterators

typealias Mask BitArray{1}

# indices2mask(N::Int, indices::Vector{Int}) = (m = Mask(N); m[indices] = true; m)

function indices2mask(N::Int, indices::Vector{Int})
    m = Mask(N)
    for i in indices
        m[i] = true
    end
    # m[indices] = true
    m
end

function indices2mask(N::Int, indices::Vector{Int}, m::Mask)
    fill!(m, false)
    for i in indices
        m[i] = true
    end
    m
end


mask2indices(mask::Mask) = find(mask)

complement(N::Int, indices::Vector{Int}) = Int[i for i=1:N if i ∉ indices]

correlationindices(N::Int, order::Int) = Set(combinations(1:N, order))
function correlationmasks(N::Int)
    S = Set{Mask}()
    for n=2:N
        S = S ∪ correlationmasks(N, n)
    end
    S
end
function correlationmasks(N::Int, order::Int)
    @assert N > 1
    @assert order > 0
    @assert N >= order
    Set(indices2mask(N, indices) for indices in correlationindices(N, order))
end
correlationmasks(S, order::Int) = [s for s in S if sum(s)==order]
subcorrelationmasks1(mask::Mask) = [indices2mask(length(mask), indices) for indices in
        chain([combinations(mask2indices(mask), k) for k=2:sum(mask)-1]...)]
function subcorrelationmasks2(mask::Mask)
    subcorrelationmasks2(length(mask), mask2indices(mask))
end
function subcorrelationmasks2(N::Int, indices::Vector{Int}, submasks=Mask[])
    order = length(indices)
    if order < 2
        return submasks
    end
    subindices = indices[2:end]
    println(subindices)
    submask = indices2mask(N, subindices)
    push!(submasks, submask)
    subcorrelationmasks2(N, subindices, submasks)
    for i in 1:order-1
        x = subindices[i]
        subindices[i] = indices[1]
        println(subindices)
        submask = indices2mask(N, subindices)
        push!(submasks, submask)
        subcorrelationmasks2(N, subindices, submasks)
        subindices[i] = x
    end
    submasks
end


function run_indices2mask1(N, indices)
    for i=1:N
        indices2mask(6, indices)
    end
end

function run_indices2mask2(N, indices)
    mask = Mask(6)
    for i=1:N
        indices2mask(6, indices, mask)
    end
end

N = 1000000
indices = [2,3,5,6]

run_indices2mask1(1, indices)
@time run_indices2mask1(N, indices)
@time run_indices2mask1(N, indices)
@time run_indices2mask1(N, indices)
@time run_indices2mask1(N, indices)

run_indices2mask2(1, indices)
@time run_indices2mask2(N, indices)
@time run_indices2mask2(N, indices)
@time run_indices2mask2(N, indices)
@time run_indices2mask2(N, indices)


# subcorrelationmasks2(6, [2,3,5,6])


# function run_subcorrelationmasks1(N, mask)
#     for i=1:N
#         subcorrelationmasks1(mask)
#     end
# end

# function run_subcorrelationmasks2(N, mask)
#     for i=1:N
#         subcorrelationmasks2(mask)
#     end
# end


# N = 100000
# mask = indices2mask(6, [2,3,5,6])

# run_subcorrelationmasks1(1, mask)
# @time run_subcorrelationmasks1(N, mask)
# @time run_subcorrelationmasks1(N, mask)
# @time run_subcorrelationmasks1(N, mask)
# @time run_subcorrelationmasks1(N, mask)

# run_subcorrelationmasks2(1, mask)
# @time run_subcorrelationmasks2(N, mask)
# @time run_subcorrelationmasks2(N, mask)
# @time run_subcorrelationmasks2(N, mask)
# @time run_subcorrelationmasks2(N, mask)


# Profile.clear()
# @profile run_subcorrelationmasks2(N, mask)

# using ProfileView
# ProfileView.view()

# c = Condition()
# wait(c)