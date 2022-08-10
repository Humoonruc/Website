module Equilibrium

using NLsolve

export solve_p, solve_factory, solve_equilibrium


"""
给定 𝒘̂ 利用 (10)(11) 两式求解 𝒑̂
"""
function solve_p(𝒘̂, 𝜿̂::Array, N::Int64, J::Int64, 𝜸ʲ, 𝜸ᵏʲ, 𝝅, 𝜽, tol, max_itr::Int64)
    𝒑̂ = ones(N, J)
    𝒄̂ = ones(N, J)

    for itr ∈ 1:max_itr
        𝒑̂₀ = copy(𝒑̂) # 直接赋值只是起了一个别名，并不会拷贝

        # (10) 式
        for n ∈ 1:N, j ∈ 1:J
            𝒄̂[n, j] = 𝒘̂[n]^𝜸ʲ[n, j] * prod(k -> 𝒑̂[n, k]^𝜸ᵏʲ[k, j, n], 1:J)
        end

        # (11) 式
        for n ∈ 1:N, j ∈ 1:J
            𝒑̂[n, j] = sum([𝝅[n, i, j] * (𝜿̂[n, i, j] * 𝒄̂[i, j])^(-𝜽[j]) for i ∈ 1:N])^(-1 / 𝜽[j])
        end

        if maximum(abs, 𝒑̂ - 𝒑̂₀) < tol
            return Dict(:𝒑̂ => 𝒑̂, :𝒄̂ => 𝒄̂, :itr => itr)
        end
    end

    println("Iteration is not convergent.")
end


"""
函数工厂，返回求解Xₙʲ′所需的闭包
"""
function solve_factory(𝒘̂, 𝝅𝝉′, N::Int64, J::Int64, 𝜸ʲ, 𝜸ᵏʲ, 𝒘𝑳, 𝑫, 𝜶)
    function solve_X!(F::Vector, x::Vector)
        𝑿′ = reshape(x, (N, J))

        # n国的关税转移支付
        TR(n) = sum([(1 - sum(𝝅𝝉′[n, :, j])) * 𝑿′[n, j] for j ∈ 1:J])

        # n国国民收入
        I′(n) = 𝒘̂[n] * 𝒘𝑳[n] + TR(n) + 𝑫[n]

        # n国对j部门最终品的需求
        Xₙʲ′_final(n, j) = 𝜶[n, j] * I′(n)

        # n国k部门的销售
        Salesₙᵏ(n, k) = sum([𝝅𝝉′[i, n, k] * 𝑿′[i, k] for i ∈ 1:N])

        # n国各部门对j部门中间品的引致需求
        Xₙʲ′_intermediate(n, j) = sum([𝜸ᵏʲ[j, k, n] * Salesₙᵏ(n, k) for k ∈ 1:J])

        # n国对j部门的总支出
        Xₙʲ′(n, j) = 𝑿′[n, j]

        for n ∈ 1:N, j ∈ 1:J
            F[(j-1)*N+n] = Xₙʲ′(n, j) - Xₙʲ′_final(n, j) - Xₙʲ′_intermediate(n, j)
        end
    end

    return solve_X!
end


"""
求(10)-(14)式相对变化方程组的解
"""
function solve_equilibrium(N, J, δ, tol, max_itr, 𝝉̃, 𝝉̃′, 𝜸ʲ, 𝜸ᵏʲ, 𝜽, 𝝅, 𝑿ₙ, 𝒘𝑳, 𝑫, 𝜶)

    𝜿̂ = 𝝉̃′ ./ 𝝉̃
    𝒘̂ = ones(N)

    for itr ∈ 1:max_itr
        𝒘̂₀ = copy(𝒘̂)

        solve_price = Equilibrium.solve_p(𝒘̂, 𝜿̂, N, J, 𝜸ʲ, 𝜸ᵏʲ, 𝝅, 𝜽, tol, max_itr)
        𝒑̂ = solve_price[:𝒑̂]
        𝒄̂ = solve_price[:𝒄̂]

        𝝅̂ = ones(N, N, J)
        𝝅′ = zeros(N, N, J)
        for n ∈ 1:N, i ∈ 1:N, j ∈ 1:J
            𝝅̂[n, i, j] = (𝒄̂[i, j] * 𝜿̂[n, i, j] / 𝒑̂[n, j])^(-𝜽[j])
            𝝅′[n, i, j] = 𝝅[n, i, j] * 𝝅̂[n, i, j]
        end
        𝝅𝝉′ = 𝝅′ ./ 𝝉̃′ # 保存 𝝅′/(1+𝝉′) 便于后续使用

        closure_X = Equilibrium.solve_factory(𝒘̂, 𝝅𝝉′, N, J, 𝜸ʲ, 𝜸ᵏʲ, 𝒘𝑳, 𝑫, 𝜶)
        solve_Xₙʲ′ = nlsolve(closure_X, 𝑿ₙ[:];
            autodiff=:forward, ftol=1e-3, show_trace=true) # 支出的数量级很大，ftol 没必要太小
        𝑿ₙ′ = reshape(solve_Xₙʲ′.zero, (N, J))

        EXₙ′(n) = sum([𝝅𝝉′[i, n, j] * 𝑿ₙ′[i, j] for i ∈ 1:N for j ∈ 1:J])
        IMₙ′(n) = sum([𝝅𝝉′[n, i, j] * 𝑿ₙ′[n, j] for i ∈ 1:N for j ∈ 1:J])
        𝑬𝑿′ = [EXₙ′(n) for n ∈ 1:N]
        𝑰𝑴′ = [IMₙ′(n) for n ∈ 1:N]

        # 在目前的工资水平下，各国的经常账户新增盈余
        Δ𝑪𝑨 = 𝑬𝑿′ - 𝑰𝑴′ + 𝑫
        # 新增盈余为正，意味着工资水平偏低，要向上调整
        𝒘̂ = 𝒘̂ .* (1 .+ δ * Δ𝑪𝑨 ./ 𝒘𝑳)

        if maximum(abs, 𝒘̂ - 𝒘̂₀) < tol
            return Dict(:𝒘̂ => 𝒘̂, :itr => itr)
        end

        println(maximum(abs, 𝒘̂ - 𝒘̂₀))
    end

    println("Iteration is not convergent.")
end


end