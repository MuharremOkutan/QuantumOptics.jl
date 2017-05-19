using QuantumOptics

spinbasis = SpinBasis(1//2)
# basis = tensor(spinbasis, fockbasis)

sx = sigmax(spinbasis)
sy = sigmay(spinbasis)
sz = sigmaz(spinbasis)
sp = sigmap(spinbasis)
sm = sigmam(spinbasis)

threespinbasis = spinbasis ⊗ spinbasis ⊗ spinbasis
Sx3 = full(sum([embed(threespinbasis, i, sx) for i=1:3])/2.)
Sy3 = full(sum([embed(threespinbasis, i, sy) for i=1:3])/2.)
Sz3 = full(sum([embed(threespinbasis, i, sz) for i=1:3])/2.)
Ssq3 = Sx3^2 + Sy3^2 + Sz3^2
ops = [Ssq3, Sz3]

function run_simdiag(N, ops)
    for i=1:N
        simdiag(ops)
    end
end

run_simdiag(1, ops)
@time run_simdiag(1000, ops)

@profile run_simdiag(1000, ops)

using ProfileView
ProfileView.view()

c = Condition()
wait(c)