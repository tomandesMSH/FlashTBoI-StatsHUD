// ---------------- Stats HUD: Flash edition ----------------
// Compiled on its own (after the generated shud_data.as: glyph/icon tables built from the EID font and stat icons in
// resources/) by flash/tools/make_payload.py; the patcher inserts it into frame 1 of the game's root timeline, after
// the game's own script.
//
// Shows Isaac's current stats on the left side of the screen, like Repentance's "Found HUD":
// speed, tears, damage, range, shot speed, luck, devil room and angel room chance.
// When a stat changes, the difference is shown next to it for a moment (green up, red down).
// While a long EID Flash description reaches down to the stats, they fade out so both stay readable.
//
// Every value is read from or computed by the game's own code in the game clip _root.a (sprite 6765):
//  - speed:      _root.playsp, recomputed by the game every frame (playc)
//  - tears:      firr(), the game's fire delay function, on a scratch object; shown as shots per second
//                (30 fps, 30 / (delay + 1), Rebirth's convention). Dr. Fetus x3 + 10 as when firing.
//  - damage:     dmgdo(), the function every tear's damage comes from, with the tear's x1.15 for Cricket's Head,
//                Blood of the Martyr, Magic Mushroom and The Devil / Book of Belial (create(), tear type 2)
//  - range:      the game's range value _root.firrr (23 by default; the pause screen bar), from the tear height
//                and fall speed set in create() (Number One, Cain and Samson lower it), without its random
//                per-tear part
//  - shot speed: the tear speed multiplier from create() (clamped to 0.6 - 1.42, My Reflection x1.4)
//  - luck:       _root.luck
//  - devil / angel room: the roll made when the boss room door opens (the "sat" door in the room code)

_root.shudCfg = {scale:1.6, x:6, y:236, row:14, textX:18, alpha:85, deltaFrames:90, deltaFade:30};
_root.shudOn = true;
_root.shudAtlas = flash.display.BitmapData.loadBitmap("shud_atlas");
_root.shudTinted = {};
_root.shudColors = {text:0xFFFFFF, outline:0x000000, up:0x5FE65F, down:0xE65F5F};

function shudTint(color)
{
   var _loc2_ = _root.shudTinted[color];
   if(_loc2_ == undefined)
   {
      _loc2_ = _root.shudAtlas.clone();
      _loc2_.colorTransform(_loc2_.rectangle,new flash.geom.ColorTransform((color >> 16 & 255) / 255,(color >> 8 & 255) / 255,(color & 255) / 255,1,0,0,0,0));
      _root.shudTinted[color] = _loc2_;
   }
   return _loc2_;
}

function shudStrWidth(str)
{
   var _loc3_ = 0;
   var _loc2_ = 0;
   while(_loc2_ < str.length)
   {
      _loc3_ += _root.shudGlyph[str.charCodeAt(_loc2_)][6];
      _loc2_++;
   }
   return _loc3_;
}

function shudDrawString(canvas, str, x, y, color)
{
   var _loc5_ = shudTint(color);
   var _loc2_ = 0;
   var _loc3_;
   while(_loc2_ < str.length)
   {
      _loc3_ = _root.shudGlyph[str.charCodeAt(_loc2_)];
      if(_loc3_ != undefined)
      {
         if(_loc3_[2] > 0)
         {
            canvas.copyPixels(_loc5_,new flash.geom.Rectangle(_loc3_[0],_loc3_[1],_loc3_[2],_loc3_[3]),new flash.geom.Point(x + _loc3_[4],y + _loc3_[5]),null,null,true);
         }
         x += _loc3_[6];
      }
      _loc2_++;
   }
}

