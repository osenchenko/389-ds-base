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
/*
 */

#define REASON_ANNOTATE_DN		"namingConflict"
#define REASON_RESURRECT_ENTRY	"deletedEntryHasChildren"

/*
 * urp.c
 */
int urp_modify_operation( Slapi_PBlock *pb );
int urp_add_operation( Slapi_PBlock *pb );
int urp_delete_operation( Slapi_PBlock *pb );
int urp_post_delete_operation( Slapi_PBlock *pb );
int urp_modrdn_operation( Slapi_PBlock *pb );
int urp_post_modrdn_operation( Slapi_PBlock *pb );

/* urp internal ops */
int urp_fixup_add_entry (Slapi_Entry *e, const char *target_uniqueid, const char *parentuniqueid, CSN *opcsn, int opflags);
int urp_fixup_delete_entry (const char *uniqueid, const char *dn, CSN *opcsn, int opflags);
int urp_fixup_rename_entry (Slapi_Entry *entry, const char *newrdn, int opflags);
int urp_fixup_modify_entry (const char *uniqueid, const char *dn, CSN *opcsn, Slapi_Mods *smods, int opflags);

int is_suffix_dn (Slapi_PBlock *pb, const Slapi_DN *dn, Slapi_DN **parenddn);

/*
 * urp_glue.c
 */
int is_glue_entry(const Slapi_Entry* entry);
int create_glue_entry ( Slapi_PBlock *pb, char *sessionid, Slapi_DN *dn, const char *uniqueid, CSN *opcsn );
int entry_to_glue(char *sessionid, const Slapi_Entry* entry, const char *reason, CSN *opcsn);
int glue_to_entry (Slapi_PBlock *pb, Slapi_Entry *entry );
PRBool get_glue_csn(const Slapi_Entry *entry, const CSN **gluecsn);

/*
 * urp_tombstone.c
 */
int is_tombstone_entry(const Slapi_Entry* entry);
int tombstone_to_glue(Slapi_PBlock *pb, const char *sessionid, Slapi_Entry *entry, const Slapi_DN *parentdn, const char *reason, CSN *opcsn);
int entry_to_tombstone ( Slapi_PBlock *pb, Slapi_Entry *entry );
PRBool get_tombstone_csn(const Slapi_Entry *entry, const CSN **delcsn);
