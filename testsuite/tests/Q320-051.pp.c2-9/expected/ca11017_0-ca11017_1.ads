--=================================================================--

-- Public child added during code maintenance without disturbing a large
-- system. This public child would add functionality to the original system.

package Ca11017_0.Ca11017_1 is

   Position_Error : exception;

   function Equal_Length
     (Left  : in String_Rec;
      Right : in String_Rec) return Boolean;

   function Same_Content
     (Left  : in String_Rec;
      Right : in String_Rec) return Boolean;

   procedure Copy
     (From_The_Substring : in     Substring;
      To_The_String      : in out String_Rec);

   -- ... Various other operations used by the application.

end Ca11017_0.Ca11017_1;
