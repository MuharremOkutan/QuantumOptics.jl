using QuantumOptics

b = GenericBasis(4)
b2 = b ⊗ b
b3 = b ⊗ b ⊗ b

function f(N, a, b)
    for i=1:N
        a ⊗ b
    end
    a
end

N = 1000000
f(1, b, b)
gc()
@time f(N, b, b)
gc()
@time f(N, b, b)
gc()
@time f(N, b, b)
gc()
@time f(N, b, b)

# @profile f(N, b1, b2)
# using ProfileView
# ProfileView.view()

# c = Condition()
# wait(c)