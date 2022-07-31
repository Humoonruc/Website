% Script

close all % 关掉画图等窗口
clear all % 清除主屏幕
clc

%%

vfactor = -0.2; % 迭代的负反馈系数
tol = 1E-07; % 误差容忍度（精度）
maxit = 1E+10; % 最大迭代次数

%Inputs
J = 40; % 行业
N = 31; % 国家

% Countries = [Argentina    Australia   Austria Brazil  Canada  Chile China   Denmark Finland France...
%              Germany  Greece  Hungary India   Indonesia   Ireland Italy   Japan   Korea Mexico ...
%              Netherlands New Zealand Norway  Portugal    SouthAfrica Spain   Sweden  Turkey  UK   USA ...
%              ROW];

%% trade flows

xbilat1993 = importdata('xbilat1993.txt');
xbilat1993 = xbilat1993 * 1000; % converted to dollars from thousand dollars
xbilat1993_new = [xbilat1993; zeros(20 * N, N)]; % adding the non-tradabble sectors，非贸易部门

%% tariff

tau1993 = importdata('tariffs1993.txt'); % tariffs 1993
tau2005 = importdata('tariffs2005.txt'); % tariffs 2005

tau = [1 + tau1993 / 100; ones(620, 31)]; % actual tariff vector, $\tilde{\tau}=1+\tau$
% 再加入 620 行，表示非贸易品（关税为0）
taup = [1 + tau2005 / 100; ones(620, 31)]; % counterfactual tariff vector, p 表示 prime，即'
taup = tau; % 1993年作为基准值
tau_hat = taup ./ tau; % Change in tariffs，(11) 式中的 kappa_hat

%% Parameters

G = importdata('IO.txt'); % IO coefs
% 注意，（1-劳动占成本份额）*I-O系数才是 \gamma_n^{j,k}
B = importdata('B.txt'); % Share of value added，劳动占成本份额
GO = importdata('GO.txt'); % Gross Output
T = importdata('T.txt'); % 各行业的thetas - dispersion of productivity
T = [1 ./ T; ones(20, 1) * (1/8.22)]; % theta^-1, non-tradables thetas= 8.22

%% Expenditure X_{ni}^j

% （1）import expenditure
xbilat = xbilat1993_new .* tau; % 含关税的贸易流量
xbilat_domestic = xbilat ./ tau; % 不含关税的贸易流量

% （2）Domestic expenditure
x = zeros(J, N); % 出口矩阵，行为部门，列为出口国

for i = 1:J
    x(i, :) = sum(xbilat_domestic(1 + (i - 1) * N:i * N, :)); % 对目的地加总，即出口
end

% 理论假设会导致出口恒不大于产出，然而现实数据有时会违反这一点
GO = max(GO, x); % 行业产出和出口中较大的一个
domsales = GO - x; % 产出供给本国的部分，即 M_{nn}^j. 若出口大于产出，M_{nn}^j=0
domsales_aux = domsales'; % 转置
aux2 = zeros(J * N, N);

for i = 1:1:J % 1:1:J 表示一个序列，初值为1，终值为J，步长为1，其实可以简化为 1:J
    aux2(1 + (i - 1) * N:i * N, :) = diag(domsales_aux(:, i)); % 某产业各国的国内销售额，扩展为对角矩阵，按产业顺序纵向堆积
end

% 完整的 expenditure 矩阵
xbilat = aux2 + xbilat; % xbilat 本来只有进口支出数据，对角元为0，现在加上了国内销售数据，成为了完整的支出数据 X_{ni}^j

%% X0 Expenditure X_{n}^j

A = sum(xbilat'); % 纵向求和，对来源国求和，这是 X_n^j

for j = 1:J
    X0(j, :) = A(:, 1 + N * (j - 1):N * j); % 将 1*1240 的矩阵重整为 40*31 维，按行填充
end

%% Expenditure shares

Xjn = sum(xbilat')' * ones(1, N);
Din = xbilat ./ Xjn;

%% 行业加总的贸易顺差

xbilattau = xbilat ./ tau; % 不含关税

for j = 1:J
    % Imports
    M(j, :) = (sum(xbilattau(1 + N * (j - 1):N * j, :)'))'; % 40*31 M_n^j

    for n = 1:N
        % Exports
        E(j, n) = sum(xbilattau(1 + N * (j - 1):N * j, n))'; % 40*31 E_n^j

    end

end;

Sn = sum(E)' - sum(M)'; % 各国所有行业加总的贸易顺差

%% w_n*L_n

% Calculating Value Added（工资）
VAjn = GO .* B; % 点乘
VAn = sum(VAjn)';

%% 某行业最终产品占预算的份额

% 对某行业产品的最终支出=总支出-中间产品支出
% （1-劳动占成本份额）*I-O系数才是 \gamma_n^{j,k}
for n = 1:N
    irow = 1 + J * (n - 1):J * n;
    num(:, n) = X0(:, n) - G(irow, :) * ((1 - B(:, n)) .* E(:, n));
end

for j = 1:J
    irow = 1 + N * (j - 1):1:N * j;
    F(j, :) = sum((Din(irow, :) ./ tau(irow, :))');
end


alphas = num ./ (ones(J, 1) * (VAn + sum(X0 .* (1 - F))' - Sn)');
% 被除数是对某行业产品的最终支出
% 除数是 I_n=w_nL_n+R_n+D_n
% 商为 \alpha

for j = 1:J

    for n = 1:N

        if alphas(j, n) < 0
            alphas(j, n) = 0; % 中间产品支出可能大于总支出？
        end

    end

end

% 使数据内在一致
% IO表
alphas = alphas ./ (ones(J, 1) * (sum(alphas))); % 归一化

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Main Program Counterfactuals 用最小信息集把其他变量都算出来，保证数据之间的钩稽关系
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Sn=zeros(N,1);

% 计算有贸易赤字的均衡解
[wf0 pf0 PQ Fp Dinp ZW Snp2] = equilibrium_LC(tau_hat, taup, alphas, T, B, G, Din, J, N, maxit, tol, VAn ./ 100000, Sn ./ 100000, vfactor);

%%

PQ_vec = reshape(PQ', 1, J * N)'; % expenditures Xji in long vector: PQ_vec=(X11 X12 X13...)'
Dinp_om = Dinp ./ taup;
xbilattau = (PQ_vec * ones(1, N)) .* Dinp_om;
xbilatp = xbilattau .* taup;

for j = 1:J
    GO(j, :) = sum(xbilattau(1 + (j - 1) * N:j * N, :)); % 这是进口或出口
end

for j = 1:J

    for n = 1:N
        xbilatp(n + (j - 1) * N, n) = 0; % 这是关税
    end

end

save('xbilat_base_year', 'xbilatp', 'Dinp', 'xbilattau')
save('alphas', 'alphas')
save('GO', 'GO')
