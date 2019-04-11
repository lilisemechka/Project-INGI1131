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
   PlayerID
   SpawnPos

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
      [] assignSpawn(Pos) then SpawnPos = Pos
      [] spawn(ID Pos) then 
         ID = PlayerID
         Pos = SpawnPos
      end
   end
   

end
