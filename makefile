# ----------------------------
# group nb 55
# 64811600 : Liliya Semerikova
# 24601600 : Gildas Mulders
# ----------------------------

# TODO complete the header with your group number, your noma's and full names
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)

ozCompiler := @ozc
ozExecuter := @ozengine

else

ozCompiler := @../../../../Applications/Mozart2.app/Contents/Resources/bin/ozc
ozExecuter := @../../../../Applications/Mozart2.app/Contents/Resources/bin/ozengine

endif

all : compile run 

compile : Main.ozf GUI.ozf PlayerManager.ozf Init.ozf Utilitaries.ozf TurnByTurn.ozf Simultaneous.ozf

compilePlayers : Random.oz Player001name.oz
	$(ozCompiler) -c Random.oz Player001name.oz

run : Main.ozf 
	$(ozExecuter) Main.ozf

Main.ozf : Main.oz GUI.ozf Input.ozf PlayerManager.ozf Init.ozf Utilitaries.ozf TurnByTurn.ozf Simultaneous.ozf
	$(ozCompiler) -c Main.oz

Init.ozf : Init.oz
	$(ozCompiler) -c Init.oz

Utilitaries.ozf : Utilitaries.oz
	$(ozCompiler) -c Utilitaries.oz

TurnByTurn.ozf : TurnByTurn.oz
	$(ozCompiler) -c TurnByTurn.oz

Simultaneous.ozf : Simultaneous.oz
	$(ozCompiler) -c Simultaneous.oz

GUI.ozf : GUI.oz
	$(ozCompiler) -c GUI.oz

Input.ozf : Input.oz
	$(ozCompiler) -c Input.oz

PlayerManager.ozf : PlayerManager.oz
	$(ozCompiler) -c PlayerManager.oz

clean : 
	@rm -f Main.ozf GUI.ozf Input.ozf PlayerManager.ozf Init.ozf Utilitaries.ozf TurnByTurn.ozf Simultaneous.ozf