// text with a 1px dark outline, so it stays readable over walls and floors
function shudDrawText(canvas, str, x, y, color)
{
   var _loc2_ = -1;
   while(_loc2_ <= 1)
   {
      var _loc3_ = -1;
      while(_loc3_ <= 1)
      {
         if(_loc2_ != 0 || _loc3_ != 0)
         {
            shudDrawString(canvas,str,x + _loc2_,y + _loc3_,_root.shudColors.outline);
         }
         _loc3_++;
      }
      _loc2_++;
   }
   shudDrawString(canvas,str,x,y,color);
}

function shudDrawIcon(canvas, icon, rowTop)
{
   var _loc2_ = Math.floor((16 - icon[2]) / 2);
   var _loc1_ = rowTop + Math.floor((_root.shudCfg.row - icon[3]) / 2);
   canvas.copyPixels(_root.shudAtlas,new flash.geom.Rectangle(icon[0],icon[1],icon[2],icon[3]),new flash.geom.Point(_loc2_,_loc1_),null,null,true);
}

// AS2 has no Number.toFixed
function shudFixed(v, digits)
{
   var _loc3_ = Math.pow(10,digits);
   var _loc2_ = Math.round(Math.abs(v) * _loc3_);
   var _loc4_ = String(Math.floor(_loc2_ / _loc3_));
   if(digits > 0)
   {
      var _loc1_ = String(_loc2_ % _loc3_);
      while(_loc1_.length < digits)
      {
         _loc1_ = "0" + _loc1_;
      }
      _loc4_ += "." + _loc1_;
   }
   return (v < 0 && _loc2_ > 0 ? "-" : "") + _loc4_;
}

// devil room chance of this floor: the game's roll when the boss room's devil door is checked
function shudDevilRoll(g)
{
   if(_root.chaps == 1 || _root.chaps >= 9 || _root.devil == 3)
   {
      return 0;
   }
   if(_root.devil == 2)
   {
      return 1;
   }
   var _loc1_ = Math.min(0.3,g.ups[51] * 0.2) + 0.01;
   if(_root.it == 2)
   {
      _loc1_ += 0.25;
   }
   if(_root.it == 38)
   {
      _loc1_ += 0.35;
   }
   if(_root.bumkill)
   {
      _loc1_ += 0.35;
   }
   if(g.bossdmg)
   {
      _loc1_ += 0.35;
   }
   if(_root.devil)
   {
      _loc1_ += 0.99;
   }
   if(_root.lastdev + 3 > _root.chaps)
   {
      _loc1_ *= 0.5;
   }
   if(_root.lastdev + 2 > _root.chaps)
   {
      _loc1_ *= 0.5;
   }
   return Math.min(1,_loc1_);
}

