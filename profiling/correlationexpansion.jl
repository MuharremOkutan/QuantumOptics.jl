using BenchmarkTools
using QuantumOptics

ce = correlationexpansion

Ncutoff = 3

ωa = 0.1 # Spin transition frequency
ωc = 0.2 # Cavity frequency
η = 0.8 # Pumping strength
g1 = 1. # Coupling spin-spin
g2 = 1. # Coupling spin-cavity
γ = 0.1 # Decay rate spin
κ1 = 3. # Decay rate left cavity
κ2 = 0.6 # Decay rate left cavity

Γ = [κ1, γ, γ, κ2]

T = [0:0.1:1;];

spinbasis = SpinBasis(1//2)
fockbasis = FockBasis(Ncutoff)
basis = fockbasis ⊗ spinbasis ⊗ spinbasis ⊗ fockbasis

sz = sigmaz(spinbasis)
sm = sigmam(spinbasis)
sp = sigmap(spinbasis)

a = destroy(fockbasis)
at = create(fockbasis)
n = at*a;

h1 = LazyTensor(basis, 1, ωc*n + η*(a + at)) # Left Cavity
h2 = LazyTensor(basis, 2, ωa*sz) # Left Spin
h3 = LazyTensor(basis, 3, ωa*sz) # Right Spin
h4 = LazyTensor(basis, 4, ωc*n) # Right Cavity
h12 = g2*LazyTensor(basis, [1,2], [a,sp])
h21 = g2*LazyTensor(basis, [1,2], [at,sm]) # Left Cavity - Left Spin
h23 = g1*LazyTensor(basis, [2,3], [sm,sp])
h32 = g1*LazyTensor(basis, [2,3], [sp,sm]) # Left Spin - Middle Spin
h34 = g2*LazyTensor(basis, [3,4], [sm,at])
h43 = g2*LazyTensor(basis, [3,4], [sp,a]) # Right Spin - Right Cavity

H = LazySum(h1, h2, h3, h4, h12, h21, h23, h32, h34, h43)

j1 = LazyTensor(basis, 1, a) # Left Cavity
j2 = LazyTensor(basis, 2, sm) # Left Spin
j3 = LazyTensor(basis, 3, sm) # Right Spin
j4 = LazyTensor(basis, 4, a) # Right Cavity

J = [j1, j2, j3, j4];

S2 = ce.masks(4,2) # All pairwise correlations
S3 = ce.masks(4,3) # All triple correlations

S2_ = [[1,2], [1,3], [2,3], [2,4], [3,4]] # All pairwise correlations but the cavity-cavity correlation
S3_ = [[1,2,3], [2,3,4]] # All triple correlations not containing both cavities;

Ψspin = spindown(spinbasis)
Ψfock = fockstate(fockbasis, 0)
ρspin = Ψspin ⊗ dagger(Ψspin)
ρfock = Ψfock ⊗ dagger(Ψfock)

operators = [ρfock, ρspin, ρspin, ρfock]

ρce_order1 = ce.CorrelationExpansion(operators) # No correlations
ρce_order2 = ce.CorrelationExpansion(operators, S2)
ρce_select2 = ce.CorrelationExpansion(operators, S2_)
ρce_order3 = ce.CorrelationExpansion(operators, S2 ∪ S3)
ρce_select3 = ce.CorrelationExpansion(operators, S2_ ∪ S3_);

Profile.clear()

J = LazyTensor[];

# @time tout, ρce_order1_t = ce.master(T, ρce_order1, H, J; Gamma=Γ)
tout, ρce_order2_t = ce.master([0,0.001], ρce_order2, H, J; Gamma=Γ)
r = @benchmark ce.master($T, $ρce_order2, $H, $J; Gamma=$Γ)
# @profile tout, ρce_order2_t = ce.master(T, ρce_order2, H, J; Gamma=Γ)

# @time tout, ρce_select2_t = ce.master(T, ρce_select2, H, J; Gamma=Γ)
# @time tout, ρce_order3_t = ce.master(T, ρce_order3, H, J; Gamma=Γ)
# @time tout, ρce_select3_t = ce.master(T, ρce_select3, H, J; Gamma=Γ);