struct Literal
    name::Int
    pos::Bool
end
Base.:!(l::Literal) = Literal(l.name,!l.pos)
Base.show(io::IO, l::Literal) = print(io, l.pos ? '+' : '-', l.name)

struct Clause
    lits::Array{Literal,1}
end
Base.length(c::Clause) = length(c.lits)
Base.iterate(c::Clause) = (c.lits[begin], firstindex(c.lits))
Base.iterate(c::Clause, i) = i >= lastindex(c.lits) ? nothing : (c.lits[i+1], i+1)
Base.getindex(c::Clause, i...) = c.lits[i...]
Base.show(io::IO, c::Clause) = begin
    print(io, '(')

    for (i,l) in enumerate(c)
        print(io, l)
        i != length(c) && print(io, " ∨ ")
    end

    print(io, ')')
end

Base.in(l::Literal, c::Clause) = l ∈ c.lits

struct Formula
    clauses::Array{Clause,1}
end
Base.length(f::Formula) = length(f.clauses)
Base.iterate(f::Formula) = (f.clauses[begin], firstindex(f.clauses))
Base.iterate(f::Formula, i) = i >= lastindex(f.clauses) ? nothing : (f.clauses[i+1], i+1)
Base.getindex(f::Formula, i...) = f.clauses[i...]
Base.show(io::IO, f::Formula) = begin
    print(io, '(')

    for (i,l) in enumerate(f)
        print(io, l)
        i != length(f) && print(io, " ∧\n ")
    end

    print(io, ')')
end

struct Trail
    decs::Vector{Tuple{Literal, Bool}}
end
Base.isempty(t::Trail) = isempty(t.decs)
Base.iterate(t::Trail) = iterate(t.decs)
Base.iterate(t::Trail, i) = iterate(t.decs, i)
Base.length(t::Trail) = length(t.decs)
Base.getindex(t::Trail, i...) = t.decs[i...]
Base.push!(t::Trail, x) = push!(t.decs, x)
Base.filter(f, t::Trail) = filter(f, t.decs)

Base.in(l::Literal, t::Trail) = any(l == x for (x,_) in t)

Base.show(io::IO, t::Trail) = begin
    print(io, '[')
    
    for (i,(l,d)) in enumerate(t)
        d && print(io, '|')
        print(io, l)
        i != length(t) && print(io, ", ")
    end

    print(io ,']')
end

# convenience constructors
Literal(literal::Int) = Literal(abs(literal), literal > 0)
Clause(v::Vector{Int}) = Clause(Literal.(v))
Formula(v::Vector{Vector{Int}}) = Formula(Clause.(v))
solve(v::Vector{Vector{Int}}) = solve(Formula(v))
