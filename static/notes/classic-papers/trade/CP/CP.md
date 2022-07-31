[TOC]

# CP（multi sector EK）

## Section 1 Introduction

创新

1. 引入部门间 I-O 联系
2. 放大了贸易成本削减的结果
3. 大大简化了评估关税变化所需的数据和参数要求，不需要估计**各国技术水平**、**双边冰山成本**等参数，就能很容易地执行反事实模拟
4. 估计参数 $\theta^j$ （本文称之为贸易弹性，本质上是各行业技术水平的国别离散程度）的新方法

## Section 2 Facts

$$
\left.\begin{matrix}
\text{大多数贸易产品都是中间产品} \\
\text{多国产业结构异质性} \\
\text{关税跨部门异质性 }
\end{matrix}\right\} \Longrightarrow \text{Model should include}

\left\{\begin{matrix}
\text{中间产品} \\
\text{多部门} \\
\text{部门间的 I-O linkage}
\end{matrix}\right.
$$



从福利变化中分离出多国项和多部门项

贸易创造和贸易转移可以对国家进行分解

贸易条件的变化可以对部门进行分解：关税降幅越大的行业，在生产中使用的比例越大，有越强的部门联系

Intermediates and sectoral linkages play an important role for welfare analysis 

## Section 3

假设

1. N 国
2. J 部门，部门分为两种类型，可贸易或不可贸易
3. 单要素（劳动），可跨部门流动，不可跨国流动
4.  $\theta$ 的部门异质性：反映生产率分散程度的 $\theta$ 参数在不同行业不同

### 3.1 Model

#### 3.1.1 Demand

$n$ 国劳动力禀赋 $L_n$，$n$ 国典型消费者对部门 $j$ 的 composite goods 的消费量为 $C_n^j$，效用最大化问题为

> $C_n^j$ 是 $j$ 部门所有产品的消费量按照一定规则计算出来的一个数量指数

$$
\max u = \prod_{j=1}^J (C_n^j)^{\alpha_n^j}, \text{where} \sum_{j=1}^J \alpha_n^j=1 \tag{1}
$$
预算约束为
$$
\sum_{j=1}^JP_n^jC_n^j \leqslant I_n
$$
#### 3.1.2 Production

设每个部门 $j$ 的产品都是一个连续统 $\omega^j \in [0,1]$，记 $z_n^j(\omega^j)$ 为 $n$ 国生产 $\omega^j$ 的效率（每个国家都有 $J$ 个表示技术的函数，共有 $N \times J$ 个技术函数）

$j$ 部门的生产需要两类要素投入：

1. labor, $l^j$
2. k 部门的 composite (intermediate) goods, $m^{k, j}$

> $m^{k, j}$ 是 $j$ 部门对 $k$ 部门所有中间产品的使用量按照一定规则计算出来的一个数量指数

假设生产函数为 **C-D 型**
$$
q_{n}^{j}\left(\omega^{j}\right)=z_{n}^{j}\left(\omega^{j}\right)\left[l_{n}^{j}\left(\omega^{j}\right)\right]^{\gamma_{n}^{j}} \prod_{k=1}^{J}\left[m_{n}^{k, j}\left(\omega^{j}\right)\right]^{\gamma_{n}^{k, j}}
$$
其中 $\gamma_n^j$ 为 $j$ 部门产品总成本中劳动力所占份额，$\gamma_n^{k,j}$ 为 $j$ 部门产品总成本中所使用的 $k$ 部门聚合中间品所占的份额（**行业间 I-O linkages 的体现**），自然有
$$
\sum_{k=1}^J \gamma_n^{k,j}+\gamma_n^j=1
$$


给定这些参数，可以证明，$n$ 国生产 $j$ 部门 $\omega^j$ 产品的单位成本（也是单价）为
$$
\Upsilon_{n}^{j} \frac{w_{n}^{\gamma_{n}^{j}} \prod_{k=1}^{J} (P_{n}^{k})^{\gamma_{n}^{k, j}}}{z_n^j(\omega^j)}
$$
其中，$\Upsilon_{n}^{j}$ 是常数（见原文脚注 19），$P_n^k$ 为 $k$ 部门**聚合中间品**的价格指数。从而 $n$ 国 $j$ 产业单位投入束的成本与具体产品 $\omega^j$ 无关，为
$$
c_n^j = \Upsilon_{n}^{j} w_{n}^{\gamma_{n}^{j}} \prod_{k=1}^{J} (P_{n}^{k})^{\gamma_{n}^{k, j}} \tag{2}
$$

本文相比 EK2002，最大的变化在于中间品从单部门变为了多部门。$j$ 部门单位投入束的成本与工资和所有部门的价格指数都有关。因此，**任何一个部门价格指数的变化，都会传导到其他所有部门**。

#### 3.1.3 Composite intermediate goods

可以证明，$n$ 国使用 $j$ 部门聚合品的数量 $Q_n^j$ 与实际使用的该部门各产品数量 $r_{n}^{j}(\omega^{j})$ 的关系为：
$$
Q_{n}^{j}=\left\{\int_0^1 \left[r_{n}^{j}\left(\omega^{j}\right)\right]^{(\sigma^{j}-1)/\sigma^{j}} d \omega^{j}\right\}^{\sigma^{j} /\left(\sigma^{j}-1\right)}
$$
其中 $\sigma^{j}$ 是生产函数中 $j$ 部门各产品之间的替代弹性。

聚合品的价格指数为
$$
P_{n}^j=\left\{\int_{0}^{1} \left[p_{n}^j(\omega^j)\right]^{1-\sigma^j} d \omega^j\right\}^{\frac{1}{1-\sigma^j}}
$$
其中 $p_{n}^j(\omega^j)$ 是每种产品经过充分市场竞争后的最低价格。

可以从中求           得关系式：
$$
r_{n}^{j}\left(\omega^{j}\right)=\left[\frac{p_{n}^{j}\left(\omega^{j}\right)}{P_{n}^{j}}\right]^{-\sigma^{j}} Q_{n}^{j}
$$
> $j$ 部门聚合品的市场出清条件为
> $$
> Q_{n}^{j}=C_{n}^{j}+\sum_{k=1}^{J} \int_0^1 m_{n}^{j, k}\left(\omega^{k}\right) d \omega^{k}
> $$
> 注意，$Q_{n}^{j}$ 不是本国产量，而是本国产量加上净进口

#### 3.1.4 International trade costs and prices

- 表示 ice-berg trade cost 的符号 $d_{ni}^j$，不仅有国别差异，还有行业差异
- 从价关税率 $\tau_{ni}^j$，且令 $\tilde\tau_{ni}^j=1+\tau_{ni}^j$

可以用以下符号表示总的贸易成本（非贸易部门的贸易成本为 $\infty$）：
$$
\kappa_{ni}^{j} \equiv \tilde\tau_{ni}^j d_{ni}^j \tag{3}
$$
此外，**假设 $\kappa_{nh}^j \kappa_{hi}^j \ge \kappa_{ni}^j$ 恒成立，即不会出现转口贸易**（即 $h$ 国从 $i$ 国进口商品再转售给 $n$ 国，这比 $n$ 国直接从 $i$ 国购买贵，因而无利可图）——**这是一个很强的假设**，因为现实中存在一些由于关税结构不同而发生的转口贸易（虽然多数时候 $n$ 国都会尽量堵上这种漏洞，防止 $n$ 国对 $i$ 国设立的关税水平沦为废纸）——**于是任意行业的出口不会大于产出**。



$i$ 国商品 $\omega^{j}$ 在 $n$ 国的价格为 $c_{i}^{j} \kappa_{n i}^{j} / z_{i}^{j}\left(\omega^{j}\right)$，则 $n$ 国最终选择的该商品价格为
$$
p_{n}^{j}\left(\omega^{j}\right)=\min _{i}\left\{\frac{c_{i}^{j} \kappa_{n i}^{j}}{z_{i}^{j}\left(\omega^{j}\right)}\right\}
$$

对于非贸易品，有

1. $\kappa_{ni}^{j} = \infty$
2. $p_n^j(\omega^j)=c_{n}^{j}/ z_{n}^{j}\left(\omega^{j}\right)$
3. $r_n^j(\omega^j)=q_n^j(\omega^j)$，即供给无法依赖进口，只能由本国生产



按照 EK 的技术分布，可以假设各国、各行业的技术水平参数为 $\lambda_i^j$，各行业技术分布的参数为 $\theta^j$，从而推导出聚合品的价格指数
$$
P_{n}^{j}=A^{j}\left[\sum_{i=1}^{N} \lambda_{i}^{j}\left(c_{i}^{j} \kappa_{n i}^{j}\right)^{-\theta^{j}}\right]^{-1 / \theta^{j}} \tag{4}
$$
则一国消费者价格指数为
$$
P_{n}=\prod_{j=1}^{J}\left(P_{n}^{j} / \alpha_{n}^{j}\right)^{\alpha_{n}^{j}} \tag{5}
$$

#### 3.1.5 Expenditure shares

在无转口贸易的假设下，$n$ 国对 $j$ 部门的总支出为 $X_n^j=\sum_{i=1}^N X_{ni}^j=P_n^jQ_n^j$，其中对 $i$ 国的支出（含关税）为 $X_{ni}^j=M_{ni}^j(1+\tau_{n i}^{j})$，则可以定义支出份额 $\pi_{ni}^j \equiv X_{ni}^j/X_n^j$

可以推导出，支出份额是各国技术水平、工资、价格指数和双边贸易成本的函数：
$$
\pi_{n i}^{j}=\frac{\lambda_{i}^{j}\left[c_{i}^{j} \kappa_{n i}^{j}\right]^{-\theta^{j}}}{\sum_{h=1}^{N} \lambda_{h}^{j}\left[c_h^j \kappa_{n h}^{j}\right]^{-\theta^{j}}} \tag{6}
$$
这是一个多部门版本的引力方程。两国关税的变化会直接影响 $\kappa_{ni}^j$. 且由 (2) 式知，还会间接地影响 $c_i^j$.

#### 3.1.6 Total expenditure and trade balance

$n$ 国对 $j$ 部门的总支出
$$
X_n^j=Y_{n}^{j}+M_n^j-E_n^j=\sum_{k=1}^{J} \gamma_{n}^{j, k}Y_n^k+\alpha_{n}^{j} I_{n}
$$

- 右边第 1 项，n 国某行业的总销售（如果不存在转口贸易，则也是总产值），乘以所使用的 $j$ 行业中间品的成本比例，再对行业加总，即 $n$ 国对 $j$ 行业中间品的总支出。
- 右边第 2 项， $n$ 国对 $j$ 行业最终品的支出。

在无转口贸易的假设下，产出 $Y_n^k=\sum_{i=1}^{N} X_{i}^{k} \frac{\pi_{i n}^{k}}{1+\tau_{i n}^{k}}$，代入上式则有
$$
X_{n}^{j}=\sum_{k=1}^{J} \gamma_{n}^{j, k} \sum_{i=1}^{N} X_{i}^{k} \frac{\pi_{i n}^{k}}{1+\tau_{i n}^{k}}+\alpha_{n}^{j} I_{n} \tag{7}
$$

其中预算可以展开为：

$$
I_{n}=w_{n} L_{n}+R_{n}+D_{n} \tag{8}
$$
- 右边第 1 项为工资收入。事实上有 $\begin{aligned} w_nL_n=\sum_{k=1}^{J} \gamma_{n}^{k}Y_n^k = \sum_{k=1}^{J} \gamma_{n}^{k} \sum_{i=1}^{N} X_{i}^{k} \frac{\pi_{i n}^{k}}{1+\tau_{i n}^{k}} \end{aligned}$，但在本模型中部门增加值（部门工资收入）外生，从而国别工资收入外生，因此无需展开。

- 右边第 2 项为关税收入转移支付，$\begin{aligned} R_n = \sum_{j=1}^J\sum_{i=1}^N\tau_{ni}^j M_{ni}^j \end{aligned}$ ，进口额（不含关税价） $\begin{aligned} M_{ni}^j=X_n^j \frac{\pi_{ni}^j}{1+\tau_{ni}^j} \end{aligned}$. 可以证明，$$\begin{aligned} R_n = \sum_{j=1}^J \left[  X_{n}^j \sum_{i=1}^N \left(1-\frac{1}{1+\tau_{ni}^j} \right)\pi_{ni}^j \right]= \sum_{j=1}^J \left[  X_{n}^j\left(1 - \sum_{i=1}^N \frac{1}{1+\tau_{ni}^j}\pi_{ni}^j \right) \right]\end{aligned}$$

- 右边第 3 项为国别贸易赤字（通过资本账户融资，以支持本国国民直接收入以外的支出），这是一个外生变量（宏观统计数据）。

 (8) 式代入 (7) 式，成为 (7) 式的完整形式。



由于贸易赤字 $\begin{aligned}D_n = \sum_{j=1}^J D_n^j= \sum_{j=1}^J \sum_{i = 1}^{N} M_{n i}^{j}-\sum_{j=1}^J\sum_{i = 1}^{N} E_{n i}^{j} \end{aligned}$，其中出口额（离岸价） $\begin{aligned} E_{n i}^{j} = X_i^j \frac{\pi_{in}^j}{1+\tau_{in}^j} \end{aligned}$. 因此有
$$
\sum_{j=1}^{J} \sum_{i=1}^{N} X_{n}^{j} \frac{\pi_{n i}^{j}}{1+\tau_{n i}^{j}}-D_{n}=\sum_{j=1}^{J} \sum_{i=1}^{N} X_{i}^{j} \frac{\pi_{i n}^{j}}{1+\tau_{i n}^{j}} \tag{9}
$$



定义 1：给定外生的 $L_n$, $D_n$, $\lambda_n^j$, $d_{ni}^j$ 向量，则每一种关税水平 $\tau_{ni}^j$，都能根据 (2), (4), (6), (7), (9) 式解出工资向量 $\boldsymbol{w}$ 和价格水平向量  $\boldsymbol{P}$。

> (2)(4) 联立，可将 $\boldsymbol{c}$ 向量和 $\boldsymbol{P}$ 向量表示为 $w$ 向量的函数，然后从 (6) 可计算 $\boldsymbol{\pi}$ 向量，从 (7) 可计算 $\boldsymbol{X}$ 向量（都表示为 $\boldsymbol{w}$ 向量的函数）。
>
> 最后带入 (9)，可解出 $\boldsymbol{w}$ 向量。

#### 3.1.7 Equilibrium in relative changes

做反事实模拟，关注的重点不是关税水平 $\tau$ 下的均衡，而是从 $\tau$ 变到 $\tau'$ 后均衡解的变化。这样，就不必估计那些难以从数据中识别出来的参数，如技术水平 $\lambda_n^j$ 和贸易成本 $d_{ni}^j$.

定义 2（帽子代数）：关税水平从 $\tau$ 到 $\tau'$，对于任意变量 $x$ 变为 $x'$，定义 $\hat x=x'/x$. 则由 (2), (4), (6), (7), (9) 式，可以得到以下 5 个变化比例方程：

投入束的成本
$$
\hat{c}_{n}^{j}=\hat{w}_{n}^{\gamma_{n}^{j}} \prod_{k=1}^{J} (\hat{P}_{n}^{k})^{ \gamma_{n}^{k, j}} \tag{10}
$$
聚合品的价格指数
$$
\hat{P}_{n}^{j}=\left[\sum_{i=1}^{N} \pi_{n i}^{j}\left[\hat{\kappa}_{n i}^{j} \hat{c}_{i}^{j}\right]^{-\theta^{j}}\right]^{-1 / \theta^{j}} \tag{11}
$$
贸易份额
$$
\hat{\pi}_{n i}^{j}=\left[\frac{\hat{c}_{i}^{j} \hat{\kappa}_{n i}^{j}}{\hat{P}_{n}^{j}}\right]^{-\theta^{j}} \tag{12}
$$
支出
$$
{X_{n}^{j}}'=\sum_{k=1}^{J} \gamma_{n}^{j, k} \sum_{i=1}^{N} \frac{{\pi_{i n}^{k}}^{\prime}}{1+{\tau_{i n}^{k}}'} {X_{i}^{k}}'+\alpha_{n}^{j} I_{n}^{\prime} \tag{13}
$$
贸易赤字
$$
\sum_{j=1}^{J} \sum_{i=1}^{N} \frac{{\pi_{n i}^{j}}'}{1+{\tau_{n i}^j}'} {X_n^j}'-D_{n}=\sum_{j=1}^{J} \sum_{i=1}^{N} \frac{{\pi_{i n}^j}'}{1+{\tau_{i n}^j}'} {X_i^j}' \tag{14}
$$
其中一些缩写的展开式为：
$$
\hat{\kappa}_{n i}^{j}=\left(1+{\tau_{n i}^j}'\right) /\left(1+\tau_{n i}^{j}\right)
$$

$$
I_{n}^{\prime}=\widehat{w}_{n} w_{n} L_{n}+\sum_{j=1}^{J} \sum_{i=1}^{N} \tau_{n i}^{j^{\prime}} \frac{\pi_{n i}^{j^{\prime}}}{1+\tau_{n i}^{j^{\prime}}} X_{n}^{j^{\prime}}+D_{n}
$$

由 (10)-(13) 式可看出

1. 不需要依赖技术水平 $\lambda_n^j$ 和冰山成本 $d_{ni}^j$，仅凭以下参数：两套关税水平（ $\tau$ 和 $\tau'$ ）、双边贸易份额 $\pi_{n i}^{j}$、劳动和中间品所占成本份额（$\gamma_n^j, \gamma_n^{k,j}$）、工资收入 $w_{n} L_{n}$、消费在不同产业产品上的分配比例 $\alpha_n^j$、生产率分布参数 $\theta^j$，就能进行反事实模拟。
2. 上述大部分参数可直接从数据中获得，唯一需要估计的只有 $\theta^j$. 

#### 3.1.8 Relative change in real wages

实际工资的变化不等于福利的变化，因为本文模型的收入中还有关税转移支付这一项，这一项的购买力也会变化。

实际工资的变化比例为：
$$
\ln \frac{\hat{w}_{n}}{\hat{P}_{n}}=-\underbrace{\sum_{j=1}^{J} \frac{\alpha_{n}^{j}}{\theta_{j}^{j}} \ln \hat{\pi}_{n n}^{j}}_{\text {Final goods }}-\underbrace{\sum_{j=1}^{J} \frac{\alpha_{n}^{j}}{\theta^{j}} \frac{1-\gamma_{n}^{j}}{\gamma_{n}^{j}} \ln \hat{\pi}_{n n}^{j}}_{\text {Intermediate goods }}-\underbrace{\sum_{j=1}^{J} \frac{\alpha_{n}^{j}}{\gamma_{n}^{j}} \ln \prod_{k=1}^{J}\left(\hat{P}_{n}^{k} / \hat{P}_{n}^{j}\right)^{\gamma_{n}^{k, j}}}_{\text {Sectoral linkages }} \tag{15}
$$
取决于每个行业产品国内购买份额 $\pi_{nn}^j$ 的变化和行业价格 $P_n^j$ 的变化

### 3.2 Welfare effects from tariff changes

定义福利 $W_n = I_n/P_n$，$I_n$ 由 (8) 式给出，$P_n$ 由 (5) 式给出，则可以推导出
$$
d \ln W_{n}=\frac{1}{I_{n}} \sum_{j=1}^{J} \sum_{i=1}^{N} \underbrace{\left(E_{n i}^{j} d \ln c_{n}^{j}-M_{n i}^{j} d \ln c_{i}^{j}\right)}_{\text {Terms of trade }}+\frac{1}{I_{n}} \sum_{j=1}^{J} \sum_{i=1}^{N} \underbrace{\tau_{n i}^{j} M_{n i}^{j}\left(d \ln M_{n i}^{j}-d \ln c_{i}^{j}\right)}_{\text {Volume of trade }} \tag{16}
$$
附录 Welfare 给出了 (16) 式的详细推导。



定义双边贸易条件的变化：
$$
d \ln t o t_{n i}=\sum_{j=1}^{J}\left(E_{n i}^{j} d \ln c_{n}^{j}-M_{n i}^{j} d \ln c_{i}^{j}\right) \tag{17}
$$
定义双边贸易量的变化：
$$
d \ln vot_{n i}=\sum_{j=1}^{J} \tau_{n i}^{j} M_{n i}^{j}\left(d \ln M_{n i}^{j}-d \ln c_{i}^{j}\right) \tag{18}
$$
福利变化可以对贸易伙伴分解：
$$
d \ln W_{n}=\frac{1}{I_{n}} \sum_{i=1}^{N}\left(d \ln t o t_{n i}+d \ln v o t_{n i}\right)
$$


定义部门贸易条件的变化：
$$
d \ln tot_{n}^{j}=\sum_{i=1}^{N}\left(E_{n i}^{j} d \ln c_{n}^{j}-M_{n i}^{j} d \ln c_{i}^{j}\right) \tag{19}
$$
定义部门贸易量的变化：
$$
d \ln vot_{n}^{j}=\sum_{i=1}^{N} \tau_{n i}^{j} M_{n i}^{j}\left(d \ln M_{n i}^{j}-d \ln c_{i}^{j}\right) \tag{20}
$$
福利变化可以对行业分解：
$$
d \ln W_{n}=\frac{1}{I_{n}} \sum_{j=1}^{J}\left(d \ln t o t_{n}^{j}+d \ln v o t_{n}^{j}\right)
$$

### 3.3 Taking the model to the data（数据预处理）

相对变化模型一个关键的优点是，使 calibrate model 所需的数据最小化。仅需要关税 $\tau_{ni}^j$、双边贸易流 $M_{ni}^j$、行业增加值 $V_n^j$（即劳动力收入）、行业产出 $Y_n^j$ 和 I-O tables，便可以计算出双边贸易份额 $\pi_{n i}^{j}$、劳动和中间品所占成本份额（$\gamma_n^j, \gamma_n^{k,j}$）、消费在不同产业产品上的分配比例 $\alpha_n^j$. 计算过程如下：

1. 本国使用的本国产 $j$ 部门产品为总产出减去出口（离岸价），即 $M_{n n}^{j}=Y_{n}^{j}-\sum_{i=1, i \neq n}^{N} M_{i n}^{j}$
   1. 若产出小于出口，存在转口贸易现象，则令 $M_{n n}^{j}=0$

2. 支出矩阵（若为进口，则含关税）为 $X_{n i}^{j}=M_{n i}^{j}\left(1+\tau_{n i}^{j}\right)$
   1. $M_{ni}^j$ 本为双边贸易数据，缺乏对角元 $M_{n n}^{j}$，因此必须有第一步，才能得到完整的 $X_{n i}^{j}$ 矩阵

3. $\pi_{n i}^{j}=X_{n i}^{j} / \sum_{i=1}^{N} X_{n i}^{j}$

4. $\gamma_n^j=V_n^j/Y_n^j$

5. $\gamma_n^{k,j}$ 可从 I-O 表中计算

   >  $\text{share of intermediate consumption of sector k in sector j over total intermediate consumption in sector j} \times (1-\gamma_n^j)$

6. $\begin{aligned} D_{n}^{j} = \sum_{i = 1}^{N} M_{n i}^{j}-\sum_{i = 1}^{N} M_{in}^{j} \end{aligned}$

7. $\alpha_{n}^{j}=\left(Y_{n}^{j}+D_{n}^{j}-\sum_{k=1}^{J} \gamma_{n}^{j, k} Y_{n}^{k}\right) / I_{n}=\left[X_n^j-\sum_{k=1}^{J} \gamma_{n}^{j, k} Y_{n}^{k}\right]/I_n$
   1. 产出加净进口，为国内使用量——这个量与支出不同

8. 唯一不能直接计算的参数是 $\theta^j$，需要估计，本文给出的方法见 Section 4

践行上述所有步骤后，即完成了对模型的校准（calibration），接下来就可以进行反事实模拟了。

> calibration，即完成了对所有外生变量和参数的计算，足以确定 baseline

### 3.4 Solving the model for tariff changes

有了 Section 3.3 中的原始数据和计算出来的变量后，便可求解相对变化模型 (10)-(14) 式的新均衡。

编程思路如下：

1. 猜测一个相对工资向量 $\boldsymbol{\hat{w}} \equiv (\hat{w_1},\cdots ,\hat{w_N})$
2. (10) 和 (11) 共有 $2\times J \times N$ 个方程，有 $J \times N$ 个未知数 $\hat{P}_n^j$ 和 $J \times N$ 个未知数 $\hat{c}_n^j$，因此可解。
3. 然后根据 (12) 式可计算 $\hat{\pi}_{n i}^{j}$，从而可计算 ${\pi_{n i}^{j}}'$
4. 根据 (14) 可计算 ${X_{n}^{j}}'$
5. 最后将所有计算出的变量带入 (13)，观察方程是否平衡。如果不平衡，则调整 $\boldsymbol{\hat{w}}$，直至方程平衡。

详见附录 Solving the Model（模型的矩阵形式）

## Section 4 估计 $\theta^{j}$

新的估计弹性的方法：由 (6) 式，对于行业 $j$，可以选三个国家 index，推导出以下方程：

> 共可推导出 $C_{N}^{3}$ 个这样的方程

$$
\frac{X_{n i}^{j} X_{i h}^{j} X_{h n}^{j}}{X_{n h}^{j} X_{h i}^{j} X_{i n}^{j}}=\left(\frac{\kappa_{n i}^{j}}{\kappa_{i n}^{j}} \frac{\kappa_{i h}^{j}}{\kappa_{h i}^{j}} \frac{\kappa_{h n}^{j}}{\kappa_{n h}^{j}}\right)^{-\theta^{j}} \tag{21}
$$
再假设贸易成本的结构为
$$
\ln \kappa_{n i}^{j}=\ln \tilde{\tau}_{n i}^{j}+\ln d_{n i}^{j}=\ln \tilde{\tau}_{n i}^{j}+\nu_{n i}^{j}+\mu_{n}^{j}+\delta_{i}^{j}+\varepsilon_{n i}^{j} \tag{22}
$$
其中 $\nu_{ni}^j=\nu_{in}^j$，表示双边贸易成本中对称的部分，如距离、语言、边界、是否共处于一个 FTA 中，等等。$\mu_n^j$ 表示**进口国**对所有贸易伙伴普遍适用的部门固定效应（sectoral fixed effect），如非关税壁垒等。$\delta_i^j$ 表示**出口国**对所有贸易伙伴普遍适用的部门固定效应。$\varepsilon_{ni}^j$ 是一个随机干扰项，表示与关税正交的、远离对称性的偏差。

将 (22) 式带入 (21) 得
$$
\ln \left(\frac{X_{n i}^{j} X_{i h}^{j} X_{h n}^{j}}{X_{i n}^{j} X_{h i}^{j} X_{n h}^{j}}\right)=-\theta^{j} \ln \left(\frac{\tilde{\tau}_{n i}^{j}}{\tilde{\tau}_{i n}^{j}} \frac{\tilde{\tau}_{i h}^{j}}{\tilde{\tau}_{h i}^{j}} \frac{\tilde{\tau}_{h n}^{j}}{\tilde{\tau}_{n h}^{j}}\right)+\tilde \varepsilon^{j} \tag{23}
$$
其中 $\tilde \varepsilon^{j} = \theta^{j}(\varepsilon_{i n}^{j}-\varepsilon_{n i}^{j}+\varepsilon_{h i}^{j}-\varepsilon_{i h}^{j}+\varepsilon_{n h}^{j}-\varepsilon_{h n}^{j})$

使用 (23) 式的计量模型，即可估计各行业的 $\theta^{j}$，见 TABLE 1

此外，作为额外的稳健性检查，本文还估计了带有进口国和出口国固定效应的模型，见附录 Additional Results

## Section 5 NAFTA 的贸易和福利影响

附录 Data Sources and Description

### 5.1 不考虑世界其他地区关税变化 

只考虑 NAFTA，不考虑世界其他地区关税变化，与二者都未发生的基期比较。

TABLE 2，由 (15)、(16) 式计算的 NAFTA 关税削减的效应。

模型假设：（1）世界其他地区的关税维持 1993 年水平；（2）贸易赤字为零。

![table2](img/table2.png)

TABLE 3，利用 (17)、(18) 式，将贸易条件效应和贸易量效应对国家分解。

![table3](img/table3.png)

出口价格的变化取决于工资增长相对于中间品投入价格下降的幅度大小。美国中间品价格变化极小，导致出口价格是提高的；而墨西哥和加拿大虽然工资增长较大，但中间品价格下降幅度更大，所以出口价格是下降的。

TABLE 4，利用 (19)、(20) 式，将贸易条件效应和贸易量效应对行业分解。

对墨西哥贸易条件恶化（出口价格降低）贡献最大的三个部门（电气设备、通信设备、汽车）占减少额的76%。 这些部门的产品在生产中被广泛使用，因此进口关税的降低极大地增强了墨西哥产品的世界竞争力。

### 5.2 纳入世界其他地区关税变化

同时考虑 NAFTA 和世界其他地区关税变化，与二者都未发生的基期比较。

TABLE 7-8

以 NAFTA 成员国为重点，与只有 NAFTA 关税削减的情况相比，所有国家都获益更多。



TABLE 9 Welfare effects from NAFTA given world tariff changes

以世界其他地区关税变化、但 NAFTA 未发生为基期，反事实模拟二者都发生，进行比较。

### 5.3 不同模型的比较

比较表明，简单的模型都低估了关税削减的影响。考虑部门异质性、中间产品（即劳动以外的多要素）和 I-O linkage 是必要的。
