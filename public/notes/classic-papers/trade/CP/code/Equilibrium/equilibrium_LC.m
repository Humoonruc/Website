% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%  Main Program Counterfactuals
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [wf0 pf0 PQ Fp Dinp ZW Snp c DP PF] = equilibrium_LC(tau_hat, taup, alphas, T, B, G, Din, J, N, maxit, tol, VAn, Sn, vfactor)

    % initialize vectors of ex-post wage and price factors 初始化w和p均为1
    wf0 = ones(N, 1); 
    pf0 = ones(J, N);

    wfmax = 1; % tolerence
    e = 1; % 迭代次数

    while (e <= maxit) && (wfmax > tol);

        [pf0 c] = PH(wf0, tau_hat, T, B, G, Din, J, N, maxit, tol); % p_hat, c_hat

        % Calculating trade shares
        Dinp = Dinprime(Din, tau_hat, c, T, J, N); % pi'
        Dinp_om = Dinp ./ taup; % (14)式中 pi'/(1+tau') 的因子

        for j = 1:1:J
            irow = 1 + N * (j - 1):1:N * j;
            Fp(j, :) = sum((Dinp(irow, :) ./ taup(irow, :))');
        end

        % % Expenditure MATRIX
        PQ = expenditure(alphas, B, G, Dinp, taup, Fp, VAn, wf0, Sn, J, N);

        
        % 以下两行都没什么用，因为后面负反馈调整wf0时，用的是贸易赤字指标，wf1被赋了另外一个值，仅作为一个过渡性的中间变量
        wf1 = LMC(PQ, Dinp_om, J, N, B, VAn); % Iterating using LMC,
        ZW = (wf1 - wf0); %Excess function，迭代到了最后，这个变量无限接近零

        
        PQ_vec = reshape(PQ', 1, J * N)'; % expenditures Xji in long vector: PQ_vec=(X11 X12 X13...)'

        for n = 1:1:N
            DP(:, n) = Dinp_om(:, n) .* PQ_vec;
        end

        LHS = sum(DP)'; %exports （14）式等号右边的出口

        % calculating RHS (Imports) trade balance
        PF = PQ .* Fp;
        RHS = sum(PF)'; %imports （14）式等号左边的进口

        % excess function (trade balance)
        Snp = (RHS - LHS + Sn); % 比较静态分析：贸易赤字增量
        ZW2 =- (RHS - LHS + Sn) ./ (VAn); % 用劳动力收入（GDP）标准化
        %Iteration factor prices
        wf1 = wf0 .* (1 - vfactor * ZW2 ./ wf0); % 负反馈，默认贸易赤字与工资水平正相关
        % 注意 vfactor 为负数

        wfmax = sum(abs(wf1 - wf0));
        wfmax = sum(abs(Snp));

        wfmax0 = wfmax;
        wf0 = (wf1);

        e = e + 1;
    end
