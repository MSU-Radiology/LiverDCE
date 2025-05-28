# Summary:
LiverDCE analyzes dynamic contrast-enhanced magnetic resonance imaging (DCE-MRI) data using a variety of pharmacokinetic models. It is primarily focused on models adapted for use with hepatobiliary contrast agents such as Gd-EOB-DTPA (gadoxetate) and Gd-BOPTA (gadobenate) which are taken up into the liver via active transport and excreted into the bile as well as renally.  
  
# Dependencies:  
## Requires the following MATLAB toolboxes:  
Medical Imaging, Global Optimization, Optimization, Image Processing, Parallel Computing, Curve Fitting, Signal Processing, Statistics and Machine Learning, Symbolic Math  
  
## Requires the following packages be installed and accessible on the MATLAB path:  
afni_matlab (https://github.com/zsaad/afni_matlab)  
imtool3D (https://github.com/MSU-Radiology/imtool3D). This is a customized version of the imtool3D package, based on version 2.4.2.0 of Justin Solomon's code published on the MATLAB File Exchange.  
  
# License:  
This software is provided under the terms of the BSD 2-clause license. Specific details of the software license are given in the file "license.txt", which you should have received together with the source code.  
  
# Citations:  
1.  Amro. Answer to ‘What’s the “right” way to organize GUI code?’ Stack Overflow https://stackoverflow.com/a/20083075/610638 (2013).  
2.  The MathWorks Inc. (2023). MATLAB® Version: 9.14.0.2306882 (R2023a) Update 4, Natick, Massachusetts: The MathWorks Inc.  
3.  The MathWorks Inc. (2023). Medical Imaging Toolbox Version: 12.5 (R2023a), Natick, Massachusetts: The MathWorks Inc.  
4.  The MathWorks Inc. (2023). Global Optimization Toolbox Version: 4.8.1 (R2023a), Natick, Massachusetts: The MathWorks Inc.  
5.  The MathWorks Inc. (2023). Optimization Toolbox Version: 9.5 (R2023a), Natick, Massachusetts: The MathWorks Inc.  
6.  The MathWorks Inc. (2023). Image Processing Toolbox Version: 11.7 (R2023a), Natick, Massachusetts: The MathWorks Inc.  
7.  The MathWorks Inc. (2023). Parallel Computing Toolbox Version: 7.8 (R2023a), Natick, Massachusetts: The MathWorks Inc.  
8.  The MathWorks Inc. (2023). Curve Fitting Toolbox Version: 3.9 (R2023a), Natick, Massachusetts: The MathWorks Inc.  
9.  The MathWorks Inc. (2023). Signal Processing Toolbox Version: 9.2 (R2023a), Natick, Massachusetts: The MathWorks Inc.  
10. The MathWorks Inc. (2023). Statistics and Machine Learning Toolbox Version: 12.5 (R2023a), Natick, Massachusetts: The MathWorks Inc.  
11. The MathWorks Inc. (2023). Symbolic Math Toolbox Version: 9.3 (R2023a), Natick, Massachusetts: The MathWorks Inc.  
12. Saad, Ziad. afni_matlab, (2001), GitHub repository, https://github.com/zsaad/afni_matlab  
13. Solomon, Justin (2016). imtool3D (https://www.mathworks.com/matlabcentral/fileexchange/40753-imtool3d), MATLAB® Central File Exchange. Retrieved May 13, 2016.  
14. Ziemian, S. et al. Ex vivo gadoxetate relaxivities in rat liver tissue and blood at five magnetic field strengths from 1.41 to 7 T. NMR Biomed 34, e4401 (2021).  
15. EOVIST (Gadoxetate Disodium) Injection for intravenouse use: prescribing information (2010) FDA.gov. Available at: https://www.accessdata.fda.gov/drugsatfda_docs/label/2010/022090s004lbl.pdf.  
16. Weinmann, H. J. et al. A new lipophilic gadolinium chelate as a tissue-specific contrast medium for MRI. Magn Reson Med 22, 233–237; discussion 242 (1991).  
17. Schuhmann-Giampieri, G. et al. Preclinical evaluation of Gd-EOB-DTPA as a contrast agent in MR imaging of the hepatobiliary system. Radiology 183, 59–64 (1992).  
18. Shen, Y. et al. T1 relaxivities of gadolinium-based magnetic resonance contrast agents in human whole blood at 1.5, 3, and 7 T. Invest Radiol 50, 330–338 (2015).  
19. Rohrer, M., Bauer, H., Mintorovitch, J., Requardt, M. & Weinmann, H.-J. Comparison of magnetic properties of MRI contrast media solutions at different magnetic field strengths. Invest Radiol 40, 715–724 (2005).  
20. Shuter, B., Tofts, P. S., Wang, S. C. & Pope, J. M. The relaxivity of Gd-EOB-DTPA and Gd-DTPA in liver and kidney of the Wistar rat. Magn Reson Imaging 14, 243–253 (1996).  
21. Shuter, B., Wang, S. C., Roche, J., Briggs, G. & Pope, J. M. Relaxivity of Gd-EOB-DTPA in the normal and biliary obstructed guinea pig. J Magn Reson Imaging 8, 853–861 (1998).  
22. Pintaske, J. et al. Relaxivity of Gadopentetate Dimeglumine (Magnevist), Gadobutrol (Gadovist), and Gadobenate Dimeglumine (MultiHance) in human blood plasma at 0.2, 1.5, and 3 Tesla. Invest Radiol 41, 213–221 (2006).  
23. Donahue, K. M., Burstein, D., Manning, W. J. & Gray, M. L. Studies of Gd-DTPA relaxivity and proton exchange rates in tissue. Magn Reson Med 32, 66–76 (1994).  
24. Ulloa, J. L. et al. Assessment of gadoxetate DCE-MRI as a biomarker of hepatobiliary transporter inhibition. NMR Biomed 26, 1258–1270 (2013).  
25. Berks, M. et al. A model selection framework to quantify microvascular liver function in gadoxetate-enhanced MRI: Application to healthy liver, diseased tissue, and hepatocellular carcinoma. Magn Reson Med 86, 1829–1844 (2021).  
26. Georgiou, L. et al. Quantitative Assessment of Liver Function Using Gadoxetate-Enhanced Magnetic Resonance Imaging. Invest Radiol 52, 111–119 (2017).  
27. Georgiou, L. DCE-MRI assessment of hepatic uptake and efflux of the contrast agent, gadoxetate, to monitor transporter-mediated processes and drug-drug interactions: in vitro and in vivo studies. University of Manchester School of Medicine (2014).  
  
Revised 5/28/2025  
-Matt Latourette  
