-- CE2102Y.ADA

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
--     CHECK THAT USE_ERROR IS RAISED IF AN IMPLEMENTATION DOES NOT
--     SUPPORT DELETION OF AN EXTERNAL DIRECT FILE.

-- APPLICABILITY CRITERIA:
--     THIS TEST IS APPLICABLE ONLY TO IMPLEMENTATIONS WHICH SUPPORT
--     CREATION OF A DIRECT FILE WITH OUT_FILE MODE.

-- HISTORY:
--     TBN 09/15/87  CREATED ORIGINAL TEST.

with Direct_Io;
with Report; use Report;
procedure Ce2102y is
   Incomplete : exception;
begin
   Test
     ("CE2102Y",
      "CHECK THAT USE_ERROR IS RAISED IF AN " &
      "IMPLEMENTATION DOES NOT SUPPORT DELETION " &
      "OF AN EXTERNAL DIRECT FILE");
   declare
      package Dir is new Direct_Io (Integer);
      use Dir;
      File1 : File_Type;
      Int1  : Integer := Ident_Int (1);
   begin
      begin
         Create (File1, Out_File, Legal_File_Name);
      exception
         when Use_Error =>
            Not_Applicable
              ("USE_ERROR RAISED ON CREATE OF " &
               "DIRECT FILE WITH OUT_FILE MODE");
            raise Incomplete;
         when Name_Error =>
            Not_Applicable
              ("NAME_ERROR RAISED ON CREATE OF " &
               "DIRECT FILE WITH OUT_FILE MODE");
            raise Incomplete;
      end;

      Write (File1, Int1);
      begin
         Delete (File1);
         Comment ("DELETION OF AN EXTERNAL DIRECT FILE IS " & "ALLOWED");
      exception
         when Use_Error =>
            Comment
              ("DELETION OF AN EXTERNAL DIRECT " & "FILE IS NOT ALLOWED");
         when others =>
            Failed
              ("UNEXPECTED EXCEPTION RAISED WHILE " &
               "DELETING AN EXTERNAL FILE");
      end;

   exception
      when Incomplete =>
         null;
   end;

   Result;
end Ce2102y;
