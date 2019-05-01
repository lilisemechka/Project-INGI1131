functor
import
   GUI
   Input
   PlayerManager
   Browser
   OS
   TurnByTurn
   Utilitaries
   Init
   Simultaneous
define
   P_GUI
   Players 
in
   %% Create MAP
   P_GUI = {GUI.portWindow}

   {Send P_GUI buildWindow}

   Players = {Init.getPlayers P_GUI}   

   {Delay 5000}
   if Input.isTurnByTurn then
      {TurnByTurn.doActionTBT Players nil Input.map Players P_GUI}
   else
      {Simultaneous.launchSimul Players P_GUI}
   end
end
