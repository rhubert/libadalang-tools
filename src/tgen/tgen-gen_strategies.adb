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

with Ada.Calendar;
with Ada.Characters.Latin_9;
with Ada.Characters;
with Ada.Directories;
with Ada.Strings.Fixed;
with Ada.Strings.Maps;
with Ada.Strings.Wide_Wide_Unbounded; use Ada.Strings.Wide_Wide_Unbounded;
with Ada.Text_IO;
with Ada.Wide_Wide_Text_IO;           use Ada.Wide_Wide_Text_IO;

with GNAT.Calendar;
with GNAT.OS_Lib; use GNAT.OS_Lib;

with Libadalang.Common; use Libadalang.Common;

with Templates_Parser; use Templates_Parser;

with TGen.Gen_Types_Value;   use TGen.Gen_Types_Value;
with TGen.Files;             use TGen.Files;
with TGen.Strings;           use TGen.Strings;
with TGen.Types.Translation; use TGen.Types.Translation;
with TGen.Types;             use TGen.Types;

package body TGen.Gen_Strategies is

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Context    : in out Generation_Context;
      Project    : Project_Type;
      Output_Dir : Unbounded_String) is
   begin
      Context.Output_Dir := Output_Dir;
      Context.Project := Project;
      Prepare_Output_Dirs (Context);
   end Initialize;

   --------------
   -- Finalize --
   --------------

   procedure Generate_Artifacts (Context : in out Generation_Context) is
   begin
      if not Context.Codegen_Required then
         --  Fully static test value generation is ON

         Dump_JSON (Context);
         return;
      end if;

      for Package_Data of Context.Packages_Data loop
         declare
            Strat_Generator : constant Strategy_Generator.Strat_Generator :=
              Strategy_Generator.Create
                (Context, Package_Data);
         begin
            Strat_Generator.Generate_Source_Code (Context);
         end;
      end loop;
      Generate_Type_Strategies (Context);
   end Generate_Artifacts;

   package body Strategy_Generator is

      function Create
        (Context : Generation_Context;
         Pkg_Data : Package_Data)
         return Strat_Generator
      is
         use type Ada.Calendar.Time;

         Strat_Template_File_ADS : Virtual_File :=
           Get_Template_Strat_ADS;

         Strat_Template_File_ADB : Virtual_File :=
           Get_Template_Strat_ADB;

      begin
         if Strat_Template_File_ADS.File_Time_Stamp = GNAT.Calendar.No_Time
            or else
            Strat_Template_File_ADB.File_Time_Stamp = GNAT.Calendar.No_Time
         then
            raise Program_Error with "Template file does not exists.";
         end if;

         declare
            use GNATCOLL.VFS;

            Strat_Source_File_ADS : Virtual_File :=
              Gen_File
                (Context,
                 Unit_To_Filename
                   (Context.Project,
                    Param_Strat_Package_Name
                      (+Pkg_Data.Pkg_Name.P_Fully_Qualified_Name),
                    Unit_Spec));

            Strat_Source_File_ADB : Virtual_File :=
              Gen_File
                (Context,
                 Unit_To_Filename
                   (Context.Project,
                    Param_Strat_Package_Name
                      (+Pkg_Data.Pkg_Name.P_Fully_Qualified_Name),
                   Unit_Body));

            Strat_ADS_File_Descriptor : constant GNAT.OS_Lib.File_Descriptor :=
              GNAT.OS_Lib.Create_File
                (+Strat_Source_File_ADS.Full_Name, GNAT.OS_Lib.Text);
            pragma Unreferenced
              (Strat_ADS_File_Descriptor);

         begin
            return Strat_Generator'
              (Strat_Source_File_ADS,
               Strat_Source_File_ADB,
               Strat_Template_File_ADS,
               Strat_Template_File_ADB,
               Pkg_Data);
         end;

      end Create;

      --------------------------------------
      -- Create_Param_Id_Table_Translator --
      --------------------------------------

      function Create_Param_Strategy_Translator
        (Pkg_Data : Package_Data;
         Next            : access constant Translator'Class := null)
         return Param_Strategy_Translator
      is ((Next, Pkg_Data));

      ----------------------
      -- Translate_Helper --
      ----------------------

      overriding
      procedure Translate_Helper
        (Self            : Param_Strategy_Translator;
         Table           : in out Templates_Parser.Translate_Set)
      is
         use type Templates_Parser.Vector_Tag;

         Param_Strategy_Tag : constant String := "PARAM_STRATEGY";

         Param_Strategy_Vector_Tag : Templates_Parser.Vector_Tag;

         With_Clauses : String_Sets.Set;

         With_Clauses_Tag : constant String := "WITH_CLAUSES";

         With_Clauses_Vector_Tag : Templates_Parser.Vector_Tag;

         procedure Gen_Strategies (Subp_Data : Subprogram_Data);

         procedure Gen_Strategies (Subp_Data : Subprogram_Data)
         is
         begin
            for Param of Subp_Data.Parameters_Data loop
               declare
                  Fun_Name : String :=
                    Gen_Param_Function_Name (Subp_Data, Param);

                  Fun_Return : String :=
                    " return " & (+To_Text (Param.Type_Fully_Qualified_Name));

                  Type_Gen_Package : String :=
                    Type_Strat_Package_Name
                      (+To_Text (Param.Type_Parent_Package));
                  Fun_Body : String :=
                    " renames "
                    & Type_Gen_Package & "."
                    & Param.Type_Repr.Get.Gen_Random_Function_Name;
               begin

                  if not With_Clauses.Contains (Type_Gen_Package) then
                     With_Clauses.Insert (Type_Gen_Package);
                  end if;
                  Templates_Parser.Append
                    (Param_Strategy_Vector_Tag,
                        "function " & Fun_Name & " " & Fun_Return
                        & Fun_Body & ";");
               end;
            end loop;
         end Gen_Strategies;

      begin

         for Subp_Data of Self.Pkg_Data.Subprograms loop
            Gen_Strategies (Subp_Data);
         end loop;

         for With_Clause of With_Clauses loop
            Templates_Parser.Append
              (With_Clauses_Vector_Tag,
               "with " & With_Clause & ";");
         end loop;

         Templates_Parser.Insert
           (Table,
            Templates_Parser.Assoc
              (With_Clauses_Tag, With_Clauses_Vector_Tag));

         Templates_Parser.Insert
           (Table,
            Templates_Parser.Assoc
              (Param_Strategy_Tag, Param_Strategy_Vector_Tag));
      end Translate_Helper;

      function Strat_Text_Template
        (Self : Strat_Generator) return Text_Type;

      -------------------------
      -- Strat_Text_Template --
      -------------------------

      function Strat_Text_Template
        (Self : Strat_Generator) return Text_Type
      is
         use GNATCOLL.VFS;

         PS   : aliased constant Param_Strategy_Translator :=
           Create_Param_Strategy_Translator
             (Self.Pkg_Data);

         Package_Name_Tag : constant String := "PACKAGE_NAME";

         Table : Templates_Parser.Translate_Set;

      begin
         PS.Translate (Table);

         --  All the tables are translated. Now translate the individual
         --  tags.

         Templates_Parser.Insert
           (Table,
            Templates_Parser.Assoc
              (Package_Name_Tag,
               (+Self.Pkg_Data.Pkg_Name.F_Package_Name
                .P_Fully_Qualified_Name)));

         return
           To_Text
             (Templates_Parser.Parse
                (Filename          => +Self.Strat_Template_File_ADS.Full_Name,
                 Translations      => Table,
                 Cached            => True,
                 Keep_Unknown_Tags => True));
      end Strat_Text_Template;

      overriding
      procedure Generate_Source_Code
        (Self    : Strat_Generator;
         Ctx : TGen.Templates.Context'Class) is
         use GNATCOLL.VFS;

         Strat_Context : constant Analysis_Context := Create_Context;
         Strat_Unit    : constant Analysis_Unit :=
           Strat_Context.Get_From_File (+Self.Strat_Source_File_ADS.Full_Name);

         --  RW_Context_Handle : Rewriting_Handle :=
         --    Start_Rewriting (Strat_Context);
         --  RW_Unit_Handle    : constant Unit_Rewriting_Handle :=
         --    Handle (Strat_Unit);
         --
         --  Strat_Unit_Root_Node : constant Node_Rewriting_Handle :=
         --    Create_From_Template
         --      (Handle    => RW_Context_Handle,
         --       Template  => Self.Strat_Text_Template,
         --       Arguments => (1 .. 0 => No_Node_Rewriting_Handle),
         --       Rule      => Compilation_Unit_Rule);

         Strat_Writable_File : Writable_File :=
           Write_File (Self.Strat_Source_File_ADS);

      begin
         --  Set_Root (RW_Unit_Handle, Strat_Unit_Root_Node);
         --
         --  if Apply (RW_Context_Handle).Success then
         --     null;
         --  else
         --     raise Program_Error;
         --  end if;

         Write
           (Strat_Writable_File,
            To_UTF8 (Self.Strat_Text_Template)
            & Ada.Characters.Latin_9.LF);

         Close (Strat_Writable_File);
      end Generate_Source_Code;
   end Strategy_Generator;

   ----------------------------------
   -- Distinct_Type_Parent_Package --
   ----------------------------------

   function Distinct_Type_Parent_Package
     (Parameters_Data : Parameters_Data_Vector)
         return String_Ordered_Set
   is
      S : String_Ordered_Set;

   begin
      for Data of Parameters_Data loop
         if not S.Contains
           (To_UTF8 (To_Text (Data.Type_Parent_Package)))
         then
            S.Insert (To_UTF8 (To_Text (Data.Type_Parent_Package)));
         end if;
      end loop;

      return S;
   end Distinct_Type_Parent_Package;

   function Distinct_Type_Parent_Package
     (Subprogram_Data : Subprograms_Data_Vector)
      return String_Ordered_Set
   is
      S : String_Ordered_Set;
   begin
      for Subprogram of Subprogram_Data loop
         S.Union (Distinct_Type_Parent_Package (Subprogram.Parameters_Data));
      end loop;
      return S;
   end Distinct_Type_Parent_Package;

   ------------------------------
   -- Generate_Type_Strategies --
   ------------------------------

   procedure Generate_Type_Strategies
     (Context : Generation_Context) is
      use Type_Vectors_Maps;
   begin
      --  for Typ in Context.Required_Type_Strategies.Iterate loop
      --     declare
      --        TSG : constant Type_Strategy_Generator.Type_Strat_Generator :=
      --          Type_Strategy_Generator.Create
      --            (Gen_File
      --               (Context,
      --                Unit_To_File_Name
      --                  (Type_Strat_Package_Name
      --                       (+Type_Vectors_Maps.Key (Typ))) & ".ads"),
      --             Get_Template_Type_Strat_ADS,
      --             Element (Typ));
      --     begin
      --        TSG.Generate_Source_Code (Context);
      --     end;
      --  end loop;
      for C in Context.Required_Type_Strategies.Iterate loop
         declare
            Pkg_Name : Unbounded_String :=
              +Type_Strat_Package_Name (+Type_Vectors_Maps.Key (C));

            Types : Typ_Set := Element (C);
            --  All types for which we should generate generation function

            Type_Depends : Typ_Set;
            --  All the type dependencies we need to generate an object of
            --  any of the given types in Types.

         begin
            for T of Types loop
               Type_Depends.Union (Get_All_Types (T.Get));
            end loop;
            declare
               TSG : constant Type_Value_Generator :=
                 Create
                   (Pkg_Name,
                    Types,
                    Type_Depends);
            begin
               TSG.Generate_Source_Code (Context);
            end;
         end;
      end loop;
   end Generate_Type_Strategies;

   package body Test_Generator is

      Ctx : Generation_Context;

      function Generate_Source_Code
        (Self    : Test_Generator;
         Ctx : TGen.Templates.Context'Class) return Wide_Wide_String
      is
         use type Ada.Containers.Count_Type;
         use GNATCOLL.VFS;

         TS : aliased constant Test_Translator :=
           Create_Test_Translator (Self.Subp);

         Proc_Name_Tag : constant String := "PROC_NAME";

         Proc_Qualified_Name_Tag : constant String := "PROC_QUALIFIED_NAME";

         Has_Params_Tag : constant String := "HAS_PARAMS";

         Precondition_Tag : String := "PRECONDITION_EXPRESSION";

         Table : Templates_Parser.Translate_Set;

      begin
         TS.Translate (Table);

         --  All the tables are translated. Now translate the individual
         --  tags.

         Templates_Parser.Insert
           (Table,
            Templates_Parser.Assoc
              (Proc_Name_Tag,
               +Self.Subp.Name));

         Templates_Parser.Insert
           (Table,
            Templates_Parser.Assoc
              (Proc_Qualified_Name_Tag,
               +Self.Subp.Fully_Qualified_Name));

         Templates_Parser.Insert
           (Table,
            Templates_Parser.Assoc
              (Has_Params_Tag,
               Self.Subp.Parameters_Data.Length > 0));

         Templates_Parser.Insert
           (Table,
            Templates_Parser.Assoc
              (Precondition_Tag,
               +Self.Subp.Precondition));

         return
           To_Text
             (Templates_Parser.Parse
                (Filename          => +Self.Test_Template_File.Full_Name,
                 Translations      => Table,
                 Cached            => True,
                 Keep_Unknown_Tags => True));
      end Generate_Source_Code;

      function Create
        (Test_Template_File  : GNATCOLL.VFS.Virtual_File;
         Subp                : Subprogram_Data)
         return Test_Generator
      is
      begin
         return Test_Generator'
           (Test_Template_File, Subp);
      end Create;

      function Create_Test_Translator
        (Subp : Subprogram_Data;
         Next  : access constant Translator'Class := null)
         return Test_Translator is
           (Next, Subp);

      procedure Translate_Helper
        (Self  : Test_Translator;
         Table : in out Templates_Parser.Translate_Set)
      is
         use type Templates_Parser.Vector_Tag;

         Strategy_Name_Tag : String := "STRATEGY_NAME";
         Strategy_Name_Vector_Tag : Templates_Parser.Vector_Tag;

         Type_Name_Tag : String := "TYPE_NAME";
         Type_Name_Vector_Tag : Templates_Parser.Vector_Tag;

         Gen_Subp_Name_Tag : String := "GEN_SUBP_NAME";
         Gen_Subp_Name_Vector_Tag : Templates_Parser.Vector_Tag;

         Param_Name_Tag : String := "PARAM_NAME";
         Param_Name_Vector_Tag : Templates_Parser.Vector_Tag;

      begin
         for Param of Self.Subp.Parameters_Data loop
            Templates_Parser.Append
              (Strategy_Name_Vector_Tag,
               Strat_Param_Name (Self.Subp, Param));
            Templates_Parser.Append
              (Type_Name_Vector_Tag,
               (+Param.Type_Fully_Qualified_Name));
            Templates_Parser.Append
              (Gen_Subp_Name_Vector_Tag,
               Gen_Param_Full_Function_Name (Self.Subp, Param));
            Templates_Parser.Append
              (Param_Name_Vector_Tag,
               (+Param.Name));
         end loop;

         Templates_Parser.Insert
           (Table,
            Templates_Parser.Assoc
              (Strategy_Name_Tag, Strategy_Name_Vector_Tag));
         Templates_Parser.Insert
           (Table,
            Templates_Parser.Assoc
              (Type_Name_Tag, Type_Name_Vector_Tag));
         Templates_Parser.Insert
           (Table,
            Templates_Parser.Assoc
              (Gen_Subp_Name_Tag, Gen_Subp_Name_Vector_Tag));
         Templates_Parser.Insert
           (Table,
            Templates_Parser.Assoc
              (Param_Name_Tag, Param_Name_Vector_Tag));
      end Translate_Helper;
   end Test_Generator;

   function Get_Parent_Package (Node : Ada_Node) return Package_Decl;

   function Get_Parent_Package (Node : Ada_Node) return Package_Decl is
      Parent_Node : Ada_Node := Node.P_Semantic_Parent;
   begin
      while not Parent_Node.Is_Null
        and then Kind (Parent_Node) /= Ada_Package_Decl
      loop
         Parent_Node := Parent_Node.P_Semantic_Parent;
      end loop;

      return Parent_Node.As_Package_Decl;
   end Get_Parent_Package;

   function Get_With_Clauses (Subp : Subprogram_Data) return String_Sets.Set;

   function Get_With_Clauses (Subp : Subprogram_Data) return String_Sets.Set
   is
      Res : String_Sets.Set;
   begin
      Res.Insert ("TGen.Stream");
      Res.Insert ("TGen.Engine");
      Res.Insert ("TGen.Strategies");
      Res.Insert (+Subp.Parent_Package);
      Res.Insert (Param_Strat_Package_Name (+Subp.Parent_Package));
      return Res;
   end Get_With_Clauses;

   function Indent (Amount : Natural; Str : String) return String is
      Res : Unbounded_String;
      Indent : String (1 .. Amount) := (others => ' ');
   begin
      Append (Res, Indent);
      for C of Str loop
         Append (Res, C);
         if C = Ada.Characters.Latin_9.LF then
            Append (Res, Indent);
         end if;
      end loop;
      return +Res;
   end Indent;

   function Number_Of_Lines (Str : String) return Natural is
   begin
      return Ada.Strings.Fixed.Count
        (Str,
         Ada.Strings.Maps.To_Set
           (Ada.Characters.Latin_9.LF)) + 1;
   end Number_Of_Lines;

   function Generate_Tests_For
     (Context  : in out Generation_Context;
      Nb_Tests : Positive;
      Subp     : Subp_Decl) return Generated_Body is

      Pkg : Package_Decl := Get_Parent_Package (Subp.As_Ada_Node);
      Pkg_Data : Package_Data;

      Res : Generated_Body;
   begin
      if Pkg.Is_Null then
         raise Program_Error with
           "Unable to find parent package of node "
           & Image (Subp.Full_Sloc_Image);
      end if;

      Pkg_Data.Pkg_Name := Pkg;

      if not Context.Packages_Data.Contains (Pkg_Data) then
         Context.Packages_Data.Insert (Pkg_Data);
      else
         Pkg_Data := Package_Data_Sets.Element
           (Context.Packages_Data.Find (Pkg_Data));
      end if;

      declare
         Subp_Data : Subprogram_Data :=
           Extract_Subprogram_Data (Subp);

         Test_Gen : Test_Generator.Test_Generator :=
           Test_Generator.Create
             (Test_Template_File => Get_Template_Test_ADB, Subp => Subp_Data);

      begin

         Res.Generated_Body :=
           Unbounded_Text_Type'
             (To_Unbounded_Wide_Wide_String
                (Test_Gen.Generate_Source_Code (Context)));

         Pkg_Data.Subprograms.Append (Subp_Data);
         Context.Packages_Data.Replace (Pkg_Data);

         --  Register parameters' type in the context

         for Param of Subp_Data.Parameters_Data loop
            declare

               Param_Type : SP.Ref := Param.Type_Repr;
               Type_Depends : Typ_Set := Get_All_Types (Param_Type.Get);
               Typ_Parent_Package : Unbounded_Text_Type :=
                 To_Unbounded_Text
                   (Param_Type.Get.Parent_Package_Name);

               procedure Add_To_Set
                 (Parent_Pkg_Name : Unbounded_Text_Type;
                  TS : in out Typ_Set);

               procedure Add_To_Set
                 (Parent_Pkg_Name : Unbounded_Text_Type;
                  TS : in out Typ_Set)
               is
               begin
                  if not TS.Contains (Param_Type) then
                     TS.Insert (Param_Type);
                  end if;
               end Add_To_Set;

            begin
               if not Context.Required_Type_Strategies.
                 Contains (Typ_Parent_Package)
               then
                  Context.Required_Type_Strategies.Insert
                    (Typ_Parent_Package, Typ_Sets.Empty);
               end if;
               Context.Required_Type_Strategies.Update_Element
                 (Context.Required_Type_Strategies.Find
                    (Typ_Parent_Package),
                  Add_To_Set'Access);
            end;
         end loop;

         Res.With_Clauses := Get_With_Clauses (Subp_Data);

      end;

      return Res;

   end Generate_Tests_For;

   procedure Dump_JSON
     (Context : Generation_Context) is
      use Unit_To_JSON_Maps;
   begin
      for Unit_JSON_Cursor in Context.Test_Vectors.Iterate loop
         declare
            File : constant Virtual_File :=
              Get_JSON_Name (Context, +Key (Unit_JSON_Cursor));
            JSON_Unit_FD : constant GNAT.OS_Lib.File_Descriptor :=
              GNAT.OS_Lib.Create_File
                (+Full_Name (File), GNAT.OS_Lib.Text);
            pragma Unreferenced (JSON_Unit_FD);

            JSON_Unit_Writable_File : Writable_File :=
              Write_File (File);
         begin
            Write
              (JSON_Unit_Writable_File,
               Write (Create (Element (Unit_JSON_Cursor))));
            Close (JSON_Unit_Writable_File);
         end;
      end loop;
   end Dump_JSON;

   procedure Generate_Test_Vectors
     (Context  : in out Generation_Context;
      Nb_Tests : Positive;
      Subp     : Subprogram_Data;
      Subp_UID : Unbounded_String := Null_Unbounded_String)
   is
      Function_JSON     : JSON_Value := Create_Object;
      Test_Vectors_JSON : JSON_Array := Empty_Array;
      Test_Vector_JSON : JSON_Array;
      Disc_Context : Disc_Value_Map;
   begin
      for J in 1 .. Nb_Tests loop
         Test_Vector_JSON := Empty_Array;
         for Param of Subp.Parameters_Data loop
            declare
               Param_JSON : JSON_Value := Create_Object;
            begin
               Param_JSON.Set_Field ("name", Create (+Param.Name));
               Param_JSON.Set_Field ("type_name", Create (+Param.Type_Name));
               Param_JSON.Set_Field
                 ("value", Param.Type_Repr.Get.Generate_Static (Disc_Context));
               Append (Test_Vector_JSON, Param_JSON);
            end;
         end loop;
         if not Is_Empty (Test_Vector_JSON) then
            Append (Test_Vectors_JSON, Create (Test_Vector_JSON));
         end if;
      end loop;

      Function_JSON.Set_Field
        ("fully_qualified_name", +Subp.Fully_Qualified_Name);
      Function_JSON.Set_Field ("package_name", +Subp.Parent_Package);
      Function_JSON.Set_Field ("UID", +Subp_UID);
      if Subp.Kind = Ada_Subp_Kind_Function then
         Function_JSON.Set_Field
           ("return_type", Create (+Subp.Return_Type_Fully_Qualified_Name));
      end if;
      Function_JSON.Set_Field ("values", Test_Vectors_JSON);

      if not Context.Test_Vectors.Contains (Subp.Parent_Package) then
         Context.Test_Vectors.Insert (Subp.Parent_Package, Empty_Array);
      end if;

      declare

         procedure Add_Function_Testing
           (Unit_Name  : Unbounded_Text_Type;
            Unit_Tests : in out JSON_Array);

         procedure Add_Function_Testing
           (Unit_Name  : Unbounded_Text_Type;
            Unit_Tests : in out JSON_Array) is
         begin
            Append (Unit_Tests, Function_JSON);
         end Add_Function_Testing;

      begin
         Context.Test_Vectors.Update_Element
           (Context.Test_Vectors.Find (Subp.Parent_Package),
            Add_Function_Testing'Access);
      end;
   end Generate_Test_Vectors;

end TGen.Gen_Strategies;
