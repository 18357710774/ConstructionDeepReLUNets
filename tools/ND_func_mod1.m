function ND_value = ND_func_mod1(x, xD, yD, N, tau)
[xDNum, d] = size(xD);
xNum = size(x, 1);
BlocksNum = N^d;
[Xi, B, B_wave] = CenterBound_func(d, N, tau);


if xNum>BlocksNum % perform the loop for Blocks
    RowIndCell = cell(BlocksNum, 1);
    ColIndCell = cell(BlocksNum, 1);
    ValCell = cell(BlocksNum, 1);
    for k = 1:BlocksNum
        indtmp1 = ones(xNum,1);
        for j = 1:d    
            indtmp11 = x(:,j)>=B_wave.lowBound(k,j) & x(:,j)<=B_wave.upBound(k,j);
            indtmp1 = indtmp1 & indtmp11;
        end
        if ~isempty(find(indtmp1==1, 1))
            RowIndCell{k} = find(indtmp1==1);
            ColIndCell{k} = k*ones(length(RowIndCell{k}),1);
            ValCell{k} = N1_func_multiCenter(x(RowIndCell{k},:), Xi(k,:), N, tau);            
        end
    end
else % perform the loop for x
    RowIndCell = cell(xNum, 1);
    ColIndCell = cell(xNum, 1);
    ValCell = cell(xNum, 1);
    for k = 1:xNum
        indtmp1 = ones(BlocksNum,1);
        for j = 1:d  % Ñ°ÕÒxÔÚÄÄÐ©blockÖÐ
            indtmp11 = x(k,j)>=B_wave.lowBound(:,j) & x(k,j)<=B_wave.upBound(:,j);
            indtmp1 = indtmp1 & indtmp11;
        end
        if ~isempty(find(indtmp1==1, 1))
            ColIndCell{k} = find(indtmp1==1);
            RowIndCell{k} =  k*ones(length(ColIndCell{k}),1);            
            ValCell{k} = (N1_func_multiCenter(x(k,:), Xi(ColIndCell{k},:), N, tau))';            
        end
    end
end
RowInd = cell2mat(RowIndCell);
ColInd = cell2mat(ColIndCell);
Val = cell2mat(ValCell);
x_Block_relation_mat = sparse(RowInd, ColInd, Val, xNum, BlocksNum);

UsedBlockInd = find(sum(abs(x_Block_relation_mat), 1)>0);

ND_value = zeros(size(x,1),1);
if length(UsedBlockInd)<xNum
    for k = 1:length(UsedBlockInd)
        if mod(k, 100) == 0
            fprintf(['Block proceeding: ' num2str(k) '/' num2str(length(UsedBlockInd)) '\n']);
        end
        kk = UsedBlockInd(k);
        x_in_Block_kk_Ind = find(x_Block_relation_mat(:,kk)>0);
        indtmp3 = ones(xDNum,1);
        for j = 1:d    
            indtmp33 = xD(:,j)>=B.lowBound(kk,j) & xD(:,j)<=B.upBound(kk,j);
            indtmp3 = indtmp3 & indtmp33;
        end
        if ~isempty(find(indtmp3==1, 1))
            yDsum = sum(yD(indtmp3));
            indtmp4 = ones(xDNum,1);
            for j = 1:d    
                indtmp44 = xD(:,j)>=B_wave.lowBound(kk,j) & xD(:,j)<=B_wave.upBound(kk,j);
                indtmp4 = indtmp4 & indtmp44;
            end
            ND_value(x_in_Block_kk_Ind,:) = ND_value(x_in_Block_kk_Ind,:)...
                + yDsum*x_Block_relation_mat(x_in_Block_kk_Ind, kk)/length(find(indtmp4==1));
        end   
    end
else
    yDkSum = zeros(1,BlocksNum);
    BkD_wave_num = zeros(1,BlocksNum);
    for k = 1:length(UsedBlockInd)
        if mod(k, 100) == 0
            fprintf(['Block proceeding: ' num2str(k) '/' num2str(length(UsedBlockInd)) '\n']);
        end
        kk = UsedBlockInd(k);
        indtmp3 = ones(xDNum,1);
        for j = 1:d    
            indtmp33 = xD(:,j)>=B.lowBound(kk,j) & xD(:,j)<=B.upBound(kk,j);
            indtmp3 = indtmp3 & indtmp33;
        end
        if ~isempty(find(indtmp3==1, 1))
            yDkSum(kk) = sum(yD(indtmp3));
            indtmp4 = ones(xDNum,1);
            for j = 1:d    
                indtmp44 = xD(:,j)>=B_wave.lowBound(kk,j) & xD(:,j)<=B_wave.upBound(kk,j);
                indtmp4 = indtmp4 & indtmp44;
            end
            BkD_wave_num(kk) = length(find(indtmp4==1));
        end   
    end
    
    for i = 1:xNum
        block_x_in_ind = find(x_Block_relation_mat(i,:)>0);
        ND_value(i) = sum(x_Block_relation_mat(i,block_x_in_ind).*yDkSum(:,block_x_in_ind)./BkD_wave_num(:,block_x_in_ind));
    end
end

