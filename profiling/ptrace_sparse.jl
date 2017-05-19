N1 = 13
N2 = 17
N3 = 11
N = N1*N2*N3

srand(1)
x = rand(Complex128, N1, N2, N3, N1, N2, N3)
x_sparse = sparse(reshape(x, N, N))


# function ptrace_forloops(x)
#     n1, n2, n3 = size(x)
#     y = zeros(Complex128, n2, n3, n2, n3)
#     for i5=1:n3
#         for i4=1:n2
#             for i3=1:n3
#                 for i2=1:n2
#                     for i1=1:n1
#                         y[i2,i3,i4,i5] += x[i1,i2,i3,i1,i4,i5]
#                     end
#                 end
#             end
#         end
#     end
#     y
# end

# function ptrace_slicing(x::Array{Complex128, 6})
#     n1, n2, n3 = size(x)
#     y = zeros(Complex128, n2, n3, n2, n3)
#     for i1=1:n1
#         y += x[i1,:,:,i1,:,:]
#     end
#     y
# end

# function ptrace_cartesian(x::Array{Complex128, 6})
#     n1, n2, n3 = size(x)
#     y = zeros(Complex128, 1, n2, n3, 1, n2, n3)
#     ymax = CartesianIndex(size(y))
#     for I in CartesianRange(size(x))
#         if I.I[1] != I.I[4]
#             continue
#         end
#         y[min(ymax, I)] += x[I]
#     end
#     reshape(y, n2, n3, n2, n3)
# end


function ptrace_cartesian_sparse(x::SparseMatrixCSC{Complex128})
    n1, n2, n3 = size(x)

    y = zeros(Complex128, 1, n2, n3, 1, n2, n3)
    for I in CartesianRange(size(y))
        for k in CartesianRange((n1, 1, 1))
            delta = CartesianIndex(k, k)
            y[I] += x[I+delta-1]
        end
    end
    reshape(y, n2, n3, n2, n3)
end

function ptrace_cartesian2(x::Array{Complex128, 6})
    n1, n2, n3 = size(x)
    y = zeros(Complex128, 1, n2, n3, 1, n2, n3)
    for I in CartesianRange(size(y))
        for k in CartesianRange((n1, 1, 1))
            delta = CartesianIndex(k, k)
            y[I] += x[I+delta-1]
        end
    end
    reshape(y, n2, n3, n2, n3)
end

# Partial trace for dense operators.


# dist(x,y) = sum(abs(x-y))
# result = ptrace_forloops(x)

# println(dist(result, ptrace_slicing(x)))
# println(dist(result, ptrace_cartesian(x)))
# println(dist(result, ptrace_cartesian2(x)))
# println(dist(result, ptrace_nloop(x)))


# println("Explicit loops")
# @time ptrace_forloops(x)
# @time ptrace_forloops(x)

# println("Slicing")
# @time ptrace_slicing(x)
# @time ptrace_slicing(x)

# println("Cartesian Index")
# @time ptrace_cartesian(x)
# @time ptrace_cartesian(x)

println("Cartesian Index 2")
@time ptrace_cartesian2(x)
@time ptrace_cartesian2(x)

# println("nloop")
# @time ptrace_nloop(x)
# @time ptrace_nloop(x)
