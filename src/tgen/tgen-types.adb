------------------------------------------------------------------------------
--                                                                          --
--                                  TGen                                    --
--                                                                          --
--                       Copyright (C) 2022, AdaCore                        --
--                                                                          --
-- TGen  is  free software; you can redistribute it and/or modify it  under --
-- under  terms of  the  GNU General  Public License  as  published by  the --
-- Free  Software  Foundation;  either version 3, or  (at your option)  any --
-- later version. This software  is distributed in the hope that it will be --
-- useful but  WITHOUT  ANY  WARRANTY; without even the implied warranty of --
-- MERCHANTABILITY  or  FITNESS  FOR A PARTICULAR PURPOSE.                  --
--                                                                          --
-- As a special  exception  under  Section 7  of  GPL  version 3,  you are  --
-- granted additional  permissions described in the  GCC  Runtime  Library  --
-- Exception, version 3.1, as published by the Free Software Foundation.    --
--                                                                          --
-- You should have received a copy of the GNU General Public License and a  --
-- copy of the GCC Runtime Library Exception along with this program;  see  --
-- the files COPYING3 and COPYING.RUNTIME respectively.  If not, see        --
-- <http://www.gnu.org/licenses/>.                                          --
------------------------------------------------------------------------------

with Ada.Strings.Fixed;

with Langkit_Support.Text;

package body TGen.Types is

   use LAL;
   package Text renames Langkit_Support.Text;

   -----------
   -- Image --
   -----------

   function Image (Self : Typ) return String is
   begin
      return (if Self.Name = No_Defining_Name
              then "Anonymous"
              else Text.Image (Self.Name.Text));
   end Image;

   ----------
   -- Kind --
   ----------

   function Kind (Self : Typ) return Typ_Kind is (Invalid_Kind);

   -----------
   -- Image --
   -----------

   function Image (Self : Access_Typ) return String is
     (Typ (Self).Image & ": access type");

   ---------------
   -- Lit_Image --
   ---------------

   function Lit_Image
     (Self : Discrete_Typ; Lit : Big_Integer) return String is
     (Big_Int.To_String (Lit));

   ---------------
   -- Low_Bound --
   ---------------

   function Low_Bound (Self : Discrete_Typ) return Big_Integer is
     (Big_Zero);

   ----------------
   -- High_Bound --
   ----------------

   function High_Bound (Self : Discrete_Typ) return Big_Integer is
     (Big_Zero);

   ------------------
   -- Package_Name --
   ------------------

   function Package_Name (Self : Typ) return String is
      Type_Parent_Package : constant Text_Type :=
        Self.Name.P_Top_Level_Decl (Self.Name.Unit).P_Defining_Name.Text;
   begin
      return Image (Type_Parent_Package);
   end Package_Name;

   -----------------------
   -- Dot_To_Underscore --
   -----------------------

   function Dot_To_Underscore (C : Character) return Character is
     ((if C = '.' then '_' else C));

   ---------------------
   -- Generate_Static --
   ---------------------

   function Generate_Static (Self : Typ) return String is
   begin
      raise Program_Error with "Static strategy not implemented";
      return "";
   end Generate_Static;

   ----------
   -- Slug --
   ----------

   function Slug (Self : Typ) return String is
   begin
      return Ada.Strings.Fixed.Translate
        (Source => To_UTF8 (Self.Name.P_Fully_Qualified_Name),
         Mapping => Dot_To_Underscore'Access);
   end Slug;

   ------------------
   -- Free_Content --
   ------------------

   procedure Free_Content_Wide (Self : in out Typ'Class) is
   begin
      Self.Free_Content;
   end Free_Content_Wide;

end TGen.Types;
