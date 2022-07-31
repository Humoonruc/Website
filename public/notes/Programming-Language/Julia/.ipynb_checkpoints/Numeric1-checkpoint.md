## root solving

### NLsolve.jl

[JuliaNLSolvers/NLsolve.jl: Julia solvers for systems of nonlinear equations and mixed complementarity problems (github.com)](https://github.com/JuliaNLSolvers/NLsolve.jl)



Solving non-linear systems of equations

```julia
# 注意，不能写成向量形式，F = ...
# 必须用分量形式
function f!(F, x) 
    F[1] = (x[1] + 3) * (x[2]^3 - 7) + 18
    F[2] = sin(x[2] * exp(x[1]) - 1)
end

results = nlsolve(f!, [0.1, 1.2], autodiff=:forward)
```



`nlsolve(f![, j!], x_initial, ...)`，其中 `f!` 为方程组，`j!` 为 Jacobian Matrix

可选参数:

- `xtol`: norm difference in `x` between two successive iterates under which convergence is declared. Default: `0.0`. 两次迭代，x 的相对变化小于多少时，被认为是收敛的。
- `ftol`: infinite norm of residuals under which convergence is declared. Default: `1e-8`. 方程残差小于多少时，被认为是收敛的。
- `iterations`: maximum number of iterations. Default: `1_000`. 最大迭代次数。
- `store_trace`: should a trace of the optimization algorithm's state be stored? Default: `false`. 是否储存收敛轨迹。
- `show_trace`: should a trace of the optimization algorithm's state be shown on `STDOUT`? Default: `false`. 是否显示收敛轨迹。
- `extended_trace`: should additifonal algorithm internals be added to the state trace? Default: `false`.



```julia
using NLsolve


function f!(F, x) # modifies the first argument
  F[1] = (x[1] + 3) * (x[2]^3 - 7) + 18
  F[2] = sin(x[2] * exp(x[1]) - 1)
end

function j!(J, x) # modifies the first argument
  J[1, 1] = x[2]^3 - 7
  J[1, 2] = 3 * x[2]^2 * (x[1] + 3)
  u = exp(x[1]) * cos(x[2] * exp(x[1]) - 1)
  J[2, 1] = x[2] * u
  J[2, 2] = u
end


# nlsolve 会迭代f!的第二个参数（向量），不断地修改f!的第一个参数（向量）
# 直到其所有分量为0，最后返回第二个参数，即为方程组的解


# 可以不给 Jacobian Matrix
solve1 = nlsolve(f!, [0.1; 1.2], show_trace=true)
solve1.zero

# 另一种不给 Jacobian Matrix 的方法，自动微分
solve2 = nlsolve(f!, [0.1; 1.2], autodiff=:forward)

# 给 Jacobian Matrix 性能会好一些
solve3 = nlsolve(f!, j!, [0.1; 1.2])
```

