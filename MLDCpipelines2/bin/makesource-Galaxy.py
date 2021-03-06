#!/usr/bin/env python

__version__ = '$Id$'

import sys
import os
import os.path

def run(command):
    commandline = command % globals()
    print "-----> %s" % commandline
    
    try:
        assert(os.system(commandline) == 0)
    except:
        print 'Script %s failed at command "%s".' % (sys.argv[0],commandline)
        sys.exit(1)

# only one argument, and it's the seed, but check whether we want to run the test Galaxy

from optparse import OptionParser

parser = OptionParser(usage="usage: %prog [options] SEED...",
                      version="$Id$")

parser.add_option("-t", "--test",
                  action="store_true", dest="istest", default=False,
                  help="run the test galaxy (seed must be 1!) [off by default]")

# add options to disable the LISA Simulator or Synthetic LISA

(options, args) = parser.parse_args()

if len(args) < 1:
    parser.error("I need the seed!")

seed = int(args[0])

if options.istest and seed != 1:
    parser.error("If you use -t/--test, the seed must be 1.")

if not options.istest and seed == 1:
    parser.error("If you don't use -t/--test, the seed cannot be 1.")

here = os.getcwd()
os.chdir('../MLDCwaveforms/Galaxy')

if options.istest:
    # just testing...
    # no need to run Galaxy_Maker, we have Data/Galaxy_1.dat and Data/Galaxy_Bright_1.dat already...
    run('./Galaxy_key Test %s' % seed)

    os.chdir(here)

    run("sed 's/Data\///g' < ../MLDCwaveforms/Galaxy/XML/Test_key.xml > Galaxy/Galaxy.xml")
    run('rm ../MLDCwaveforms/Galaxy/XML/TheGalaxy_key.xml')
    
    # we copy, not move, the test galaxy (since that's not generated, but included in the Galaxy tar.gz)
    run('cp ../MLDCwaveforms/Galaxy/Data/Galaxy_%s.dat Galaxy/.' % seed)
    run('cp ../MLDCwaveforms/Galaxy/Data/Galaxy_Bright_%s.dat Galaxy/.' % seed)
else:
    # here 1 is a switch to include verification binaries
    run('./Galaxy_Maker %s 1' % seed)

    run('./Galaxy_key TheGalaxy %s' % seed)    

    os.chdir(here)

    # copy over Galaxy XML, normalizing location of dat file
    run("sed 's/Data\///g' < ../MLDCwaveforms/Galaxy/XML/TheGalaxy_key.xml > Galaxy/Galaxy.xml")
    run('rm ../MLDCwaveforms/Galaxy/XML/TheGalaxy_key.xml')

    # move the files to MLDCpipelines2/Galaxy, but create symlinks so they can still 
    # be used from here (they're needed later to make TDI)

    galaxyfile = os.path.abspath('../MLDCwaveforms/Galaxy/Data/Galaxy_%s.dat' % seed)
    run('mv %s Galaxy/.' % galaxyfile)
    galaxydest = os.path.abspath('Galaxy/Galaxy_%s.dat' % seed)
    run('ln -sf %s %s' % (galaxydest,galaxyfile))

    galaxyfile = os.path.abspath('../MLDCwaveforms/Galaxy/Data/Galaxy_Bright_%s.dat' % seed)
    run('mv %s Galaxy/.' % galaxyfile)
    galaxydest = os.path.abspath('Galaxy/Galaxy_Bright_%s.dat' % seed)
    run('ln -sf %s %s' % (galaxydest,galaxyfile))