// [speed, tears, damage, range, shot speed, luck, devil %, angel %]
function shudStats(g)
{
   var _loc2_ = g.ups;
   // damage: dmgdo() changes a few of the game's variables; keep them, and leave out the per-shot parts
   // (Chemical Peel's left eye, Chocolate Milk's charge) so the value doesn't flicker
   var _loc6_ = [g.sob,_root.hat[11],g.chaf,g.chal,_root.firrb,g.f1];
   g.sob = 1;
   _root.hat[11] = false;
   g.chaf = 0;
   var _loc4_ = g.dmgdo();
   if(_loc2_[4] || g.doub || _loc2_[7] || _loc2_[12])
   {
      _loc4_ *= 1.15;
   }
   var _loc3_ = {};
   g.firr(_loc3_);
   g.sob = _loc6_[0];
   _root.hat[11] = _loc6_[1];
   g.chaf = _loc6_[2];
   g.chal = _loc6_[3];
   _root.firrb = _loc6_[4];
   g.f1 = _loc6_[5];
   var _loc5_ = _loc3_.fire;
   if(_loc2_[52])
   {
      _loc5_ = _loc5_ * 3 + 10;
   }
   var _loc7_ = (_loc2_[12] + _loc2_[30] + _loc2_[31] + _loc2_[29] + _loc2_[71] * 3 + _loc2_[101] + _loc2_[110] + _loc2_[121] + _loc2_[182] * 1.5 + _loc2_[197] + _loc2_[14] + _loc2_[189]) * 0.5;
   var _loc9_ = 23 + (_loc2_[12] - _loc2_[71] + _loc2_[30] + _loc2_[31] + _loc2_[29]) * 5 + _loc7_ * 5.5;
   // lower tears: Number One, else Cain or Samson (create(), before the range is computed)
   if(_loc2_[6])
   {
      _loc9_ -= 13;
   }
   else if(_root.skiner == 2)
   {
      _loc9_ -= 6;
   }
   else if(_root.skiner == 6)
   {
      _loc9_ -= 5;
   }
   var _loc8_ = 1 - (_loc2_[110] + _loc2_[108]) * 0.25 - 0.17 * (_loc2_[153] + _loc2_[16] + _loc2_[159] + _loc2_[169]) + _loc2_[143] * 0.2 + _loc2_[165] * 0.23 + _loc2_[176] * 0.16 + (_loc2_[183] + _loc2_[194]) * 0.16 - _loc2_[182] * 0.25;
   if(_root.skiner == 6)
   {
      _loc8_ += 0.31;
   }
   _loc8_ = Math.max(0.6,Math.min(_loc8_,1.42));
   if(_loc2_[5])
   {
      _loc8_ *= 1.4;
   }
   // angel room: a floor's devil room is replaced by the holy room (_root.altsat, a coin flip at the start of the
   // floor) if a devil room was seen before and no devil deal was ever taken. Until the room appears, the chance
   // is split evenly, without peeking at the coin flip.
   var _loc10_ = shudDevilRoll(g);
   var _loc11_ = 0;
   if(_root.devil == 2)
   {
      if(_root.altsat)
      {
         _loc11_ = _loc10_;
         _loc10_ = 0;
      }
   }
   else if(_root.evs == 0 && _root.lastdev > 0)
   {
      _loc10_ /= 2;
      _loc11_ = _loc10_;
   }
   return [_root.playsp,30 / (_loc5_ + 1),_loc4_,_loc9_,_loc8_,_root.luck,_loc10_ * 100,_loc11_ * 100];
}

function shudFormat(i, v)
{
   return i < 6 ? shudFixed(v,2) : shudFixed(v,1) + "%";
}

// draws row i of the stat column (icon + value)
function shudDrawRow(layer, i, text)
{
   var _loc2_ = i * _root.shudCfg.row;
   layer.canvas.fillRect(new flash.geom.Rectangle(0,_loc2_,layer.canvas.width,_root.shudCfg.row),0);
   shudDrawIcon(layer.canvas,_root.shudIcon[_root.shudStatNames[i]],_loc2_);
   shudDrawText(layer.canvas,text,_root.shudCfg.textX,_loc2_ + 1,_root.shudColors.text);
}

// "+0.30" / "-12.5%" next to the value, fading out
function shudShowDelta(layer, i, text, diff)
{
   var _loc2_ = layer["d" + i];
   var _loc3_ = (i < 6 ? shudFixed(diff,2) : shudFixed(diff,1) + "%");
   if(diff > 0)
   {
      _loc3_ = "+" + _loc3_;
   }
   _loc2_.bmp.fillRect(_loc2_.bmp.rectangle,0);
   shudDrawText(_loc2_.bmp,_loc3_,1,1,diff > 0 ? _root.shudColors.up : _root.shudColors.down);
   _loc2_._x = _root.shudCfg.textX + shudStrWidth(text) + 3;
   _loc2_.frames = _root.shudCfg.deltaFrames;
   _loc2_._alpha = 100;
   _loc2_._visible = true;
}

