with Other_Package;

package My_Package is

   type Optional_Integer (Is_Set : Boolean := True) is record
      Value : Integer;
   end record;

   Positive_Middle : constant Positive := (Positive'Last - Positive'First) / 2;

   type X_Range is range 1 .. 10;
   type Y_Range is (One, Two, Three);
   type Y_Range_Array is array (Y_Range) of Integer;
   type Z_Range is range 1 .. 4;

   type Constrained_Array is array (X_Range, Y_Range, Z_Range) of Positive;
   CA1 : constant Constrained_Array :=
     (others => (others => (others => Positive'First)));
   CA2 : constant Constrained_Array :=
     (others => (others => (others => Positive_Middle)));
   CA3 : constant Constrained_Array :=
     (others => (others => (others => Positive'Last)));

   type Range_Constrained_Array is
     array
       (X_Range range 1 .. 10, Y_Range range One .. Two,
        Z_Range range 1 .. 2) of Positive;
   RCA1 : constant Range_Constrained_Array :=
     (others => (others => (others => Positive'First)));
   RCA2 : constant Range_Constrained_Array :=
     (others => (others => (others => Positive_Middle)));
   RCA3 : constant Range_Constrained_Array :=
     (others => (others => (others => Positive'Last)));

   type Bin_Op_Constrained_Array is
     array (1 .. 10, 1 .. 3, 1 .. 2) of Positive;
   BOCA1 : constant Bin_Op_Constrained_Array :=
     (others => (others => (others => Positive'First)));
   BOCA2 : constant Bin_Op_Constrained_Array :=
     (others => (others => (others => Positive_Middle)));
   BOCA3 : constant Bin_Op_Constrained_Array :=
     (others => (others => (others => Positive'Last)));

   type Mixed_Constrained_Array is
     array
       (X_Range, Y_Range range One .. Two,
        1 .. 2) of Optional_Integer (Is_Set => True);
   MCA1 : constant Mixed_Constrained_Array :=
     (others =>
        (others =>
           (others =>
              Optional_Integer'(Is_Set => True, Value => Positive'First))));
   MCA2 : constant Mixed_Constrained_Array :=
     (others =>
        (others =>
           (others =>
              Optional_Integer'(Is_Set => True, Value => Positive_Middle))));
   MCA3 : constant Mixed_Constrained_Array :=
     (others =>
        (others =>
           (others =>
              Optional_Integer'(Is_Set => True, Value => Positive'First))));

   type Unconstrained_Array is
     array (X_Range range <>, Y_Range range <>, Z_Range range <>) of Positive;
   UA1 : constant Unconstrained_Array :=
     (1 .. 1 => (One .. One => (1 .. 1 => 1)));
   --  TODO

   type Derived_Unconstrained_Array is new String;

   type Derived_Bin_Op_Unconstrained_Array is new String (1 .. 10);

   subtype Subtype_Unconstrained_Array is String;

   subtype Subtype_Bin_Op_Unconstrained_Array is String (1 .. 10);

   type Derived_Derived_Unconstrained_Array is new Derived_Unconstrained_Array;

   type Derived_Subtype_Bin_Op_Unconstrained_Array is
     new Subtype_Bin_Op_Unconstrained_Array;

   subtype Subtype_Private_Array is Other_Package.Private_Array;

   type Record_With_Arrays is record
      A : String (1 .. 10);
      B : Derived_Unconstrained_Array (1 .. 10);
      C : Unconstrained_Array (1 .. 1, One .. One, 1 .. 1);
      D : Subtype_Bin_Op_Unconstrained_Array;
   end record;

   type My_Index is (A);
   type My_Array is array (My_Index range <>) of Positive;
   B : constant My_Array := (A => 1);

   D : constant String (1 .. 0) := (others => <>);

end My_Package;
