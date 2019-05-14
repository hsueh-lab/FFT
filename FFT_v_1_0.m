(* ::Package:: *)

(* ::Input::Initialization:: *)

(*Initial parameters value*)
Dir=NotebookDirectory[];
FFTfunctions={"Spore/Conidia counting", "Spore morphology", "Trap counting", "Mycelium characterization"};
Selectedfunction=1;
font1=18;
imagesize=500;
resimagequality=100;
ParametersInitialization[Selectedfunction_,auxim_]:=
Which[Selectedfunction==1,
{b1=FindThreshold[ColorNegate@auxim,Method->"Entropy"]*1.3;
b2=b1;
gaussian=20;
elongation=0.7;
minArea=20;
maxArea=300},
Selectedfunction==2,
{b1=FindThreshold[auxim,Method->"Entropy"]*1.5;
b2=b1;
gaussian=20;
elongation=0.5;
minArea=1500;
maxArea=50000},

Selectedfunction==3,
{(*b1=FindThreshold[auxim,Method\[Rule]"Entropy"]*0.8;
b2=FindThreshold[auxim,Method\[Rule]"Entropy"]*1.2;*)
gaussian=20;
b1=FindThreshold[ColorNegate@auxim,Method->"Entropy"];
b2=b1;
elongation=0.7;
minArea=15;
maxArea=100},
Selectedfunction==4,
{gaussian=40;
b1=FindThreshold[ImageSubtract[ColorNegate@auxim,ColorNegate@GaussianFilter[auxim,gaussian]],Method->"Entropy"];
b2=b1*1.5;
b1=FindThreshold[auxim,Method->"Entropy"]*0.8;
b2=FindThreshold[auxim,Method->"Entropy"];
minArea=10}];

(*Mycelium characterization related functions*)

Myceliumaux1[auxim_,b1_,b2_,gaussian_,minHypha_,imagesize_,cal_,mask_]:=Module[{aux},
aux=If[UseMask,
Pruning[ImageSubtract[DeleteSmallComponents[Thinning[MorphologicalTransform[MorphologicalBinarize[ImageSubtract[auxim,GaussianFilter[auxim,gaussian]],{b1,b2}],"Max"]],minHypha],Dilation[Import[mask],gaussian]],minHypha],Pruning[DeleteSmallComponents[Thinning[MorphologicalTransform[MorphologicalBinarize[ImageSubtract[auxim,GaussianFilter[auxim,gaussian]],{b1,b2}],"Max"]],minHypha],minHypha]];If[cal,HighlightImage[auxim,aux,ImageSize->imagesize],aux]];

Mycelium[auxim_,b1_,b2_,gaussian_,minHypha_,imagesize_,mask_]:=Module[{coords,BWImage,graph,tips,edges,edgeslength,area,graphaux},
BWImage=Myceliumaux1[auxim,b1,b2,gaussian,minHypha,imagesize,False,mask];
graphaux=MorphologicalGraph[BWImage];
graph=EdgeDelete[graphaux,EdgeList[graphaux,x_<->x_]];
Clear[BWImage];
Clear[graphaux];
coords=GraphEmbedding[graph];
tips=coords[[Flatten[Position[VertexDegree[graph],1]]]];
edges=Table[coords[[List@@e]],{e,EdgeList[IndexGraph[graph]]}];
edgeslength=EuclideanDistance@@@edges;
area=ConvexHullMesh[coords];
{HighlightImage[auxim,{Graphics[{Yellow,PointSize[0.0025],Point[tips]}],{Opacity[0.15],Blue,ConvexHullMesh[coords]},Show[Graph[IndexGraph[graph],GraphStyle->"BasicGreen",EdgeStyle->{Thickness[0.0005],Green}]]}],
{Length[tips],Total[edgeslength],Area[ConvexHullMesh[coords]]}}];

(*Trap Tracker*)

