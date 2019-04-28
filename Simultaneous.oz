functor
define
	HandlePort
	TreatBombs
	DoAction
	Simul
in
	
   	fun{HandlePort}
      	local
         	S
         	R = {NewPort S}
      	in
         	thread {TreatBombs S nil Input.map} end
         	R
      	end
   	end

   proc{TreatBombs Stream Bombs Map}

      case Stream 
      of nil then skip
      [] H|T then 
         case H
         of 



   	proc{DoAction H Bombs NewBombs Map FinalMap PlayersList NewPlayerList}
	    local 
	        ID
	        Action
	        NewMap
	        Type
	    in            
	        {Send H.port doaction(ID Action)}
	        local 
	            IDState 
	          	State 
	        in
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
	               	local 
	                  	Score 
	               	in
	                  	{Send H.port add(point 1 Score)}
	                  	{Send P_GUI scoreUpdate(ID Score)}
	               	end
	               	{DoActionTBT {Append T player(port:H.port pos:Pos)|nil} {HandleBombs Bombs Map NewMap PlayersList} {ChangeMap NewMap Pos deletePoint}}
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
	               	NewBombs = {HandleBombs Bombs Map NewMap PlayersList} 
	               	FinalMap = {ChangeMap NewMap Pos deleteBonus}                   
	            else 
	               	{DoActionTBT {Append T player(port:H.port pos:Pos)|nil} {HandleBombs Bombs Map NewMap PlayersList} NewMap}                  
	            end
	        [] bomb(Pos) then                
	            {Send P_GUI spawnBomb(Pos)}
	            for E in PlayersList do
	               	{Send E.port info(bombPlanted(Pos))}
	            end
	            {DoActionTBT {Append T H|nil} bomb(pos:Pos timer:Input.timingBomb*Input.nbBombers port:H.port)|{HandleBombs Bombs Map NewMap PlayersList} NewMap}
	        else
	            {Browser.browse Action} 
	        end                 
	    end
   	end

   proc{Simul PlayersList Bombs Map}
      	local         
         	NewBombs
         	NewMap
      	in
	        for P in PlayersList do
	            thread 
	               	{DoAction P Bombs NewBombs Map NewMap PlayersList}
	            	end
	         	end
	         	{Simul PlayersList NewBombs NewMap}
      	end
   	end
end