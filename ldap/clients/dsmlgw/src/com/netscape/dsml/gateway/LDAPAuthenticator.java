/* --- BEGIN COPYRIGHT BLOCK ---
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
 * Copyright (C) 2005 Red Hat, Inc.
 * All rights reserved.
 * --- END COPYRIGHT BLOCK --- */
package com.netscape.dsml.gateway;

import netscape.ldap.*;
/**
 *
 * @author  elliot
 */
public class LDAPAuthenticator {
    
    String DN = null;
    String PW = null;
    
    
    /** Creates a new instance of LDAPAuthenticator */
    public LDAPAuthenticator(String username, String password) {
        DN = username;
        PW = password;
    }
    
   public int  authenticate() {
       
       if (DN == null && PW == null)
           return 0;
      
        LDAPConnection ldc = null;
        
        ProxyConnMgrFactory pmc = new ProxyConnMgrFactory();
        IConnectionManager ldap_pool= pmc.getInstance();
        
        ldc = ldap_pool.getLoginConnection();
     
        if (ldc != null) {
            try {
                ldc.authenticate( DN, PW );
            } catch ( LDAPException e ) {
                switch( e.getLDAPResultCode() ) {
                    case LDAPException.NO_SUCH_OBJECT:
                        // System.out.println( "The specified user does not exist." );
                        return LDAPException.NO_SUCH_OBJECT;
                        
                    case LDAPException.INVALID_CREDENTIALS:
                        // System.out.println( "Invalid password." );
                        return LDAPException.INVALID_CREDENTIALS;
                        
                    default:
                        // System.out.println( "Error number: " + e.getLDAPResultCode() );
                        // System.out.println( "Failed to authentice as " + DN );
                        return e.getLDAPResultCode() ;
                        
                }
            }
            // System.out.println( "Authenticated as " + DN );
            return 0;
        } else {
            
            // System.out.println( "Can't establish connection to LDAP server");
            return LDAPException.UNAVAILABLE ;
        }
   }
}
