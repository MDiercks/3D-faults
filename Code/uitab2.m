%this code is triggered by the import button
clearvars citation settings
set(tabgp,'SelectedTab',tab2);
set(imp_btn,'Enable','off')
vars;   %fetch variables from first uitab

%import faults:
if rb_shp.Value == true %shapefile
        [file,path] = uigetfile('*.shp','Choose a .shp-file');
        fault_input = struct2table(shaperead(fullfile(path,file)));
elseif rb_kml.Value == true %kml file
        [file,path] = uigetfile({'*.txt';'*.csv';'*.xlsx';'*.xls';'*.dat'},'Choose an input table');
        fault_input = readtable(fullfile(path,file));
        fault_input.X = cell(length(fault_input.fault_name),1);
        fault_input.Y = cell(length(fault_input.fault_name),1);
        i = 1;                      %independent counter to keep the right number if lines are deleted
        for n = 1:length(fault_input.fault_name)
            kml_file = strcat('Fault_traces/',fault_input.fault_name{n},'.kml');
            if isfile(kml_file) == false
                msg = strcat('No kml file found for:',fault_input.fault_name(n));
                warndlg(msg)
                fault_input(n,:) = [];    %delete all rows from table where no kml file is given
            else
                fault_struct = kml2struct_multi(kml_file);
                [fault_input.X{i}, fault_input.Y{i}] = wgs2utm(fault_struct.Lat',fault_struct.Lon',utmzone,utmhemi);
                i = i+1;
            end
        end
elseif rb_kmz.Value == true %kmz file
        [file,path] = uigetfile({'*.xlsx';'*.csv';'*.txt';'*.xls';'*.dat'},'Choose an input table');
        props = readtable(fullfile(path,file));
        [file,path] = uigetfile('*.kmz','Choose a .kmz file');
        kmlStruct = kmz2struct(fullfile(path,file));
        kmz_table = struct2table(kmlStruct);
        fault_input = kmz_table(:,{'Name','Lon','Lat'});
        fault_input.Properties.VariableNames = cell({'fault_name','X','Y'});
        fault_input.dip = NaN(length(fault_input.fault_name),1);
        fault_input.rake = NaN(length(fault_input.fault_name),1);
        fault_input.dip_dir = NaN(length(fault_input.fault_name),1);
        fault_input.len = NaN(length(fault_input.fault_name),1);
        for k = 1:length(kmz_table.Name)
            [fault_input.X{k}, fault_input.Y{k}] = wgs2utm(kmz_table.Lat{k},kmz_table.Lon{k},utmzone,utmhemi);
            row_idx = strcmp(fault_input.fault_name(k),props.fault_name);
            if any(row_idx) == true
                fault_input.dip(row_idx) = props.dip(row_idx);
                fault_input.rake(row_idx) = props.rake(row_idx);
                fault_input.dip_dir(row_idx) = props.dip_dir(row_idx);
                fault_input.len(row_idx) = props.len(row_idx);
            else
                msg = sprintf('Missing information for: %s',fault_input.fault_name{k});
                warndlg(msg)
            end
        end
end
figure(fig);
%check if variables in input files have correct names
vars = {'fault_name','dip','rake','dip_dir','len'};  %variable names of the relevant fields
for i = 1:length(vars)    
    while any(strcmp(vars{i},fault_input.Properties.VariableNames)) == false
        msg = sprintf('Enter the field name containing %s',vars{i});
        var1 = inputdlg(msg,'Var not found');
        if any(strcmp(var1,fault_input.Properties.VariableNames)) == true
            fault_input.Properties.VariableNames{var1} = vars{i};
        end
    end
end
%build the table t to be plotted in the uitable (other data remains stored in fault_input)
if isnumeric(fault_input.dip) == false
    fault_input.dip = str2double(fault_input.dip);
end
if isnumeric(fault_input.rake) == false
    fault_input.rake = str2double(fault_input.rake);
end
if isnumeric(fault_input.dip_dir) == false
    fault_input.dip_dir = str2double(fault_input.dip_dir);
end
if isnumeric(fault_input.len) == false
    fault_input.len = str2double(fault_input.len);
end
t = fault_input(:,vars);
t.depth = cell(1,length(t.fault_name))';
t.slip_fault = false(1,length(t.fault_name))';
t.plot = true(1,length(t.fault_name))';
[row,col] = find(ismissing([t.dip, t.rake, t.dip_dir]));
t.plot(row) = false;

%% configuration of ui tab 2
lbl = uilabel(tab2,'Position',[10 420 700 20],'FontSize',13,'BackgroundColor',[.98 .98 .98],'FontWeight','bold','HorizontalAlignment','left','VerticalAlignment','top');
lbltext = sprintf('Tick all faults to be plotted. Choose one slip fault (rupture plane).');
lbl.Text = lbltext;

