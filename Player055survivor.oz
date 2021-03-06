functor
import
   Input
   Browser
   Projet2019util
   OS
   System
export
   portPlayer:StartPlayer
define
   StartPlayer
   TreatStream
   Name = 'name001'

   %functions
   GetState
   Spawn
   Add
   GotHit
   ChangeMap
   Info
   IsBox
   DoAction
   AvoidBombs
   Random
   AddElem
   DeleteFirstElem
   BonusPath
   DeleteElem
   Move
   BestMove
   PositionBox
   PositionFloor
   ChooseBestPoint
in
   fun{StartPlayer ID}
      Stream Port OutputStream      
   in
      thread %% filter to test validity of message sent to the player
         OutputStream = {Projet2019util.portPlayerChecker Name ID Stream}
      end
      {NewPort Stream Port}
      thread
         Map
         in
         if Input.useExtention then Map = Input.map1
         else Map = Input.map
         end
	     {TreatStream OutputStream bombInfo(id:ID state:off pos:nil live:Input.nbLives spawn:nil nBomb:Input.nbBombs point:0 map:Map bomb:nil bonus:nil bonusPath:pt(x:0 y:0))}

      end
      Port
   end

   /*
   * If the bomber is out of the map and he has at least one life then spawn the bomber at the spawn position.
   * Otherwise the position and the ID are assigned at null
   */

   fun{Spawn BombInfo ID Pos}
      if (BombInfo.state == off) andthen (BombInfo.live > 0) then
         Pos = BombInfo.spawn
         ID = BombInfo.id
         {AdjoinAt {AdjoinAt BombInfo state on} pos Pos}
      else
         Pos = null
         ID = null
         BombInfo
      end      
   end

   /*
   * Add some bonus to the bomber (exemple: bomb, life or more points).
   */

   fun{Add BombInfo Type Option Result}
      case Type of 
         bomb then 
            Result = BombInfo.nBomb+Option
            {AdjoinAt BombInfo nBomb Result}
         [] point then 
            Result = BombInfo.point+Option
            {AdjoinAt BombInfo point Result}
         [] life then
            Result = BombInfo.live+Option
            {AdjoinAt BombInfo live Result}
         [] shield then BombInfo
      else BombInfo
      end
   end

   /*
   * Bomber has been hit.
   * Put him out of the map and decrease his lives.
   */

   fun{GotHit BombInfo ID Result}
      if BombInfo.state == off then
         ID = null
         Result = null
         BombInfo
      else
         local NewLife in
            ID = BombInfo.id
            NewLife = BombInfo.live-1
            Result = death(NewLife)
            {AdjoinAt {AdjoinAt BombInfo state off} live NewLife}
         end
      end
   end

   /*
   * Change the map
   */

   fun {ChangeMap Map Pos Type}
      fun{NewMap Map X Y}
      	 case Map of H|T then
      	    if Y > 1 then H|{NewMap T X Y-1}
      	    elseif Y == 1 then {NewMap H X 0}|T
      	    elseif X > 1 then H|{NewMap T X-1 0}
      	    elseif X == 1 then
      	       if Type == deleteBox then 0|T
                elseif Type == deleteBomb then 0|T
      	       end
      	    end
      	 end
      end
   in
	  {NewMap Map Pos.x Pos.y}
   end

   /*
   * Add an element to the list
   */

   fun{AddElem List Pos}
      if Pos == nil then nil
      else 
         case List of H|T then H|{AddElem T Pos}
         [] nil then Pos|nil
         else nil
         end
      end
   end

   /*
   * Delete an element from the list
   */

   fun{DeleteFirstElem List}
        case List of H|T then T
        [] nil then nil
        end
   end

   /*
   * Delete an element Elem from the list
   */

   fun{DeleteElem List Elem}
      case List of H|T then 
         case H of pos(x:X1 y:Y1) then
            case Elem of pos(x:X2 y:Y2) then
               if X1 == X2 andthen Y1 == Y2 then {DeleteElem List Elem}
               else H|{DeleteElem List Elem}
               end
            end
            else nil
         end
      [] nil then nil
      else nil
      end
   end

   /*
   * Check if a case is a floor, a box or a wall
   */

   fun{IsBox Map Pos}
      fun{CheckMap Map X Y}
      	 case Map of H|T then
      	    if Y > 1 then {CheckMap T X Y-1}
      	    elseif Y == 1 then {CheckMap H X 0}
      	    elseif X > 1 then {CheckMap T X-1 0}
      	    elseif X == 1 then
      	      if H == 1 orelse H == 2 orelse H == 3 then
                  false
               else 
                  true
      	      end
      	    end
         else  false
      	 end
      end
   in
	    {CheckMap Map Pos.x Pos.y}
   end

   /*
   * Manage different information. For exemple, the information about bombs or other players
   */

   fun{Info BombInfo Message}
      case Message of
         spawnPlayer(ID Pos) then
            BombInfo
      [] movePlayer(ID Pos) then
            BombInfo
      [] deadPlayer(ID) then
            BombInfo
      [] bombPlanted(Pos) then
            if {Abs Pos.x-BombInfo.pos.x} =< Input.fire then 
               {AdjoinAt BombInfo bomb {AddElem BombInfo.bomb Pos}} 
            else BombInfo
            end
      [] bombExploded(Pos) then
            {AdjoinAt BombInfo bomb {DeleteElem BombInfo.bomb Pos}} 
      [] boxRemoved(Pos) then
            {AdjoinAt BombInfo map {ChangeMap BombInfo.map Pos deleteBox}}
      else BombInfo   
      end
   end

   /*
   * Move the bomber according to the bomb position
   */

   fun{AvoidBombs BombInfo Bool}
	            case BombInfo.bomb of H|T then 
                  case H of pt(x:X1 y:Y1) then
		            case BombInfo.pos of pt(x:X2 y:Y2) then
		               if X1 == X2 andthen Y1 == Y2 then
		                    Bool = false
		                    {Random BombInfo Bool}
		               elseif X1 == X2 then
                        Bool = true
                        if {IsBox BombInfo.map pt(x:X2+1 y:Y2)} then move(pt(x:X2+1 y:Y2))
                        elseif {IsBox BombInfo.map pt(x:X2-1 y:Y2)} then move(pt(x:X2-1 y:Y2))
                        elseif Y2 - Y1 > 0 then 
                           if {IsBox BombInfo.map pt(x:X2 y:Y2+1)} then move(pt(x:X2 y:Y2+1))
                           else move(pt(x:X2 y:Y2-1))
                           end
                        elseif {IsBox BombInfo.map pt(x:X2 y:Y2-1)} then move(pt(x:X2 y:Y2-1))
                        else {Random BombInfo Bool}
                        end
		               elseif Y1 == Y2 then
                        Bool = true
                        if {IsBox BombInfo.map pt(x:X2 y:Y2+1)} then move(pt(x:X2 y:Y2+1))
                        elseif {IsBox BombInfo.map pt(x:X2 y:Y2-1)} then move(pt(x:X2 y:Y2-1))
                        elseif X2 - X1 > 0 then 
                           if {IsBox BombInfo.map pt(x:X2+1 y:Y2)} then move(pt(x:X2+1 y:Y2))
                           else  move(pt(x:X2-1 y:Y2))
                           end
                        elseif {IsBox BombInfo.map pt(x:X2-1 y:Y2)} then move(pt(x:X2-1 y:Y2))
                        else {Random BombInfo Bool}
                        end
		               elseif Y1 < Y2 then
                        Bool = true
                        if {IsBox BombInfo.map pt(x:X2 y:Y2+1)} then move(pt(x:X2 y:Y2+1))
                        elseif {IsBox BombInfo.map pt(x:X2-1 y:Y2)} andthen X1 > X2 then move(pt(x:X2-1 y:Y2))
                        elseif {IsBox BombInfo.map pt(x:X2+1 y:Y2)} andthen X1 < X2 then move(pt(x:X2+1 y:Y2))
			               elseif {IsBox BombInfo.map pt(x:X2 y:Y2-1)} then move(pt(x:X2 y:Y2-1))
                        else {Random BombInfo Bool}
			               end
		               elseif Y1 > Y2 then
                        Bool = true
                        if {IsBox BombInfo.map pt(x:X2 y:Y2-1)} then move(pt(x:X2 y:Y2-1))
                        elseif {IsBox BombInfo.map pt(x:X2-1 y:Y2)} andthen X1 > X2 then move(pt(x:X2-1 y:Y2))
                        elseif {IsBox BombInfo.map pt(x:X2+1 y:Y2)} andthen X1 < X2 then move(pt(x:X2+1 y:Y2))
			               elseif {IsBox BombInfo.map pt(x:X2 y:Y2+1)} then move(pt(x:X2 y:Y2+1))
                        else {Random BombInfo Bool}
			               end
                     elseif X1 > X2 then
                        Bool = true
                        if {IsBox BombInfo.map pt(x:X2+1 y:Y2)} then move(pt(x:X2+1 y:Y2))
                        elseif {IsBox BombInfo.map pt(x:X2 y:Y2-1)} andthen Y1 > Y2 then move(pt(x:X2 y:Y2-1))
                        elseif {IsBox BombInfo.map pt(x:X2 y:Y2+1)} andthen Y1 < Y2 then move(pt(x:X2 y:Y2+1))
			               elseif {IsBox BombInfo.map pt(x:X2-1 y:Y2)} then move(pt(x:X2-1 y:Y2))
                        else {Random BombInfo Bool}
			               end
                     elseif X1 < X2 then
                     Bool = true
                        if {IsBox BombInfo.map pt(x:X2-1 y:Y2)} then move(pt(x:X2-1 y:Y2))
                        elseif {IsBox BombInfo.map pt(x:X2 y:Y2-1)} andthen Y1 > 1 then move(pt(x:X2 y:Y2-1))
                        elseif {IsBox BombInfo.map pt(x:X2 y:Y2+1)} andthen Y1 < Y2 then move(pt(x:X2 y:Y2+1))
			               elseif {IsBox BombInfo.map pt(x:X2+1 y:Y2)} then move(pt(x:X2+1 y:Y2))
                        else {Random BombInfo Bool}
			               end
		                else
		                    Bool = true
		                    {Random BombInfo Bool}
		                end
                  end
		        end
         end
   end
   

   /*
   * Move the bomber randomly
   */

   fun{Random BombInfo Bool}
        local Result in
        Result = {OS.rand} mod 9
            if Result == 0 then 
               if BombInfo.nBomb > 0 andthen Bool then 
                    bomb(BombInfo.pos)
               else {Random BombInfo Bool}
               end
            elseif Result == 1  orelse Result == 5 then 
               case BombInfo.pos of pt(x:X y:Y) then
                  if {IsBox BombInfo.map pt(x:X y:(Y-1))} then move(pt(x:X y:(Y-1)))
                  else {Random BombInfo Bool}
                  end
               end
            elseif Result == 2 orelse Result == 6 then 
               case BombInfo.pos of pt(x:X y:Y) then
                  if {IsBox BombInfo.map pt(x:X y:(Y+1))} then move(pt(x:X y:(Y+1)))
                  else {Random BombInfo Bool}
                  end
               end
            elseif Result == 3 orelse Result == 7 then 
               case BombInfo.pos of pt(x:X y:Y) then
                  if {IsBox BombInfo.map pt(x:(X-1) y:Y)} then move(pt(x:(X-1) y:Y))
                  else {Random BombInfo Bool}
                  end
               end
            elseif Result == 4 orelse Result == 8 then 
               case BombInfo.pos of pt(x:X y:Y) then
                  if {IsBox BombInfo.map pt(x:(X+1) y:Y)} then move(pt(x:(X+1) y:Y))
                  else {Random BombInfo Bool}
                  end
               end
            end
        end
    end

   /*
   * Assign an action to the bomber: move or put a bomb
   * If the bomber is out of the map then assigne his action and hist ID to null
   */

   fun{DoAction BombInfo ID Action}
        if BombInfo.state == off then 
            ID = null
            Action = null
            BombInfo
        else
            ID = BombInfo.id
            if BombInfo.bomb \= nil then 
                local Bool in
                    Action = {AvoidBombs BombInfo Bool}
                end
            else Action = {Random BombInfo true}
            end
            case Action of move(Pos) then
                {AdjoinAt BombInfo pos Pos}
            [] bomb(Pos) then 
                {AdjoinAt {AdjoinAt BombInfo bomb {AddElem BombInfo.bomb Pos}} nBomb BombInfo.nBomb-1}
	         end
        end
    end
   
   %% bombInfo(id:ID state:State pos:Pos live:Live spawn:Spawn nBomb:NBomb point:Point map:Map bomb:Bomb bonus:Bonus bonusPath:bonusPath) 
   proc{TreatStream Stream BombInfo}
      case Stream of nil then skip
      [] getId(ID)|T then 
         ID = BombInfo.id
         {TreatStream T BombInfo}
      [] getState(ID State)|T then 
         ID = BombInfo.id
         State = BombInfo.state
         {TreatStream T BombInfo}
      [] assignSpawn(Pos)|T then 
         {TreatStream T {AdjoinAt {AdjoinAt BombInfo spawn Pos} pos Pos}}
      [] spawn(ID Pos)|T then 
         {TreatStream T {Spawn BombInfo ID Pos}}
      [] doaction(ID Action)|T then 
         {TreatStream T {DoAction BombInfo ID Action}}
      [] add(Type Option Result)|T then 
         {TreatStream T {Add BombInfo Type Option Result}}
      [] gotHit(ID Result)|T then
         {TreatStream T {GotHit BombInfo ID Result}}
      [] info(Message)|T then 
         {TreatStream T {Info BombInfo Message}}
      else {TreatStream Stream BombInfo}
      end
   end
   

end