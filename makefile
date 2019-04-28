# ----------------------------
# group nb 99
# noma1 : Liliya Semerikova
# 24601600 : Gildas Mulders
# ----------------------------

# TODO complete the header with your group number, your noma's and full names
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)

all : clean main 

main : Main.ozf 
	ozengine Main.ozf

Main.ozf : Main.oz GUI.ozf Input.ozf PlayerManager.ozf Init.ozf Utilitaries.ozf TurnByTurn.ozf Simultaneous.ozf
	ozc -c Main.oz

Init.ozf : Init.oz
	ozc -c Init.oz

Utilitaries.ozf : Utilitaries.oz
	ozc -c Utilitaries.oz

TurnByTurn.ozf : TurnByTurn.oz
	ozc -c TurnByTurn.oz

Simultaneous.ozf : Simultaneous.oz
	ozc -c Simultaneous.oz

GUI.ozf : GUI.oz
	ozc -c GUI.oz

Input.ozf : Input.oz
	ozc -c Input.oz

PlayerManager.ozf : PlayerManager.oz
	ozc -c PlayerManager.oz

clean : 
	@rm -f Main.ozf GUI.ozf Input.ozf PlayerManager.ozf Init.ozf Utilitaries.ozf TurnByTurn.ozf Simultaneous.ozf

else

all : clean main 

main : Main.ozf 
	../../../../Applications/Mozart2.app/Contents/Resources/bin/ozengine Main.ozf

Main.ozf : Main.oz GUI.ozf Input.ozf PlayerManager.ozf Init.ozf Utilitaries.ozf TurnByTurn.ozf Simultaneous.ozf
	../../../../Applications/Mozart2.app/Contents/Resources/bin/ozc -c Main.oz

Init.ozf : Init.oz
	../../../../Applications/Mozart2.app/Contents/Resources/bin/ozc -c Init.oz

Utilitaries.ozf : Utilitaries.oz
	../../../../Applications/Mozart2.app/Contents/Resources/bin/ozc -c Utilitaries.oz

TurnByTurn.ozf : TurnByTurn.oz
	../../../../Applications/Mozart2.app/Contents/Resources/bin/ozc -c TurnByTurn.oz

Simultaneous.ozf : Simultaneous.oz
	../../../../Applications/Mozart2.app/Contents/Resources/bin/ozc -c Simultaneous.oz

GUI.ozf : GUI.oz
	../../../../Applications/Mozart2.app/Contents/Resources/bin/ozc -c GUI.oz

Input.ozf : Input.oz
	../../../../Applications/Mozart2.app/Contents/Resources/bin/ozc -c Input.oz

PlayerManager.ozf : PlayerManager.oz
	../../../../Applications/Mozart2.app/Contents/Resources/bin/ozc -c PlayerManager.oz

clean : 
	@rm -f Main.ozf GUI.ozf Input.ozf PlayerManager.ozf Init.ozf Utilitaries.ozf TurnByTurn.ozf Simultaneous.ozf

endif
