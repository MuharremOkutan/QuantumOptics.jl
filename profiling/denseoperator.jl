using QuantumOptics

b1 = FockBasis(2)
b2 = SpinBasis(1//2)
b3 = NLevelBasis(5)
b4 = NLevelBasis(7)
b = tensor(b1, b2, b3, b4)



function create_operator(N::Int, b::Basis)
    for i=1:N
        DenseOperator(b, b, Matrix{Complex128}(length(b), length(b)))
        # DenseOperator(b)
    end
end

function add_operators(N::Int, a::DenseOperator)
    for i = 1:N
        a+a
    end
end

function create_matrix(N::Int)
    for i=1:N
        # Matrix{Complex128}(100, 100)
        zeros(Complex128, 100, 100)
    end
end

function add_matrices(N::Int, a::Matrix{Complex128})
    for i=1:N
        a = a + a
    end
    a
end

N = 10000

a = zeros(Complex128, 100, 100)
add_matrices(1, a)
println("Add matrices")
@time add_matrices(N, a)
@time add_matrices(N, a)
@time add_matrices(N, a)
@time add_matrices(N, a)

create_matrix(1)
println("Create matrices")
@time create_matrix(N)
@time create_matrix(N)
@time create_matrix(N)
@time create_matrix(N)

println("Create operator")
create_operator(1, b)
@time create_operator(100, b)
@time create_operator(100, b)
@time create_operator(100, b)
@time create_operator(100, b)

println("Add operator")
a = DenseOperator(b)
add_operators(1, a)
@time add_operators(100, a)
@time add_operators(100, a)
@time add_operators(100, a)
@time add_operators(100, a)

Profile.clear()
@profile create_operator(10000, b)