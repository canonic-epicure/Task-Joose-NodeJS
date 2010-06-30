#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Path::Class;


#======================================================================================================================================================================================
# detecting JSAN root

use Module::Build::JSAN::Installable;


my $jsan_root = dir(Module::Build::JSAN::Installable::get_jsan_libroot(), 'lib');


#======================================================================================================================================================================================
# setting up the package content

my @package = (
    'Task.Joose.Core',
    'Task.JooseX.Attribute.Bootstrap',
    'Task.JooseX.Namespace.Depended.NodeJS',
    'Task.JooseX.CPS.All'
);


#======================================================================================================================================================================================
# concatenating


my $content = '';

foreach my $module (@package) {
    
    my @dirs = split /\./, $module;
    $dirs[ -1 ] .= '.js';
    
    $content .= ";\n;" . $jsan_root->file(@dirs)->slurp();
}



#======================================================================================================================================================================================
# writing the results

my $package_file        = file("$FindBin::Bin/../lib/Task/Joose/NodeJS.js");


my $fh = $package_file->openw;

print $fh $content;

$fh->close;


#print `java -jar bin/yuicompressor-2.4.2.jar -o lib/Task/Joose/NodeJS.js lib/Task/Joose/NodeJS.js`; 