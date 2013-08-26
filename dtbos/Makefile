all: bone_pru_rcs-00A0.dtbo

install:
	cp -v *.dtbo /lib/firmware
	
clean: 
	rm *.dtbo

%.dtbo : %.dts
	dtc -O dtb -o $@ -b 0 -@ $<