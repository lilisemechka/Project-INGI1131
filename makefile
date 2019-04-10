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

Main.ozf : Main.oz GUI.ozf Input.ozf PlayerManager.ozf
	ozc -c Main.oz

GUI.ozf : GUI.oz
	ozc -c GUI.oz

Input.ozf : Input.oz
	ozc -c Input.oz

PlayerManager.ozf : PlayerManager.oz
	ozc -c PlayerManager.oz

clean : 
	@rm -f Main.ozf GUI.ozf Input.ozf PlayerManager.ozf

else

all : clean main 

main : Main.ozf 
	../../../../Applications/Mozart2.app/Contents/Resources/bin/ozengine Main.ozf

Main.ozf : Main.oz GUI.ozf Input.ozf PlayerManager.ozf
	../../../../Applications/Mozart2.app/Contents/Resources/bin/ozc -c Main.oz

GUI.ozf : GUI.oz
	../../../../Applications/Mozart2.app/Contents/Resources/bin/ozc -c GUI.oz

Input.ozf : Input.oz
	../../../../Applications/Mozart2.app/Contents/Resources/bin/ozc -c Input.oz

PlayerManager.ozf : PlayerManager.oz
	../../../../Applications/Mozart2.app/Contents/Resources/bin/ozc -c PlayerManager.oz

clean : 
	@rm -f Main.ozf GUI.ozf Input.ozf PlayerManager.ozf

endif
