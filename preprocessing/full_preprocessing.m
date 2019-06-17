clear; close all

path_to_data = '/home/ammilten/Documents/Stanford/Second Project/Attenuation Model/Data/Vostok Radar Line/';

addpath('utils')

disp('Extracting Radar Data from NetCDF Files...')
run('extract_radar_data.m')

disp('Extracting Temperature Model Info from Radar Data...')
run('process_OIB_forTempModeling.m')

disp('Done.')
clear