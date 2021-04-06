function [helpbox1,helpbox2,help_general,help_utm,help_max_slip,help_slipdist,help_imp,help_vardip,help_calclen,help_table,help_grid_size,help_config,help_coords] = uihelp(tab1,tab2,p1,p2,p3,p4,p5,opt_pnl,coord_pnl)
%this script only contains functions for the ? - buttons on the ui
%set up helpbox:
text = sprintf('\n\t\t\t\t\t\t3D - Faults v 1.6');

helpbox1 = uitextarea(tab1,'Position',[855 385 485 270],'Value',text,'Editable','off');
helpbox2 = uitextarea(tab2,'Position',[920 470 420 180],'Value',text,'Editable','off');

% '?' - buttons tab 1:
help_general = uibutton(p1,'push','Text','?','Position',[730,20,20,20],'BackgroundColor',[.6 .6 .6],'FontWeight','bold','FontSize',12,'ButtonPushedFcn',@(help_general,event) uihelp_general(helpbox1));
help_imp = uibutton(p5,'push','Text','?','Position',[255,20,40,40],'BackgroundColor',[.6 .6 .6],'FontWeight','bold','FontSize',14,'ButtonPushedFcn',@(help_imp,event) uihelp_imp(helpbox1));
help_utm = uibutton(p4,'push','Text','?','Position',[270,20,20,20],'BackgroundColor',[.6 .6 .6],'FontWeight','bold','FontSize',14,'ButtonPushedFcn',@(help_utm,event) uihelp_utm(helpbox1));

% ? - buttons tab2:
help_vardip = uibutton(opt_pnl,'push','Text','?','Position',[150,130,20,20],'BackgroundColor',[.6 .6 .6],'FontWeight','bold','FontSize',12,'ButtonPushedFcn',@(help_vardip,event) uihelp_vardip(helpbox2));
help_calclen = uibutton(opt_pnl,'push','Text','?','Position',[150,100,20,20],'BackgroundColor',[.6 .6 .6],'FontWeight','bold','FontSize',12,'ButtonPushedFcn',@(help_calclen,event) uihelp_calclen(helpbox2));
help_table = uibutton(opt_pnl,'push','Text','?','Position',[150,20,20,20],'BackgroundColor',[.6 .6 .6],'FontWeight','bold','FontSize',12,'ButtonPushedFcn',@(help_table,event) uihelp_table(helpbox2));
help_slipdist = uibutton(p2,'push','Text','?','Position',[240,10,20,20],'BackgroundColor',[.6 .6 .6],'FontWeight','bold','FontSize',12,'ButtonPushedFcn',@(help_slipdist,event) uihelp_slipdist(helpbox2));
help_max_slip = uibutton(p3,'push','Text','?','Position',[200,10,20,20],'BackgroundColor',[.6 .6 .6],'FontWeight','bold','FontSize',12,'ButtonPushedFcn',@(help_max_slip,event) uihelp_max_slip(helpbox2));
help_grid_size = uibutton(tab2,'push','Text','?','Position',[880,600,20,20],'BackgroundColor',[.6 .6 .6],'FontWeight','bold','FontSize',12,'ButtonPushedFcn',@(help_grid_size,event) uihelp_grid_size(helpbox2));
help_config = uibutton(tab2,'push','Text','?','Position',[880,480,20,20],'BackgroundColor',[.6 .6 .6],'FontWeight','bold','FontSize',12,'ButtonPushedFcn',@(help_config,event) uihelp_config(helpbox2));
help_coords = uibutton(coord_pnl,'push','Text','?','Position',[160,20,20,20],'BackgroundColor',[.6 .6 .6],'FontWeight','bold','FontSize',12,'ButtonPushedFcn',@(help_coords,event) uihelp_coords(helpbox2));


%% functions
function helpbox1 = uihelp_general(helpbox1)
    helptext = sprintf('Output file name: Name for the output file that will be created\n');
    set(helpbox1,'Value',helptext);
end
function helpbox1 = uihelp_utm(helpbox1)
    helptext = sprintf(strcat(('UTM coordinates:\n\n'),...
        ('If faults are imported from kml or kmz files, coordinates are converted to UTM. \n'),...
        ('Therefore please specify the utm zone and hemisphere before the import.\n')));
    set(helpbox1,'Value',helptext);
