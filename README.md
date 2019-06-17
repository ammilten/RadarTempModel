Try running the `trace_test.m` and `vostok_test.m` scripts first to verify that everything is working.

To run `ThawModel_On_Line.m` first open the file `preprocessing/full_preprocessing.m` and change the `path_to_data` variable to the path where the `DomeC-Vostok-2013` and `CSVData` folders are. Then run the `preprocessing/full_preprocessing.m` script and you should see files `radargrams.mat`, `TempModelData.mat`, and `FullProcessedData.mat` appear. Once these .mat files exist then you can run `ThawModel_On_Line.m`.
