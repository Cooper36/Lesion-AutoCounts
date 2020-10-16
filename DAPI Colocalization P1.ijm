//Choose Folders
dir1 = getDirectory("Choose Source Directory ");
dir2 = getDirectory("Choose Destination Directory ");
list = getFileList(dir1);

//setBatchMode(true); 
setBatchMode(false);


//Open Tools
run("Channels Tool...");
run("Brightness/Contrast...");
run("ROI Manager...");
roiManager("reset");
run("Clear Results");

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
for (i=0; i < list.length; i++) {
//Assuming "RB" begins the name of the file 
	if (startsWith(list[i], "RB")){

	fileName = dir1 + list[i];
	ROIsave = dir2 + "[ROI] " + substring(list[i], 0, lengthOf(list[i])-4) + ".zip";
	CO_Lesion = dir2 + "[CO_Lesion] " + substring(list[i], 0, lengthOf(list[i])-4);
	
	//Open image
	run("Bio-Formats Importer", "open='fileName' color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
	//Flips
	selectWindow(getTitle);
	run("Flip Vertically");

	//B&C + ROI
	selectWindow(getTitle);
	run("Blue");
	run("Enhance Contrast", "saturated=0.35");
	run("Next Slice [>]");
	run("Green");
	run("Enhance Contrast", "saturated=0.35");
	run("Next Slice [>]");
	run("Cyan");
	run("Enhance Contrast", "saturated=0.35");
	run("Next Slice [>]");
	run("Red");
	run("Enhance Contrast", "saturated=0.35");

	setTool("polygon");
	waitForUser("Adjust B&C and Draw ROI");

	//Save ROI
	roiManager("Add");
	roiManager("select", roiManager("count")-1);
	roiManager("Rename", substring(list[i], 0, lengthOf(list[i])-4));
	roiManager("deselect");
	roiManager("save", ROIsave);

	roiManager("show all");
	roiManager("deselect");
	roiManager("show none");
	roiManager("select", roiManager("count")-1);
	run("Clear Outside");
	saveAs("tiff", CO_Lesion);
	close("*");
	roiManager("reset");
	} 
}
showMessage("Done");