-- CC1307A.ADA

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
-- CHECK THAT SUBPROGRAM PARAMETERS MAY HAVE AN OPERATOR_SYMBOL DEFAULT, WHICH
-- LOOKS THE SAME AS A DEFAULT STRING PARAMETER.

-- DAT 9/8/81

with Report; use Report;

procedure Cc1307a is
begin
   Test
     ("CC1307A",
      "GENERIC SUBPROGRAM AND STRING DEFAULT PARAMETERS" &
      " MAY LOOK THE SAME");

   declare
      generic
         with function Cat (X, Y : String) return String is "&";
         S : String := "&";
      package Pk is
         Val : constant String := Cat (S, S);
      end Pk;

      package Pk1 is new Pk;
   begin
      if Pk1.Val /= "&&" then
         Failed ("INCORRECT GENERIC INSTANTIATION WITH DEFAULTS");
      end if;
   end;

   Result;
end Cc1307a;
