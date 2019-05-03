functor
import
   Player000bomber
   Player055Random
   Player055Clever

   Player001Turing
   Player016Intel
   Player033AI
   Player033DP
   Player100advanced
   %% Add here the name of the functor of a player
   %% Player000name
export
   playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   fun{PlayerGenerator Kind ID}
      case Kind
      of player000bomber then {Player000bomber.portPlayer ID}
      %% Add here the pattern to recognize the name used in the 
      %% input file and launch the portPlayer function from the functor
      [] player055random then {Player055Random.portPlayer ID}
      [] player055clever then {Player055Clever.portPlayer ID}
      [] player001turing then {Player001Turing.portPlayer ID}
      [] player016intel then {Player016Intel.portPlayer ID}
      [] player033ai then {Player033AI.portPlayer ID}
      [] player033dp then {Player033DP.portPlayer ID}
      [] player100advanced then {Player100advanced.portPlayer ID}
      else
         raise 
            unknownedPlayer('Player not recognized by the PlayerManager '#Kind)
         end
      end
   end
end
