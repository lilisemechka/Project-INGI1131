functor
import
	TurnByTurn
	Input
	Utilitaries
	Browser
	OS
export
	launchSimul:LaunchSimul
define
	HandlePort
	TreatBombs
	DoAction
	LaunchSimul
	ChangePlayer
	RemovePlayer
	ExploLoc
	Explode
in
	fun{ChangePlayer Players PlayerPort NewPos}
		case Players of nil then nil
		[] H|T then 
			if H.port == PlayerPort then
				player(port:PlayerPort pos:NewPos)|T 
			else
				H|{ChangePlayer T PlayerPort NewPos}
			end
		end
	end

	fun{RemovePlayer PlayersList Player}
		case PlayersList of nil then nil
		[] H|T then 
			if H == Player then
				T 
			else
				H|{RemovePlayer T Player}
			end
		end
	end

	proc{ExploLoc Pos Action Direction Acc PBombs Players P_GUI}
      	{Browser.browse 'exploloc'}
      	if Acc == Input.fire then
         	skip
      	else      
         	local 
            	Type
         	in
            	if (Pos.y < 1) orelse (Pos.y > Input.nbRow) orelse (Pos.x < 1) orelse (Pos.x > Input.nbColumn) then
               		skip
            	else
            		Map
            		in
               		{Send PBombs readMap(Map)}
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
	                        		{Send PBombs changeMap(type:pointAndFire pos:Pos)}
	                           		{Send P_GUI spawnPoint(Pos)}
				               	else
				               		{Send PBombs changeMap(type:bonusAndFire pos:Pos)}
	                           		{Send P_GUI spawnBonus(Pos)}
	                        	end
	                        	for E in Players do
	                           		{Send E.port info(boxRemoved(Pos))}
	                        	end
	                        	skip
			                else
	               				{Send PBombs changeMap(type:fire pos:Pos)}
	               			   	case Direction
	               			   	of north then {ExploLoc pt(x:Pos.x y:Pos.y-1) Action north Acc+1 PBombs Players P_GUI}
	               			   	[] south then {ExploLoc pt(x:Pos.x y:Pos.y+1) Action south Acc+1 PBombs Players P_GUI}
	               			   	[] west then {ExploLoc pt(x:Pos.x-1 y:Pos.y) Action west Acc+1 PBombs Players P_GUI}
	               			   	[] east then {ExploLoc pt(x:Pos.x+1 y:Pos.y) Action east Acc+1 PBombs Players P_GUI}
	               			   	end
	                        	skip
	                     	end
                  		[] hideFire then
            			   	if Type == 12 then 
            			   		{Send PBombs changeMap(type:deleteFireP pos:Pos)}
                           		{Send P_GUI hideFire(Pos)}
            			   	elseif Type == 13 then 
                           		{Send PBombs changeMap(pos:Pos type:deleteFireB)}
                           		{Send P_GUI hideFire(Pos)}
            			   	else 
            			   		{Send PBombs changeMap(pos:Pos type:deleteFire)}           			   
               			   		{Send P_GUI hideFire(Pos)}
               			   		case Direction
               			   		of north then {ExploLoc pt(x:Pos.x y:Pos.y-1) Action north Acc+1 PBombs Players P_GUI}
               			   		[] south then {ExploLoc pt(x:Pos.x y:Pos.y+1) Action south Acc+1 PBombs Players P_GUI}
               			   		[] west then {ExploLoc pt(x:Pos.x-1 y:Pos.y) Action west Acc+1 PBombs Players P_GUI}
               			   		[] east then {ExploLoc pt(x:Pos.x+1 y:Pos.y) Action east Acc+1 PBombs Players P_GUI}
               			   		end
            				end
		             	end
            		end
         		end
      		end
      		{Browser.browse 'QUIT EXPLODE'}
      	end
   	end

   	proc{Explode Pos Action PBombs Players P_GUI}
      	if(Action == spawnFire) then
	 		for E in Players do
	    		{Send E.port info(bombExploded(Pos))}
	 		end
      	end      
        {Browser.browse 'explode'}
        case Pos of pt(x:X y:Y) then
        {ExploLoc pt(x:X-1 y:Y) Action west 0 PBombs Players P_GUI}

        {ExploLoc pt(x:X+1 y:Y) Action east 0 PBombs Players P_GUI}

        {ExploLoc pt(x:X y:Y+1) Action south 0 PBombs Players P_GUI}

        {ExploLoc pt(x:X y:Y-1) Action north 0 PBombs Players P_GUI}
      	end
      	{Browser.browse 'REAL QUIT EXPLODE'}
   	end
				
   	fun{HandlePort Map PlayersList P_GUI}
      	local
         	S
         	R = {NewPort S}
      	in
         	thread {TreatBombs S R Map PlayersList P_GUI} end
         	R
      	end
   	end

   	proc{TreatBombs Stream PBombs Map PlayersList P_GUI}   
   		case PlayersList of nil then skip
   		else		
	      	case Stream 
	      	of nil then skip
	      	[] H|T then 
	         	case H
	         	of addBomb(B) then 
	         		local
	         			Pos = B.pos
	         			NewIntMap1
	         			NewIntMapInter
	         			NewIntMap2
	         			RandTime = Input.timingBombMin + {OS.rand} mod (Input.timingBombMax - Input.timingBombMin)
	         		in
	         			thread 
	         				{Delay RandTime}
	         				{Send P_GUI hideBomb(Pos)}
	                  		{Send P_GUI spawnFire(Pos)}
		                  	for E in PlayersList do
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
		                    {Send PBombs changeMap(type:fire pos:Pos)}
		                    {Explode Pos spawnFire PBombs PlayersList P_GUI}
		                    {Delay Input.thinkMin}
		                    local 
		                    	NbBombs 
		                    in
                     			{Send B.port add(bomb 1 NbBombs)}
                  			end
                  			{Send P_GUI hideFire(Pos)}
                  			{Send PBombs changeMap(type:deleteFire pos:Pos)}
                  			{Explode Pos hideFire PBombs PlayersList P_GUI}
	                  	end	                  	   
	         			{TreatBombs T PBombs Map PlayersList P_GUI}
	         		end
	         	[] changeMap(type:Type pos:Pos) then
	         		{TreatBombs T PBombs {Utilitaries.changeMap Map Pos Type} PlayersList P_GUI}
	         	[] changePlayer(player(port:Play pos:NewPos)) then
	         		{TreatBombs T PBombs Map {ChangePlayer PlayersList Play NewPos} P_GUI}
	         	[] removePlayer(Player) then
	         		{TreatBombs T PBombs Map {RemovePlayer PlayersList Player} P_GUI}         		
	         	[] readMap(M) then
	         		M = Map
	         		{TreatBombs T PBombs Map PlayersList P_GUI}
	         	[] readPlayers(P) then
	         	 	P = PlayersList
	         	 	{TreatBombs T PBombs Map PlayersList P_GUI}
	         	[] close then
	         		skip
	        	end
	        end
	    end
    end



   	proc{DoAction H PBombs P_GUI}   		
	    local 
	        ID
	        Action
	        NewMap
	        Type
	        IDState 
	        State
	        PList
	        CheckMap 
	    in  
	    	{Send PBombs readPlayers(PList)}
	    	{Send PBombs readMap(CheckMap)}
	    	{Wait PList}
	    	{Wait CheckMap}
	    	if {Length PList} < 2 then
	    		{Send PBombs close} 
	    		{Send P_GUI displayWinner({Utilitaries.bestScore PList})}
	            {Delay 10000}
	        elseif {Utilitaries.boxCheck CheckMap} then 
	        	{Send PBombs removePlayer(H)}
         		{Send P_GUI displayWinner({Utilitaries.bestScore PList})}
         		{Delay 10000}
	        else	          
		        {Send H.port doaction(ID Action)}
	            {Send H.port getState(IDState State)}
	            if State == off then 
	               	local 
	                  	IDSpawn 
	                  	PosSpawn 
	               	in
	                  	{Send H.port spawn(IDSpawn PosSpawn)}
	                  	case PosSpawn of pt(x:X y:Y) then
	                     	{Send P_GUI spawnPlayer(IDSpawn PosSpawn)}
	                     	{Send PBombs changePlayer(player(port:H.port pos:PosSpawn))}
	                     	{DoAction H PBombs P_GUI}
	                  	else
	                  		{Send PBombs removePlayer(H)}
	                  		local
	                  			PlayersList
	                  		in
	                  			{Send PBombs readPlayers(PlayersList)}
		                     	for Ps in PlayersList do
		                        	{Send Ps.port info(deadPlayer(IDSpawn))}
		                     	end
		                    end
	                  	end                                   
	               	end
	            else                          
			         case Action 
			         of move(Pos) then            
			            {Send P_GUI movePlayer(ID Pos)}
			            {Send PBombs changePlayer(player(port:H.port pos:Pos))}
			            local
			            	PlayersList
			            	Map
			            in
			            	{Send PBombs readPlayers(PlayersList)}
				            for E in PlayersList do
				               {Send E.port info(movePlayer(ID Pos))}
				            end
				            {Send PBombs readMap(Map)}
			            	Type =  {Nth {Nth Map Pos.y} Pos.x}
			            end
			            if Type == 5 then
			               	{Send P_GUI hidePoint(Pos)}
			               	local 
			                  	Score 
			               	in
			                  	{Send H.port add(point 1 Score)}
			                  	{Send P_GUI scoreUpdate(ID Score)}
			               	end
			               	{Send PBombs changeMap(type:deletePoint pos:Pos)}
			            elseif Type == 6 then
			               	{Send P_GUI hideBonus(Pos)}
			               	if ({OS.rand} mod 2 ) == 0 then
			               		Thrash
			               		in
			                  	{Send H.port add(bomb 1 Thrash)}
			               	else
			                  	local 
			                     	Score 
			                  	in
			                     	{Send H.port add(point 10 Score)}
			                     	{Send P_GUI scoreUpdate(ID Score)}
			                  	end
			               	end  
			               	{Send PBombs changeMap(type:deleteBonus pos:Pos)}     		            	
			            end
			        [] bomb(Pos) then                
			            {Send P_GUI spawnBomb(Pos)}
			            local 
			            	PlayersList
			            in
			            	{Send PBombs readPlayers(PlayersList)}
				            for E in PlayersList do
				               	{Send E.port info(bombPlanted(Pos))}
				            end
				        end
			            {Send PBombs addBomb(bomb(pos:Pos port:H.port))}
			        else
			            {Browser.browse Action} 
			        end
			        local
			        	RandTime = Input.thinkMin + {OS.rand} mod (Input.thinkMax - Input.thinkMin)
			        in
			        	{Delay RandTime}
			        	{DoAction H PBombs P_GUI}
			        end
			    end
			end                 
	    end
   	end
   	

   	proc{LaunchSimul PlayersList P_GUI}			 				   		
      	local  
      		PBombs = {HandlePort Input.map PlayersList P_GUI}           	
      	in
	        for P in PlayersList do
	            thread 
	               	{DoAction P PBombs P_GUI}
	            end
	        end
      	end			   	
	end
end