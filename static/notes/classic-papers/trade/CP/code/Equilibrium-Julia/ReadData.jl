module ReadData

using Pipe, CSV, DataFrames

export to_matrix, to_tensor


"""
将只有二维的数据表读为矩阵, 两个维度分别代表国家, 部门
"""
function to_matrix(path::String)
    CSV.read(path, DataFrame; header=false) |> Matrix
end


"""
将三维数据读为张量, 三个维度分别代表本国, 他国, 部门
# Arguments
- `path`, 数据文件路径, 一般有N×J行、M列. 每N行M列构成一个具有意义的二维表, 第三维(1:J)在行方向排列
"""
function to_tensor(path::String, N::Int64, M::Int64, J::Int64)
    # 封装匿名函数：读取N行数据, 返回DataFrame; j决定从哪行开始读
    read_lines = j -> CSV.read(path, DataFrame; header=false, skipto=N * (j - 1) + 1, limit=N)

    @pipe [read_lines(j) for j ∈ 1:J] .|>
          Matrix .|>  # 若干个N×M矩阵，在第三维上排列成向量
          reshape(_, N * M) |> vcat(_...) |>  # 将这些表展开成一个大向量
          reshape(_, (N, M, J)) # 重组为张量
end


end