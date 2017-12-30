-- C3A0009.A
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
--      Check that subprogram references may be passed as parameters using
--      access-to-subprogram types. Check that the passed subprograms may
--      be invoked from within the called subprogram.
--
-- TEST DESCRIPTION:
--      Declare an access to procedure type in a package specification.
--      Declare a root tagged type with the access to procedure type as a
--      component.  Declare three primitive procedures for the type that
--      can be referred to by the access to procedure type.  Use the access
--      to procedure type to initialize the component of a record.
--
--      Extend the root type with a private extension in the same package
--      specification. Declare two new primitive subprograms for the extension
--      (in addition to its three inherited subprograms).
--
--      In the main program, declare an operation for the root tagged type
--      which can be passed as an access value to change the initial value
--      of the component.  Call the inherited operations indirectly by
--      de-referencing the access value to set value in the extension.
--      Call the primitive function to modify the extension by passing
--      the access value designating the primitive procedure as a parameter.
--
--
-- CHANGE HISTORY:
--      06 Dec 94   SAIC    ACVC 2.0
--
--!

package C3a0009_0 is -- Push_Buttons

   type Button is tagged private;

   -- Type accesses to procedures Push and Default_Response
   type Button_Response_Ptr is access procedure (B : in out Button);

   procedure Push (B : in out Button);               -- to be inherited

   procedure Set_Response
     (B : in out Button;        -- to be inherited
      R : in     Button_Response_Ptr);

   procedure Default_Response (B : in out Button);  -- to be inherited

   type Alert_Button is new Button with private;  -- private extension of
   -- root tagged type
   -- Inherits procedure Push from Button Inherits procedure Set_Response from
   -- Button Inherits procedure Default_Response from Button

   procedure Replace_Action (B : in out Alert_Button);

   -- type accesses to procedure Default_Action
   type Button_Action_Ptr is access procedure;

   -- The following function is needed to set value in the extension's private
   -- component.
   function Alert (B : in Alert_Button) return Button_Action_Ptr;

private

   type Button is tagged                             -- root tagged type
   record
      Response : Button_Response_Ptr := Default_Response'Access;
   end record;

   procedure Default_Action;

   type Alert_Button is new Button with record
      Action : Button_Action_Ptr := Default_Action'Access;
   end record;

end C3a0009_0;
