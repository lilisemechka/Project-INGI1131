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
in
	
   	fun{HandlePort Map TB PlayersList}
      	local
         	S
         	R = {NewPort S}
      	in
         	thread TB = {TreatBombs S nil nil Map 0 PlayersList} end
         	R
      	end
   	end

   	fun{TreatBombs Stream Bombs Players Map PlayersPlayed PlayersList}
      	case Stream 
      	of nil then nil
      	[] H|T then 
         	case H
         	of addBomb(B) then 
         		{TreatBombs T B|Bombs Players Map PlayersPlayed PlayersList}
         	[] addPlayer(Player) then
         		{TreatBombs T Bombs Player|Players Map PlayersPlayed PlayersList}
         	[] changeMap(type:Type pos:Pos) then
         		{TreatBombs T Bombs Players {Utilitaries.changeMap Map Pos Type} PlayersPlayed PlayersList}
         	[] played then
         		if PlayersPlayed + 1 == {Length PlayersList} then
         			[Bombs Players Map]
         		else 
         			{TreatBombs T Bombs Players Map PlayersPlayed+1 PlayersList}
         		end
        	end
        end
    end



   	proc{DoAction H Map PlayersList PBombs P_GUI}
	    local 
	        ID
	        Action
	        NewMap
	        Type
	        IDState 
	        State
	    in            
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
                     	{Send PBombs addPlayer(player(port:H.port pos:PosSpawn))}
                  	else
                     	for Ps in PlayersList do
                        	{Send Ps.port info(deadPlayer(IDSpawn))}
                     	end
                  	end                                   
               	end
            else                          
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
		               	{Send PBombs addPlayer(player(port:H.port pos:Pos))}
		               	{Send PBombs changeMap(type:deletePoint pos:Pos)}
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
		               	{Send PBombs addPlayer(player(port:H.port pos:Pos))} 
		               	{Send PBombs changeMap(type:deleteBonus pos:Pos)}                  
		            else 
		            	{Send PBombs addPlayer(player(port:H.port pos:Pos))}		            	
		            end
		        [] bomb(Pos) then                
		            {Send P_GUI spawnBomb(Pos)}
		            for E in PlayersList do
		               	{Send E.port info(bombPlanted(Pos))}
		            end
		            {Send PBombs addPlayer(H)}
		            {Send PBombs addBomb(bomb(pos:Pos timer:Input.timingBomb port:H.port))}
		        else
		            {Browser.browse Action} 
		        end
		    end                 
	    end
	    {Send PBombs played}
   	end
   	

   	proc{LaunchSimul PlayersList P_GUI}
   		local   			 	
		   	proc{Simul PlayersListLoc Bombs Map P_GUI}		   		 
		   		{Delay 3000}
		   		if {Utilitaries.boxCheck Map} then 
         			{Send P_GUI displayWinner({Utilitaries.bestScore PlayersList})}
         			{Delay 10000}
         			skip
      			else
         			case PlayersListLoc 
         			of H|nil then       
	            		{Send P_GUI displayWinner({Utilitaries.bestScore PlayersList})}
	            		{Delay 10000}
	            		skip
         			[] nil then
	            		{Send P_GUI displayWinner({Utilitaries.bestScore PlayersList})}
	            		{Delay 10000}
	            		skip
            		else
				      	local    
				      		TB
				      		PBombs = {HandlePort Map TB PlayersListLoc}  
				      		NewPlayersList   
				         	NewBombs
				         	ChangedMap
				         	NewMap         	
				      	in
					        for P in PlayersListLoc do
					            thread 
					               	{DoAction P Map PlayersListLoc PBombs P_GUI}
					            end
					        end
					        {Wait TB}
					        {Simul TB.2.1 {Append {TurnByTurn.handleBombs Bombs TB.2.2.1 NewMap TB.2.1 P_GUI} TB.1} NewMap P_GUI}
				      	end
				    end
				end
		   	end
		in
			{Simul PlayersList nil Input.map P_GUI}
		end
	end
end