#!/usr/bin/perl
#
# Author: Mike Dearman
# Date:   20-03-2015
# Requirements: Win32::SerialPort 
# (Uses same interface as Device::SerialPort linux module so can be ported)
#
# Version: 1.0
#
# Description:  This perl script is for customizing a sequence of events over a short interval of time manually.
# PCIe Card Module has been connected via a serial connection.In this case the customer has been using complex 
# server backplane design which has an FPGA which is controlling PERST#, SSD +12V and REFCLK. 


use strict;
use warnings;
use Time::HiRes qw (sleep);       # Perl Sleep command for short intervals 
use Win32::SerialPort;            # use Win32 serial port module

# Import torridon common functions
require 'TorridonCommon.pl';


#
# Serial Settings
#
# Create SerialPort object called $Connection and configure

my $PORT = "COM4"; 		# **** Serial port to use ****


my $Connection = Win32::SerialPort->new ($PORT) || die "Can't Open $PORT: $!";
$Connection->baudrate(19200)   || die "failed setting baudrate";
$Connection->databits(8)       || die "failed setting databits";
$Connection->stopbits(1)       || die "failed setting stopbits";
$Connection->handshake("none") || die "failed setting handshake";
$Connection->parity("none")    || die "failed setting parity";


#SerialPort defers change to serial settings until write_settings() 
#method which validates settings and then implements changes
$Connection->write_settings    || die "no settings";

 
print "\n# Running Script\n\n>";

###

#reset module to defaults
print"Print RETURN to reset module";
<STDIN>;
&SendTorridonCommand ($Connection, "conf:def state");

# assign all signals to source 8 so they are always on
&SendTorridonCommand ($Connection, "sig:all:source 8");

#reassign the signals we want to control
&SendTorridonCommand ($Connection, "sig:PERST:source 1");
&SendTorridonCommand ($Connection, "sig:12V_POWER:source 2");
&SendTorridonCommand ($Connection, "sig:REFCLK_MN:source 2");
&SendTorridonCommand ($Connection, "sig:REFCLK_PL:source 2");

#set signal driving logic on PERST signal (supported on QTL1688-04 & QTL1630-04 modules and above)
#&SendTorridonCommand ($Connection, "SIGnal:PERST:DRIve:OPEn LOW");
#&SendTorridonCommand ($Connection, "SIGnal:PERST:DRIve:CLOsed HIGH");

print"Print RETURN to start script";
<STDIN>;

# Timing sequence begins here
&SendTorridonCommand ($Connection, "source:1:STATE off");
sleep(0.4);
&SendTorridonCommand ($Connection, "source:1:STATE on");
sleep(4.5);
&SendTorridonCommand ($Connection, "source:1:STATE off");
sleep(0.4);
&SendTorridonCommand ($Connection, "source:2:STATE off");
sleep(1.6);
&SendTorridonCommand ($Connection, "source:2:STATE on");
sleep(0.2);
&SendTorridonCommand ($Connection, "source:1:STATE on");
sleep(6);
&SendTorridonCommand ($Connection, "source:1:STATE off");
sleep(0.6);
&SendTorridonCommand ($Connection, "source:2:STATE off");
sleep(3.8);
&SendTorridonCommand ($Connection, "source:2:STATE on");
sleep(0.2);
&SendTorridonCommand ($Connection, "source:1:STATE on");


print "\n\n# Script Completed!";


# Close the COM port
undef $Connection;  