%table
uit = uitable(tab2,'Data',t,'ColumnWidth',{215,60,60,60,60,60,67,45});
uit.Position = [10 10 650, 410];
uit.ColumnEditable = [false true true true true true true true];
s = uistyle('BackgroundColor','[.95 .5 .3]');
addStyle(uit,s,'row',row);

%initiate plot:
axe = uiaxes(tab2,'Position',[700 10 400 400],'Color',[1 1 1],'Box','On');

%coordinates panel:
coord_pnl = uipanel(tab2,'Title','Grid Limits (UTM coordinates)','Position',[1130 10 180 400],'BackgroundColor',[1 1 1],'FontWeight','bold');
uilabel(coord_pnl,'Position',[10 350 130 20],'Text','min_x       _____    000');
uilabel(coord_pnl,'Position',[10 320 130 20],'Text','max_x       _____   000');
uilabel(coord_pnl,'Position',[10 290 130 20],'Text','min_y       _____    000');
uilabel(coord_pnl,'Position',[10 260 130 20],'Text','max_y       _____   000');
uilabel(coord_pnl,'Position',[10 180 130 20],'Text','margin    _____     %');

minx_txt = uitextarea(coord_pnl,'Position',[60 350 50 20],'HorizontalAlignment','right','ValueChangedFcn','min_x = str2double(minx_txt.Value{1});');
maxx_txt = uitextarea(coord_pnl,'Position',[60 320 50 20],'HorizontalAlignment','right','ValueChangedFcn','max_x = str2double(maxx_txt.Value{1});');
miny_txt = uitextarea(coord_pnl,'Position',[60 290 50 20],'HorizontalAlignment','right','ValueChangedFcn','min_y = str2double(miny_txt.Value{1});');
maxy_txt = uitextarea(coord_pnl,'Position',[60 260 50 20],'HorizontalAlignment','right','ValueChangedFcn','max_y = str2double(maxy_txt.Value{1});');
margin_txt = uitextarea(coord_pnl,'Position',[60 180 50 20],'HorizontalAlignment','right','Value','10','ValueChangedFcn','mrg = str2double(margin_txt.Value{1})/100;');
autogrid(uit,fault_input,minx_txt, maxx_txt, miny_txt, maxy_txt, margin_txt);

%buttons on coordinate panel
coord_btn = uibutton(coord_pnl,'push',...
               'Text','Update Plot',...
               'Position',[10 220 80 20],...
               'BackgroundColor',[.3 .8 .8],...
               'ButtonPushedFcn',@(coord_btn,event) uiplot(axe,fault_input,uit,minx_txt,maxx_txt,miny_txt,maxy_txt));
auto_btn = uibutton(coord_pnl,'push',...
               'Text','Auto',...
               'Position',[95 220 80 20],...
               'BackgroundColor',[.3 .8 .8],...
               'ButtonPushedFcn',@(auto_btn,event) autogrid(uit,fault_input,minx_txt, maxx_txt, miny_txt, maxy_txt, margin_txt));

opt_pnl = uipanel(tab2,'Title','Data options','Position',[10 470 430 180],'BackgroundColor',[1 1 1],'FontWeight','bold');
%additional buttons
len_btn = uibutton(opt_pnl,'push',...
               'Text','calculate length',...
               'Position',[10, 100, 130, 20],...
               'BackgroundColor',[.3 .8 .8],'FontWeight','bold',...
               'ButtonPushedFcn', @(len_btn,event) calc_length(fault_input,uit));
exp_btn = uibutton(opt_pnl,'push',...
               'Text','Export table',...
               'Position',[10, 50, 130, 20],...
               'BackgroundColor',[.3 .8 .8],'FontWeight','bold',...
               'ButtonPushedFcn', @(exp_btn,event) table_export(uit));
           
vardip = uitable(fig,'Visible','off');  %this table is just for storing variable dip values but is not shown in ui
dip_btn = uibutton(opt_pnl,'push',...
               'Text','Import variable dip',...
               'Position',[10, 130, 130, 20],...
               'BackgroundColor',[.3 .8 .8],'FontWeight','bold',...
               'ButtonPushedFcn', @(dip_btn,event) variable_dip(uit,vardip,fig));

%Plot button
btn = uibutton(tab2,'push',...
               'Text','Build 3D faults',...
               'Position',[480, 500, 150, 120],...
               'BackgroundColor',[.3 .8 .8],'FontWeight','bold',...
               'ButtonPushedFcn','model_3D_faults',...
               'FontSize',18);
set(uit, 'CellEditCallback', @(uit,event) uiplot(axe,fault_input,uit,minx_txt,maxx_txt,miny_txt,maxy_txt));
axe = uiplot(axe,fault_input,uit,minx_txt,maxx_txt,miny_txt,maxy_txt);

