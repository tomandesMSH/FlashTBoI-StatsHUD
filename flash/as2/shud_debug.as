// ---------------- Stats HUD: TEST-ONLY hooks (built only with build.py --debug) ----------------
// F9: teleport to this floor's treasure room using the game's own room teleport (tar/telf).
// F8: next test item into ups[] (stat formulas only, no costume or pickup animation).
// F7: luck +1.  F6: lose this floor's devil room bonus, as when taking damage.
// F5: test state for the devil/angel chance (see below; changes the run, test builds only).
_root.createEmptyMovieClip("shudDebug",1048502);
_root.shudDebug.createTextField("st",1,4,440,632,36);
_root.shudDebug.st.textColor = 0xFFFF00;
_root.shudDebug.st.multiline = true;
_root.shudDebug.onEnterFrame = function()
{
   var _loc2_ = _root.a;
   if(Key.isDown(120))
   {
      if(!this.down9 && _root._currentframe == 2 && _root.boner != undefined)
      {
         _loc2_.tar = _root.boner;
         _loc2_.telf = _loc2_.fra + 2;
      }
      this.down9 = true;
   }
   else
   {
      this.down9 = false;
   }
   // Magic Mushroom, The Sad Onion, Cricket's Head, Polyphemus, The Small Rock, My Reflection, Sacred Heart, Pentagram
   if(Key.isDown(119))
   {
      if(!this.down8 && _root._currentframe == 2)
      {
         var _loc3_ = [12,1,4,169,90,5,182,51];
         this.cyc = isNaN(this.cyc) ? 0 : (this.cyc + 1) % _loc3_.length;
         _loc2_.ups[_loc3_[this.cyc]] += 1;
         this.last = "gave item " + _loc3_[this.cyc];
      }
      this.down8 = true;
   }
   else
   {
      this.down8 = false;
   }
   if(Key.isDown(118))
   {
      if(!this.down7)
      {
         _root.luck += 1;
      }
      this.down7 = true;
   }
   else
   {
      this.down7 = false;
   }
   if(Key.isDown(117))
   {
      _root.devil = false;
   }
   // F5: pretend this is floor 5, no damage taken yet, a devil room was seen on floor 1 (devil/angel chance test)
   if(Key.isDown(116))
   {
      _root.chaps = 5;
      _root.devil = true;
      _root.lastdev = 1;
   }
   this.st.text = "fire=" + _root.firra + " firrb=" + _root.firrb + " firrr=" + _root.firrr + " playsp=" + _root.playsp + " chaps=" + _root.chaps + " devil=" + _root.devil + " lastdev=" + _root.lastdev + " evs=" + _root.evs + " altsat=" + _root.altsat + "\n" + this.last;
};
