-- CXC3003.A
--
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
--
-- OBJECTIVE:
--     Check that when a protected object is finalized, for any of its
--     procedures that are attached to interrupts, the handler is detached.
--     Check that if the handler was attached by a pragma Attach_Handler,
--     the previous handler is restored.
--
-- TEST DESCRIPTION:
--     An anonymous protected object A is declared with a pragma
--     Interrupt_Handler. A protected type B is declared with a discriminant of
--     type Ada.Interrupts.Interrupt_ID, and a pragma Attach_Handler which
--     designates a procedure within the protected type to be attached to the
--     interrupt specified by the discriminant.
--
--     The test proceeds as follows:
--
--     (1) The procedure in A designated by the pragma Interrupt_Handler is
--         attached to the interrupt ImpDef.Annex_C.Interrupt_To_Generate
--         using the procedure Ada.Interrupts.Attach_Handler.
--
--     (2) Next, within a block statement, a protected object of the type B
--         is declared using ImpDef.Annex_C.Interrupt_To_Generate as the
--         discriminant. This causes the procedure designated by the pragma
--         Attach_Handler to be attached to the interrupt, overriding the
--         the previous handler.
--
--     (3) The test verifies that the handler in the protected object of type
--         B has not yet been called.
--
--     (4) The interrupt corresponding to ImpDef.Annex_C.Interrupt_To_Generate
--         is generated by calling ImpDef.Annex_C.Generate_Interrupt.
--
--     (5) The test verifies that the handler in the protected object of type
--         B was called.
--
--     (6) The block statement is then left, resulting in the finalization of
--         the protected object of type B. At this point the original handler
--         (that of object A) should be restored.
--
--     (7) The test verifies that the handler in the protected object A has
--         not yet been called.
--
--     (8) The interrupt is again generated by calling the procedure
--         ImpDef.Annex_C.Generate_Interrupt.
--
--     (9) The test verifies that the handler in protected object A was called.
--
-- SPECIAL REQUIREMENTS:
--      This test requires that interrupts be enabled, and that an
--      interrupt (identified by ImpDef.Annex_C.Interrupt_To_Generate)
--      be generated multiple times, at points designated by calls to
--      ImpDef.Annex_C.Generate_Interrupt.
--
-- APPLICABILITY CRITERIA:
--      This test is only applicable for implementations validating the
--      the Systems Programming Annex.
--
--
-- CHANGE HISTORY:
--      27 Oct 95   SAIC    Initial prerelease version.
--      23 Feb 96   SAIC    Updated ImpDef references to ImpDef.Annex_C.
--
--!

package Cxc3003_0 is

   protected Dynamic_Handler is
      procedure Handle_Interrupt;
      pragma Interrupt_Handler (Handle_Interrupt);

      function Handled return Boolean;
   private
      Was_Handled : Boolean := False;
   end Dynamic_Handler;

end Cxc3003_0;
