%IMPORT:
import = questdlg('Choose the import format','Input format','shapefile','kml','kmz','shapefile');
switch import
    case 'shapefile'
        [file,path] = uigetfile('*.shp','Choose a .shp-file');
        fault_input = struct2table(shaperead(fullfile(path,file)));
        vars = {'fault_name','dip','rake','dip_dir','len'};  %variable names of the relevant fields
        t = fault_input(:,vars);
    case 'kml'
        [file,path] = uigetfile({'*.txt';'*.csv';'*.xlsx';'*.xls';'*.dat'},'Choose an input table');
        t = readtable(fullfile(path,file)); %t is the table plotted in UI, fault_input is the table containing the geometry etc.
        fault_input = t;
        fault_input.X = cell(length(t.fault_name),1);
        fault_input.Y = cell(length(t.fault_name),1);

        i = 1;                      %independent counter to keep the right number if lines are deleted
        for n = 1:length(t.fault_name)
            kml_file = strcat('Fault_traces/',t.fault_name{n},'.kml');
            if isfile(kml_file) == false
                msg = strcat('No kml file found for:',t.fault_name(n));
                warndlg(msg)
                t(n,:) = [];    %delete all rows from table where no kml file is given
            else
                fault_struct = kml2struct_multi(kml_file);
                [fault_input.X{i}, fault_input.Y{i}] = wgs2utm(fault_struct.Lon',fault_struct.Lat',utmzone,utmhemi);
                i = i+1;
            end
        end
    case 'kmz'
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
            [fault_input.X{k}, fault_input.Y{k}] = wgs2utm(kmz_table.Lon{k},kmz_table.Lat{k},utmzone,utmhemi);
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
        t = fault_input(:,{'fault_name','dip','rake','dip_dir','len'});
        end
end
t.slip_fault = false(1,length(t.fault_name))';
t.plot = true(1,length(t.fault_name))';

missing_dip = find(ismissing(t.dip));
missing_rake = find(ismissing(t.rake));
missing_dip_dir = find(ismissing(t.dip_dir));
missing_vals = [missing_dip; missing_rake; missing_dip_dir];
t.plot(missing_vals) = false;

%open main user interface:
fig = uifigure('Name','Fault Input','Position',[10 50 1346 668],'Color',[1 1 1]);

%bottom label:
lbl = uilabel(fig,'FontSize',13,'BackgroundColor',[1 1 1],'FontWeight','bold','HorizontalAlignment','left','VerticalAlignment','top');
lbl.Position = [10 10 700 30];
lbl.Text = sprintf(' 1 - Tick all faults to be plotted. Choose one slip fault (rupture plane).\n 2 - Press "Save Changes and Plot" to exit the dialog and build the 3D fault network.');

%table
uit = uitable(fig,'Data',t,'ColumnWidth',{240,80,80,80,80,70,68});
uit.Position = [10 50 700, 400];
uit.ColumnEditable = true;

[row,col] = find(ismissing(t));
s = uistyle('BackgroundColor','yellow');
addStyle(uit,s,'cell',[row,col]);

%initiate plot:
axe = uiaxes(fig,'Position',[720 50 400 400],'Color',[1 1 1],'Box','On');

%coordinates panel:
coord_pnl = uipanel(fig,'Title','Grid Limits (UTM coordinates)','Position',[1130 50 180 400],'BackgroundColor',[1 1 1],'FontWeight','bold');
minx_lbl = uilabel(coord_pnl,'Position',[10 350 130 20],'Text','min_x       _____    000');
maxx_lbl = uilabel(coord_pnl,'Position',[10 320 130 20],'Text','max_x       _____   000');
miny_lbl = uilabel(coord_pnl,'Position',[10 290 130 20],'Text','min_y       _____    000');
maxy_lbl = uilabel(coord_pnl,'Position',[10 260 130 20],'Text','max_y       _____   000');

