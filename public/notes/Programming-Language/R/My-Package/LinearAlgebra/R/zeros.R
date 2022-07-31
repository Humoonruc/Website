# 全 0 向量、矩阵

zeros <- function(n1, n2 = 0) {
  if (n2 == 0) {
    rep(0, n1)
  } else {
    rep(0, n1 * n2) |> matrix(nrow = n1)
  }
}
