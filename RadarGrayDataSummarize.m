clear;
loadpath = 'C:\Users\admin\Desktop\¡ıœº\code\results\RadarResults\';
% loadname = '20201009135029_mse_140x170';
% loadname = '20201009135112_mse_167x225';
% loadname = '20201010101543_mse_230x250';
% loadname = 'RiverIce20150417_223028_200x225';
loadname = 'RiverIce20200513_013745_200x150';

load([loadpath 'BP_' loadname '_Res2\BPGDM_' loadname '_Res2.mat']);
[mse_BPGDM_min_val, mse_BPGDM_min_ind] = min(mse_BPGDM);
vpa(mse_BPGDM_min_val,10)
para_BPGDM_min = para(:,mse_BPGDM_min_ind)
vpa(para_BPGDM_min,10)
clear para

load([loadpath 'BP_' loadname '_Res2\BPGDA_' loadname '_Res2.mat']);
[mse_BPGDA_min_val, mse_BPGDA_min_ind] = min(mse_BPGDA);
vpa(mse_BPGDA_min_val,10)
para_BPGDA_min = para(:,mse_BPGDA_min_ind)
vpa(para_BPGDA_min,10)
clear para

load([loadpath 'BP_' loadname '_Res2\BPGDX_' loadname '_Res2.mat']);
[mse_BPGDX_min_val, mse_BPGDX_min_ind] = min(mse_BPGDX);
vpa(mse_BPGDX_min_val,10)
para_BPGDX_min = para(:,mse_BPGDX_min_ind)
vpa(para_BPGDX_min,10)
clear para

load([loadpath 'BP_' loadname '_Res2\BPRP_' loadname '_Res2.mat']);
[mse_BPRP_min_val, mse_BPRP_min_ind] = min(mse_BPRP);
vpa(mse_BPRP_min_val,10)
para_BPRP_min = para(:,mse_BPRP_min_ind)
vpa(para_BPRP_min,10)
clear para

load([loadpath 'BP_' loadname '_Res2\BPCGF_' loadname '_Res2.mat']);
[mse_BPCGF_min_val, mse_BPCGF_min_ind] = min(mse_BPCGF);
vpa(mse_BPCGF_min_val,10)
para_BPCGF_min = para(:,mse_BPCGF_min_ind)
vpa(para_BPCGF_min,10)
clear para

load([loadpath 'BP_' loadname '_Res2\BPCGP_' loadname '_Res2.mat']);
[mse_BPCGP_min_val, mse_BPCGP_min_ind] = min(mse_BPCGP);
vpa(mse_BPCGP_min_val,10)
para_BPCGP_min = para(:,mse_BPCGP_min_ind)
vpa(para_BPCGP_min,10)
clear para

load([loadpath 'BP_' loadname '_Res2\BPCGB_' loadname '_Res2.mat']);
[mse_BPCGB_min_val, mse_BPCGB_min_ind] = min(mse_BPCGB);
vpa(mse_BPCGB_min_val,10)
para_BPCGB_min = para(:,mse_BPCGB_min_ind)
vpa(para_BPCGB_min,10)
clear para

load([loadpath 'BP_' loadname '_Res2\BPSCG_' loadname '_Res2.mat']);
[mse_BPSCG_min_val, mse_BPSCG_min_ind] = min(mse_BPSCG);
vpa(mse_BPSCG_min_val,10)
para_BPSCG_min = para(:,mse_BPSCG_min_ind)
vpa(para_BPSCG_min,10)
clear para

load([loadpath 'BP_' loadname '_Res2\BPBFG_' loadname '_Res2.mat']);
[mse_BPBFG_min_val, mse_BPBFG_min_ind] = min(mse_BPBFG);
vpa(mse_BPBFG_min_val,10)
para_BPBFG_min = para(:,mse_BPBFG_min_ind)
vpa(para_BPBFG_min,10)
clear para

load([loadpath 'BP_' loadname '_Res2\BPOSS_' loadname '_Res2.mat']);
[mse_BPOSS_min_val, mse_BPOSS_min_ind] = min(mse_BPOSS);
vpa(mse_BPOSS_min_val,10)
para_BPOSS_min = para(:,mse_BPOSS_min_ind)
vpa(para_BPOSS_min,10)
clear para

load([loadpath 'BP_' loadname '_Res2\BPLM_' loadname '_Res2.mat']);
[mse_BPLM_min_val, mse_BPLM_min_ind] = min(mse_BPLM);
vpa(mse_BPLM_min_val,10)
para_BPLM_min = para(:,mse_BPLM_min_ind)
vpa(para_BPLM_min,10)
clear para


