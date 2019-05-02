functor
export
	changeMap:ChangeMap
	bestScore:BestScore
	boxCheck:BoxCheck
define
	ChangeMap
   	BestScore
   	BoxCheck
in
	%Change MAP 
   	fun {ChangeMap Map Pos Type}
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
	      	       elseif Type == deleteFireBB then 8|T
	      	       elseif Type == bbAndFire then 9|T
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
   	fun{BestScore Players}
      	fun{BestScoreAcc Players AccPt AccId}
	 		case Players of H|T then
	    		local 
	    			Result 
	    			ID 
	    		in 
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
      	local 
      		AccId 
      	in
	 		{BestScoreAcc Players ~1 AccId}
      	end
   	end
   
   	%%Return true if there are no more boxes on the map false otherwise
   	fun{BoxCheck Map}
      	case Map
      	of H|T then
	     	case H of nil then {BoxCheck T}
	     	[] H1|T1 then
	        	if H1 == 2 then false
	        	elseif H1 == 3 then false
	        	else
	           		{BoxCheck T1|T}
	        	end
	     	end
      	[] nil then true
      	end
   	end
end