function shudCreateLayer()
{
   var _loc3_ = _root.createEmptyMovieClip("shudLayer",1048490);
   _loc3_.canvas = new flash.display.BitmapData(64,_root.shudStatNames.length * _root.shudCfg.row,true,0);
   _loc3_.createEmptyMovieClip("pic",1);
   _loc3_.pic.attachBitmap(_loc3_.canvas,1,"never",false);
   var _loc2_ = 0;
   while(_loc2_ < _root.shudStatNames.length)
   {
      var _loc1_ = _loc3_.createEmptyMovieClip("d" + _loc2_,10 + _loc2_);
      _loc1_.bmp = new flash.display.BitmapData(48,_root.shudCfg.row,true,0);
      _loc1_.attachBitmap(_loc1_.bmp,1,"never",false);
      _loc1_._y = _loc2_ * _root.shudCfg.row;
      _loc1_._visible = false;
      _loc2_++;
   }
   _loc3_._xscale = _loc3_._yscale = _root.shudCfg.scale * 100;
   _loc3_._x = _root.shudCfg.x;
   _loc3_._y = _root.shudCfg.y;
   _loc3_._alpha = _root.shudCfg.alpha;
   _loc3_._visible = false;
   _loc3_.shown = [];
}

shudCreateLayer();

_root.shudLayer.onEnterFrame = function()
{
   // F3 shows/hides the stats
   if(Key.isDown(114))
   {
      if(!this.f3Down)
      {
         _root.shudOn = !_root.shudOn;
      }
      this.f3Down = true;
   }
   else
   {
      this.f3Down = false;
   }
   var _loc4_ = _root.a;
   if(!_root.shudOn || _root._currentframe != 2 || _loc4_.player == undefined || _loc4_.ups == undefined || _loc4_.dmgdo == undefined)
   {
      this._visible = false;
      this.game = undefined;
      return undefined;
   }
   // a new game clip (new run, or back from the menu): take the values as they are, without change indicators
   var _loc6_ = this.game == _loc4_;
   this.game = _loc4_;
   var _loc5_ = shudStats(_loc4_);
   var _loc2_ = 0;
   while(_loc2_ < _loc5_.length)
   {
      var _loc3_ = shudFormat(_loc2_,_loc5_[_loc2_]);
      if(_loc3_ != this.shown[_loc2_])
      {
         if(_loc6_ && this.shown[_loc2_] != undefined)
         {
            shudShowDelta(this,_loc2_,_loc3_,parseFloat(_loc3_) - parseFloat(this.shown[_loc2_]));
         }
         else
         {
            this["d" + _loc2_]._visible = false;
         }
         this.shown[_loc2_] = _loc3_;
         shudDrawRow(this,_loc2_,_loc3_);
      }
      var _loc7_ = this["d" + _loc2_];
      if(_loc7_._visible)
      {
         _loc7_.frames--;
         if(_loc7_.frames <= 0)
         {
            _loc7_._visible = false;
         }
         else if(_loc7_.frames < _root.shudCfg.deltaFade)
         {
            _loc7_._alpha = _loc7_.frames / _root.shudCfg.deltaFade * 100;
         }
      }
      _loc2_++;
   }
   // EID Flash's description box (_root.eidLayer) can reach down to the stats: fade them out while it does
   var _loc8_ = _root.eidLayer;
   var _loc9_ = false;
   if(_loc8_._visible && _loc8_.canvas != undefined)
   {
      if(_loc8_.lastKey != this.eidKey || _loc8_.lastEntity != this.eidEntity)
      {
         this.eidKey = _loc8_.lastKey;
         this.eidEntity = _loc8_.lastEntity;
         var _loc10_ = _loc8_.canvas.getColorBoundsRect(0xFF000000,0,false);
         this.eidBottom = _loc8_._y + (_loc10_.y + _loc10_.height) * _loc8_._yscale / 100;
      }
      _loc9_ = this.eidBottom > this._y;
   }
   this._alpha = _loc9_ ? Math.max(0,this._alpha - 15) : Math.min(_root.shudCfg.alpha,this._alpha + 15);
   this._visible = this._alpha > 0;
};
// ---------------- end Stats HUD ----------------
