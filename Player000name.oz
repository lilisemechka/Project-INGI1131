functor
import
   Input
   Browser
   Projet2019util
export
   portPlayer:StartPlayer
define   
   StartPlayer
   TreatStream
   Name = 'namefordebug'

   %Attributes
   PlayerID
   SpawnPos
   PlayerState
in
   fun{StartPlayer ID}
      Stream Port OutputStream      
   in
      thread %% filter to test validity of message sent to the player
         OutputStream = {Projet2019util.portPlayerChecker Name ID Stream}
      end
      PlayerID = ID
      {NewPort Stream Port}
      thread
	     {TreatStream OutputStream}
      end
      Port
   end

   
   proc{TreatStream Stream} %% TODO you may add some arguments if needed
      %% TODO complete
      case Stream of nil then skip
      [] getId(ID) then ID = PlayerID
      [] getState(ID State) then 
         ID = PlayerID
         State = PlayerState
      [] assignSpawn(Pos) then SpawnPos = Pos
      [] spawn(ID Pos) then 
         PlayerState = on
         ID = PlayerID
         Pos = SpawnPos
      end
   end
   

end
