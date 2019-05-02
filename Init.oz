functor
import 
	Input
	PlayerManager
   OS
export
	getPlayers:GetPlayers

define
	Initialize 
   FindSpawns
   AssignSpawns %Proc   
   SpawnPlayers %Proc
   RandomPlayers
   GetPlayers
in
	%% Initializing all players and creating one port / player
   	fun{Initialize N Names Colors Acc P_GUI}
      	if N > 0 then
         	local 
            	NewPlayer
         	in
            	NewPlayer = bomber(id:Acc name:Names.1 color:Colors.1)
            	{Send P_GUI initPlayer(NewPlayer)}
            	{PlayerManager.playerGenerator NewPlayer.name NewPlayer}|{Initialize N-1 Names.2 Colors.2 Acc+1 P_GUI}
         	end
      	else
         	nil
      	end
   	end      	

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
   	

   	%%Assign spawn position to each player

   	fun{AssignSpawns Players AvailSpawns Spawns}
      	local ActualSpawns
      	in
         	if AvailSpawns == nil then ActualSpawns = Spawns
         	else ActualSpawns = AvailSpawns
         	end
         	case Players of nil then nil
         	[] H|T then         
            	{Send H assignSpawn(AvailSpawns.1)}            
            	player(port:H pos:AvailSpawns.1)|{AssignSpawns T AvailSpawns.2 Spawns}
         	end         
      	end
   	end

   	%% Spawn the players who should be spawned

   	proc{SpawnPlayers PortPlayers P_GUI Players} 
      	case PortPlayers of nil then skip
      	[] H|T then
         	local 
            	IDPlayer PosPlayer
         	in
            	{Send H spawn(IDPlayer PosPlayer)}
	        	   {Send P_GUI spawnPlayer(IDPlayer PosPlayer)}
	    		for E in Players do
	       			{Send E.port info(spawnPlayer(IDPlayer PosPlayer))}
	    		end
            {SpawnPlayers T P_GUI Players}
         	end
      	end
   	end

      fun{RandomPlayers Players NbPlayers}
         local
            fun{GetN PList N Nth}
               case PList of nil then nil
               [] H|T then
                  if N==0 then
                     Nth = H
                     T
                  else
                     H|{GetN T N-1 Nth}
                  end
               end
            end
         in
            case Players of nil then nil
            [] H|T then
               local
                  Nth
                  L1 = {GetN Players ({OS.rand} mod NbPlayers) Nth}
               in
                  Nth|{RandomPlayers L1 NbPlayers-1}
               end
            end
         end
      end



   	fun{GetPlayers P_GUI}
   		local
   			R
   			Spawns
   			PortPlayers
   		in
   			PortPlayers = {Initialize Input.nbBombers {RandomPlayers Input.bombers Input.nbBombers} {RandomPlayers Input.colorsBombers Input.nbBombers} 1 P_GUI}
            if Input.useExtention then
   			   Spawns = {FindSpawns Input.map1 1 1}
            else
               Spawns = {FindSpawns Input.map 1 1}
            end
   		 	R = {AssignSpawns PortPlayers Spawns Spawns}
   		 	{SpawnPlayers PortPlayers P_GUI R}
   		 	R
   		end
	end 
end
