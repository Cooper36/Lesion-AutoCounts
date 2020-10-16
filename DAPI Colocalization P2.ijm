

//Choose Folders

dir1 = getDirectory("Choose Source Directory ");
dir2 = getDirectory("Choose Destination Directory ");

//print(dir1);
//print(dir2);
list = getFileList(dir1);

//setBatchMode(true); 
setBatchMode(false);

Dialog.create("Setting Parameters");
Dialog.addNumber("Number of channels", 4);
Dialog.addNumber("Channel for ROI Creation?:", 1);

Dialog.show();

num_channel= Dialog.getNumber();
Main_channel = Dialog.getNumber();


//////////////////////////////////////////////
//Manual Threshold values in order of channel
//threshold= newArray(2500, 2000 , 4000, 3000);
//threshold= newArray();
//DAPI:2500
//hNA: 2000
//SOX2:4000
//Olig2:3500

//////////////////////////////////////////////
run("ROI Manager...");
roiManager("reset");
run("Clear Results");
close("Log");
close("Summary");
close("*");
Run = 0 ; 
Table.create("Sum");
print("Sections to Check (High Bakground)");
for (i = 0 ; i < list.length; i++) {
	if (startsWith(list[i], "[CO_Lesion]")){
		image_name = list[i];
		file_name = dir1 + list[i];
		slide_name = substring(list[i], 12, lengthOf(list[i])-4);
		LROI_name = dir1 + "[LesionROI] " + slide_name + ".zip";
		
		open(file_name);

		//run("Subtract Background...", "rolling=50");
		//ROI Area, Perim, centroid for Summary
		roiManager("add");
		roiManager("deselect");
		run("Set Measurements...", "area perimeter stack display redirect=None decimal=3");
		roiManager("deselect");
		roiManager("deselect");
		roiManager("show all");
		roiManager("show none");
		run("Measure");
		roiManager("select", 0);
		run("Measure");
		selectWindow("Sum");
		Table.set("RB ID", Run, substring(list[i], indexOf(list[i], "RB")+2, indexOf(list[i], "RB")+4));
		Table.set("Ls", Run, substring(list[i], indexOf(list[i], "Ls")+2, indexOf(list[i], " Ls")+4));
		Table.set(" S", Run, substring(list[i], indexOf(list[i], " S")+2, indexOf(list[i], " S")+5));
		Table.set("Image Name", Run, slide_name);
		Table.set("Total Area (mm2)", Run, getResult("Area", 0)/1000000);
		Table.set("Lesion Area (mm2)", Run, getResult("Area", 1)/1000000);
		Table.set("Perim. (mm)", Run, getResult("Perim.", 1)/1000);
		run("Clear Results");
		
		roiManager("deselect");
		run("Set Measurements...", "centroid stack display redirect=None decimal=3");
		roiManager("select", 0);
		run("Set Scale...", "distance=0 known=0 unit=pixel");
		run("Measure");
		selectWindow("Sum");
		Table.set("X", Run, getResult("X", 0));
		Table.set("Y", Run, getResult("Y", 0));
		run("Clear Results");
		
		roiManager("deselect");
		roiManager("deselect");
		roiManager("show all");
		roiManager("show none");
		roiManager("show all");
		roiManager("show none");
		
		run("Duplicate...", "duplicate channels=&Main_channel");
		rename("Poop");
		run("Threshold...");
		call("ij.plugin.frame.ThresholdAdjuster.setMode", "Over/Under");
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
		setAutoThreshold("Default dark");
		//setAutoThreshold("Percentile dark");
		//setAutoThreshold("Minimum dark");
		//setAutoThreshold("Intermodes dark");
		//setAutoThreshold("MaxEntropy dark");
		////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		setOption("BlackBackground", true);
		//waitForUser;

		run("Convert to Mask");
		run("Convert to Mask");
		run("Make Binary");
		
		run("Erode");
		run("Dilate");
		close("Threshold");
		run("Watershed");
		run("Watershed");
		run("Analyze Particles...", "size=5-700 circularity=0-1.00 summarize add");
		run("16-bit");
		close("Poop");

		All_ROI_array= newArray();
		for (z=1;z<roiManager("count");z++){
			All_ROI_array = Array.concat(All_ROI_array,z); 
		}


		roiManager("select", All_ROI_array);
		roiManager("Set Color", "cyan");
				
		All_ROI_name = dir2 + "[ALL_ROIs]" + slide_name + ".zip";	
		roiManager("save selected",  All_ROI_name);
			
		run("Set Measurements...", "area centroid stack display redirect=None decimal=3");
		roiManager("select", All_ROI_array);
		roiManager("multi-measure append");	
		
		ALL_Total = roiManager("count")-1;
		Table.create("Shit");
		Area_Array = newArray();
		X_Array = newArray();
		Y_Array = newArray();
		InLes_Array = newArray();
		InLes_ROI_Array = newArray();
		OutLes_ROI_Array = newArray();
		roiManager("select", 0);
		for (t = 0; t < nResults; t++) {
			Area_Array = Array.concat(Area_Array, getResult("Area", t));
			X_Array = Array.concat(X_Array,getResult("X", t));
			Y_Array = Array.concat(Y_Array,getResult("Y", t));
			
			if (Roi.contains(getResult("X", t), getResult("Y", t))) {
				InLes_Array = Array.concat(InLes_Array, 1);
				InLes_ROI_Array = Array.concat(InLes_ROI_Array, t+1);
			}
			else {
				InLes_Array = Array.concat(InLes_Array, 0);
				OutLes_ROI_Array = Array.concat(OutLes_ROI_Array, t+1);
			}
		}
		selectWindow("Sum");
		DAPIDens_Out = OutLes_ROI_Array.length / Table.get("Total Area (mm2)", Run);
		DAPIDens_In = InLes_ROI_Array.length / Table.get("Lesion Area (mm2)", Run);
		Table.set("Normal DAPI Density", Run, DAPIDens_Out );
		Table.set("Lesion DAPI Density", Run, DAPIDens_In );
		roiManager("deselect");
		roiManager("deselect");
		
		roiManager("select", InLes_ROI_Array);
		
		InLes_ROI_name = dir2 + "[In Lesion ROIs]" + slide_name + ".zip";	
		roiManager("save selected", InLes_ROI_name);
		
		roiManager("deselect");
		roiManager("deselect");
		
		roiManager("select", OutLes_ROI_Array);
		OutLes_ROI_name = dir2 + "[Out Lesion ROIs]" + slide_name + ".zip";	
		roiManager("save selected", OutLes_ROI_name);

		roiManager("deselect");
		roiManager("deselect");		
		
		run("Clear Results");
		selectWindow("Shit");
		Table.setColumn("Area", Area_Array);
		Table.setColumn("X", X_Array);
		Table.setColumn("Y", Y_Array);
		Table.setColumn("In Lesion", InLes_Array);

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//Florecent intensity in DAPI ROI?
		roiManager("select", All_ROI_array);
		tf_name_array = newArray("DAPI Positive", "488 Positive", "594 Positive", "647 Positive");
		Mean_name_array = newArray("DAPI mean", "488 mean", "594 mean", "647 mean");
		Min_name_array = newArray("DAPI min", "488 min", "594 min", "647 min");
		Max_name_array = newArray("DAPI max", "488 max", "594 max", "647 max");
		RawIntDen_name_Array = newArray("DAPI RawIntDen", "488 RawIntDen", "594 RawIntDen", "647 RawIntDen");
		IntDen_name_Array = newArray("DAPI IntDen", "488 IntDen", "594 IntDen", "647 IntDen");
		Modal_name_Array = newArray("DAPI Mode", "488 mode", "594 mode", "647 mode");
		Total_name_Array = newArray("DAPI Total", "488 Total", "594 Total", "647 Total");
		InLes_name_Array = newArray("DAPI Lesion Total", "488 Lesion Total", "594 Lesion Total", "647 Lesion Total");
		Channel_name_Array = newArray("DAPI", "488" , "594" , "647");

		Q=0;
		threshold = newArray();
		
		
		Les_Raw_intensity = newArray();
		Les_Area = newArray();
	
		for (y=0; y < num_channel; y++) {
			Q= Q + 1;
			selectWindow(image_name);
			setSlice(Q);

			run("Set Measurements...", "area mean modal integrated centroid display redirect=None decimal=3");
			roiManager("select", 0);
			run("Measure");
			Les_Raw_intensity = Array.concat(Les_Raw_intensity, getResult("RawIntDen", 0));

			Les_Area = Array.concat(Les_Area, getResult("Area", 0));
			run("Clear Results");
			
			run("Set Measurements...", "area mean min modal centroid integrated display redirect=None decimal=3");
			roiManager("select", InLes_ROI_Array);
			roiManager("multi-measure append");
			
			ROI_Intensity_Sum = 0;
			ROI_Area_Sum = 0;
			for (w = 0; w < nResults; w++) {
				ROI_Intensity_Sum = ROI_Intensity_Sum + getResult("RawIntDen", w);
				ROI_Area_Sum = ROI_Area_Sum + getResult("Area", w);
			}

			ROI_mean = ROI_Intensity_Sum / ROI_Area_Sum ;
			background_Intensity = Les_Raw_intensity[y] - ROI_Intensity_Sum ; 
			background_Area = Les_Area[y] - ROI_Area_Sum ; 
			background_mean = background_Intensity / background_Area ;
			background_to_ROImean_ratio = background_mean / ROI_mean ; 
			Les_to_backgroundInt_ratio = Les_Raw_intensity[y] / background_Intensity; 
			buffer = background_mean * Les_to_backgroundInt_ratio/2 ; 
			threshold = Array.concat(threshold, background_mean + buffer);
			selectWindow("Sum");
			//Table.set(Total_name_Array[y], Run, posCountTot);
			if(Les_to_backgroundInt_ratio < 1.3){
				print(slide_name +" Ch"+ y);
				Table.set("High Bkg in " + Channel_name_Array[y] , Run, "Yes");
				
			}
			else {
				Table.set("High Bkg in " + Channel_name_Array[y] , Run, "No");
			}


			run("Clear Results");
			
			run("Set Measurements...", "area mean min modal centroid integrated display redirect=None decimal=3");
			roiManager("select", All_ROI_array);

			roiManager("multi-measure append");
		
			GroupROI_Array = newArray();
			Mean_Array = newArray();
			tf_Array = newArray();
			
			posCountTot = 0 ;
			posCountLesion = 0 ;
			
			selectWindow("Shit");
			roiManager("deselect");
			roiManager("select", 0);
			for (r = 0; r < nResults; r++) {
				Mean_Array = Array.concat(Mean_Array,getResult("Mean", r));
				
				if (getResult("Mean", r)>threshold[y]) {	
					posCountTot = posCountTot + 1;
					tf_Array = Array.concat(tf_Array,1);
					
					GroupROI_Array = Array.concat(GroupROI_Array, r+1 );
					
					if (Roi.contains(getResult("X", r), getResult("Y", r))) {
					//if (InLes_Array[r] == 1 ) {
						posCountLesion = posCountLesion +1;
						
					}

				}
				else {
					tf_Array = Array.concat(tf_Array,0);
					
				}

			}

		selectWindow("Shit");
			Table.setColumn(tf_name_array[y], tf_Array);
			Table.setColumn(Mean_name_array[y], Mean_Array);

			roiManager("deselect");
			roiManager("deselect");
			roiManager("select", GroupROI_Array);
			

			PositiveROIs = dir2 + "[" + Channel_name_Array[y] + "]" + slide_name  + ".zip" ;
			roiManager("save selected", PositiveROIs);
			
			run("Clear Results");
			
			selectWindow("Sum");
			//Table.set(Total_name_Array[y], Run, posCountTot);
			Table.set(InLes_name_Array[y], Run, posCountLesion);

			Table.set("Lesion " + Channel_name_Array[y] +  " Density", Run, posCountLesion / Table.get("Lesion Area (mm2)", Run));


			//Table.set("Threshold " + y+1 , Run, threshold[y]);
			//Table.set("bkg mean " + y+1 , Run, background_mean);
			//Table.set("les/bkg int " + y+1 , Run, Les_to_backgroundInt_ratio);
			selectWindow("Shit");
		}

		
		Lesion_raw_save = dir2 + "[Raw Data]" + slide_name + ".csv";
		Table.save(Lesion_raw_save);

		Ch647_488_count = 0 ;
		Ch647_594_count = 0 ;
		for (u = 0; u < Table.size; u++) {
				if (Table.get("In Lesion", u) == 1) {
	
				if (Table.get("647 Positive", u) == 1 && Table.get("488 Positive", u) == 1 ) {
					Ch647_488_count = Ch647_488_count + 1 ;
				}
				if (Table.get("647 Positive", u) == 1 && Table.get("594 Positive", u) == 1 ) {
					Ch647_594_count = Ch647_594_count + 1 ;
				}
			}
		}
		roiManager("reset");
		Table.reset("Shit");
		close("Shit");

		selectWindow("Sum");
		Table.set("488+647 Positive", Run, Ch647_488_count);
		Table.set("488+647 Density", Run, Ch647_488_count / Table.get("Lesion Area (mm2)", Run));
		Table.set("594+647 Positive", Run, Ch647_594_count);
		Table.set("594+647 Density", Run, Ch647_594_count / Table.get("Lesion Area (mm2)", Run));
		
		close("*");
		Run = Run + 1; 
		print(" ");
	}

}
selectWindow("Sum");
Lesion_Sum_save = dir2 + "Summary of Run.csv";
		Table.save(Lesion_Sum_save);
selectWindow("Log");
Log_save = dir2 + "Sections to Check.txt"
saveAs("Text", Log_save);
//close("*");
showMessage("Done");


