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
# Copyright (C) 2001 Sun Microsystems, Inc. Used by permission.
# Copyright (C) 2005 Red Hat, Inc.
# All rights reserved.
# END COPYRIGHT BLOCK
#

# enable the use of our bundled perldap with our bundled ldapsdk libraries
# all of this nonsense can be omitted if the mozldapsdk and perldap are
# installed in the operating system locations (e.g. /usr/lib /usr/lib/perl5)
$ENV{'PATH'} = '$prefix/usr/lib/mozldap6:$prefix/usr/lib:/usr/lib/mozldap6:/usr/lib';
$ENV{'LD_LIBRARY_PATH'} = '$prefix/usr/lib/dirsec:$prefix/usr/lib:/usr/lib/dirsec:/usr/lib';
$ENV{'SHLIB_PATH'} = '$prefix/usr/lib/dirsec:$prefix/usr/lib:/usr/lib/dirsec:/usr/lib';
# Add new password policy specific entries

#############################################################################
# enable the use of Perldap functions
require DynaLoader;

use Getopt::Std;
use Mozilla::LDAP::Conn;
use Mozilla::LDAP::Utils qw(:all);
use Mozilla::LDAP::API qw(:api :ssl :apiv3 :constant); # Direct access to C API

#############################################################################
# Default values of the variables

$opt_D = "{{ROOT-DN}}";
$opt_p = "{{SERVER-PORT}}";
$opt_h = "{{SERVER-NAME}}";
$opt_v = 0;

$ENV{'PATH'} = '$prefix{{SEP}}usr{{SEP}}lib:{{SEP}}usr{{SEP}}lib{{SEP}}mozldap';
$ENV{'LD_LIBRARY_PATH'} .= ":";
$ENV{'LD_LIBRARY_PATH'} .= "$prefix{{SEP}}usr{{SEP}}lib:{{SEP}}usr{{SEP}}lib{{SEP}}mozldap";
$ENV{'SHLIB_PATH'} .= ":";
$ENV{'SHLIB_PATH'} .= "$prefix{{SEP}}usr{{SEP}}lib:{{SEP}}usr{{SEP}}lib{{SEP}}mozldap";

# Variables
$ldapsearch="ldapsearch -1";
$ldapmodify="ldapmodify";

#############################################################################

sub usage {
	print (STDERR "ns-newpwpolicy.pl [-v] [-D rootdn] { -w password | -j filename } \n");
	print (STDERR "                  [-p port] [-h host] -U UserDN -S SuffixDN\n\n");

	print (STDERR "Arguments:\n");
	print (STDERR "	-?		- help\n");
	print (STDERR "	-v		- verbose output\n");
	print (STDERR "	-D rootdn	- Directory Manager DN. Default= '$opt_D'\n");
	print (STDERR "	-w rootpw	- password for the Directory Manager DN\n");
	print (STDERR "	-j filename	- Read the Directory Manager's password from file\n");
	print (STDERR "	-p port		- port. Default= $opt_p\n");
	print (STDERR "	-h host		- host name. Default= '$opt_h'\n");
	print (STDERR "	-U userDN	- User entry DN\n");
	print (STDERR "	-S suffixDN	- Suffix entry DN\n");
	exit 100;
}

