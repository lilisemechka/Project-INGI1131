functor
import
   GUI
   Input
   PlayerManager
define
   P_GUI
   
   Initialize %First : function
   Players %Second : List

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



   proc{ExploLoc Pos Action Direction Acc}
      if Acc == Input.fire then
         skip
      else      
         local 
            Type
         in
            if (Pos.y < 1) orelse (Pos.y > Input.nbRow) orelse (Pos.x < 1) orelse (Pos.x > Input.nbColumn) then
               skip
            else
               Type =  {Nth {Nth Input.map Pos.y} Pos.x}
               if Type \= 1 then
                  case Action
                  of spawnFire then               
                     {Send P_GUI spawnFire(Pos)}
                     if Type == 2 orelse Type == 3 then
                        {Send P_GUI hideBox(Pos)}
                        for E in Players do
                           {Send E info(boxRemoved(Pos))}
                        end
                     else
                        case Direction
                        of north then {ExploLoc pt(x:Pos.x y:Pos.y+1) Action north Acc+1} 
                        [] south then {ExploLoc pt(x:Pos.x y:Pos.y-1) Action south Acc+1}
                        [] west then {ExploLoc pt(x:Pos.x-1 y:Pos.y) Action west Acc+1}
                        [] east then {ExploLoc pt(x:Pos.x+1 y:Pos.y) Action east Acc+1}
                        end
                     end
                  [] hideFire then
                     {Send P_GUI hideFire(Pos)}
                     case Direction
                     of north then {ExploLoc pt(x:Pos.x y:Pos.y+1) Action north Acc+1} 
                     [] south then {ExploLoc pt(x:Pos.x y:Pos.y-1) Action south Acc+1}
                     [] west then {ExploLoc pt(x:Pos.x-1 y:Pos.y) Action west Acc+1}
                     [] east then {ExploLoc pt(x:Pos.x+1 y:Pos.y) Action east Acc+1}
                     end
                  end
               end
            end
         end
      end
   end

   proc{Explode Pos Action}
      case Pos of pt(x:X y:Y) then
         {ExploLoc pt(x:X-1 y:Y) Action west 1}
         {ExploLoc pt(x:X+1 y:Y) Action east 1}
         {ExploLoc pt(x:X y:Y-1) Action south 1}
         {ExploLoc pt(x:X y:Y+1) Action north 1}         
      end
   end


   fun{HandleBombs Bombs}
      case Bombs 
      of nil then nil
      [] H|T then
         case H of bomb(pos:Pos timer:TicTac) then
            local NewTicTac = TicTac -1
            in
               if NewTicTac == 0 then
                  {Send P_GUI hideBomb(Pos)}
                  {Send P_GUI spawnFire(Pos)}
                  {Explode Pos spawnFire}
                  bomb(pos:Pos timer:NewTicTac)|{HandleBombs T}
               elseif NewTicTac == ~1 then 
                  {Send P_GUI hideFire(Pos)}
                  {Explode Pos hideFire}
                  {HandleBombs T}
               else
                  bomb(pos:Pos timer:NewTicTac)|{HandleBombs T}
               end
            end
         end
      end
   end


   proc{DoActionTBT PlayersList Bombs}      
      {Delay 500}
      case PlayersList 
      of nil then {DoActionTBT Players Bombs}
      [] H|T then
         local 
            ID
            Action 
         in
            {Send H doaction(ID Action)}
            case Action 
            of move(Pos) then 
               {Send P_GUI movePlayer(ID Pos)}
               {DoActionTBT T {HandleBombs Bombs}}
            [] bomb(Pos) then 
               {Send P_GUI spawnBomb(Pos)}
               {DoActionTBT T bomb(pos:Pos timer:3*Input.nbBombers)|{HandleBombs Bombs}}
            end
            
         end         
      end      
   end

   {Delay 2000}
   {DoActionTBT Players nil}
   

end
