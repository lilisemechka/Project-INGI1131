functor
import
   	GUI
   	Input
   	PlayerManager
   	Browser
   	OS
   	Utilitaries
   	Main
export
	doActionTBT:DoActionTBT
	handleBombs:HandleBombs
define
   	ExploLoc
   	Explode
   	HandleBombs
   	DoActionTBT
in
	proc{ExploLoc Pos Action Direction Acc Map NewMap Players P_GUI}
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
                           NewMap = {Utilitaries.changeMap Map Pos pointAndFire}
                           {Send P_GUI spawnPoint(Pos)}
			               else
			                  NewMap = {Utilitaries.changeMap Map Pos bonusAndFire}
                           {Send P_GUI spawnBonus(Pos)}
                        end
                        for E in Players do
                           {Send E.port info(boxRemoved(Pos))}
                        end
                        skip
		                else
               			local NewMap1 in
               			   NewMap1 = {Utilitaries.changeMap Map Pos fire}
               			   case Direction
               			   of north then {ExploLoc pt(x:Pos.x y:Pos.y-1) Action north Acc+1 NewMap1 NewMap Players P_GUI}
               			   [] south then {ExploLoc pt(x:Pos.x y:Pos.y+1) Action south Acc+1 NewMap1 NewMap Players P_GUI}
               			   [] west then {ExploLoc pt(x:Pos.x-1 y:Pos.y) Action west Acc+1 NewMap1 NewMap Players P_GUI}
               			   [] east then {ExploLoc pt(x:Pos.x+1 y:Pos.y) Action east Acc+1 NewMap1 NewMap Players P_GUI}
               			   end
               			end
                        skip
                     end
                  [] hideFire then
            			local NewMap1
            			in
            			   if Type == 12 then 
                           NewMap = {Utilitaries.changeMap Map Pos deleteFireP}
                           {Send P_GUI hideFire(Pos)}
            			   elseif Type == 13 then 
                           NewMap = {Utilitaries.changeMap Map Pos deleteFireB}
                           {Send P_GUI hideFire(Pos)}
            			   else 
                           NewMap1 = {Utilitaries.changeMap Map Pos deleteFire}            			   
               			   {Send P_GUI hideFire(Pos)}
               			   case Direction
               			   of north then {ExploLoc pt(x:Pos.x y:Pos.y-1) Action north Acc+1 NewMap1 NewMap Players P_GUI}
               			   [] south then {ExploLoc pt(x:Pos.x y:Pos.y+1) Action south Acc+1 NewMap1 NewMap Players P_GUI}
               			   [] west then {ExploLoc pt(x:Pos.x-1 y:Pos.y) Action west Acc+1 NewMap1 NewMap Players P_GUI}
               			   [] east then {ExploLoc pt(x:Pos.x+1 y:Pos.y) Action east Acc+1 NewMap1 NewMap Players P_GUI}
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

   proc{Explode Pos Action Map NewMap Players P_GUI}
      NewMap1 NewMap2 NewMap3
   in
      if(Action == spawnFire) then
	 for E in Players do
	    {Send E.port info(bombExploded(Pos))}
	 end
      end
      
         {Browser.browse 'explode'}
         case Pos of pt(x:X y:Y) then
         {ExploLoc pt(x:X-1 y:Y) Action west 0 Map NewMap1 Players P_GUI}

         {ExploLoc pt(x:X+1 y:Y) Action east 0 NewMap1 NewMap2 Players P_GUI}

         {ExploLoc pt(x:X y:Y+1) Action south 0 NewMap2 NewMap3 Players P_GUI}

         {ExploLoc pt(x:X y:Y-1) Action north 0 NewMap3 NewMap Players P_GUI}
      end
      {Browser.browse 'REAL QUIT EXPLODE'}
   end



   fun{HandleBombs Bombs Map NewMap Players P_GUI}
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
                  {Explode Pos spawnFire {Utilitaries.changeMap Map Pos fire} NewIntMap Players P_GUI}                  
                  bomb(pos:Pos timer:NewTicTac port:P)|{HandleBombs T NewIntMap NewMap Players P_GUI}
                  
               elseif TicTac == ~1 then 
                  local NbBombs in
                     {Send P add(bomb 1 NbBombs)}
                  end
                  {Send P_GUI hideFire(Pos)}
                  {Explode Pos hideFire {Utilitaries.changeMap Map Pos deleteFire} NewIntMap Players P_GUI}
                  {HandleBombs T NewIntMap NewMap Players P_GUI}                  
               else
                  NewIntMap = Map
                  bomb(pos:Pos timer:NewTicTac port:P)|{HandleBombs T NewIntMap NewMap Players P_GUI}  
               end
            end
         end
      end
   end


   proc{DoActionTBT PlayersList Bombs Map P_GUI}
      {Browser.browse 'doaction'}
      {Delay 500}
      {Browser.browse PlayersList}
      if {Utilitaries.boxCheck Map} then 
         {Send P_GUI displayWinner({Utilitaries.bestScore PlayersList})}
         {Delay 10000}
         skip
      else
         case PlayersList 
         of H|nil then          
            {Send P_GUI displayWinner({Utilitaries.bestScore PlayersList})}
            {Delay 10000}
            skip
         [] nil then
            {Send P_GUI displayWinner({Utilitaries.bestScore PlayersList})}
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
                           {DoActionTBT {Append T player(port:H.port pos:PosSpawn)|nil} Bombs Map P_GUI}  
                        else
                           for Ps in PlayersList do
                              {Send Ps.port info(deadPlayer(IDSpawn))}
                           end
                           {DoActionTBT T Bombs Map P_GUI}  
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
   	              {DoActionTBT {Append T player(port:H.port pos:Pos)|nil} {HandleBombs Bombs Map NewMap PlayersList P_GUI} {Utilitaries.changeMap NewMap Pos deletePoint} P_GUI}
                  elseif Type == 6 then
            		   {Send P_GUI hideBonus(Pos)}
                     if ({OS.rand} mod 2 ) == 0 then
            		      {Send H.port add(bomb 1)}
                     else
                        local 
                           Score 
                        in
                          {Send H.port add(point 10 Score)}
                          {Send P_GUI scoreUpdate(ID Score)}
                        end
                     end
            		   {DoActionTBT {Append T player(port:H.port pos:Pos)|nil} {HandleBombs Bombs Map NewMap PlayersList P_GUI} {Utilitaries.changeMap NewMap Pos deleteBonus} P_GUI}                   
   	            else 
                     {DoActionTBT {Append T player(port:H.port pos:Pos)|nil} {HandleBombs Bombs Map NewMap PlayersList P_GUI} NewMap P_GUI}                  
   	            end
               [] bomb(Pos) then                
                  {Send P_GUI spawnBomb(Pos)}
                  for E in PlayersList do
   	               {Send E.port info(bombPlanted(Pos))}
                  end
                  {DoActionTBT {Append T H|nil} bomb(pos:Pos timer:Input.timingBomb*Input.nbBombers port:H.port)|{HandleBombs Bombs Map NewMap PlayersList P_GUI} NewMap P_GUI}
               else
                  {Browser.browse Action} 
               end                 
            end
         else
            {Browser.browse 'No Players left'}
         end
      end
   end     
end