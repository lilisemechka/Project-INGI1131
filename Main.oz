functor
import
   GUI
   Input
   PlayerManager
   Browser
define
   P_GUI

   Initialize %First : function
   Players %Second : List
   ChangeMap

   FindSpawns
   Spawns   

   AssignSpawns %Proc

   SpawnPlayers %Proc
   ExploLoc
   Explode
   HandleBombs
   DoActionTBT
in
   %% Create MAP
   P_GUI = {GUI.portWindow}
   {Send P_GUI buildWindow}

   %Change MAP 
   fun {ChangeMap Map Pos Type}
      {Browser.browse 'changemap'}

      fun{NewMap Map X Y}

      	 case Map of H|T then
      	    if Y > 1 then H|{NewMap T X Y-1}
      	    elseif Y == 1 then {NewMap H X 0}|T
      	    elseif X > 1 then H|{NewMap T X-1 0}
      	    elseif X == 1 then
      	       if Type == point then 5|T
      	       elseif Type == bonus then 6|T
      	       elseif Type == deletePoint then 0|T
      	       elseif Type == deleteBonus then 0|T
      	       end
      	    end
      	 end
      end
   in
      case Pos of pt(x:X y:Y) then
	  {NewMap Map X Y}

      end      
   end


   %% Initializing all players and creating one port / player
   fun{Initialize N Names Colors Acc}
      if N > 0 then
         local 
            NewPlayer
         in
            NewPlayer = bomber(id:Acc name:Names.1 color:Colors.1)
            {Send P_GUI initPlayer(NewPlayer)}
            {PlayerManager.playerGenerator NewPlayer.name NewPlayer}|{Initialize N-1 Names.2 Colors.2 Acc+1}
         end
      else
         nil
      end
   end   
   Players = {Initialize Input.nbBombers Input.bombers Input.colorsBombers 1}



   %% Identifying spawn positions
   fun{FindSpawns Map Y X}
      case Map 
      of H|T then
         case H of nil then {FindSpawns T Y+1 1}
         [] H1|T1 then
            if H1 == 4 then
               pt(x:X y:Y)|{FindSpawns T1|T Y X+1}
            else
               {FindSpawns T1|T Y X+1}
            end
         end
      [] nil then nil
      end
   end

   Spawns = {FindSpawns Input.map 1 1}

   %%Assign spawn position to each player

   proc{AssignSpawns Players AvailSpawns}
      case Players of nil then skip
      [] H|T then         
         {Send H assignSpawn(AvailSpawns.1)}
         if AvailSpawns.2 == nil then
            {AssignSpawns Players.2 Spawns}
         else
            {AssignSpawns Players.2 AvailSpawns.2}
         end
      end
   end  

   {AssignSpawns Players Spawns} 


   %% Spawn the players who should be spawned

   proc{SpawnPlayers Players} 
      case Players of nil then skip
      [] H|T then
         local 
            IDPlayer PosPlayer
         in
            {Send H spawn(IDPlayer PosPlayer)}
            {Send P_GUI spawnPlayer(IDPlayer PosPlayer)}
            {SpawnPlayers T}
         end
      end
   end

   {SpawnPlayers Players}



   proc{ExploLoc Pos Action Direction Acc Map NewMap}
      {Browser.browse 'exploloc'}
      if Acc == Input.fire then
         NewMap = Map
         skip
      else      
         local 
            Type
         in
            if (Pos.y < 1) orelse (Pos.y > Input.nbRow) orelse (Pos.x < 1) orelse (Pos.x > Input.nbColumn) then
               NewMap = Map
               skip
            else
               Type =  {Nth {Nth Map Pos.y} Pos.x}
               if Type \= 1 then
                  case Action
                  of spawnFire then               
                     {Send P_GUI spawnFire(Pos)}
                     if Type == 2 orelse Type == 3 then
                        {Send P_GUI hideBox(Pos)}
                        if Type == 2 then
                           {Browser.browse 'type2'}
                           NewMap = {ChangeMap Map Pos point}
                           {Browser.browse NewMap}
                           {Send P_GUI spawnPoint(Pos)}
                           {Browser.browse 'TYPE2'}
                        else NewMap = {ChangeMap Map Pos bonus}
                           {Browser.browse 'TYPE3'}
                           {Send P_GUI spawnBonus(Pos)}
                           {Browser.browse NewMap}
                           {Browser.browse 'TYPE3'}
                        end
                        for E in Players do
                           {Send E info(boxRemoved(Pos))}
                        end
                     else
                        case Direction
                        of north then {ExploLoc pt(x:Pos.x y:Pos.y+1) Action north Acc+1 Map NewMap} 
                        [] south then {ExploLoc pt(x:Pos.x y:Pos.y-1) Action south Acc+1 Map NewMap}
                        [] west then {ExploLoc pt(x:Pos.x-1 y:Pos.y) Action west Acc+1 Map NewMap}
                        [] east then {ExploLoc pt(x:Pos.x+1 y:Pos.y) Action east Acc+1 Map NewMap}
                        end
                     end
                  [] hideFire then
                     local NewMap1 in
                        {Send P_GUI hideFire(Pos)}
                        case Direction
                        of north then {ExploLoc pt(x:Pos.x y:Pos.y+1) Action north Acc+1 Map NewMap}
                        [] south then {ExploLoc pt(x:Pos.x y:Pos.y-1) Action south Acc+1 Map NewMap}
                        [] west then {ExploLoc pt(x:Pos.x-1 y:Pos.y) Action west Acc+1 Map NewMap}
                        [] east then {ExploLoc pt(x:Pos.x+1 y:Pos.y) Action east Acc+1 Map NewMap}
                        end
                     end
                  end
               else
                  NewMap = Map
               end
            end
         end
      end
      {Browser.browse 'QUIT EXPLODE'}
   end

   proc{Explode Pos Action Map NewMap}
      NewMap1 NewMap2 NewMap3
      in
         {Browser.browse 'explode'}
         case Pos of pt(x:X y:Y) then
         {ExploLoc pt(x:X-1 y:Y) Action west 1 Map NewMap1}

         {ExploLoc pt(x:X+1 y:Y) Action east 1 NewMap1 NewMap2}

         {ExploLoc pt(x:X y:Y-1) Action south 1 NewMap2 NewMap3}

         {ExploLoc pt(x:X y:Y+1) Action north 1 NewMap3 NewMap}
      end
   end



   fun{HandleBombs Bombs Map NewMap}
      {Browser.browse 'handleBombs'}
      case Bombs 
      of nil then
         NewMap = Map
         nil
      [] H|T then
         case H of bomb(pos:Pos timer:TicTac) then
            local
            NewTicTac = TicTac -1
            NewIntMap
            in
               if NewTicTac == 0 then
                  {Send P_GUI hideBomb(Pos)}
                  {Send P_GUI spawnFire(Pos)}
                  {Explode Pos spawnFire Map NewIntMap}
                  local NewIntMap1 in
                     bomb(pos:Pos timer:NewTicTac)|{HandleBombs T NewIntMap NewMap}
                  end
               elseif NewTicTac == ~1 then 
                  {Send P_GUI hideFire(Pos)}
                  {Explode Pos hideFire Map NewIntMap}
                  {HandleBombs T NewIntMap NewMap}                  
               else
                  NewIntMap = Map
                  bomb(pos:Pos timer:NewTicTac)|{HandleBombs T NewIntMap NewMap}  
               end
            end
         end
      end
   end


   proc{DoActionTBT PlayersList Bombs Map}
      {Browser.browse 'doation'}
      {Delay 500}
      case PlayersList 
      of nil then {DoActionTBT Players Bombs Map}
      [] H|T then
         local 
            ID
      	     Action
      	    NewMap
      	    NewIntMap
      	    Type
         in
            {Send H doaction(ID Action)}
            case Action 
            of move(Pos) then 
            
	       {Send P_GUI movePlayer(ID Pos)}
	       Type =  {Nth {Nth Map Pos.y} Pos.x}
	       if Type == 5 then
		  {Send P_GUI hidePoint(Pos)}
		  {DoActionTBT T {HandleBombs Bombs Map NewMap} {ChangeMap NewMap Pos deletePoint}}
	       elseif Type == 6 then
		  {Send P_GUI hideBonus(Pos)}
		  {DoActionTBT T {HandleBombs Bombs Map NewMap} {ChangeMap NewMap Pos deleteBonus}}
	       else 
          {DoActionTBT T {HandleBombs Bombs Map NewMap} NewMap}
	       end
	       {DoActionTBT T {HandleBombs Bombs Map NewMap} NewMap}
            [] bomb(Pos) then 
               {Send P_GUI spawnBomb(Pos)}
               {DoActionTBT T bomb(pos:Pos timer:3*Input.nbBombers)|{HandleBombs Bombs Map NewMap} NewMap}
            end
         end         
      end      
   end

   {Delay 2000}
   {DoActionTBT Players nil Input.map}

end
