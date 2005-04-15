/** BEGIN COPYRIGHT BLOCK
 * This Program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation; version 2 of the License.
 * 
 * This Program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * this Program; if not, write to the Free Software Foundation, Inc., 59 Temple
 * Place, Suite 330, Boston, MA 02111-1307 USA.
 * 
 * In addition, as a special exception, Red Hat, Inc. gives You the additional
 * right to link the code of this Program with code not covered under the GNU
 * General Public License ("Non-GPL Code") and to distribute linked combinations
 * including the two, subject to the limitations in this paragraph. Non-GPL Code
 * permitted under this exception must only link to the code of this Program
 * through those well defined interfaces identified in the file named EXCEPTION
 * found in the source code files (the "Approved Interfaces"). The files of
 * Non-GPL Code may instantiate templates or use macros or inline functions from
 * the Approved Interfaces without causing the resulting work to be covered by
 * the GNU General Public License. Only Red Hat, Inc. may make changes or
 * additions to the list of Approved Interfaces. You must obey the GNU General
 * Public License in all respects for all of the Program code and other code used
 * in conjunction with the Program except the Non-GPL Code covered by this
 * exception. If you modify this file, you may extend this exception to your
 * version of the file, but you are not obligated to do so. If you do not wish to
 * do so, delete this exception statement from your version. 
 * 
 * 
 * Copyright (C) 2001 Sun Microsystems, Inc. Used by permission.
 * Copyright (C) 2005 Red Hat, Inc.
 * All rights reserved.
 * END COPYRIGHT BLOCK **/
/* namegen.c - utility program to generate name *
 * of backup files in the format YYYY_MM_DD_HMS *
 * and set it up as an environment variable to  *
 * be used by batch files on NT                 *
 *                                              *
 * to use it do the following in your batch file*
 * namegen                                      *
 * call bstart                                   *
 * .......                                      *
 * call bend                                     *
 * rm end.bat                                   *
 *                                              *
 * start and end are batch files generated by   *
 * name gen.                                    *
 * Example: ldif2db.bat                         */

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>

#define STARTFILE "bstart.bat"
#define ENDFILE   "bend.bat"
#define CMD       "set DATESTR=%0\n"
 

int main (int argc, char **argv)
{
    char      szDate [64];
    char      szDateFile [64];
	char      szCmd [256];
	struct tm *sCurTime;
	long      lCurTime;
    int       rt;
    FILE      *fBatch;

	time( &lCurTime );

	sCurTime = localtime( &lCurTime );

	strftime(szDate, sizeof (szDateFile), "%Y_%m_%d_%H%M%S", 
             sCurTime);

    _snprintf (szDateFile, sizeof(szDateFile), "%s.bat", szDate);
	szDateFile[sizeof(szDateFile)-1] = (char)0;

    /* create date batch file */
    fBatch = fopen (szDateFile, "w");
    if (fBatch == NULL)
    {
        perror ("Unable to create date file!");
        exit (1);
    }

    rt = fwrite (CMD, strlen (CMD), 1, fBatch);
    if (rt != 1)
    {
        perror ("Unable to write date file\n");
        exit (1);
    }

    fclose (fBatch);

    /* create bstart.bat that executest date batch file */
    fBatch = fopen (STARTFILE, "w");
    if (fBatch == NULL)
    {
        perror ("Unable to bstart file!");
        exit (1);
    }

    _snprintf (szCmd, sizeof(szCmd), "call %s", szDate);
	szCmd[sizeof(szCmd)-1] = (char)0;

    rt = fwrite (szCmd, strlen (szCmd), 1, fBatch);
    if (rt != 1)
    {
        perror ("Unable to write bstart file\n");
        exit (1);
    }

    fclose (fBatch);

    /* create bstart.bat that executest date batch file */
    fBatch = fopen (ENDFILE, "w");
    if (fBatch == NULL)
    {
        perror ("Unable to bend file!");
        exit (1);
    }

    _snprintf (szCmd, sizeof(szCmd), "del %s\ndel bstart.bat\nset DATESTR=", szDateFile);
	szCmd[sizeof(szCmd)-1] = (char)0;

    rt = fwrite (szCmd, strlen(szCmd), 1, fBatch);
    if (rt != 1)
    {
        perror ("Unable to write bend file\n");
        exit (1);
    }

    fclose (fBatch);

    return 0;
}
