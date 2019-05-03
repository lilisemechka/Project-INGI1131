functor
import
   Input
   Browser
   Projet2019util
   OS
export
   portPlayer:StartPlayer
define   
   StartPlayer
   TreatStream
   Name = 'namefordebug'

   %functions
   Spawn
   Add
   GotHit
   ChangePos
   ChangeMap
   Info
   IsBox
   DoAction
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
	     {TreatStream OutputStream bombInfo(id:ID state:off pos:nil live:Input.nbLives spawn:nil nBomb:Input.nbBombs point:0 map:Map) }
      end
      Port
   end

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
      end
   end

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

   fun{ChangePos ID Pos ListPlayer}
      case ListPlayer of
         H|T then
            if H.id == ID then player(id:ID pos:Pos)|T
            else H|{ChangePos ID Pos T}
            end
         [] nil then player(id:ID pos:Pos)|nil
      end
   end

   fun {ChangeMap Map Pos Type}

      fun{NewMap Map X Y}
      	 case Map of H|T then
      	    if Y > 1 then H|{NewMap T X Y-1}
      	    elseif Y == 1 then {NewMap H X 0}|T
      	    elseif X > 1 then H|{NewMap T X-1 0}
      	    elseif X == 1 then
      	       if Type == deleteBox then 0|T
                elseif Type == bomb then 5|T
                elseif Type == deleteBomb then 0|T
      	       end
      	    end
      	 end
      end
   in
      case Pos of pt(x:X y:Y) then
	  {NewMap Map X Y}
      end      
   end

   fun{Info BombInfo Message}
      case Message of
         spawnPlayer(ID Pos) then
            BombInfo
         [] movePlayer(ID Pos) then
            BombInfo
         [] deadPlayer(ID) then
            BombInfo
         [] bombPlanted(Pos) then 
            BombInfo
         [] bombExploded(Pos) then
            BombInfo
         [] boxRemoved(Pos) then
            {AdjoinAt BombInfo map {ChangeMap BombInfo.map Pos deleteBox}}
      end
   end

   fun{IsBox Map Pos}
      fun{CheckMap Map X Y}
      	 case Map of H|T then
      	    if Y > 1 then {CheckMap T X Y-1}
      	    elseif Y == 1 then {CheckMap H X 0}
      	    elseif X > 1 then {CheckMap T X-1 0}
      	    elseif X == 1 then
      	      if H == 1 orelse H == 2 orelse H == 3 then
                  true
               else false
      	      end
      	    end
      	 end
      end
   in
	  {CheckMap Map Pos.x Pos.y}
   end


   fun{DoAction BombInfo ID Action}
      if BombInfo.state == off then 
         ID = null
         Action = null
         BombInfo
      else
         ID = BombInfo.id
         local Random in
            Random = {OS.rand} mod 5
            if Random == 0 then 
               if BombInfo.nBomb > 0 then 
                  Action = bomb(BombInfo.pos)
                  {AdjoinAt BombInfo nBomb BombInfo.nBomb-1}
               else {DoAction BombInfo ID Action}
               end
            elseif Random == 1 then 
                  if {IsBox BombInfo.map pt(x:BombInfo.pos.x y:BombInfo.pos.y-1)} then {DoAction BombInfo ID Action}
                  else Action = move(pt(x:BombInfo.pos.x y:BombInfo.pos.y-1))
                     {AdjoinAt BombInfo pos pt(x:BombInfo.pos.x y:BombInfo.pos.y-1)}
                  end
            elseif Random == 2 then 
                  if {IsBox BombInfo.map pt(x:BombInfo.pos.x y:BombInfo.pos.y+1)} then {DoAction BombInfo ID Action}
                  else Action = move(pt(x:BombInfo.pos.x y:BombInfo.pos.y+1))
                     {AdjoinAt BombInfo pos pt(x:BombInfo.pos.x y:BombInfo.pos.y+1)}
                  end
            elseif Random == 3 then 
                  if {IsBox BombInfo.map pt(x:BombInfo.pos.x-1 y:BombInfo.pos.y)} then {DoAction BombInfo ID Action}
                  else Action = move(pt(x:BombInfo.pos.x-1 y:BombInfo.pos.y))
                     {AdjoinAt BombInfo pos pt(x:BombInfo.pos.x-1 y:BombInfo.pos.y)}
                  end
            elseif Random == 4 then 
                  if {IsBox BombInfo.map pt(x:BombInfo.pos.x+1 y:BombInfo.pos.y)} then {DoAction BombInfo ID Action}
                  else Action = move(pt(x:BombInfo.pos.x+1 y:BombInfo.pos.y))
                     {AdjoinAt BombInfo pos pt(x:BombInfo.pos.x+1 y:BombInfo.pos.y)}
                  end
            end
         end
      end
   end
   
   proc{TreatStream Stream BombInfo}
      %% BombInfo to save all the information about the bomber
      %% BombInfo = bombInfo(id:ID state:State pos:Pos live:Live spawn:Spawn nBomb:NBomb point:Point map:Map) 

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
      end
   end
   

end
