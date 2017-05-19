using BenchmarkTools
using QuantumOptics

function run_timeevolution(Ncutoff)
    κ = 1.
    η = 4κ
    Δ = 0
    tmax = 100
    tsteps = 201
    tlist = Vector(linspace(0, tmax, tsteps))

    b = FockBasis(Ncutoff)
    a = destroy(b)
    ad = dagger(a)
    H = Δ*ad*a + η*(a + ad)
    J = [sqrt(2κ)*destroy(b)]

    ψ0 = fockstate(b, 0)
    n = number(b)
    exp_n = Float64[]
    fout(t, ρ) = push!(exp_n, real(expect(n, ρ)))
    timeevolution.master(tlist, ψ0, H, J; fout=fout, abstol=1e-8, reltol=1e-6)
    exp_n
end

Ncutoff = 100

@benchmark run_timeevolution(Ncutoff)