minx_txt = uitextarea(coord_pnl,'Position',[60 350 50 20],'HorizontalAlignment','right','ValueChangedFcn','min_x = str2double(minx_txt.Value{1});');
maxx_txt = uitextarea(coord_pnl,'Position',[60 320 50 20],'HorizontalAlignment','right','ValueChangedFcn','max_x = str2double(maxx_txt.Value{1});');
miny_txt = uitextarea(coord_pnl,'Position',[60 290 50 20],'HorizontalAlignment','right','ValueChangedFcn','min_y = str2double(miny_txt.Value{1});');
maxy_txt = uitextarea(coord_pnl,'Position',[60 260 50 20],'HorizontalAlignment','right','ValueChangedFcn','max_y = str2double(maxy_txt.Value{1});');
autogrid(uit,fault_input,minx_txt, maxx_txt, miny_txt, maxy_txt);

%buttons on coordinate panel
coord_btn = uibutton(coord_pnl,'push',...
               'Text','Update Plot',...
               'Position',[10 220 80 20],...
               'BackgroundColor',[.1 .5 .8],...
               'ButtonPushedFcn',@(coord_btn,event) uiplot(axe,fault_input,uit,minx_txt,maxx_txt,miny_txt,maxy_txt));
auto_btn = uibutton(coord_pnl,'push',...
               'Text','Auto',...
               'Position',[95 220 80 20],...
               'BackgroundColor',[.1 .5 .8],...
               'ButtonPushedFcn',@(auto_btn,event) autogrid(uit,fault_input,minx_txt, maxx_txt, miny_txt, maxy_txt));     

%'Save and Plot' button
btn = uibutton(fig,'push',...
               'Text','Save Changes and Plot',...
               'Position',[860, 10, 150, 30],...
               'BackgroundColor',[.1 .5 .8],'FontWeight','bold',...
               'ButtonPushedFcn','model_3D_variable_faults');

set(uit, 'CellEditCallback', @(uit,event) uiplot(axe,fault_input,uit,minx_txt,maxx_txt,miny_txt,maxy_txt));
axe = uiplot(axe,fault_input,uit,minx_txt,maxx_txt,miny_txt,maxy_txt);

%calculate well-fitting grid extends (Auto button):
function [minx_txt, maxx_txt, miny_txt, maxy_txt] = autogrid(uit,fault_input,minx_txt, maxx_txt, miny_txt, maxy_txt)
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
    %set margins to width and height + 10% of size
    set(minx_txt,'Value', num2str(round((min(dim(:,1)) - 0.1 * width),-3)/1000));
    set(maxx_txt,'Value', num2str(round((max(dim(:,2)) + 0.1 * width),-3)/1000));
    set(miny_txt,'Value', num2str(round((min(dim(:,3)) - 0.1 * height),-3)/1000));
    set(maxy_txt,'Value', num2str(round((max(dim(:,4)) + 0.1 * height),-3)/1000));
end
%function that plots the map
function axe = uiplot(axe,fault_input,uit,minx_txt,maxx_txt,miny_txt,maxy_txt)
    min_x = str2double(minx_txt.Value{1});
    max_x = str2double(maxx_txt.Value{1});
    min_y = str2double(miny_txt.Value{1});
    max_y = str2double(maxy_txt.Value{1});
    cla(axe)
    hold(axe,'ON')
    rectangle(axe,'Position',[min_x min_y max_x-min_x max_y-min_y],'FaceColor',[.9 .99 .9])
    axis(axe, 'equal')
    title(axe, 'Overview Map of the Fault Network')
    xlabel(axe,'UTM_x')
    ylabel(axe,'UTM_y')
    for i = 1:length(fault_input.X)
        if uit.Data.plot(i) == true && uit.Data.slip_fault(i) == false
            plot(axe,cell2mat(fault_input.X(i))/1000,cell2mat(fault_input.Y(i))/1000,'k')
        elseif uit.Data.plot(i) == true && uit.Data.slip_fault(i) == true
            plot(axe,cell2mat(fault_input.X(i))/1000,cell2mat(fault_input.Y(i))/1000,'r','LineWidth',2)
        end
    end
end