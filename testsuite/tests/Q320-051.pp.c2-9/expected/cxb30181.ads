-- CXB30181.A
--
--                             Grant of Unlimited Rights
--
--     The Ada Conformity Assessment Authority (ACAA) holds unlimited
--     rights in the software and documentation contained herein. Unlimited
--     rights are the same as those granted by the U.S. Government for older
--     parts of the Ada Conformity Assessment Test Suite, and are defined
--     in DFAR 252.227-7013(a)(19). By making this public release, the ACAA
--     intends to confer upon all recipients unlimited rights equal to those
--     held by the ACAA. These rights include rights to use, duplicate,
--     release or disclose the released technical data and computer software
--     in whole or in part, in any manner and for any purpose whatsoever, and
--     to have or permit others to do so.
--
--                                    DISCLAIMER
--
--     ALL MATERIALS OR INFORMATION HEREIN RELEASED, MADE AVAILABLE OR
--     DISCLOSED ARE AS IS. THE ACAA MAKES NO EXPRESS OR IMPLIED
--     WARRANTY AS TO ANY MATTER WHATSOEVER, INCLUDING THE CONDITIONS OF THE
--     SOFTWARE, DOCUMENTATION OR OTHER INFORMATION RELEASED, MADE AVAILABLE
--     OR DISCLOSED, OR THE OWNERSHIP, MERCHANTABILITY, OR FITNESS FOR A
--     PARTICULAR PURPOSE OF SAID MATERIAL.
--
--                                     Notice
--
--     The ACAA has created and maintains the Ada Conformity Assessment Test
--     Suite for the purpose of conformity assessments conducted in accordance
--     with the International Standard ISO/IEC 18009 - Ada: Conformity
--     assessment of a language processor. This test suite should not be used
--     to make claims of conformance unless used in accordance with
--     ISO/IEC 18009 and any applicable ACAA procedures.
--*
--
-- OBJECTIVE
--      See CXB30182.AM.
--
-- TEST DESCRIPTION
--      See CXB30182.AM.
--
-- TEST FILES:
--      This test consists of the following files:
--         CXB30180.C
--      -> CXB30181.A
--         CXB30182.AM
--
-- PASS/FAIL CRITERIA:
--      See CXB30182.AM.
--
-- CHANGE HISTORY:
--      26 Mar 2014    RLB     Created from skelton provided by STT.
--
--!

with Interfaces.C;                                          -- N/A => ERROR
with Impdef;
package Cxb30181 is

   Global : Interfaces.C.Int := 0 with
      Export,
      Convention    => C,                         -- N/A => ERROR
      External_Name => Impdef.Cxb30181_Global_External_Name;

   procedure Ada_Doubler
     (Inout1 : in out Interfaces.C.Int;
      Inout2 : in out Interfaces.C.Short;
      Inout3 : in out Interfaces.C.C_Float;
      Inout4 : in out Interfaces.C.Double) with
      Export,
      Convention    => C,                           -- N/A => ERROR
      External_Name => Impdef.Cxb30181_Proc_External_Name;
      -- Double the value of each of the parameters.

end Cxb30181;