# Process the command line arguments
{
	usage() if (!getopts('vD:w:j:p:h:U:S:'));

	if ($opt_j ne ""){
		die "Error, cannot open password file $opt_j\n" unless (open (RPASS, $opt_j));
		$opt_w = <RPASS>;
		chomp($opt_w);
		close(RPASS);
	} 

	usage() if( $opt_w eq "" );
	if ($opt_U eq "" && $opt_S eq "") {
		print (STDERR "Please provide at least -S or -U option.\n\n");
	}

	# Now, check if the user/group exists

	if ($opt_S) {
		print (STDERR "host = $opt_h, port = $opt_p, suffixDN = \"$opt_S\"\n\n") if $opt_v;
		@base=(
			"cn=nsPwPolicyContainer,$opt_S",
			"cn=\"cn=nsPwPolicyEntry,$opt_S\",cn=nsPwPolicyContainer,$opt_S",
			"cn=\"cn=nsPwTemplateEntry,$opt_S\",cn=nsPwPolicyContainer,$opt_S",
			"cn=nsPwPolicy_cos,$opt_S"
		);

		$ldapadd="$ldapmodify -p $opt_p -h $opt_h -D \"$opt_D\" -w \"$opt_w\" -c -a 2>&1";
		$modifyCfg="$ldapmodify -p $opt_p -h $opt_h -D \"$opt_D\" -w \"$opt_w\" -c 2>&1";

		@container=(
			"dn: cn=nsPwPolicyContainer,$opt_S\n",
			"objectclass: top\n",
			"objectclass: nsContainer\n\n" );
		@pwpolicy=(
			"dn: cn=\"cn=nsPwPolicyEntry,$opt_S\",cn=nsPwPolicyContainer,$opt_S\n",
			"objectclass: top\n",
			"objectclass: ldapsubentry\n",
			"objectclass: passwordpolicy\n\n" );
		@template=(
			"dn: cn=\"cn=nsPwTemplateEntry,$opt_S\",cn=nsPwPolicyContainer,$opt_S\n",
			"objectclass: top\n",
			"objectclass: extensibleObject\n",
			"objectclass: costemplate\n",
			"objectclass: ldapsubentry\n",
			"cosPriority: 1\n",
			"pwdpolicysubentry: cn=\"cn=nsPwPolicyEntry,$opt_S\",cn=nsPwPolicyContainer,$opt_S\n\n" );
		@cos=(
			"dn: cn=nsPwPolicy_cos,$opt_S\n",
			"objectclass: top\n",
			"objectclass: LDAPsubentry\n",
			"objectclass: cosSuperDefinition\n",
			"objectclass: cosPointerDefinition\n",
			"cosTemplateDn: cn=\"cn=nsPwTemplateEntry,$opt_S\",cn=nsPwPolicyContainer,$opt_S\n",
			"cosAttribute: pwdpolicysubentry default operational-default\n\n" );

		@all=(\@container, \@pwpolicy, \@template, \@cos);

        $i=0;

        foreach $current (@base)
        {
			open(FD,"| $ldapadd");
			print FD @{$all[$i]};
			close(FD);
			if ( $? != 0 ) {
				$retCode=$?>>8;
				if ( $retCode == 68 ) {
					print( STDERR "Entry \"$current\" already exists. Please ignore the error\n\n");
				}
				else {
					# Probably a more serious problem.
					# Exit with LDAP error
					print(STDERR "Error $retcode while adding \"$current\". Exiting.\n");
					exit $retCode;
				}
			}
			else {
				print( STDERR "Entry \"$current\" created\n\n") if $opt_v;
			}
			$i=$i+1;
		}

		$modConfig = "dn:cn=config\nchangetype: modify\nreplace:nsslapd-pwpolicy-local\nnsslapd-pwpolicy-local: on\n\n";
		open(FD,"| $modifyCfg ");
		print(FD $modConfig);
		close(FD);
		$retcode = $?;
		if ( $retcode != 0 ) {
			print( STDERR "Error $retcode while modifing \"cn=config\". Exiting.\n" );
			exit ($retcode);
		}
		else {
			print( STDERR "Entry \"cn=config\" modified\n\n") if $opt_v;
		}
	} # end of $opt_S

	if ($opt_U) {
		my $norm_opt_U = normalizeDN($opt_U);
		print (STDERR "host = $opt_h, port = $opt_p, userDN = \"$norm_opt_U\"\n\n") if $opt_v;
		$retcode = `$ldapsearch -h $opt_h -p $opt_p -b \"$norm_opt_U\" -s base \"\"`;
		if ($retcode != 0 ) {
			print( STDERR "the user entry $norm_opt_U does not exist. Exiting.\n");
			exit ($retcode);
		}
		
		print( STDERR "the user entry $norm_opt_U found..\n\n") if $opt_v;
		
		# Now, get the parentDN 
		@rdns = ldap_explode_dn($norm_opt_U, 0);
		shift @rdns;
		$parentDN = join(',', @rdns);

		print (STDERR "parentDN is $parentDN\n\n") if $opt_v;

		@base=(
			"cn=nsPwPolicyContainer,$parentDN",
			"cn=\"cn=nsPwPolicyEntry,$norm_opt_U\",cn=nsPwPolicyContainer,$parentDN"
		);

		$ldapadd="$ldapmodify -p $opt_p -h $opt_h -D \"$opt_D\" -w \"$opt_w\" -c -a 2>&1";
		$modifyCfg="$ldapmodify -p $opt_p -h $opt_h -D \"$opt_D\" -w \"$opt_w\" -c 2>&1";

		@container=(
			"dn: cn=nsPwPolicyContainer,$parentDN\n",
			"objectclass: top\n",
			"objectclass: nsContainer\n\n" );
		@pwpolicy=(
			"dn: cn=\"cn=nsPwPolicyEntry,$norm_opt_U\",cn=nsPwPolicyContainer,$parentDN\n",
			"objectclass: top\n",
			"objectclass: ldapsubentry\n",
			"objectclass: passwordpolicy\n\n" );

		@all=(\@container, \@pwpolicy);

        $i=0;

        foreach $current (@base)
        {
			open(FD,"| $ldapadd ");
			print FD @{$all[$i]};
			close(FD);
			if ( $? != 0 ) {
				$retCode=$?>>8;
				if ( $retCode == 68 ) {
					print( STDERR "Entry $current already exists. Please ignore the error\n\n");
				}
				else {
					# Probably a more serious problem.
					# Exit with LDAP error
					print(STDERR "Error $retcode while adding \"$current\". Exiting.\n");
					exit $retCode;
				}
			}
			else {
				print( STDERR "Entry $current created\n\n") if $opt_v;
			}
			$i=$i+1;
		}

		$target = "cn=\"cn=nsPwPolicyEntry,$norm_opt_U\",cn=nsPwPolicyContainer,$parentDN";
		$modConfig = "dn: $norm_opt_U\nchangetype: modify\nreplace:pwdpolicysubentry\npwdpolicysubentry: $target\n\n";
		open(FD,"| $modifyCfg ");
		print(FD $modConfig);
		close(FD);
		$retcode = $?;
		if ( $retcode != 0 ) {
			print( STDERR "Error $retcode while modifing $norm_opt_U. Exiting.\n" );
			exit ($retcode);
		}
		else {
			print( STDERR "Entry \"$norm_opt_U\" modified\n\n") if $opt_v;
		}

		$modConfig = "dn:cn=config\nchangetype: modify\nreplace:nsslapd-pwpolicy-local\nnsslapd-pwpolicy-local: on\n\n";
		open(FD,"| $modifyCfg ");
		print(FD $modConfig);
		close(FD);
		$retcode = $?;
		if ( $retcode != 0 ) {
			print( STDERR "Error $retcode while modifing \"cn=config\". Exiting.\n" );
			exit ($retcode);
		}
		else {
			print( STDERR "Entry \"cn=config\" modified\n\n") if $opt_v;
		}
	} # end of $opt_U
}
