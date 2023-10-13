## Julia高性能科学计算（第二版）


# Install packages
using Pkg
Pkg.add("JuMP")
Pkg.add("Clp")
Pkg.add("Cbc")
Pkg.add("GLPK")
Pkg.add("Ipopt")
Pkg.add("MadNLP") # 作为 Ipopt 的替代，解决非线性问题
# https://jump.dev/JuMP.jl/stable/installation/#Supported-solvers
# https://github.com/MadNLP/MadNLP.jl



# Using packages
using JuMP, GLPK
# using Ipopt
using MadNLP

##################################
# 简单线性优化
##################################


# Define the model
m = Model()

# Set the optimizer
set_optimizer(m, GLPK.Optimizer)

# Define the variables
@variable(m, 0 ≤ x₁ ≤ 10)
@variable(m, x₂ ≥ 0)
@variable(m, x₃ ≥ 0)

# Define the constraints
@constraint(m, constraint₁, -x₁ + x₂ + 3x₃ ≤ -5)
@constraint(m, constraint₂, x₁ + 3x₂ - 7x₃ ≤ 10)

# Define the objective function
@objective(m, Max, x₁ + 2x₂ + 5x₃)

# show the problem
print(m)

# Run the solver
optimize!(m)

# Output
println(objective_value(m)) # optimal objective value
println("x₁ = ", value(x₁))
println("x₂ = ", value(x₂))
println("x₃ = ", value(x₃))

# shadow prices
println("Dual Variables:")
println("dual₁ = ", shadow_price(constraint₁))
println("dual₂ = ", shadow_price(constraint₂))


##################################
# 矩阵写法
##################################

# Define the model
m2 = Model()

# Set the optimizer
set_optimizer(m2, GLPK.Optimizer)

# Define variables and constraints
A = [-1 1 3; 1 3 -7]
b = [-5; 10]
c = [1, 2, 5]
index_x = 1:3
index_constraints = 1:2

@variable(m2, x[index_x] ≥ 0)
@constraint(m2, bound, x[1] ≤ 10) # bound 表示边界约束
@constraint(m2, constraint[j in index_constraints],
    sum(A[j, i] * x[i] for i in index_x) ≤ b[j]) # constraint是约束向量，长度为2，表示有两个约束

# Define the objective function
@objective(m2, Max, sum(c[i] * x[i] for i in index_x))

# show the problem
print(m2)

# Run the solver
optimize!(m2)

# Output
println("Optimal Solutions:")
for i in index_x
    println("x[$i] = ", value(x[i]))
end
println("Dual Variables:")
for j in index_constraints
    println("dual[$j] = ", shadow_price(constraint[j]))
end


##################################
# 混合了整数的线性优化
##################################

# Define the model
m = Model()

# Set the optimizer
set_optimizer(m, GLPK.Optimizer)

# Define the variables
@variable(m, 0 ≤ x₁ ≤ 10)
@variable(m, x₂ ≥ 0, Int) # x₂为整数
@variable(m, x₃ ≥ 0, Bin) # x₃只能为0或1

# Define the constraints
@constraint(m, constraint₁, -x₁ + x₂ + 3x₃ ≤ -5)
@constraint(m, constraint₂, x₁ + 3x₂ - 7x₃ ≤ 10)

# Define the objective function
@objective(m, Max, x₁ + 2x₂ + 5x₃)

# show the problem
print(m)

# Run the solver
optimize!(m)

# Output
println(objective_value(m)) # optimal objective value
println("x₁ = ", value(x₁))
println("x₂ = ", value(x₂))
println("x₃ = ", value(x₃))


##################################
# 非线性优化 NLP
##################################

m = Model()
# set_optimizer(m, Ipopt.Optimizer)
set_optimizer(m, MadNLP.Optimizer)

@variable(m, x[1:2])
@NLconstraint(m, (x[1] - 1)^2 + (x[2] + 1)^3 + exp(-x[1]) ≤ 1)
@NLobjective(m, Min, (x[1] - 3)^3 + (x[2] - 4)^2)

optimize!(m)

println("** Optimal objective function value = ", objective_value(m))
println("** Optimal solution = ", value.(x))


##################################
# NLP 非矩阵写法
##################################
using JuMP
using GLPK, MadNLP


# Define the model
m = Model()

# Set the optimizer
set_optimizer(m, MadNLP.Optimizer)

# Define the variables
@variable(m, b ≥ 0)
@variable(m, 0 ≤ cr ≤ 1)
@variable(m, cd ≥ 0)

# Define the constraints
@NLconstraint(m, constraint, b / 0.05 + cr / 0.033 + cd / 0.066 ≤ 100)

# Define the objective function
@NLobjective(m, Max, (1 + b) * (1 + cr * cd))

# show the problem
print(m)

# Run the solver
optimize!(m)

# Output
println(objective_value(m)) # optimal objective value
println("b = ", value(b))
println("cr = ", value(cr))
println("cd = ", value(cd))