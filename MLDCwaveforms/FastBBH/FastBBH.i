%module FastBBH
%{
#include "Declarations.h"
%}

// the following three lines allow the automatic conversion of a numpy array
// into a pointer to an array of doubles without the long length of the array

%include numpy_typemaps.i
%typemap(in) double *hp = double *carray;
%typemap(in) double *hc = double *carray;

// the following include defines all the calls that need to be wrapped by SWIG
// the include at the top serves only to provide definitions for this one;
// since it is between braces %{ %}, its content goes straight into
// the CPP wrapper file

%include "Declarations.h"

// and here we can add some Python to the interface code

%pythoncode %{
import numpy
import math

import sys
if 'lisaxml2' in sys.modules:
	import lisaxml2 as lisaxml
else:
	import lisaxml

lisaxml.SourceClassModules['FastSpinBlackHoleBinary'] = 'FastBBH'

# generic CoherentWave    

class FastSpinBlackHoleBinary(lisaxml.Source):
    """Returns a MLDC source that models the waveform emitted by a
	 spinning black hole binary (by Neil Cornish)."""
    
    # this is the list of parameters that will be recorded in the lisaXML SourceData sections
    # give ParameterName, DefaultUnit, DefaultValue (a string), Description
    
    dopolarization = True

    outputlist = (('EclipticLatitude',                 'Radian',        None, 'standard ecliptic latitude'),
                  ('EclipticLongitude',                'Radian',        None, 'standard ecliptic longitude'),
                  ('PolarAngleOfSpin1',                'Radian',        None, 'initial  polar angle of the first spin'),
                  ('PolarAngleOfSpin2',                'Radian',        None, 'initial  polar angle of the second spin'),
                  ('AzimuthalAngleOfSpin1',            'Radian',        None, 'initial azimuthal direction of first spin'),
                  ('AzimuthalAngleOfSpin2',            'Radian',        None, 'initial azimuthal direction of second spin'),
                  ('Spin1',                            'MassSquared',   None, 'magnitude of (specific) of first spin'),
                  ('Spin2',                            'MassSquared',   None, 'magnitude of (specific) of second spin'),
                  ('Mass1',                            'SolarMass',     None, 'mass of the first object'),
                  ('Mass2',                            'SolarMass',     None, 'mass of the secondary object'),
                  ('CoalescenceTime',                  'Second',        None, 'time of coalescence'),
                  ('PhaseAtCoalescence',               'Radian',        None, 'GW phase at coalescence (excluding modulation)'),
                  ('InitialPolarAngleL',               'Radian',        None, 'initial polar angle of the angular orbital momentum L_N'),
                  ('InitialAzimuthalAngleL',           'Radian',        None, 'initial azimuthal direction of L_N'),
                  ('Distance',                         'Parsec',        None, 'standard source distance'),
                  ('TaperApplied',                     'TotalMass',     '7',  'tapering parameter'),
                  ('AmplPNorder',                      'Unit',          '0',  'Post-Newtonian order of the amplitude corrections, phase is hardcoded to 2PN'),
                  ('TaperQFactor', 				       'Unit',          '3.0', 'Factor regulating the length of the half-hann taper: Dt = TaperQFactor/f_end' ))
    
    def  __init__(self,name=''):
        super(FastSpinBlackHoleBinary, self).__init__('FastSpinBlackHoleBinary',name)
        
        # pre-define variables here if used later, so that they will not be included in parameters when they are set
    
    def waveforms(self,samples,deltat,inittime):
        SBH = SBH_structure()
        
        SBH.EclipticLatitude       = self.EclipticLatitude
        SBH.EclipticLongitude      = self.EclipticLongitude
        SBH.PolarAngleOfSpin1      = self.PolarAngleOfSpin1
        SBH.PolarAngleOfSpin2      = self.PolarAngleOfSpin2
        SBH.AzimuthalAngleOfSpin1  = self.AzimuthalAngleOfSpin1
        SBH.AzimuthalAngleOfSpin2  = self.AzimuthalAngleOfSpin2
        SBH.Spin1                  = self.Spin1
        SBH.Spin2                  = self.Spin2        
        SBH.Mass1                  = self.Mass1
        SBH.Mass2                  = self.Mass2
        SBH.CoalescenceTime        = self.CoalescenceTime
        SBH.PhaseAtCoalescence     = self.PhaseAtCoalescence
        SBH.InitialPolarAngleL     = self.InitialPolarAngleL
        SBH.InitialAzimuthalAngleL = self.InitialAzimuthalAngleL        
        SBH.Distance               = self.Distance
        SBH.TaperApplied           = self.TaperApplied
        SBH.AmplPNorder            = self.AmplPNorder
        SBH.TaperQFactor           = self.TaperQFactor
        SBH.Rmin                   = 6.0
        SBH.TaperSteepness         = 150.0   
        
        
        # The signal generated by FastBBH is for the time of observation, plus two padding periods;
        # but the standard interface specifies an inittime, usually = -Tpad, and the total number
        # of samples. A positive inittime does not really fit this scheme...
        
        if inittime > 0:
            raise NotImplementedError, "Sorry, FastSpinBlackHoleBinary currently supports only negative inittime (used for padding)"
        
        SBH.TimeSample             = deltat
        SBH.Tobs 				   = deltat * samples + 2 * inittime
        SBH.Tpad                   = -inittime
        
        hp = numpy.empty(samples,'d')
        hc = numpy.empty(samples,'d')
                
        SBH_Barycenter(SBH, hp, hc);
		
        return (hp,hc)
    
%}
