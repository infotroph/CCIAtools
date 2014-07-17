CCIAtools
=========

Scripts useful when running a LGR CCIA-36EP CO2 isotope analyzer and peripherals

Very much in progress. If any of this looks interesting, get in touch: black11@illinois.edu.

### Subdirectories: 
  * linearity-rig: Test whether the the CCIA reports the same delta for the same gas fed in at different concentrations. 
  My setup assumes two Alicat mass flow controllers, one feeding zero air and one feeding a high-concentration CO2-air 
  mix -- I use 0.5% in a scuba tank. I will eventually document how I convert the output from this test into 
  a fine-calibration table.
  
  * inlet-manifold: I'm sampling atmospheric air from the canopy over four different crops, using a sampling manifold 
  that was originally set up for N2O measurements using a Campbell tunable diode laser. All pressure control and source 
  switching is handled by a CR3000 datalogger controlling an 8-way manifold and a set of bypass valves for pressure and flow tuning. 
  I expect this directory to contain mostly datalogger programs.
  
  * 2umCCIA120136_ini: configuration files from the DeLucia lab's instrument. My changes aren't necessarily blessed by LGR staff and I do not know which values are specific to this particular instrument, so use anything from this directory with great care!
 
## Coming soon:
  * R scripts to read, quality-control, and analyze 1 Hz continuous sampling data, both with and without timed inlet switching.
  
  * R scripts to read and summarize batch-mode data (discrete injections).
  
  * CCIA calibration routines.
  
  * Tweaked versions of CCIA configuration files, especially linearity tables and fine-tuned injection parameters 
  (N.B. these tunings are probably specific to my instrument!).
