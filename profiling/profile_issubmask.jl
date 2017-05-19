typealias Mask BitArray{1}

indices2mask(N::Int, indices::Vector{Int}) = (m = Mask(N); m[indices] = true; m)

function issubmask1(submask::Mask, mask::Mask)
    all(mask[submask])
end

function issubmask2(submask::Mask, mask::Mask)
    if sum(submask) >= sum(mask)
        return false
    end
    for i=1:length(mask)
        if submask[i] && !mask[i]
            return false
        end
    end
    true
end


function run_issubmask1(N, submask, mask)
    for i=1:N
        issubmask1(submask, mask)
    end
end

function run_issubmask2(N, submask, mask)
    for i=1:N
        issubmask2(submask, mask)
    end
end


N = 1000000
submask = indices2mask(6, [2,3,5])
mask = indices2mask(6, [2,3,5,6])

run_issubmask1(1, submask, mask)
@time run_issubmask1(N, submask, mask)
@time run_issubmask1(N, submask, mask)
@time run_issubmask1(N, submask, mask)
@time run_issubmask1(N, submask, mask)

run_issubmask2(1, submask, mask)
@time run_issubmask2(N, submask, mask)
@time run_issubmask2(N, submask, mask)
@time run_issubmask2(N, submask, mask)
@time run_issubmask2(N, submask, mask)
