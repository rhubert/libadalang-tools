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

with Libadalang.Analysis;
with Langkit_Support.Text;

with Ada.Containers;
with Ada.Containers.Hashed_Maps;
with Ada.Numerics.Big_Numbers.Big_Integers;
with Ada.Strings.Wide_Wide_Hash;
with Ada.Unchecked_Deallocation;

with GNATCOLL.JSON; use GNATCOLL.JSON;
with GNATCOLL.Refcount; use GNATCOLL.Refcount;

limited with Tgen.Types.Array_Types;
limited with Tgen.Types.Enum_Types;
limited with Tgen.Types.Int_Types;
limited with TGen.Types.Real_Types;
limited with Tgen.Types.Record_Types;
with TGen.Strings; use TGen.Strings;

package TGen.Types is

   package LAL renames Libadalang.Analysis;
   package Big_Int renames Ada.Numerics.Big_Numbers.Big_Integers;
   type Typ is tagged record
      Name : LAL.Defining_Name;
   end record;

   type Typ_Kind is (Invalid_Kind,
                     Signed_Int_Kind,
                     Mod_Int_Kind,
                     Bool_Kind,
                     Char_Kind,
                     Enum_Kind,
                     Float_Kind,
                     Fixed_Kind,
                     Decimal_Kind,
                     Ptr_Kind,
                     Unconstrained_Array_Kind,
                     Constrained_Array_Kind,
                     Disc_Record_Kind,
                     Non_Disc_Record_Kind,
                     Anonymous_Kind,
                     Unsupported);

   subtype Discrete_Typ_Range is Typ_Kind range Signed_Int_Kind .. Enum_Kind;

   subtype Real_Typ_Range is Typ_Kind range Float_Kind .. Fixed_Kind;

   subtype Array_Typ_Range is
     Typ_Kind range Unconstrained_Array_Kind .. Constrained_Array_Kind;

   subtype Record_Typ_Range
     is Typ_Kind range Disc_Record_Kind .. Non_Disc_Record_Kind;

   subtype Big_Integer is Big_Int.Big_Integer;

   function Hash (Name : LAL.Defining_Name) return Ada.Containers.Hash_Type is
     (Ada.Strings.Wide_Wide_Hash (Name.Text));

   function Equivalent_Keys (Left, Right : LAL.Defining_Name) return Boolean is
     (Left.Text = Right.Text);

   package Disc_Value_Maps is new Ada.Containers.Hashed_Maps
     (Key_Type        => LAL.Defining_Name,
      Element_Type    => Big_Integer,
      Hash            => Hash,
      Equivalent_Keys => Equivalent_Keys,
      "="             => Big_Int."=");
   subtype Disc_Value_Map is Disc_Value_Maps.Map;

   function Image (Self : Typ) return String;

   function Is_Anonymous (Self : Typ) return Boolean;

   function Fully_Qualified_Name (Self : Typ) return Text_Type is
     (Self.Name.P_Basic_Decl.P_Fully_Qualified_Name);

   function Parent_Package_Name (Self : Typ) return Text_Type is
     (Self.Name.P_Basic_Decl.P_Top_Level_Decl (Self.Name.Unit).
          P_Defining_Name.F_Name.Text);

   function Parent_Package_Fully_Qualified_Name
     (Self : Typ) return Text_Type
   is
     (Self.Name.P_Basic_Decl.P_Top_Level_Decl (Self.Name.Unit).
          P_Fully_Qualified_Name);

   function Type_Name (Self : Typ) return Text_Type is
     (if Is_Null (Self.Name)
      then Langkit_Support.Text.To_Text ("anonymous")
      else Self.Name.F_Name.Text);

   function Gen_Random_Function_Name
     (Self : Typ) return String is
     ("Gen_" & Qualified_To_Unique_Name (Self.Fully_Qualified_Name));

   function "<" (L : Typ'Class; R : Typ'Class) return Boolean is
     (L.Name.P_Fully_Qualified_Name < R.Name.P_Fully_Qualified_Name);

   function Slug (Self : Typ) return String;
   --  Return a unique identifier for the type

   function Package_Name (Self : Typ) return String;
   --  Return the package name this type belongs to

   function Is_Constrained (Self : Typ) return Boolean is (False);
   --  An array type with indefinite bounds must be constrained, a discriminant
   --  record type must be constrained.

   function Generate_Random_Strategy (Self : Typ) return String is ("");

   function Generate_Constrained_Random_Strategy
     (Self : Typ) return String is ("")
     with Pre => Self.Is_Constrained;

   function Generate_Static
     (Self         : Typ;
      Disc_Context : Disc_Value_Map) return String;
   --  Generate statically a value of the given Typ and returns its string
   --  representation, so that it can be inlined in a program that want to use
   --  it. Default function returns an error. Derivation of this function
   --  should also generate an error if the type is not static.

   function Type_Image (Self : Typ) return String is ("");

   function Kind (Self : Typ) return Typ_Kind;

   procedure Free_Content (Self : in out Typ) is null;

   type Scalar_Typ (Is_Static : Boolean) is new Typ with null record;

   type Discrete_Typ is new Scalar_Typ with null record;

   function Low_Bound (Self : Discrete_Typ) return Big_Integer with
     Pre => Self.Is_Static;

   function High_Bound (Self : Discrete_Typ) return Big_Integer with
     Pre => Self.Is_Static;

   function Lit_Image (Self : Discrete_Typ; Lit : Big_Integer) return String;
   --  Returns the image of the Litteral whose "position" is Lit. For integer
   --  types, this is simply Lit'Image, for enum types, this correponds to
   --  the image of the enum litteral at position Lit.

   type Access_Typ is new Typ with null record;

   function Image (Self : Access_Typ) return String;

   type Composite_Typ is new Typ with null record;

   procedure Free_Content_Wide (Self : in out Typ'Class);

   package SP is new Shared_Pointers
     (Element_Type => Typ'Class, Release => Free_Content_Wide);

   function As_Discrete_Typ (Self : SP.Ref) return Discrete_Typ'Class is
     (Discrete_Typ'Class (Self.Unchecked_Get.all)) with
     Pre => (not SP.Is_Null (Self))
            and then (Self.Get.Kind in Discrete_Typ_Range);
   pragma Inline (As_Discrete_Typ);

   --  As_<Target>_Typ functions are useful to view a certain objetc of type
   --  Typ'Class wrapped in a smart pointer as a <Target>_Typ, and thus be able
   --  to access the components and primitives defined for that particular
   --  type. The return value is the object encapsulated in the smart pointer,
   --  so under no circumstances should it be freed.

   Big_Zero : constant Big_Integer :=
     Ada.Numerics.Big_Numbers.Big_Integers.To_Big_Integer (0);

   type Unsupported_Typ is new Typ with null record;

   function Kind (Self : Unsupported_Typ) return Typ_Kind is (Unsupported);

end TGen.Types;
