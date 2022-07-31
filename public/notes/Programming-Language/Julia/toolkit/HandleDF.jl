using DataFrames


module HandleDF

export extract


"""
select(df, args...) 返回 DataFrame，有时候计算起来不方便
所以自定义一个 extract 函数，返回多列 Matrix 或单列 Vector
"""
function extract(df, args...)
    M = DataFrames.select(df, args...) |> Matrix
    size(M, 2) > 1 ? M : reshape(M, length(M))
end

end