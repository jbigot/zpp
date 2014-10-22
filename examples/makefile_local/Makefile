BPP_PATH:="../.."
BPP_COMPILER_ID:=Gnu

BPP:=$(BPP_PATH)/scripts/bpp
BPPOPTS:=-I $(BPP_PATH)/include -DBPP_CONFIG=config.$(BPP_COMPILER_ID)

example: example.F90
	$(FC) -o $@ $<

%: %.bpp
	$(BPP) $(BPPOPTS) $< $@
