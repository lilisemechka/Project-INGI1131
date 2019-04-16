functor
import
   GUI
   Input
   PlayerManager
   Browser
   OS
define
   P_GUI

   Initialize 
   PortPlayers
   Players 

   FindSpawns
   Spawns   

   AssignSpawns %Proc

   ChangeMap
   BestScore
   SpawnPlayers %Proc
   ExploLoc
   Explode
   HandleBombs
   DoActionTBT
   BoxCheck
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
      	       elseif Type == pointAndFire then 12|T
      	       elseif Type == bonusAndFire then 13|T
      	       elseif Type == fire then 7|T
      	       elseif Type == deletePoint then 0|T
      	       elseif Type == deleteBonus then 0|T
      	       elseif Type == deleteFire then 0|T
      	       elseif Type == deleteFireP then 5|T
      	       elseif Type == deleteFireB then 6|T
      	       end
      	    end
      	 end
      end
   in
      case Pos of pt(x:X y:Y) then
	  {NewMap Map X Y}

      end      
   end

   %%Compare and retun the best score
   fun{BestScore}
      fun{BestScoreAcc Players AccPt AccId}
	 case Players of H|T then
	    local Result ID in 
	       {Send H.port add(point 0 Result)}
	       if Result > AccPt then
		  {Send H.port getId(ID)}
		  {BestScoreAcc T Result ID}
	       else
		  {BestScoreAcc T AccPt AccId}
	       end
	    end
	 [] nil then AccId
	 end
      end
   in
      local AccId in
	 {BestScoreAcc Players 0 AccId}
      end
   end
   
   %%Return true if there are some boxes on the map false otherwise
   fun{BoxCheck Map}
      case Map
      of H|T then
	     case H of nil then {BoxCheck T}
	     [] H1|T1 then
	        if H1 == 2 then true
	        elseif H1 == 3 then true
	        else
	           {BoxCheck T1|T}
	        end
	     end
      [] nil then false
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
   PortPlayers = {Initialize Input.nbBombers Input.bombers Input.colorsBombers 1}



   %% Identifying spawn positions
   fun{BoxCheck Map}
      case Map
      of H|T then
	 case H of nil then {BoxCheck T}
	 [] H1|T1 then
	    if H1 == 2 then true
	    elseif H1 == 3 then true
	    else
	       {BoxCheck T1|T}
	    end
	 end
      [] nil then false
      end
   end

   Spawns = {FindSpawns Input.map 1 1}

   %%Assign spawn position to each player

   fun{AssignSpawns Players AvailSpawns}
      local ActualSpawns
      in
         if AvailSpawns == nil then ActualSpawns = Spawns
         else ActualSpawns = AvailSpawns
         end
         case Players of nil then nil
         [] H|T then         
            {Send H assignSpawn(AvailSpawns.1)}            
            player(port:H pos:AvailSpawns.1)|{AssignSpawns Players.2 AvailSpawns.2}
         end         
      end
   end  

   Players = {AssignSpawns PortPlayers Spawns} 


   %% Spawn the players who should be spawned

   proc{SpawnPlayers PortPlayers} 
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
            {SpawnPlayers T}
         end
      end
   end

   {SpawnPlayers PortPlayers}



   proc{ExploLoc Pos Action Direction Acc Map NewMap Players}
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
                     for E in Players do
                        case E.pos of pt(x:X y:Y) then
                           if X==Pos.x andthen Y==Pos.y then
                              local 
                                 IDead
                                 Lives
                              in
                                 {Send E.port gotHit(IDead Lives)}
                                 {Send P_GUI hidePlayer(IDead)}                                 
                                 case Lives of death(NewLife) then
                                    {Send P_GUI lifeUpdate(IDead NewLife)}
                                 else
                                    skip
                                 end
                              end
                           end
                        end
                     end
                     if Type == 2 orelse Type == 3 then
                        {Send P_GUI hideBox(Pos)}
                        if Type == 2 then
                           NewMap = {ChangeMap Map Pos pointAndFire}
                           {Send P_GUI spawnPoint(Pos)}
			               else
			                  NewMap = {ChangeMap Map Pos bonusAndFire}
                           {Send P_GUI spawnBonus(Pos)}
                        end
                        for E in Players do
                           {Send E.port info(boxRemoved(Pos))}
                        end
                        skip
		                else
               			local NewMap1 in
               			   NewMap1 = {ChangeMap Map Pos fire}
               			   case Direction
               			   of north then {ExploLoc pt(x:Pos.x y:Pos.y-1) Action north Acc+1 NewMap1 NewMap Players}
               			   [] south then {ExploLoc pt(x:Pos.x y:Pos.y+1) Action south Acc+1 NewMap1 NewMap Players}
               			   [] west then {ExploLoc pt(x:Pos.x-1 y:Pos.y) Action west Acc+1 NewMap1 NewMap Players}
               			   [] east then {ExploLoc pt(x:Pos.x+1 y:Pos.y) Action east Acc+1 NewMap1 NewMap Players}
               			   end
               			end
                        skip
                     end
                  [] hideFire then
            			local NewMap1
            			in
            			   if Type == 12 then 
                           NewMap = {ChangeMap Map Pos deleteFireP}
                           {Send P_GUI hideFire(Pos)}
            			   elseif Type == 13 then 
                           NewMap = {ChangeMap Map Pos deleteFireB}
                           {Send P_GUI hideFire(Pos)}
            			   else 
                           NewMap1 = {ChangeMap Map Pos deleteFire}            			   
               			   {Send P_GUI hideFire(Pos)}
               			   case Direction
               			   of north then {ExploLoc pt(x:Pos.x y:Pos.y-1) Action north Acc+1 NewMap1 NewMap Players}
               			   [] south then {ExploLoc pt(x:Pos.x y:Pos.y+1) Action south Acc+1 NewMap1 NewMap Players}
               			   [] west then {ExploLoc pt(x:Pos.x-1 y:Pos.y) Action west Acc+1 NewMap1 NewMap Players}
               			   [] east then {ExploLoc pt(x:Pos.x+1 y:Pos.y) Action east Acc+1 NewMap1 NewMap Players}
               			   end
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

   proc{Explode Pos Action Map NewMap Players}
      NewMap1 NewMap2 NewMap3
   in
      if(Action == spawnFire) then
	 for E in Players do
	    {Send E.port info(bombExploded(Pos))}
	 end
      end
      
         {Browser.browse 'explode'}
         case Pos of pt(x:X y:Y) then
         {ExploLoc pt(x:X-1 y:Y) Action west 0 Map NewMap1 Players}

         {ExploLoc pt(x:X+1 y:Y) Action east 0 NewMap1 NewMap2 Players}

         {ExploLoc pt(x:X y:Y+1) Action south 0 NewMap2 NewMap3 Players}

         {ExploLoc pt(x:X y:Y-1) Action north 0 NewMap3 NewMap Players}
      end
      {Browser.browse 'REAL QUIT EXPLODE'}
   end



   fun{HandleBombs Bombs Map NewMap Players}
      {Browser.browse 'handleBombs'}
      case Bombs 
      of nil then
         NewMap = Map
         nil
      [] H|T then
         case H of bomb(pos:Pos timer:TicTac port:P) then
            local
            NewTicTac = TicTac -1
            NewIntMap
            in
               if TicTac == 0 then
                  {Send P_GUI hideBomb(Pos)}
                  {Send P_GUI spawnFire(Pos)}
                  for E in Players do
                     case E.pos of pt(x:X y:Y) then
                        if X==Pos.x andthen Y==Pos.y then
                           local 
                              IDead
                              Lives
                           in
                              {Send E.port gotHit(IDead Lives)}
                              {Send P_GUI hidePlayer(IDead)}                                 
                              case Lives of death(NewLife) then
                                 {Send P_GUI lifeUpdate(IDead NewLife)}
                              else
                                 skip
                              end
                           end
                        end
                     end
                  end
                  {Explode Pos spawnFire {ChangeMap Map Pos fire} NewIntMap Players}                  
                  bomb(pos:Pos timer:NewTicTac port:P)|{HandleBombs T NewIntMap NewMap Players}
                  
               elseif TicTac == ~1 then 
                  local NbBombs in
                     {Send P add(bomb 1 NbBombs)}
                  end
                  {Send P_GUI hideFire(Pos)}
                  {Explode Pos hideFire {ChangeMap Map Pos deleteFire} NewIntMap Players}
                  {HandleBombs T NewIntMap NewMap Players}                  
               else
                  NewIntMap = Map
                  bomb(pos:Pos timer:NewTicTac port:P)|{HandleBombs T NewIntMap NewMap Players}  
               end
            end
         end
      end
   end


   proc{DoActionTBT PlayersList Bombs Map}
      {Browser.browse 'doaction'}
      {Delay 500}
      {Browser.browse PlayersList}
      case PlayersList 
      of H|nil then          
         {Send P_GUI displayWinner({BestScore})}
         {Delay 10000}
         skip
      [] nil then
         {Send P_GUI displayWinner({BestScore})}
         {Delay 10000}
         skip
      [] H|T then
         local 
            ID
   	      Action
      	   NewMap
      	   Type
         in            
            {Send H.port doaction(ID Action)}
            local IDState State in
               {Send H.port getState(IDState State)}
               {Browser.browse State}
               if State == off then 
                  local 
                     IDSpawn 
                     PosSpawn 
                  in
                     {Send H.port spawn(IDSpawn PosSpawn)}
                     case PosSpawn of pt(x:X y:Y) then
                        {Send P_GUI spawnPlayer(IDSpawn PosSpawn)}
                        {DoActionTBT {Append T player(port:H.port pos:PosSpawn)|nil} Bombs Map}  
                     else
                        for Ps in PlayersList do
                           {Send Ps.port info(deadPlayer(IDSpawn))}
                        end
                        {DoActionTBT T Bombs Map}  
                     end
                                
                  end
               end
            end               
            case Action 
            of move(Pos) then            
              {Send P_GUI movePlayer(ID Pos)}
              for E in PlayersList do
	             {Send E.port info(movePlayer(ID Pos))}
              end
              Type =  {Nth {Nth Map Pos.y} Pos.x}
	            if Type == 5 then
	              {Send P_GUI hidePoint(Pos)}
         		  local Score in
         		     {Send H.port add(point 1 Score)}
         		     {Send P_GUI scoreUpdate(ID Score)}
         		  end
	              {DoActionTBT {Append T player(port:H.port pos:Pos)|nil} {HandleBombs Bombs Map NewMap PlayersList} {ChangeMap NewMap Pos deletePoint}}
               elseif Type == 6 then
         		   {Send P_GUI hideBonus(Pos)}
                  if ({OS.rand} mod 2 ) == 0 then
         		      {Send H.port add(bomb 1)}
                  else
                     {Send H.port add(point 10)}
                  end
         		   {DoActionTBT {Append T player(port:H.port pos:Pos)|nil} {HandleBombs Bombs Map NewMap PlayersList} {ChangeMap NewMap Pos deleteBonus}}                   
	            else 
                  {DoActionTBT {Append T player(port:H.port pos:Pos)|nil} {HandleBombs Bombs Map NewMap PlayersList} NewMap}                  
	            end
            [] bomb(Pos) then                
               {Send P_GUI spawnBomb(Pos)}
               for E in PlayersList do
	               {Send E.port info(bombPlanted(Pos))}
               end
               {DoActionTBT {Append T H|nil} bomb(pos:Pos timer:3*Input.nbBombers port:H.port)|{HandleBombs Bombs Map NewMap PlayersList} NewMap}
            else
               {Browser.browse Action} 
            end                 
         end
      else
         {Browser.browse 'No Players left'}
      end
   end     

   {Delay 7000}
   {DoActionTBT Players nil Input.map}

end
