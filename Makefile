CXXFLAGS=-Wall -I./include

all: rc_switch

rc_switch: main.cpp src/pru.o include/pru.h rc_switch_out.bin rc_switch_in.bin
	g++ $(CXXFLAGS) main.cpp src/pru.o -lprussdrv -lpthread -o rc_switch

rc_switch_out.bin: src/rc_switch_out.p include/pru.hp
	cd src; pasm -b rc_switch_out.p; mv rc_switch_out.bin ../; cd ..
	
rc_switch_in.bin: src/rc_switch_in.p include/pru.hp
	cd src; pasm -b rc_switch_in.p; mv rc_switch_in.bin ../; cd ..
	
clean:
	rm rc_switch_out.bin rc_switch src/*.o