end
function helpbox1 = uihelp_imp(helpbox1)
    helptext = sprintf(strcat(('FAULT INPUT FORMATS: \n\n'),...
        (' .shp - ESRI shapefile: Import a shapefile that contains fault traces and properties (as attributes). Shapefile must be projected in UTM coordinates.\n\n'),...
        (' .kml-files: Choose a table (e.g. .txt, .csv, .xlsx) that contains all fault properties. '),...
        ('  kml files of all faults must be stored in the Faults_3D/Fault_traces folder.\n\n'),...
        (' .kmz-file: First choose a table containing the fault properties and then choose a kmz-file containing the fault traces.\n\n'),...
        ('  Make sure that the input files are formatted appropriately! Necessary fault properties are dip, dip direction, rake and length.'),...
        ('  Fields may be empty if data is missing. See README and input examples.')));
    set(helpbox1,'Value',helptext);
end
%tab 2:
function helpbox2 = uihelp_vardip(helpbox2)
    helptext = sprintf(strcat(('FAULTS WITH VARIABLE DIP \n\n'),...
        ('To model variable dip faults, dip/depth profiles must be imported. Variable dip profiles for all faults are stored in a single table.\n'),...
        ('Make sure that the table is formatted in the same way as the given example (variable_dip_example.xlsx).\n'),...
        ('For each fault up to 10 dip/depth pairs can be specified. Faults in the table are recognised by their names, so make sure that these are spelled correctly.')));
    set(helpbox2,'Value',helptext);
end
function helpbox2 = uihelp_calclen(helpbox2)
    helptext = sprintf(strcat(('Calculate length from input fault trace.')));
    set(helpbox2,'Value',helptext);
end
function helpbox2 = uihelp_table(helpbox2)
    helptext = sprintf(strcat(('Save the table below to a .txt file. The file will be stored in the "Output_files" folder.')));
    set(helpbox2,'Value',helptext);
end
function helpbox2 = uihelp_slipdist(helpbox2)
    helptext = sprintf(strcat(('INFORMATION TO BUILD THE SLIP DISTRIBUTION \n\n'),...
        ('Slip at surface: What percentage of the maximum slip at depth occurs at the surface.\n'),...
        ('Maximum slip (m): Defines the maximum slip at the center of the bulls eye slip distribution\n\n'),...
        ('Seismogenic depth (km): Depth of the seismogenic zone in kilometres\n'),...
        ('Rupture depth (km): 0 = default - the fault ruptures the whole seismogenic zone. Change to down-dip extent (in km).')));
    set(helpbox2,'Value',helptext);
end
function helpbox2 = uihelp_max_slip(helpbox2)
    helptext = sprintf(strcat(('SETTING THE LOCATION OF MAXIMUM SLIP\n\n'),...
        ('Default setting is to have the location of maximum slip in the centre of the fault'),...
        (' to generate a symmetric concentric slip distribution.\n\n'),...
        ('Horizontal centre: Change to distance (in km) to control the location of'),...
        (' maximum slip along the fault. This must be less than length of the fault that ruptures.\n'),...
        ('Vertical centre: Change to depth (in km) from the surface to control the location of'),...
        (' maximum slip down-dip of the fault. This must be less than the rupture depth.')));
    set(helpbox2,'Value',helptext);
end
function helpbox2 = uihelp_grid_size(helpbox2)
    helptext = sprintf('Grid size (km): The size of the rectangular elements along strike in kilometers.\n');
    set(helpbox2,'Value',helptext);
end
function helpbox2 = uihelp_config(helpbox2)
    helptext = sprintf(strcat(('Custom configuration:\n\n'),...
        ('Export the current settings as custom configuration by pressing "Export custom config."\n'),...
        ('The custom configuration can be loaded by clicking "Load custom config." even after the program was closed.')));
    set(helpbox2,'Value',helptext);
end
function helpbox2 = uihelp_coords(helpbox2)
    helptext = sprintf(strcat(('Grid limits\n\n'),...
        ('Define the map extent of the output:\n'),...
        ('The "Auto" button automatically calculates grid extends that fit the given faults with the defined margin (default 10 percent).'),...
        ('After changing the extent or using the "Auto" button, press "Update plot" to re-plot the map and save the changes.')));
    set(helpbox2,'Value',helptext);
end
end