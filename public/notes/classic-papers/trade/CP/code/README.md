### Data

数据说明见附录，Data Sources and Description

#### B.txt

share of value added (工资在总成本中的占比) in gross output across sectors and countries, $\gamma_n^j$

$40 \times 31$ 矩阵，行为部门，列为国家

（预处理其他数据后，获得的表格）

#### GO.txt

gross output by sector and country, $Y_n^j$

$40 \times 31$ 矩阵，行为部门，列为国家

#### IO.txt

input-output coefficients for each country, 但==注意，这个值不是 $\gamma_n^{k,j}$==，而与其成正比。因为 $\sum_{k=1}^J \gamma_n^{k,j}=1-\gamma_n^j$，但 IO 表中相应一列的和就是 1.

$1240 \times 40$ 矩阵，每 40 行为一个国家的 I-O 矩阵。行为 source sectors，列为 destination sectors （即对每个国家而言，各列的和为1）

#### tariffs1993.txt

1993 年双边关税数据 $\tau_{ni}^j$

$620 \times 31$ matrix，每 31 行为一个可贸易部门的双边关税矩阵。行为 destination countries，列为 source countries.

#### tariffs2005.txt

2005 年双边关税数据 ${\tau_{ni}^j}'$

#### xbilat1993.txt

1993 年双边贸易流矩阵 $M_{ni}^j$，单位为 $10^3$ dollar

$620 \times 31$ matrix，每 31 行为一个可贸易部门的双边贸易量矩阵。行为 destination countries，列为   source countries.

#### alphas.mat 

最终消费中各部门产品所占份额 $\alpha_n^j$，在 matlab 内部计算出来的

$40 \times 31$ 矩阵，行为部门，列为国家

#### T.txt

可贸易部门的参数 $\theta^j$

$20 \times 1$ matrix

### Functions

1. equilibrium_LC.m，一个计算 equilibrium in relative changes（$\hat{w},  \hat{P}$ 等指标）的函数，其中调用了以下函数
   1. PH.m，计算 (10)(11) 式的 $\hat{c}$ 和 $\hat{P}$
   2. Dinprime.m，使用 (12) 式计算 $\pi'$
   3. expenditure.m 计算 (13) 式的 ${X_{n}^{j}}'$
   4. LMC.m 求解一种等价于 (14) 式的均衡（基本无用）

### 文件夹 Elasticities

#### Estimation of trade elasticities

TABLE1, TABLE A.2

Sample_100.m，100% 样   本的 data and the statistics 

Sample_99.m，99% 样本的 data and the statistics 

Sample_975.m，97.5% 样本的 data and the statistics

Estimation.do，估计 $\theta^j$

Final_Tables.m 展示估计的结果

### 文件夹 Equilibrium

equilibrium in the base year without aggregate trade deficits

1. Script.m，计算 equilibrium in the base year ==with== trade deficits
2. script_eliminating_trade_surplus.m，计算 counterfactual equilibrium without aggregate trade deficits.
3. script_no_surplus.m，构建 base year without aggregate trade deficits，将其保存为 initial_conditions_1993_noS.mat，包含计算反事实所需的所有变量

### 文件夹 Counterfactuals

Counterfactual results without aggregate trade deficits

1. CP_counterfactuals.m ，使用 initial_conditions_1993_noS.mat 作为输入，runs all the counterfactuals (compute the welfare and trade effects of NAFTA’s tariff reductions, world’s tariff changes, and NAFTA given world tariff changes)
2. results_counterfactualsCP.m，展示 Table 2 through Table 10, Table A.3, and Table A.8 through Table A.13.

### 文件夹 Equilibrium_with_deficit

Equilibrium in the base year with aggregate trade deficits

1. script.m，计算 equilibrium in the base year with trade deficits
2. script_with_surplus.m，构建 base year with aggregate trade deficits，将其保存为initial_conditions_1993_withS.mat，包含计算反事实所需的所有变量

### 文件夹 Counterfactuals_with_deficit

Counterfactual results with aggregate trade deficits

1. CP_counterfactuals_withdeficits.m，使用 initial_conditions_1993_withS.mat 作为输入，runs all the counterfactuals (compute the welfare and trade effects of NAFTA’s tariff reductions, world’s tariff changes, and NAFTA given world tariff changes)
2. results_counterfactualsCP_withdeficits.m，展示 Table A.4 through Table A.7 in the paper.

### 文件夹 Counterfactuals_across_models

Counterfactual results across different models

计算 trade and welfare effects from NAFTA in a one-sector model, a model without materials, and a model 
without input-output linkages，展示 TABLE 11

#### 文件夹 Counterfactuals_one_sector

#### 文件夹 Counterfactuals_no_materials

#### 文件夹 Counterfactuals_no_io



