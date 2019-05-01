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

   %Attributes
   PlayerID
   SpawnPos
   PlayerState

   %functions
   GetState
   Spawn
   Add
   GotHit
   ChangePos
   DeletePlayer
   ChangeMap
   Info
   IsBox
   DoAction
   AvoidBombs
   Random
   AddElem
   Decrease
   DeleteElem
   BonusPath
in
   fun{StartPlayer ID}
      Stream Port OutputStream      
   in
      thread %% filter to test validity of message sent to the player
         OutputStream = {Projet2019util.portPlayerChecker Name ID Stream}
      end
      PlayerID = ID
      {NewPort Stream Port}
      thread
	     {TreatStream OutputStream bombInfo(id:PlayerID state:off pos:nil live:Input.nbLives spawn:nil nBomb:Input.nbBombs point:0 listPlayer:nil map:Input.map bomb:nil bonus:nil) }
      end
      Port
   end

   %
   %
   %
   %
   %

   fun{Spawn BombInfo ID Pos}
      if (BombInfo.state == off) andthen (BombInfo.live > 0) then
         Pos = BombInfo.spawn
         ID = PlayerID
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
            ID = PlayerID
            NewLife = BombInfo.live-1
            Result = death(NewLife)
            {AdjoinAt {AdjoinAt BombInfo state off} live NewLife}
         end
      end
   end   

   fun{ChangePos ID Pos ListPlayer}
      case ListPlayer of
         H|T then
            case H of player(id:ID1 pos:Pos1) then
               if  ID1 == ID then player(id:ID1 pos:Pos)|T
               else H|{ChangePos ID Pos T}
               end
            end
         [] nil then player(id:ID pos:Pos)|nil
      end
   end

   fun{DeletePlayer ID ListPlayer}
      case ListPlayer of
         H|T then
            if H.id == ID then T
            else H|{DeletePlayer ID T}
            end
         [] nil then nil
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

   fun{AddElem List Pos}
        if(Input.isTurnByTurn) then
            bomb(time:Input.timingBomb pos:Pos)|List
        end
   end

   fun{DeleteElem List Pos}
        case List of H|T then 
            if H == Pos then T
            else H|{DeleteElem List Pos}
            end
        end
   end

   fun{BonusPath BombInfo Bool}
      case BombInfo.bonus of pt(x:X1 y:Y1) then
		            case BombInfo.pos of pt(x:X2 y:Y2) then
		               if X1 == X2 andthen Y1 == Y2 then
                        Bool = true
                        {Random BombInfo true}
		               elseif X1 == X2 then
                        Bool = false
                        if Y2 - Y1 > 0 then 
                           if {IsBox BombInfo.map pt(x:X2 y:Y2-1)} then move(pt(x:X2 y:Y2-1))
                           elseif {IsBox BombInfo.map pt(x:X2-1 y:Y2)} then move(pt(x:X2-1 y:Y2))
                           elseif {IsBox BombInfo.map pt(x:X2+1 y:Y2)} then move(pt(x:X2+1 y:Y2))
                           elseif {IsBox BombInfo.map pt(x:X2 y:Y2+1)} then move(pt(x:X2 y:Y2+1))
                           end
                        else
                           if {IsBox BombInfo.map pt(x:X2 y:Y2+1)} then move(pt(x:X2 y:Y2+1))
                           elseif {IsBox BombInfo.map pt(x:X2-1 y:Y2)} then move(pt(x:X2-1 y:Y2))
                           elseif {IsBox BombInfo.map pt(x:X2+1 y:Y2)} then move(pt(x:X2+1 y:Y2))
                           elseif {IsBox BombInfo.map pt(x:X2 y:Y2-1)} then move(pt(x:X2 y:Y2-1))
                           end
                        end
		               elseif Y1 == Y2 then
                        Bool = false
                        if X2 - X1 > 0 then 
                           if {IsBox BombInfo.map pt(x:X2-1 y:Y2)} then move(pt(x:X2-1 y:Y2))
                           elseif {IsBox BombInfo.map pt(x:X2 y:Y2-1)} then move(pt(x:X2 y:Y2-1))
                           elseif {IsBox BombInfo.map pt(x:X2 y:Y2+1)} then move(pt(x:X2 y:Y2+1))
                           elseif {IsBox BombInfo.map pt(x:X2+1 y:Y2)} then move(pt(x:X2+1 y:Y2))
                           end
                        else
                           if {IsBox BombInfo.map pt(x:X2+1 y:Y2)} then move(pt(x:X2+1 y:Y2))
                           elseif {IsBox BombInfo.map pt(x:X2 y:Y2-1)} then move(pt(x:X2 y:Y2-1))
                           elseif {IsBox BombInfo.map pt(x:X2 y:Y2+1)} then move(pt(x:X2 y:Y2+1))
                           elseif {IsBox BombInfo.map pt(x:X2-1 y:Y2)} then move(pt(x:X2-1 y:Y2))
                           end
                        end
		               elseif Y2 - Y1 > 0 then
                        Bool = false
                        if X2 - X1 > 0 then 
                           if {IsBox BombInfo.map pt(x:X2-1 y:Y2)} then move(pt(x:X2-1 y:Y2))
                           elseif {IsBox BombInfo.map pt(x:X2 y:Y2-1)} then move(pt(x:X2 y:Y2-1))
                           elseif {IsBox BombInfo.map pt(x:X2 y:Y2-1)} then move(pt(x:X2 y:Y2+1))
                           elseif {IsBox BombInfo.map pt(x:X2 y:Y2-1)} then move(pt(x:X2+1 y:Y2))
                           end
                        else
                           if {IsBox BombInfo.map pt(x:X2+1 y:Y2)} then move(pt(x:X2+1 y:Y2))
                           elseif {IsBox BombInfo.map pt(x:X2 y:Y2-1)} then move(pt(x:X2 y:Y2-1))
                           elseif {IsBox BombInfo.map pt(x:X2 y:Y2+1)} then move(pt(x:X2 y:Y2+1))
                           elseif {IsBox BombInfo.map pt(x:X2-1 y:Y2)} then move(pt(x:X2-1 y:Y2))
                           end
                        end
		               elseif Y2 - Y1 < 0 then
                        Bool = false
                        if X2 - X1 > 0 then 
                           if {IsBox BombInfo.map pt(x:X2-1 y:Y2)} then move(pt(x:X2-1 y:Y2))
                           elseif {IsBox BombInfo.map pt(x:X2 y:Y2+1)} then move(pt(x:X2 y:Y2+1))
                           elseif {IsBox BombInfo.map pt(x:X2 y:Y2-1)} then move(pt(x:X2 y:Y2-1))
                           elseif {IsBox BombInfo.map pt(x:X2+1 y:Y2)} then move(pt(x:X2+1 y:Y2))
                           end
                        else
                           if {IsBox BombInfo.map pt(x:X2+1 y:Y2)} then move(pt(x:X2+1 y:Y2))
                           elseif {IsBox BombInfo.map pt(x:X2 y:Y2-1)} then move(pt(x:X2 y:Y2-1))
                           elseif {IsBox BombInfo.map pt(x:X2 y:Y2+1)} then move(pt(x:X2 y:Y2+1))
                           elseif {IsBox BombInfo.map pt(x:X2-1 y:Y2)} then move(pt(x:X2-1 y:Y2))
                           end
                        end
                     end
		        end
         end
   end

   fun{Info BombInfo Message}
      case Message of
         spawnPlayer(ID Pos) then
            if(ID == PlayerID) then BombInfo
            else 
               local NewList in
                  NewList = {ChangePos ID Pos BombInfo.listPlayer}
                  {AdjoinAt BombInfo listPlayer NewList}
               end
            end
         [] movePlayer(ID Pos) then
            if(ID == PlayerID) then BombInfo
            else
               local NewList in
                  NewList = {ChangePos ID Pos BombInfo.listPlayer}
                  {AdjoinAt BombInfo listPlayer NewList}
               end
            end
         [] deadPlayer(ID) then
            if(ID == PlayerID) then BombInfo
            else 
               local NewList in
                  NewList = {DeletePlayer ID BombInfo.listPlayer}
                  {AdjoinAt BombInfo listPlayer NewList}
               end
            end
         [] bombPlanted(Pos) then
            %{AdjoinAt BombInfo bomb {AddElem BombInfo.bomb Pos}} 
            {AdjoinAt BombInfo map {ChangeMap BombInfo.map Pos bomb}}
         [] bombExploded(Pos) then
            %{AdjoinAt BombInfo bomb {DeleteElem BombInfo.bomb Pos}}
            case BombInfo.bomb of pt(x:X1 y:Y1) then 
               case Pos of pt(x:X2 y:Y2) then
                  if X1 == X2 andthen Y1 == Y2 then
                     {AdjoinAt {AdjoinAt BombInfo bomb nil} map {ChangeMap BombInfo.map Pos deleteBomb}}
                  else{AdjoinAt BombInfo map {ChangeMap BombInfo.map Pos deleteBomb}}
                  end
               end
            else {AdjoinAt BombInfo map {ChangeMap BombInfo.map Pos deleteBomb}}
            end
         [] boxRemoved(Pos) then
            case Pos of pt(x:X1 y:Y1) then
               case BombInfo.pos of pt(x:X2 y:Y2) then
                  if {Abs X1-X2} =< Input.timingBomb andthen {Abs Y1-Y2} =< Input.timingBomb then 
                     {AdjoinAt {AdjoinAt BombInfo bonus Pos} map {ChangeMap BombInfo.map Pos deleteBox}}
                  else {AdjoinAt BombInfo map {ChangeMap BombInfo.map Pos deleteBox}}
                  end
               else {AdjoinAt BombInfo map {ChangeMap BombInfo.map Pos deleteBox}}
               end
            end
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
                  false
               else 
                  true
      	      end
      	    end
         else  false
      	 end
      end
   in
      case Pos of pt(x:X y:Y) then
	    {CheckMap Map X Y}
      end 
   end

   fun{Decrease BombList}
        case BombList of H|T then
            case H of bomb(time:Time pos:Pos) then
                if Time < 2 then 
                    {DeleteElem BombList Pos}
                else
                    bomb(time:(Time-1) pos:Pos)|T
                end
            [] nil then nil
            end
        end
   end

   fun{AvoidBombs BombInfo Bool}
	            case BombInfo.bomb of pt(x:X1 y:Y1) then
		            case BombInfo.pos of pt(x:X2 y:Y2) then
		               if X1 == X2 andthen Y1 == Y2 then
		                    Bool = false
		                    {Random BombInfo Bool}
		               elseif X1 == X2 then
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
                        if {IsBox BombInfo.map pt(x:X2 y:Y2+1)} then move(pt(x:X2 y:Y2+1))
                        elseif {IsBox BombInfo.map pt(x:X2-1 y:Y2)} andthen X1 > X2 then move(pt(x:X2-1 y:Y2))
                        elseif {IsBox BombInfo.map pt(x:X2+1 y:Y2)} andthen X1 < X2 then move(pt(x:X2+1 y:Y2))
			               elseif {IsBox BombInfo.map pt(x:X2 y:Y2-1)} then move(pt(x:X2 y:Y2-1))
                        else {Random BombInfo Bool}
			               end
		               elseif Y1 > Y2 then
                        if {IsBox BombInfo.map pt(x:X2 y:Y2-1)} then move(pt(x:X2 y:Y2-1))
                        elseif {IsBox BombInfo.map pt(x:X2-1 y:Y2)} andthen X1 > X2 then move(pt(x:X2-1 y:Y2))
                        elseif {IsBox BombInfo.map pt(x:X2+1 y:Y2)} andthen X1 < X2 then move(pt(x:X2+1 y:Y2))
			               elseif {IsBox BombInfo.map pt(x:X2 y:Y2+1)} then move(pt(x:X2 y:Y2+1))
                        else {Random BombInfo Bool}
			               end
                     elseif X1 > X2 then
                        if {IsBox BombInfo.map pt(x:X2+1 y:Y2)} then move(pt(x:X2+1 y:Y2))
                        elseif {IsBox BombInfo.map pt(x:X2 y:Y2-1)} andthen Y1 > Y2 then move(pt(x:X2 y:Y2-1))
                        elseif {IsBox BombInfo.map pt(x:X2 y:Y2+1)} andthen Y1 < Y2 then move(pt(x:X2 y:Y2+1))
			               elseif {IsBox BombInfo.map pt(x:X2-1 y:Y2)} then move(pt(x:X2-1 y:Y2))
                        else {Random BombInfo Bool}
			               end
                     elseif X1 < X2 then
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


   fun{DoAction BombInfo ID Action}
      local Bl in 
        if BombInfo.state == off then 
            ID = null
            Action = null
            BombInfo
        else
            ID = PlayerID
            if BombInfo.bomb \= nil then 
                local Bool in
                    Action = {AvoidBombs BombInfo Bool}
                end
            elseif BombInfo.bonus \= nil then 
                  Action = {BonusPath BombInfo Bl}
            else Action = {Random BombInfo true}
            end
            case Action of move(Pos) then
                  if {IsFree Bl} then 
                     {AdjoinAt BombInfo pos Pos}
                  elseif Bl == true then {AdjoinAt {AdjoinAt BombInfo bonus nil} pos Pos}
                  else {AdjoinAt BombInfo pos Pos}
                  end
            [] bomb(Pos) then 
                  {AdjoinAt {AdjoinAt BombInfo bomb Pos} nBomb BombInfo.nBomb-1}
	         end
        end
      end
    end
   
   %% bombInfo(id:ID state:State pos:Pos live:Live spawn:Spawn nBomb:NBomb point:Point listPlayer:ListPlayer map:Map bomb:Bomb bonus:Bonus) 
   proc{TreatStream Stream BombInfo}
      case Stream of nil then skip
      [] getId(ID)|T then 
         ID = PlayerID
         {TreatStream T BombInfo}
      [] getState(ID State)|T then 
         ID = PlayerID
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