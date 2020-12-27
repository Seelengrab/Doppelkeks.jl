module Doppelkeks

export Literal, Clause, Formula, solve

include("structs.jl")

abstract type SAT_State end
struct SAT <: SAT_State end
struct UNSAT <: SAT_State end

function solve(formula::Formula)
    trail = Trail(Tuple{Literal, Bool}[])
    while true
        if doBacktrack(trail, formula)
            if isempty(decisions(trail))
                return UNSAT, nothing
            else
                trail = applyBacktrack(trail)
            end
        else
            if vars(trail) == vars(formula)
                return SAT, trail
            else
                applyDecide!(trail, formula)
            end
        end
    end

    return UNSAT, nothing
end

###### Utiliy

function doBacktrack(trail, formula)
    isempty(trail) && return false

    for clause in formula
        all(!l in trail for l in clause) && return true
    end
    
    return false
end

function vars(f::Formula)
    res = Set{Int}()
    
    for c in f.clauses
        for l in c.lits
            push!(res, l.name)
        end
    end

    return res
end

function vars(trail)
    res = Set{Int}()
    
    for (l,_) in trail
        push!(res, l.name)
    end

    return res
end

###### Trail functions

function decisions(trail) 
    filter(x -> x[2], trail)
end

function lastDecision(trail)
    for i in length(trail):-1:1
        name, decision = trail[i]
        decision && return name
    end
    return nothing
end

function decisionsTo(trail, lit)
    decisions(trail[1:findfirst(x -> x[1] == lit, trail)])
end

function currentLevel(trail)
    length(decisions(trail))
end

function level(lit, trail)
    length(decisionsTo(trail, lit))
end

function prefixToLevel(trail, level)
    filter(x -> x[2] <= level, trail)
end

function prefixBeforeLastDecision(trail)
    for i in length(trail):-1:1
        _, decision = trail[i]
        decision && return Trail(trail[1:i-1])
    end
    return nothing
end

function lastAssertedLiteral(clause, trail)
    lastLit = first(clause)
    lastLevel = level(lastLit, trail)

    for i in 2:length(clause)
        tmp = clause[i]
        tmpLvl = level(tmp, trail)
        if tmpLvl > lastLevel
            lastLevel = tmpLvl
            lastLit = tmp
        end
    end

    return lastLit
end

maxLevel(clause, trail) = level(lastAssertedLiteral(clause, trail), trail)

function assertLiteral!(trail, literal, decision)
    push!(trail, (literal, decision))
end

##### Decisions

function applyDecide!(trail, formula)
    l = selectLiteral(trail, formula)
    assertLiteral!(trail, l, true)
    println(rpad("applyDecide", 16), l, " -> ", trail)
end

function applyBacktrack(trail)
    l = lastDecision(trail)
    M = prefixBeforeLastDecision(trail)
    assertLiteral!(M, !l, false)
    println(rpad("applyBacktrack", 16), !l, " -> ", M)
    M
end

function selectLiteral(trail, formula)
    t_vars = vars(trail)
    f_vars = vars(formula)
    @assert t_vars != f_vars
    pos_vars = setdiff(f_vars, t_vars)
    Literal(rand(pos_vars), rand(Bool))
end

end # module
