TARGET:=none
CPU:=65C02
LINKER_CONFIG:=memory.cfg
ROM:=AT28C256

CA65:=ca65
LD65:=ld65
UPLOADER:=minipro

CA65_FLAGS:=--target $(TARGET) --cpu $(CPU) -U -g --feature labels_without_colons
LD65_FLAGS:=-C $(LINKER_CONFIG) -m ehbasic.map -Ln ehbasic.lbl
UPLOADER_FLAGS:=-uP -p $(ROM) -w ehbasic.rom

SRC_FILES:=main.s
OBJ_FILES:=$(SRC_FILES:.s=.o)

.PHONY: all clean upload

all: ehbasic.rom

ehbasic.rom: $(OBJ_FILES)
	$(LD65) $(LD65_FLAGS) $^ -o $@

%.o: %.s
	$(CA65) $(CA65_FLAGS) $< -o $@ -l $(@:.o=.lst)

upload: ehbasic.rom
	$(UPLOADER) $(UPLOADER_FLAGS)

clean:
	rm -f *.o *.rom *.lst *.map *.lbl
