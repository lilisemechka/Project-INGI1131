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

   FindSpawns
   Spawns   

   AssignSpawns %Proc

   SpawnPlayers %Proc
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

end
