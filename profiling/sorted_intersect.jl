using BenchmarkTools

function intersect1(ind1::Vector{Int}, ind2::Vector{Int})
    intersect(ind1, ind2)
end

function intersect2(ind1::Vector{Int}, ind2::Vector{Int})
    i1 = 1
    i2 = 1
    N1 = length(ind1)
    N2 = length(ind2)
    xvec = Vector{Int}()
    while true
        if i1 > N1 || i2 > N2
            return xvec
        end
        x1 = ind1[i1]
        x2 = ind2[i2]
        if x1 == x2
            i1 += 1
            i2 += 1
            push!(xvec, x1)
        elseif x1 < x2
            i1 += 1
        else
            i2 += 1
        end
    end
end

function intersect3(ind1::Vector{Int}, ind2::Vector{Int})
    i1 = 1
    i2 = 1
    N1 = length(ind1)
    N2 = length(ind2)
    xvec = Vector{Int}()
    if i1 > N1 || i2 > N2
        return xvec
    end
    x1 = ind1[i1]
    x2 = ind2[i2]
    while true
        if x1 == x2
            i1 += 1
            i2 += 1
            push!(xvec, x1)
            if i1 > N1 || i2 > N2
                return xvec
            end
            x1 = ind1[i1]
            x2 = ind2[i2]
        elseif x1 < x2
            i1 += 1
            if i1 > N1
                return xvec
            end
            x1 = ind1[i1]
        else
            i2 += 1
            if i2 > N2
                return xvec
            end
            x2 = ind2[i2]
        end
    end
end

ind1 = [2, 3, 6]
ind2 = [1, 3, 4, 6, 7]

println(intersect1(ind1, ind2))
println(intersect2(ind1, ind2))
println(intersect3(ind1, ind2))

r1 = @benchmark intersect1($ind1, $ind2)
r2 = @benchmark intersect2($ind1, $ind2)
r3 = @benchmark intersect3($ind1, $ind2)

println(r1)
println(r2)
println(r3)
