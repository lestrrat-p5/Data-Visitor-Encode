# $Id$
#
# Copyright (c) 2006 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

use inc::Module::Install;

name 'Data-Visitor-Encode';
all_from 'lib/Data/Visitor/Encode.pm';

requires 'Encode';
requires 'Data::Visitor';
requires 'Scalar::Util';
build_requires 'Test::More';

auto_install;
WriteAll;