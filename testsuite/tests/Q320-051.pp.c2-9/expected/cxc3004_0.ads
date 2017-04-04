-- CXC3004.A
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
--     Check that an exception propagated from a handler invoked by an
--     interrupt has no effect. Check that the exception causes further
--     execution of the handler to be abandoned.
--
-- TEST DESCRIPTION:
--     The test checks that, for protected procedures which have been attached
--     to interrupts statically, a user-defined exception which is raised in
--     the executable part has no effect outside the protected procedure. The
--     test also checks that the raising of the exception causes further
--     execution of the protected procedure to be abandoned.
--
--     An anonymous protected object Static_Handler is declared with a
--     pragma Attach_Handler which designates a procedure, and attaches
--     that procedure to the interrupt corresponding to
--     ImpDef.Annex_C.Generate_Interrupt.
--
--     The test proceeds as follows:
--
--     (1)  The interrupt corresponding to ImpDef.Annex_C.Interrupt_To_Generate
--          is generated by calling ImpDef.Annex_C.Generate_Interrupt. This
--          call is is made within a block statement which possesses an
--          exception handler.
--
--     (2)  Within the body of the procedure in Static_Handler, a user-defined
--          exception is raised by a raise statement.
--
--     (3)  The test verifies that the procedure in Static_Handler was indeed
--          called, and that the exception caused the execution of the
--          procedure to be abandoned.
--
--     (4)  The test verifies that the block statement's handler for the
--          user-defined exception is not executed.
--
--     In the protected object, boolean flags are used to determine whether
--     the interrupt handler was called, and whether its execution was
--     abandoned after the exception was raised.
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
--      31 Dec 97   EDS     Split test, placing dynamic case in CXC3009
--!

with Impdef.Annex_C;
package Cxc3004_0 is

   User_Exception : exception;

   protected Static_Handler is
      procedure Handle_Interrupt;
      pragma Attach_Handler
        (Handle_Interrupt,
         Impdef.Annex_C.Interrupt_To_Generate);

      function Handled return Boolean;
      function Abandoned return Boolean;
   private
      Was_Handled   : Boolean := False;
      Was_Abandoned : Boolean := True;
   end Static_Handler;

end Cxc3004_0;
