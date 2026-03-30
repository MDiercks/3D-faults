% function triggerred when slip options change
% update the UI elements of the slip_options window (slip_options_panel.m)
% function input_check = slip_opts_update(sl_centre_hor,sp_end,sp_start,l_lbl,txt_hor,sp_rupt_top,sp_centre_ver,sp_rupt_bot,warn_lbl,set_surfSlip,btn_ok) 
function input_check = slip_opts_update(sl_centre_hor,sp_end,sp_start,l_lbl,txt_hor,sp_rupt_top,sp_centre_ver,sp_rupt_bot,warn_lbl,surfSlip_lbl,set_surfSlip,maxSlip_lbl,btn_ok,mw_lbl,btn_mw,sliptype_dd)
l_lbl.Text = strcat('Rupture length: ',num2str(round(sp_end.Value-sp_start.Value)),' km');
txt_hor.Value = num2str(round(sl_centre_hor.Value));
if sp_rupt_top.Value ~= 0
    set(set_surfSlip,'Enable','off');
else
    set(set_surfSlip,'Enable','on');
end

%% check if inputs are valid:
if sp_centre_ver.Value >= sp_rupt_bot.Value || sp_centre_ver.Value <= sp_rupt_top.Value
    warn_lbl.Text = 'Vertical centre must be between rupture top and rupture bottom!';
    set(btn_ok,'Enable','off');
    input_check = false;
elseif sp_start.Value >= round(sl_centre_hor.Value) || sp_end.Value <= round(sl_centre_hor.Value)
    warn_lbl.Text = 'Horizontal centre must be between start and end of rupture!';
    set(btn_ok,'Enable','off');
    input_check = false;
else
    warn_lbl.Text = ' ';
    set(btn_ok,'Enable','on');
    input_check = true;
end

%% modify UI if interseismic (backslip) is selected
if sliptype_dd.Value(1) == 'T'
    set(surfSlip_lbl, 'Visible', 'off');
    set(set_surfSlip, 'Visible', 'off');
    set(maxSlip_lbl, 'Text', 'Maximum slip (mm):');
    set(mw_lbl, 'Visible', 'off')
    set(btn_mw, 'Visible', 'off')
else
    set(surfSlip_lbl, 'Visible', 'on');
    set(set_surfSlip, 'Visible', 'on');
    set(maxSlip_lbl, 'Text', 'Maximum slip (m):');
    set(mw_lbl, 'Visible', 'on')
    set(btn_mw, 'Visible', 'on')
end