-- CD2D13A.ADA

--                             Grant of Unlimited Rights
--
--     Under contracts F33600-87-D-0337, F33600-84-D-0280, MDA903-79-C-0687,
--     F08630-91-C-0015, and DCA100-97-D-0025, the U.S. Government obtained
--     unlimited rights in the software and documentation contained herein.
--     Unlimited rights are defined in DFAR 252.227-7013(a)(19).  By making
--     this public release, the Government intends to confer upon all
--     recipients unlimited rights  equal to those held by the Government.
--     These rights include rights to use, duplicate, release or disclose the
--     released technical data and computer software in whole or in part, in
--     any manner and for any purpose whatsoever, and to have or permit others
--     to do so.
--
--                                    DISCLAIMER
--
--     ALL MATERIALS OR INFORMATION HEREIN RELEASED, MADE AVAILABLE OR
--     DISCLOSED ARE AS IS.  THE GOVERNMENT MAKES NO EXPRESS OR IMPLIED
--     WARRANTY AS TO ANY MATTER WHATSOEVER, INCLUDING THE CONDITIONS OF THE
--     SOFTWARE, DOCUMENTATION OR OTHER INFORMATION RELEASED, MADE AVAILABLE
--     OR DISCLOSED, OR THE OWNERSHIP, MERCHANTABILITY, OR FITNESS FOR A
--     PARTICULAR PURPOSE OF SAID MATERIAL.
--*
-- OBJECTIVE:
--     CHECK THAT A SMALL CLAUSE CAN BE GIVEN IN THE VISIBLE
--     OR PRIVATE PART OF A PACKAGE FOR A FIXED POINT TYPE DECLARED
--     IN THE VISIBLE PART.

-- HISTORY:
--     BCB 09/01/87  CREATED ORIGINAL TEST.
--     PWB 05/11/89  CHANGED EXTENSION FROM '.DEP' TO '.ADA'.

with System;
with Text_Io;
with Report; use Report;
procedure Cd2d13a is

   Specified_Small : constant := 2.0**(-4);

   package P is
      type Fixed_In_P is delta 1.0 range -4.0 .. 4.0;
      for Fixed_In_P'Small use Specified_Small;
      type Alt_Fixed_In_P is delta 1.0 range -4.0 .. 4.0;
   private
      for Alt_Fixed_In_P'Small use Specified_Small;
   end P;

   use P;

begin

   Test
     ("CD2D13A",
      "A SMALL CLAUSE CAN BE GIVEN IN THE VISIBLE " &
      "OR PRIVATE PART OF A PACKAGE FOR A FIXED " &
      "POINT TYPE DECLARED IN THE VISIBLE PART");

   if Fixed_In_P'Small /= Specified_Small then
      Failed ("INCORRECT VALUE FOR FIXED_IN_P'SMALL");
   end if;

   if Alt_Fixed_In_P'Small /= Specified_Small then
      Failed ("INCORRECT VALUE FOR ALT_FIXED_IN_P'SMALL");
   end if;

   Result;

end Cd2d13a;
