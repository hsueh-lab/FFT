# Fungal Feature Tracker (FFT): A tool to quantitatively characterize morphology and growth of filamentous fungi

The FFT represents a user-friendly tool that automatically characterizes several fungal phenotypes using images that can be obtained using basic imaging devices. The FFT can be used to study different fungal species, conditions and image scales and resolutions. Relying on simple built-in image analysis functions, the FFT is able to quantitatively characterize conidiation, conidia morphology and different aspects of the mycelium, including the growth area, number of hyphal tips and total length of the hyphae. In addition, we developed a function within the FFT that can detect and count traps developed by nematode-trapping fungi.

## The functions of the FFT

### Spore morphology characterization

This function allows to automatically compute the area, length, width and circularity of fungal spores relying in images of stained spores.

<img width="292" alt="Screen Shot 2019-05-14 at 12 47 00 PM" src="https://user-images.githubusercontent.com/50606488/57671514-b6e8a900-7646-11e9-828d-a5464fd65b19.png">

### Spore counting

The FFT can be used to accurately count the number of spores present in an image. 
 
![FFT_NC_Spores_07](https://user-images.githubusercontent.com/50606488/57671637-2eb6d380-7647-11e9-9bc1-9b794572b86d.jpg)

### Mycelium characterization

The mycelium characterization function of the FFT quantitatively computes several fungal measures from images of the mycelium such as the total length, the area covered by the mycelium and the number of tips.

![FFT_Profile](https://user-images.githubusercontent.com/50606488/57671661-51e18300-7647-11e9-8182-ee7c6e93e36c.png)

### Fungal trap counting

The fungal trip counting function quantifies the traps developed by nematode-trapping fungi to capture and consume nematodes.

![R_0928 AO12 N2 7 40x](https://user-images.githubusercontent.com/50606488/57671816-ed72f380-7647-11e9-909c-0e7758242caa.jpg)

## Fungal Feature Tracker (FFT) Tutorial
 
1. Select the images on which you want to run the FFT

<img width="1278" alt="Screen Shot 2019-05-14 at 12 16 41 PM" src="https://user-images.githubusercontent.com/50606488/57670693-f7462800-7642-11e9-94ac-a66afe37999b.png">

Use the Browse button to select the folder containing the fungal images.

2. Select the FFT function you want to perform on your images

<img width="1278" alt="Screen Shot 2019-05-14 at 12 16 49 PM" src="https://user-images.githubusercontent.com/50606488/57670706-04631700-7643-11e9-9904-651055b17773.png">

Check our paper to get more information about each of the functions, how they work and what kind of images will work better for each of them.

3. Select a mask to subtract to all your original images (only if you have one)

<img width="1243" alt="Screen Shot 2019-05-14 at 12 16 59 PM" src="https://user-images.githubusercontent.com/50606488/57670742-2ceb1100-7643-11e9-95c1-708d7e7ada22.png">

4. Save the input options

<img width="1278" alt="Screen Shot 2019-05-14 at 12 17 09 PM" src="https://user-images.githubusercontent.com/50606488/57670755-3f654a80-7643-11e9-8654-ca9ae7b77e52.png">

5. Calibrate your parameters

![Picture5](https://user-images.githubusercontent.com/50606488/57670799-74719d00-7643-11e9-86ac-80e2287fa029.png)

Move the sliders until to find a suitable parameter configuration. The features detected by the FFT appear in the window on top of the original image (in red for the mycelium characterization and in Blue for the rest of the functions). Select the zoom option to perform the calibration on a zoom area of your image.

6. Test your parameters on other images of the set

![Picture6](https://user-images.githubusercontent.com/50606488/57670812-83f0e600-7643-11e9-9cb6-c3d7a9e39869.png)

Once you have selected your parameters you can test them on other images using the Test button which opens the Validation window:

7. Save the selected parameters

<img width="639" alt="Screen Shot 2019-05-14 at 12 18 35 PM" src="https://user-images.githubusercontent.com/50606488/57670817-86534000-7643-11e9-9dfd-47fb060aef9d.png">

The OK button from the Validation window is equivalent to the Save parameters button.

8. Select the directory, name and extension to save the FFT results

<img width="636" alt="Screen Shot 2019-05-14 at 12 18 50 PM" src="https://user-images.githubusercontent.com/50606488/57670845-ab47b300-7643-11e9-8e6d-f08895527aad.png">

If the Directory introduced in “Select Folder to store results” does not exist the FFT will create it. You can change the name and extension of the table results with all the measures. The image outputs will name after the image they come from and with the same extension.

9. Save the Output options

<img width="642" alt="Screen Shot 2019-05-14 at 12 18 56 PM" src="https://user-images.githubusercontent.com/50606488/57670885-d3371680-7643-11e9-8328-91e5ef6f7954.png">

10. Click the Run button

<img width="646" alt="Screen Shot 2019-05-14 at 12 19 04 PM" src="https://user-images.githubusercontent.com/50606488/57670889-d5997080-7643-11e9-8fd2-45bb7d3134a9.png">

Clicking the Run button will start the execution of the FFT on all images of the set. The execution window will open showing a progress bar:

<img width="643" alt="Screen Shot 2019-05-14 at 12 19 11 PM" src="https://user-images.githubusercontent.com/50606488/57670892-d9c58e00-7643-11e9-87c4-5a9278569e64.png">

Once the execution a window will pop up confirming that the execution has finished successfully and where to find the final results.

<img width="494" alt="Screen Shot 2019-05-14 at 12 19 23 PM" src="https://user-images.githubusercontent.com/50606488/57670893-dc27e800-7643-11e9-8c67-caf5a29aebfe.png">


## Prerequisites and Instalation 

Download the `FFT_v_1_0.m` file and paste it somewhere in your computer. Open the file using Mathematica (Wolfram Research Inc., USA) and click Run all codeDownload the `FFT_v_1_0.m` file and paste it somewhere in your computer. Open the file using Mathematica (Wolfram Research Inc., USA) and click `Run All Code` at the top-right corner. 