TrapTracker[auxim_,b1_,b2_,elongation_,minTrap_,maxTrap_,gaussian_,imagesize_]:=Module[{list,num,coords},
list=SelectComponents[MorphologicalBinarize[ColorNegate@auxim,{b1,b2}],maxTrap>#Width>minTrap&&#Elongation<elongation&];
coords=ComponentMeasurements[list,"Centroid"];
Clear[list];
{Labeled[HighlightImage[auxim,{Opacity[0.3,Blue],Graphics[Point/@coords[[All,2]]]},ImageSize->imagesize],Style[" Traps = "<>ToString[Length[coords]]<>" ", Bold, font1],Top],Length[coords]}];

(*Spore Counting*)
Spores[auxim_,b1_,b2_,elongation_,minArea_,maxArea_,imagesize_]:=Module[{list,num,coords},
list=DeleteSmallComponents[SelectComponents[MorphologicalBinarize[ColorNegate@auxim,{b1,b2}],#Elongation<elongation&&#Area<maxArea&],minArea];
coords=ComponentMeasurements[list,"Centroid",#Elongation<elongation&];
Clear[list];
{Labeled[HighlightImage[auxim,{Blue,Graphics[Point/@coords[[All,2]]]},ImageSize->imagesize],Style[" Conidia/Spores = "<>ToString[Length[coords]]<>" ", Bold, font1],Top],Length[coords]}];

(* Spore Morphology*)

SporeMorphologyaux1[centre_,semiaxis_,orientation_]:=Rotate[{Opacity[0.7],Thick,Darker[Blue],Line[{centre-{0,semiaxis[[2]]},centre+{0,semiaxis[[2]]}}],Blue,Line[{centre-{semiaxis[[1]],0},centre+{semiaxis[[1]],0}}]},orientation];

SporeMorphology[auxim_,b1_,b2_,elongation_,minArea_,maxArea_,imagesize_]:=Module[{image,data,aux1,aux2},
aux1=SelectComponents[DeleteBorderComponents[MorphologicalBinarize[auxim,{b1,b2}]], #Area<maxArea&&#Area>minArea&&#Elongation<elongation&];
aux2=ComponentMeasurements[aux1,{"Centroid","SemiAxes","Orientation","Area","Length","Width","FilledCircularity"}];
image=If[aux2!={},Show[HighlightImage[auxim,{Opacity[0.3],Darker[Blue],aux1}],Graphics[Table[{Text[Style[" A = "<>ToString[aux2[[j,2,4]]]<>"\n L = "<>ToString[aux2[[j,2,5]]]<>"\n W = "<>ToString[aux2[[j,2,6]]]<>"\n C = "<>ToString[aux2[[j,2,7]]],Bold,Darker[Blue],12,TextAlignment->Left],aux2[[j,2,1]]+{150,150}],SporeMorphologyaux1[aux2[[j,2,1]],aux2[[j,2,2]],aux2[[j,2,3]]]},{j,1,Length[aux2]}]],ImageSize->imagesize],Show[HighlightImage[auxim,{Opacity[0.3],Darker[Blue],aux1}],ImageSize->imagesize]];
Clear[aux1];
data=If[aux2!={},Table[Flatten[{aux2[[j,1]],aux2[[j,2,4;;7]]}],{j,1,Length[aux2]}],ConstantArray["NA",5]];
{image,data}];

(*Calibration tab related functions*)

ZoomCalibration[auxim_]:=Module[{imageSize},
imageSize=ImageDimensions[auxim];
ImageCrop[auxim,imageSize/3]];

Calibration[auxim_,b1_,b2_,elongation_,minArea_,maxArea_,gaussian_,ZoomImage_,Selectedfunction_,imagesize_]:=Which[Selectedfunction==1,Spores[If[ZoomImage,ZoomCalibration[auxim],auxim],b1,b2,elongation,minArea,maxArea,imagesize][[1]],
Selectedfunction==2,SporeMorphology[If[ZoomImage,ZoomCalibration[auxim],auxim],b1,b2,elongation,minArea,maxArea,imagesize][[1]],
Selectedfunction==3,
TrapTracker[If[ZoomImage,ZoomCalibration[auxim],auxim],b1,b2,elongation,minArea,maxArea,gaussian,imagesize][[1]],
Selectedfunction==4,Myceliumaux1[If[ZoomImage,ZoomCalibration[auxim],auxim],b1,b2,gaussian,minArea,imagesize,True,Mask]];

Calibration2[auxim_,b1_,b2_,elongation_,minArea_,maxArea_,gaussian_, ZoomImage_,Selectedfunction_,imagesize_]:=Module[{aux},
ShowImage=Overlay[{If[ZoomImage,ZoomCalibration[auxim],auxim],ProgressIndicator[Appearance->"Percolate",ImageSize->200]},Alignment->Center,ImageSize->imagesize];
Which[Selectedfunction==1,aux=Spores[If[ZoomImage,ZoomCalibration[auxim],auxim],b1,b2,elongation,minArea,maxArea,imagesize][[1]],
Selectedfunction==2,aux=SporeMorphology[If[ZoomImage,ZoomCalibration[auxim],auxim],b1,b2,elongation,minArea,maxArea,imagesize][[1]],
Selectedfunction==3,
aux=TrapTracker[If[ZoomImage,ZoomCalibration[auxim],auxim],b1,b2,elongation,minArea,maxArea,gaussian,imagesize][[1]],
Selectedfunction==4,aux=Myceliumaux1[If[ZoomImage,ZoomCalibration[auxim],auxim],b1,b2,gaussian,minArea,imagesize,True,Mask]];
ShowImage=aux];

(*Validation tab related functions*)
ValidationDialog[b1_,b2_,elongation_,minArea_,maxArea_,gaussian_, ZoomImage_,Selectedfunction_,imagesize_]:=
Module[{verificationImages,tab},
verificationImages=RandomSample[FileNames[],Min[length,3]];
tab=Table[Labeled[Show[Calibration[Import[verificationImages[[i]]],b1,b2,elongation,minArea,maxArea,gaussian,ZoomImage,Selectedfunction,imagesize],ImageSize->400],verificationImages[[i]]],{i,1,Min[length,3]}];
CreateDialog[
Column[{Style["Do you want to use these parameters for all the images?",Bold],
Grid[{tab}],
ChoiceButtons[{DialogReturn[fix=True],
DialogReturn[fix=False]}]},
Spacings->1],
WindowTitle->"Validation",Modal->False,WindowSize->Fit]];

CreateFinalTab[Selectedfunction_,Finalfile_]:=Module[{FinalTabTitle,FinalTab},
FinalTabTitle={{"File name","Number of spores/conidia"},{"File name","Spore/Conidia number", "Area","Length","Width","Circularity"},{"File name","Number of traps","Mean trap area","Normalized trap number"},{"File name","Number of tips","Total length","Area covered"}};
FinalTab={FinalTabTitle[[Selectedfunction]]};
Which[Selectedfunction==1||Selectedfunction==3||Selectedfunction==4,Do[AppendTo[FinalTab,Flatten[Finalfile[[i]]]],{i,1,Length[Finalfile]}],
Selectedfunction==2,Do[If[Length[Finalfile[[i,2]]]==1,
AppendTo[FinalTab,Flatten[Finalfile[[i]]]],
Do[AppendTo[FinalTab,Flatten[{Finalfile[[i,1]],Finalfile[[i,2,j]]}]],{j,1,Length[Finalfile[[i,2]]]}]],{i,1,Length[Finalfile]}]];
FinalTab];
(*Execution related functions*)

FinalExecution[Name_,FinalDir_,b1_,b2_,elongation_,minArea_,maxArea_,gaussian_, Selectedfunction_]:=Module[{im,aux,Finalfile=ConstantArray[0,length]},
Do[If[FileNames[][[i]]!=".DS_Store",{
im=Import[FileNames[][[i]]];
If[AutomaticParams,ParametersInitialization[Selectedfunction,im]];
Which[Selectedfunction==1,
aux=Spores[im,b1,b2,elongation,minArea,maxArea,Full],Selectedfunction==2,aux=SporeMorphology[im,b1,b2,elongation,minArea,maxArea,Full],
Selectedfunction==3,aux=TrapTracker2[im,b1,b2,elongation,minArea,maxArea,gaussian,Full],Selectedfunction==4,aux=Mycelium[im,b1,b2,gaussian,minArea,imagesize,Mask]];
Clear[im];
Finalfile[[i]]={FileNames[][[i]],aux[[2]]};
Export[FinalDir<>"/R_"<>FileNames[][[i]],aux[[1]],ImageResolution->resimagequality];
Clear[aux]}],{i,1,length}];
Export[FinalDir<>"/"<>"Execution_params_"<>DateString["ISODateTime"]<>".txt",{"b1= "<>ToString[b1],"b2= "<>ToString[b2],"Elongation= "<>ToString[elongation],"MinArea= "<>ToString[minArea],"MaxArea= "<>ToString[maxArea],"Gaussian filter= "<>ToString[gaussian]}];
Export[FinalDir<>"/"<>Name,CreateFinalTab[Selectedfunction,Finalfile]];
i=length+1]

(*FFT INTERFACE*)

CreateDialog[Column[
(*Input options*)
SaveInputConf=False;
Mask="";
OpenInput=True;
OpenCalibration=False;
UseMask=False;
OpenOutput=False;
{OpenerView[{Style["Input options",font1],DynamicModule[{},
Grid[{{"Select the Folder containing the images:",InputField[Dynamic[Dir],String,Enabled->Dynamic[!SaveInputConf,TrueQ]],FileNameSetter[Dynamic[Dir],"Directory",Enabled->Dynamic[!SaveInputConf,TrueQ]]},
{"Select a function:"PopupView[FFTfunctions,Dynamic[Selectedfunction],Enabled->Dynamic[!SaveInputConf,TrueQ]]},
{Row[{Checkbox[Dynamic[UseMask]],"  Select mask: ",InputField[Dynamic[FileNameTake[Mask]],String,Enabled->False],FileNameSetter[Dynamic[Mask],Enabled->Dynamic[UseMask,TrueQ]]}]},
{Button["Edit",SaveInputConf=False,Enabled->Dynamic[SaveInputConf,TrueQ]],Button["Save",SaveInputConf=True;
SetDirectory[Dir];
If[FileExistsQ[".DS_Store"],DeleteFile[".DS_Store"]];
length=Length[FileNames[]];
ParametersInitialization[Selectedfunction,Import[FileNames[][[1]]]];
FinalDir=ParentDirectory[Dir]<>"/Results";
OpenInput=False;
OpenCalibration=True;
CalImageName=FileNames[][[1]],Appearance->If[Dynamic[SaveInputConf,TrueQ],"Pressed",Automatic]]}},Spacings->{1,Automatic},Alignment->Left],LocalizeVariables->False,SaveDefinitions->True]},Dynamic[OpenInput]],

(*Calibration*)
fix=False;
AutomaticParams=False;
SaveCalibrationConf=False;
ZoomImage=True;

CalImageName=FileNames[][[1]];
OpenerView[{Style["Calibration",font1],Manipulate[If[SaveInputConf,Calibration2[Import[CalImageName],b1,b2,elongation,minArea,maxArea,gaussian,ZoomImage,Selectedfunction,400];
Labeled[Dynamic[ShowImage],Dynamic[FileNameTake[CalImageName]]]],
Column[{"Select image for Calibration",InputField[Dynamic[FileNameTake[CalImageName]],String,Enabled->False],FileNameSetter[Dynamic[CalImageName],Enabled->Dynamic[SaveInputConf,TrueQ]]}],
Control[{{ZoomImage,False,"Zoom"},{True,False},Checkbox,Enabled->!SaveCalibrationConf}],
Tooltip[Control[{{b1,0.3,"Binarization threshold 1"},0,1, Enabled->!SaveCalibrationConf}],"Binarization threshold 1: Pixels above this threshold (whiter) connected to the foreground will be selected",TooltipDelay->1],
Control[{{SaveCalibrationConf,False,"Fix parameters"},{False,True},None}],

(*More parameters tab*)
OpenerView[{"More parameters",Dynamic[Which[Selectedfunction==1,Column[
{Tooltip[Control[{{b2,0.4,"Binarization threshold 2"},0,1,Enabled->!SaveCalibrationConf}],"Binarization threshold 2: Pixels above this threshold (whiter) will be selected",TooltipDelay->1],
Tooltip[Control[{{elongation,0.7,"Max elongation"},0,1,Enabled->!SaveCalibrationConf}],"Maximum elongation: Elements with an elongation (Length/Width) higher than this threshold will be excluded",TooltipDelay->1],
Tooltip[Control[{{minArea,20,"Min area"},0,maxArea,Enabled->!SaveCalibrationConf}],"Minimum area: Elements with smaller area than this threshold will be excluded",TooltipDelay->1],
Tooltip[Control[{{maxArea,300,"Max area"},minArea,500,Enabled->!SaveCalibrationConf}],"Maximum area: Elements with higher area than this threshold will be excluded",TooltipDelay->1]
}],
Selectedfunction==2,Column[
{Tooltip[Control[{{b2,0.4,"Binarization threshold 2"},0,1,Enabled->!SaveCalibrationConf}],"Binarization threshold 2: Pixels above this threshold (whiter) will be selected",TooltipDelay->1],
Tooltip[Control[{{elongation,0.5,"Max elongation"},0,1,Enabled->!SaveCalibrationConf}],"Maximum elongation: Elements with an elongation (Length/Width) higher than this threshold will be excluded",TooltipDelay->1],
Tooltip[Control[{{minArea,1500,"Min area"},0,maxArea,Enabled->!SaveCalibrationConf}],"Minimum area: Elements with smaller area than this threshold will be excluded",TooltipDelay->1],
Tooltip[Control[{{maxArea,50000,"Max area"},minArea,50000,Enabled->!SaveCalibrationConf}],"Maximum area: Elements with higher area than this threshold will be excluded",TooltipDelay->1]}],
Selectedfunction==3,Column[
{Tooltip[Control[{{b2,0.4,"Binarization threshold 2"},0,1,Enabled->!SaveCalibrationConf}],"Binarization threshold 2: Pixels above this threshold (whiter) will be selected",TooltipDelay->1],
Tooltip[Control[{{elongation,0.7,"Max elongation"},0,1,Enabled->!SaveCalibrationConf}],"Maximum elongation: Elements with an elongation (Length/Width) higher than this threshold will be excluded",TooltipDelay->1],
Tooltip[Control[{{minArea,15,"Min trap width"},0,1000,Enabled->!SaveCalibrationConf}],"Minimum area: Elements with smaller area than this threshold will be excluded",TooltipDelay->1],
Tooltip[Control[{{maxArea,600,"Max trap width"},0,1000,Enabled->!SaveCalibrationConf}],"Maximum area: Elements with higher area than this threshold will be excluded",TooltipDelay->1](*,
Tooltip[Control[{{gaussian,3,"Gaussian filter"},0,20,Enabled\[Rule]!SaveCalibrationConf}],"Gaussian kernel radius: Radius size (pixels) use in the Gaussian kernel to filter the image",TooltipDelay\[Rule]1]*)}],
Selectedfunction==4,Column[
{Tooltip[Control[{{b2,0.4,"Binarization threshold 2"},0,1,Enabled->!SaveCalibrationConf}],"Binarization threshold 2: Pixels above this threshold (whiter) will be selected",TooltipDelay->1],
Tooltip[Control[{{minArea,10,"Min hypha length"},0,100,1,Enabled->!SaveCalibrationConf}],"Minimum hyphal length: Elements with a smaller count than this threshold will be excluded",TooltipDelay->1],
Tooltip[Control[{{gaussian,3,"Gaussian filter"},0,200,Enabled->!SaveCalibrationConf}],"Gaussian kernel radius: Radius size (pixels) use in the Gaussian kernel to filter the image",TooltipDelay->1]}]
]]}],Button["Test",ValidationDialog[b1,b2,elongation,minArea,maxArea,gaussian,ZoomImage, Selectedfunction,400],Enabled->!SaveCalibrationConf],
Row[{Button["Edit",
AutomaticParams=False;
SaveCalibrationConf=False,Enabled->Dynamic[SaveCalibrationConf,TrueQ]],Button["Save parameters",SaveCalibrationConf=True;OpenCalibration=False;
OpenOutput=True ,Appearance->If[Dynamic[SaveCalibrationConf,TrueQ],"Pressed",Automatic],Enabled->!SaveCalibrationConf]}],
LocalizeVariables->False,ContinuousAction->False]},Dynamic[OpenCalibration],Enabled->Dynamic[SaveInputConf,TrueQ]],
(*Output options*)
Name="Results_"<>DateString["ISODate"]<>".csv";
SaveOutputConf=False;
OpenerView[{Style["Output options",font1],DynamicModule[{},
Grid[{{"Select Folder to store results:",InputField[Dynamic[FinalDir],String,Enabled->Dynamic[!SaveOutputConf,TrueQ]],FileNameSetter[Dynamic[FinalDir],"Directory",Enabled->Dynamic[!SaveOutputConf,TrueQ]]},{"Select Name and extension for table:",InputField[Dynamic[Name],String,Enabled->Dynamic[!SaveOutputConf,TrueQ]]},{Button["Edit",SaveOutputConf=False,Enabled->Dynamic[SaveOutputConf,TrueQ]],Button["Save",SaveOutputConf=True,Appearance->If[Dynamic[SaveOutputConf,TrueQ],"Pressed",Automatic]]}},Spacings->{1,Automatic},Alignment->Left]]},Dynamic[OpenOutput],Enabled->Dynamic[SaveInputConf&&SaveCalibrationConf,TrueQ]],
(*Execution*)
Button["Run",
If[!DirectoryQ[FinalDir],CreateDirectory[FinalDir]];
execution=CreateDialog[Column[{Style["Execution progress: ",Bold],ProgressIndicator[Dynamic[(i-1)/length]],
CancelButton[DialogReturn[];FrontEndTokenExecute["EvaluatorAbort"]]}],WindowTitle->"Execution",Modal->False,WindowSize->Fit];
FinalExecution[ToString[Name],ToString[FinalDir],b1,b2,elongation,minArea,maxArea,gaussian, Selectedfunction];
NotebookClose[execution];
MessageDialog["The execution finished successfully \n \n You can find the results in: \n"<>ToString[FinalDir]],(*Enabled\[Rule]Dynamic[!Continue,TrueQ],*) Method->"Queued",Enabled->Dynamic[SaveInputConf&&SaveCalibrationConf&&SaveOutputConf,TrueQ]]}],
WindowTitle->"FUNGAL FEATURE TRACKER V.1.0",WindowSize->1000,WindowElements->{"VerticalScrollBar","HorizontalScrollBar","StatusArea"}]
