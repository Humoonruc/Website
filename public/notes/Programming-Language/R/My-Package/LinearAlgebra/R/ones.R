# 全 1 向量、矩阵

ones <- function(n1, n2 = 0) {
  if (n2 == 0) {
    rep(1, n1)
  } else {
    rep(1, n1 * n2) |> matrix(nrow = n1)
  }
}
