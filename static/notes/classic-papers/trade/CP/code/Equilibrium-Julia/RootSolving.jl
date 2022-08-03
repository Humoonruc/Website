module RootSolving

export Newton_solve, feedback_solve

using Calculus, NLsolve

########################
## 辅助函数
########################
function modulus(x::Vector)::Float64
    √sum(x .* x)
end


########################
## 手写牛顿迭代法
########################
"""
    Newton_solve(f, x₀[; tol, max_iter])
# Newton迭代法解一元方程 ``f(x) = 0``
人为设定迭代初始值 ``x₀``, 然后令 ``xₖ₊₁ = xₖ - f(xₖ)/f'(xₖ)``  
直到``|f(xₖ₊₁)| < tol``，停止迭代  
如果迭代次数超过 max_iter 仍未满足上述条件，一般视为发散
"""
function Newton_solve(f, x₀; tol=1e-10, max_iter=500)
    xₖ = x₀

    for i in 1:max_iter
        xₖ₊₁ = xₖ - f(xₖ) / Calculus.derivative(f, xₖ)
        abs(f(xₖ₊₁)) < tol && return Dict(:x => xₖ₊₁, :iter => i)
        xₖ = xₖ₊₁
        @show i xₖ
    end

    println("Maximum number of iterations exceeded.")
end


# Newton_solve(atan, 1.391)
# Newton_solve(atan, 2)


########################
## 手写反馈迭代法
########################
"""
    feedback_solve(Q, X₀, Q₀[; δ, tol, max_iter])
# 反馈迭代法解多元非线性方程组 ``F(X) = Q(X) - Q₀ = 0``
人为设定迭代初始值 ``X₀``, 然后令 ``(Xₖ₊₁ - Xₖ) ./ Xₖ = δ * (Q(Xₖ) - Q₀ ./ Q₀)``  
直到 ``||Q(Xₖ₊₁) .- Q₀)|| < tol``，停止迭代  
如果迭代次数超过 max_iter 仍未满足上述条件，一般视为发散 

# Arguments
- `δ`: 反馈系数
"""
function feedback_solve(Q, X₀::Vector, Q₀::Vector; δ=0.3, tol=1e-10, max_iter=500)
    Xₖ = X₀

    for i in 1:max_iter
        Qₖ = Q(Xₖ)
        Xₖ₊₁ = @. Xₖ * (1 + δ * (Qₖ / Q₀ - 1))
        modulus(Q(Xₖ₊₁) .- Q₀) < tol && return Dict(:X => Xₖ₊₁, :iter => i)
        Xₖ = Xₖ₊₁
        @show i Xₖ
    end

    println("Maximum number of iterations exceeded.")
end


# function Q(X::Vector)::Vector
#     Q = zeros(length(X))
#     Q[1] = 10 / X[1]
#     Q[2] = 10 - X[2]
#     return Q
# end


# feedback_solve(Q, [1, 1], [2, 5])


########################
## NLsolve 包提供的方程组求解器
########################
function equations!(F, X)
    F[1] = X[1] * X[2] - 600
    F[2] = X[2] - 30
end


# solve = NLsolve.nlsolve(equations!, [2.0, 2.0]; ftol=1e-10, iterations=500,
#     show_trace=true, extended_trace=true)
# Dict(:X => solve.zero, :iter => solve.iterations)

end