%% ------------------ function space -------------------------
%calculate well-fitting grid extends (Auto button):
function [minx_txt,maxx_txt,miny_txt,maxy_txt] = autogrid(uit,fault_input,minx_txt,maxx_txt,miny_txt,maxy_txt,margin_txt)
    rows = find(uit.Data.plot);
    faults = uit.Data(rows,:);
    faults.X = fault_input.X(rows);
    faults.Y = fault_input.Y(rows);
    dim = zeros(length(faults.X),4);
    for i = 1:length(faults.X)
       dim(i,1)= min(faults.X{i});
       dim(i,2)= max(faults.X{i});
       dim(i,3)= min(faults.Y{i});
       dim(i,4)= max(faults.Y{i});
    end
    width = max(dim(:,2)) - min(dim(:,1));
    height = max(dim(:,4)) - min(dim(:,3));
    mrg = str2double(margin_txt.Value{1})/100;
    set(minx_txt,'Value', num2str(round((min(dim(:,1)) - mrg * width),-3)/1000));
    set(maxx_txt,'Value', num2str(round((max(dim(:,2)) + mrg * width),-3)/1000));
    set(miny_txt,'Value', num2str(round((min(dim(:,3)) - mrg * height),-3)/1000));
    set(maxy_txt,'Value', num2str(round((max(dim(:,4)) + mrg * height),-3)/1000));
end
%function that plots the map
function axe = uiplot(axe,fault_input,uit,minx_txt,maxx_txt,miny_txt,maxy_txt)
    min_x = str2double(minx_txt.Value{1});
    max_x = str2double(maxx_txt.Value{1});
    min_y = str2double(miny_txt.Value{1});
    max_y = str2double(maxy_txt.Value{1});
    cla(axe)
    hold(axe,'ON')
    rectangle(axe,'Position',[min_x min_y max_x-min_x max_y-min_y],'FaceColor',[.85 .95 .7])
    axis(axe, 'equal')
    title(axe, 'Overview Map of the Fault Network')
    xlabel(axe,'UTM x')
    ylabel(axe,'UTM y')
    for i = 1:length(fault_input.X)
        if uit.Data.plot(i) == true && uit.Data.slip_fault(i) == false
            plot(axe,cell2mat(fault_input.X(i))/1000,cell2mat(fault_input.Y(i))/1000,'k')
        elseif uit.Data.plot(i) == true && uit.Data.slip_fault(i) == true
            plot(axe,cell2mat(fault_input.X(i))/1000,cell2mat(fault_input.Y(i))/1000,'r','LineWidth',2)
        end
    end
end
%function to calculate fault length from X and Y data
function uit = calc_length(fault_input,uit)
    f = waitbar(0,'Please wait for the calculation of fault lengths...');
    uit.Data.len = zeros(length(uit.Data.len),1);
    for i = 1:length(fault_input.X)
        fault_input.X{i}(ismissing(fault_input.X{i})) = [];
        fault_input.Y{i}(ismissing(fault_input.Y{i})) = [];
        for j = 1:length(fault_input.X{i})-1
            dist = sqrt((fault_input.X{i}(j)-fault_input.X{i}(j+1))^2 + (fault_input.Y{i}(j)-fault_input.Y{i}(j+1))^2)/1000;
            uit.Data.len(i) = uit.Data.len(i) + dist;
        end
        waitbar(i/length(fault_input.X));
    end
    uit.Data.len = round(uit.Data.len);
    close(f)
end
%function for table export to .csv
function table_export(uit)
    output_file = inputdlg('Output file name:');
    file = strcat('Output_files/',output_file{1},'.csv');
    writetable(uit.Data,file)
    msg = sprintf('Table stored to %s',file);
    msgbox(msg)
end
%function to fetch variable dip data from table
function [uit,vardip] = variable_dip(uit,vardip,fig)
    [file,path] = uigetfile('*.xlsx','Variable Dip Data');
    figure(fig);
    dip_imp = readtable(fullfile(path,file));
    dipdata = table(cell(height(dip_imp),1),cell(height(dip_imp),1),cell(height(dip_imp),1));
    dipdata.Properties.VariableNames = {'fault_name','depth','dip'};
    depth_dip = table2array(dip_imp(:,2:21));
    s = uistyle('BackgroundColor',[.3 .8 .8]);
    uit.Data.dip = num2cell(uit.Data.dip);
    for i = 1:length(dip_imp.fault_name)
        idx = find(strcmp(uit.Data.fault_name,dip_imp.fault_name(i)));
        if any(idx) == true
            dipdata.fault_name{i} = uit.Data.fault_name{idx};
            dipdata.depth{i} = depth_dip(i,[1 3 5 7 9]);
            dipdata.dip{i} = depth_dip(i,[2 4 6 8 10]);
            addStyle(uit,s,'row',idx);
            uit.Data.dip{idx} = 'var. dip';
        else
            dipdata(end,:) = []; %delete row for each not matching fault to get the right table length
        end
    end
    set(vardip,'Data',dipdata);
    disp('Variable dip information imported.')
end