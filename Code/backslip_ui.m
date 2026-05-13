%user interface to generate slip distribution for backslip method
%NOT WORKING PROPERLY! STILL IN DEVELOPMENT!
backslip_fig = uifigure("Name",'Backslip Options','Position',[500 500 800 800],'Resize','off');

max_slip = 1; %NEEDS UI ELEMENT TO ADJUST


%% set up plot
backslip_ax = uiaxes(backslip_fig,'Position',[50 200 440 250],'Color',[1 1 1],'Color',[.95 .95 .95]);
ylim(backslip_ax,[0 inf])

%% calculate generic triangular slip distribution
uilabel(backslip_fig,'Position',[50 130 180 20],'Text','Annual slip (mm):');
set_annualslip = uispinner(backslip_fig,'Position',[190 130 60 20],'Step',0.1,'Limits',[0 inf],'Value',1,...
    'Tooltip','Annual slip (mm) = slip rate (mm/a):',...
    'ValueChangedFcn', @(set_annualslip,event) slipdist_triangular(max_slip,x_points,backslip_ax));

slip_distribution = slipdist_triangular(max_slip,x_points,backslip_ax);
% imagesc(backslip_ax,slip_distribution)


%% plot configurations
c = colorbar(backslip_ax,'southoutside'); c.Label.String = 'slip (m)';
axis(backslip_ax,'equal')
xlabel(backslip_ax,'distance (km)')
T=[1,1,1; 1,1,0; 1,0,0]; A=[0;1;2]; % white, yellow, red % Colour map for slip distribution
colormap(backslip_ax,interp1(A,T,linspace(0,2,101)))

uiwait(backslip_fig)

%% OK button
btn_ok = uibutton(slip_fig,'Position',[260 20 50 30],'Text','OK','ButtonPushedFcn','uiresume(backslip_fig)');


%elements to add
% button to generate the standard 'triangular' slip distribution'
% button to generate empty slip dist AND
% uitable to add custom slip rate values along fault
% ok button to save data and close window
% 



%% Triangular slip distribution (for backslip)
% simple slip distribution to calculate interseismic stress loading using
% 'virtual negative displacements ('back-slip' method; Deng & Sykes, 1997)
function [slip_distribution, backslip_ax] = slipdist_triangular(max_slip,x_points,backslip_ax)
    slip_distribution=zeros(size(x_points) - [1 1]);
    slip_rate = max_slip/1000;
    half_len = linspace(0,slip_rate,round(size(slip_distribution,2)/2));
    comp_len = [half_len, flip(half_len)];
    if length(comp_len) > size(slip_distribution,2)
        comp_len(length(half_len)) = [];
    end
    for i = 1:size(slip_distribution,1)
        slip_distribution(i,:) = comp_len;
    end
    imagesc(backslip_ax,slip_distribution)
    disp('Something happening?')
end




