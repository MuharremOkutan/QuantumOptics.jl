using QuantumOptics
correlationexpansion = correlationexpansion3

srand(0)

b1 = FockBasis(2)
b2 = SpinBasis(1//2)
b3 = NLevelBasis(4)
b4 = NLevelBasis(2)
b = tensor(b1, b2, b3, b4)

randdo(b) = (x = normalize(Ket(b, rand(Complex128, length(b)))); x ⊗ dagger(x))
randop(b) = DenseOperator(b, rand(Complex128, length(b), length(b)))


S2 = correlationexpansion.correlationmasks(4, 2)
S3 = correlationexpansion.correlationmasks(4, 3)
S4 = correlationexpansion.correlationmasks(4, 4)

rho = randdo(b1) ⊗ randdo(b2) ⊗ randdo(b3) ⊗ randdo(b4)

# rho_ = correlationexpansion.approximate(rho, S2 ∪ S3 ∪ S4)
rho_ = correlationexpansion.approximate(rho, S2)
# rho_ = correlationexpansion.approximate(rho)

h = 0.5*lazy(randop(b1)) ⊗ lazy(randop(b2)) ⊗ lazy(randop(b3)) ⊗ lazy(randop(b4))

result = deepcopy(rho_)
a = complex(1.)
b = complex(1.)


function run_gemm(N::Int, a::Complex128, h::LazyTensor, rho::correlationexpansion.ApproximateOperator, b::Complex128, result::correlationexpansion.ApproximateOperator)
    for i=1:N
        operators.gemm!(a, full(h), rho, b, result)
    end
end



run_gemm(1, a, h, rho_, b, result)
@time run_gemm(100, a, h, rho_, b, result)

Profile.clear()
@profile run_gemm(100, a, h, rho_, b, result)

