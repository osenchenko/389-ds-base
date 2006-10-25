#{{PERL-EXEC}}
#
# BEGIN COPYRIGHT BLOCK
# This Program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; version 2 of the License.
# 
# This Program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with
# this Program; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place, Suite 330, Boston, MA 02111-1307 USA.
# 
# In addition, as a special exception, Red Hat, Inc. gives You the additional
# right to link the code of this Program with code not covered under the GNU
# General Public License ("Non-GPL Code") and to distribute linked combinations
# including the two, subject to the limitations in this paragraph. Non-GPL Code
# permitted under this exception must only link to the code of this Program
# through those well defined interfaces identified in the file named EXCEPTION
# found in the source code files (the "Approved Interfaces"). The files of
# Non-GPL Code may instantiate templates or use macros or inline functions from
# the Approved Interfaces without causing the resulting work to be covered by
# the GNU General Public License. Only Red Hat, Inc. may make changes or
# additions to the list of Approved Interfaces. You must obey the GNU General
# Public License in all respects for all of the Program code and other code used
# in conjunction with the Program except the Non-GPL Code covered by this
# exception. If you modify this file, you may extend this exception to your
# version of the file, but you are not obligated to do so. If you do not wish to
# provide this exception without modification, you must delete this exception
# statement from your version and license this file solely under the GPL without
# exception. 
# 
# 
# Copyright (C) 2005 Red Hat, Inc.
# All rights reserved.
# END COPYRIGHT BLOCK
#

use Cgi;

$params = "";
$params .= " -h $cgiVars{'servhost'}" if $cgiVars{'servhost'};
$params .= " -p $cgiVars{'servport'}" if $cgiVars{'servport'};
$params .= " -f $cgiVars{'configfile'}" if $cgiVars{'configfile'};
$params .= " -t $cgiVars{'refreshinterval'}" if $cgiVars{'refreshinterval'};
if ($cgiVars{'admurl'}) {
	$admurl = "$cgiVars{'admurl'}";
	if ( $ENV{'QUERY_STRING'} ) {
		$admurl .= "?$ENV{'QUERY_STRING'}";
	}
	elsif ( $ENV{'CONTENT_LENGTH'} ) {
		$admurl .= "?$Cgi::CONTENT";
	}
	$params .= " -u \"$admurl\"";
}
$siteroot = $cgiVars{'siteroot'};
$ENV{'PATH'} = '$prefix/usr/lib/mozldap6:$prefix/usr/lib:/usr/lib/mozldap6:/usr/lib';
$ENV{'LD_LIBRARY_PATH'} = '$prefix/usr/lib/dirsec:$prefix/usr/lib:/usr/lib/dirsec:/usr/lib';
$ENV{'SHLIB_PATH'} = '$prefix/usr/lib/dirsec:$prefix/usr/lib:/usr/lib/dirsec:/usr/lib';

# Save user-specified parameters as cookies in monreplication.properties.
# Sync up with the property file so that monreplication2 is interval, and
# monreplication3 the config file pathname.
$propertyfile = "$siteroot/bin/admin/admin/bin/property/monreplication.properties";
$edit1 = "s#monreplication2=.*#monreplication2=$cgiVars{'refreshinterval'}#;";
$edit2 = "s#^monreplication3=.*#monreplication3=$cgiVars{'configfile'}#;";
system("perl -p -i.bak -e \"$edit1\" -e \"$edit2\" $propertyfile");

# Now the real work
$replmon = "$siteroot/bin/slapd/admin/scripts/template-repl-monitor.pl";
system("perl -I$siteroot/lib/perl/arch -I$siteroot/lib/perl $replmon $params");
