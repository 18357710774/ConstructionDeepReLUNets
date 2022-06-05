clear;
loadpath = 'C:\Users\admin\Desktop\¡ıœº\code\results\RadarResults\';
% loadname = 'RiverIce20150417_223028_200x225';
loadname = 'RiverIce20200513_013745_200x150';


% load([loadpath 'ND_' loadname '_2ResColor\ND_' loadname '_2ResColor.mat'])
% [mse_ND_3channel_min_val, mse_ND_3channel_min_ind] = min(mse_ND_3channel,[],2);
% vpa(mse_ND_3channel_min_val,10)
% para_ND_3channel_min = N_starCross(:,mse_ND_3channel_min_ind)
% vpa(para_ND_3channel_min,10)
% [mse_ND_all_min_val, mse_ND_all_min_ind] = min(mse_ND_all,[],2);
% vpa(mse_ND_all_min_val,10)
% para_ND_all_min = N_starCross(:,mse_ND_all_min_ind)
% vpa(para_ND_all_min,10)

% load([loadpath 'SVRepsRBF' loadname '_2ResColor\SVRepsRBF' loadname '_2ResColor.mat']);
% [mse_SVRepsRBF_3channel_min_val, mse_SVRepsRBF_3channel_min_ind] = min(mse_SVRepsRBF_3channel,[],2);
% vpa(mse_SVRepsRBF_3channel_min_val,10)
% para_SVRepsRBF_3channel_min = para(:,mse_SVRepsRBF_3channel_min_ind)
% vpa(para_SVRepsRBF_3channel_min,10)
% [mse_SVRepsRBF_all_min_val, mse_SVRepsRBF_all_min_ind] = min(mse_SVRepsRBF_all,[],2);
% vpa(mse_SVRepsRBF_all_min_val,10)
% para_SVRepsRBF_all_min = para(:,mse_SVRepsRBF_all_min_ind)
% vpa(para_SVRepsRBF_all_min,10)
% clear para

load([loadpath 'BP' loadname '_2ResColor\BPGDM_' loadname '_2ResColor.mat']);
[mse_BPGDM_3channel_min_val, mse_BPGDM_3channel_min_ind] = min(mse_BPGDM_3channel,[],2);
vpa(mse_BPGDM_3channel_min_val,10)
para_BPGDM_3channel_min = para(:,mse_BPGDM_3channel_min_ind)
vpa(para_BPGDM_3channel_min,10)
[mse_BPGDM_all_min_val, mse_BPGDM_all_min_ind] = min(mse_BPGDM_all,[],2);
vpa(mse_BPGDM_all_min_val,10)
para_BPGDM_all_min = para(:,mse_BPGDM_all_min_ind)
vpa(para_BPGDM_all_min,10)
clear para

load([loadpath 'BP' loadname '_2ResColor\BPGDA_' loadname '_2ResColor.mat']);
[mse_BPGDA_3channel_min_val, mse_BPGDA_3channel_min_ind] = min(mse_BPGDA_3channel,[],2);
vpa(mse_BPGDA_3channel_min_val,10)
para_GDA_3channel_min = para(:,mse_BPGDA_3channel_min_ind)
vpa(para_GDA_3channel_min,10)
[mse_BPGDA_all_min_val, mse_BPGDA_all_min_ind] = min(mse_BPGDA_all,[],2);
vpa(mse_BPGDA_all_min_val,10)
para_GDA_all_min = para(:,mse_BPGDA_all_min_ind)
vpa(para_GDA_all_min,10)
clear para

load([loadpath 'BP' loadname '_2ResColor\BPGDX_' loadname '_2ResColor.mat']);
[mse_BPGDX_3channel_min_val, mse_BPGDX_3channel_min_ind] = min(mse_BPGDX_3channel,[],2);
vpa(mse_BPGDX_3channel_min_val,10)
para_BPGDX_3channel_min = para(:,mse_BPGDX_3channel_min_ind)
vpa(para_BPGDX_3channel_min,10)
[mse_BPGDX_all_min_val, mse_BPGDX_all_min_ind] = min(mse_BPGDX_all,[],2);
vpa(mse_BPGDX_all_min_val,10)
para_BPGDX_all_min = para(:,mse_BPGDX_all_min_ind)
vpa(para_BPGDX_all_min,10)
clear para

load([loadpath 'BP' loadname '_2ResColor\BPRP_' loadname '_2ResColor.mat']);
[mse_BPRP_3channel_min_val, mse_BPRP_3channel_min_ind] = min(mse_BPRP_3channel,[],2);
vpa(mse_BPRP_3channel_min_val,10)
para_BPRP_3channel_min = para(:,mse_BPRP_3channel_min_ind)
vpa(para_BPRP_3channel_min,10)
[mse_BPRP_all_min_val, mse_BPRP_all_min_ind] = min(mse_BPRP_all,[],2);
vpa(mse_BPRP_all_min_val,10)
para_BPRP_all_min = para(:,mse_BPRP_all_min_ind)
vpa(para_BPRP_all_min,10)
clear para

