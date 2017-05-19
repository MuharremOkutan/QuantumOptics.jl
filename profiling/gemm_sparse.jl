using BenchmarkTools
using QuantumOptics

srand(0)


N = 1000

result = zeros(Complex128, N, N)
B = ones(Complex128, N, N)
A1 = sprand(Complex128, N, N, 1.)
A2 = sprand(Complex128, N, N, 0.1)
A3 = sprand(Complex128, N, N, 0.01)
A4 = sprand(Complex128, N, N, 0.001)

α = complex(1.)
β = complex(0.)

r1 = @benchmark QuantumOptics.sparsematrix.gemm!($α, $A4, $B, $β, $result)
r2 = @benchmark A_mul_B!($α, $A4, $B, $β, $result)


# function run_mul(N, a, b)
#     for i=1:N
#         a*b
#     end
# end

# r = @profile run_mul(100, A1, B)
# using ProfileView
# ProfileView.view()