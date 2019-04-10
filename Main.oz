functor
import
   GUI
   Input
   PlayerManager
define
   ID P
   Init
   Players
in
   %% Implement your controller here
   P = {GUI.portWindow}
   {Send P buildWindow}

   %% 
   fun{Init N Names Colors Acc}
      if N > 0 then
	     local NewPlayer in
	        NewPlayer = bomber(id:Acc name:Names.1 color:Colors.1)
	        {Send P initPlayer(NewPlayer)}
	        {PlayerManager.playerGenerator NewPlayer.name NewPlayer}|{Init N-1 Names.2 Colors.2 Acc+1}
	     end
      else
        nil
      end
   end
   Players = {Init Input.nbBombers Input.bombers Input.colorsBombers 1}
end