load([loadpath 'BP' loadname '_2ResColor\BPCGF_' loadname '_2ResColor.mat']);
[mse_BPCGF_3channel_min_val, mse_BPCGF_3channel_min_ind] = min(mse_BPCGF_3channel,[],2);
vpa(mse_BPCGF_3channel_min_val,10)
para_BPCGF_3channel_min = para(:,mse_BPCGF_3channel_min_ind)
vpa(para_BPCGF_3channel_min,10)
[mse_BPCGF_all_min_val, mse_BPCGF_all_min_ind] = min(mse_BPCGF_all,[],2);
vpa(mse_BPCGF_all_min_val,10)
para_BPCGF_all_min = para(:,mse_BPCGF_all_min_ind)
vpa(para_BPCGF_all_min,10)
clear para

load([loadpath 'BP' loadname '_2ResColor\BPCGP_' loadname '_2ResColor.mat']);
[mse_BPCGP_3channel_min_val, mse_BPCGP_3channel_min_ind] = min(mse_BPCGP_3channel,[],2);
vpa(mse_BPCGP_3channel_min_val,10)
para_BPCGP_3channel_min = para(:,mse_BPCGP_3channel_min_ind)
vpa(para_BPCGP_3channel_min,10)
[mse_BPCGP_all_min_val, mse_BPCGP_all_min_ind] = min(mse_BPCGP_all,[],2);
vpa(mse_BPCGP_all_min_val,10)
para_BPCGP_all_min = para(:,mse_BPCGP_all_min_ind)
vpa(para_BPCGP_all_min,10)
clear para

load([loadpath 'BP' loadname '_2ResColor\BPCGB_' loadname '_2ResColor.mat']);
[mse_BPCGB_3channel_min_val, mse_BPCGB_3channel_min_ind] = min(mse_BPCGB_3channel,[],2);
vpa(mse_BPCGB_3channel_min_val,10)
para_BPCGB_3channel_min = para(:,mse_BPCGB_3channel_min_ind)
vpa(para_BPCGB_3channel_min,10)
[mse_BPCGB_all_min_val, mse_BPCGB_all_min_ind] = min(mse_BPCGB_all,[],2);
vpa(mse_BPCGB_all_min_val,10)
para_BPCGB_all_min = para(:,mse_BPCGB_all_min_ind)
vpa(para_BPCGB_all_min,10)
clear para

load([loadpath 'BP' loadname '_2ResColor\BPSCG_' loadname '_2ResColor.mat']);
[mse_BPSCG_3channel_min_val, mse_BPSCG_3channel_min_ind] = min(mse_BPSCG_3channel,[],2);
vpa(mse_BPSCG_3channel_min_val,10)
para_BPSCG_3channel_min = para(:,mse_BPSCG_3channel_min_ind)
vpa(para_BPSCG_3channel_min,10)
[mse_BPSCG_all_min_val, mse_BPSCG_all_min_ind] = min(mse_BPSCG_all,[],2);
vpa(mse_BPSCG_all_min_val,10)
para_BPSCG_all_min = para(:,mse_BPSCG_all_min_ind)
vpa(para_BPSCG_all_min,10)
clear para

load([loadpath 'BP' loadname '_2ResColor\BPBFG_' loadname '_2ResColor.mat']);
[mse_BPBFG_3channel_min_val, mse_BPBFG_3channel_min_ind] = min(mse_BPBFG_3channel,[],2);
vpa(mse_BPBFG_3channel_min_val,10)
para_BPBFG_3channel_min = para(:,mse_BPBFG_3channel_min_ind)
vpa(para_BPBFG_3channel_min,10)
[mse_BPBFG_all_min_val, mse_BPBFG_all_min_ind] = min(mse_BPBFG_all,[],2);
vpa(mse_BPBFG_all_min_val,10)
para_BPBFG_all_min = para(:,mse_BPBFG_all_min_ind)
vpa(para_BPBFG_all_min,10)
clear para

load([loadpath 'BP' loadname '_2ResColor\BPOSS_' loadname '_2ResColor.mat']);
[mse_BPOSS_3channel_min_val, mse_BPOSS_3channel_min_ind] = min(mse_BPOSS_3channel,[],2);
vpa(mse_BPOSS_3channel_min_val,10)
para_BPOSS_3channel_min = para(:,mse_BPOSS_3channel_min_ind)
vpa(para_BPOSS_3channel_min,10)
[mse_BPOSS_all_min_val, mse_BPOSS_all_min_ind] = min(mse_BPOSS_all,[],2);
vpa(mse_BPOSS_all_min_val,10)
para_BPOSS_all_min = para(:,mse_BPOSS_all_min_ind)
vpa(para_BPOSS_all_min,10)
clear para

load([loadpath 'BP' loadname '_2ResColor\BPLM_' loadname '_2ResColor.mat']);
[mse_BPLM_3channel_min_val, mse_BPLM_3channel_min_ind] = min(mse_BPLM_3channel,[],2);
vpa(mse_BPLM_3channel_min_val,10)
para_BPLM_3channel_min = para(:,mse_BPLM_3channel_min_ind)
vpa(para_BPLM_3channel_min,10)
[mse_BPLM_all_min_val, mse_BPLM_all_min_ind] = min(mse_BPLM_all,[],2);
vpa(mse_BPLM_all_min_val,10)
para_BPLM_all_min = para(:,mse_BPLM_all_min_ind)
vpa(para_BPLM_all_min,10)
clear para
