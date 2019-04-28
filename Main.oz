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
define
   P_GUI
   Players 
in
   %% Create MAP
   P_GUI = {GUI.portWindow}

   {Send P_GUI buildWindow}

   Players = {Init.getPlayers P_GUI}   

   {Delay 7000}
   {Browser.browse 1}
   {TurnByTurn.doActionTBT Players nil Input.map P_GUI}

end
