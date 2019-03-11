###############################################################################
#                     Makefile for Arduino Duemilanove/Uno                    #
#             Copyright (C) 2011 Álvaro Justen <alvaro@justen.eng.br>         #
#                         http://twitter.com/turicas                          #
#                                                                             #
# This project is hosted at GitHub: http://github.com/turicas/arduinoMakefile #
#                                                                             #
# This program is free software; you can redistribute it and/or               #
#  modify it under the terms of the GNU General Public License                #
#  as published by the Free Software Foundation; either version 2             #
#  of the License, or (at your option) any later version.                     #
#                                                                             #
# This program is distributed in the hope that it will be useful,             #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of             #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              #
#  GNU General Public License for more details.                               #
#                                                                             #
# You should have received a copy of the GNU General Public License           #
#  along with this program; if not, please read the license at:               #
#  http://www.gnu.org/licenses/gpl-2.0.html                                   #
###############################################################################

include $(PWD)/config

SKETCH_NAME=DHT_PROJECT

# The port Arduino is connected
#  Uno, in GNU/linux: generally /dev/ttyACM0
#  Duemilanove, in GNU/linux: generally /dev/ttyUSB0
ifneq ($(CONFIG_PORT),)
   PORT=$(CONFIG_PORT)
else
   PORT=/dev/ttyACM0
endif

# The path of Arduino IDE
KERNEL_DIR=$(PWD)

#Compiler and uploader configuration
ARDUINO_CORE=$(KERNEL_DIR)/cores/arduino
INCLUDE=-I. \
	-I$(KERNEL_DIR)/cores/arduino \
	-I$(KERNEL_DIR)/variants/standard

include drivers/Makefile
include libraries/Makefile

TMP_DIR=$(PWD)/out
CC=/usr/bin/avr-gcc
CPP=/usr/bin/avr-g++
AVR_OBJCOPY=/usr/bin/avr-objcopy 
AVRDUDE=/usr/bin/avrdude
CC_FLAGS=-g -Os -w -Wall -ffunction-sections -fdata-sections -fno-exceptions \
	 -std=gnu99
CPP_FLAGS=-g -Os -w -Wall -ffunction-sections -fdata-sections -fno-exceptions
AVRDUDE_CONF=/etc/avrdude.conf
CORE_C_FILES= hooks WInterrupts wiring_analog wiring wiring_digital \
	     wiring_pulse wiring_shift
CORE_CPP_FILES=HardwareSerial main Print Tone WMath WString

all:		clean compile upload

clean:
		@echo '# *** Cleaning...'
		rm -rf "$(TMP_DIR)"

compile:
		@echo '# *** Compiling...'

		mkdir -p $(TMP_DIR)/bin
		mkdir -p $(TMP_DIR)/lib

		@#Compiling the sketch file:
		$(CPP) -c -mmcu=$(MCU) -DF_CPU=$(DF_CPU) $(INCLUDE) \
		       $(CPP_FLAGS) "$(KERNEL_DIR)/$(SKETCH_NAME).cpp" \
		       -o "$(TMP_DIR)/$(SKETCH_NAME).o"
		
		@#Compiling Arduino core .c dependecies:
		for core_c_file in ${CORE_C_FILES}; do \
		    $(CC) -c -mmcu=$(MCU) -DF_CPU=$(DF_CPU) $(INCLUDE) \
		          $(CC_FLAGS) $(ARDUINO_CORE)/$$core_c_file.c \
			  -o $(TMP_DIR)/$$core_c_file.o; \
		done

		@#Compiling Arduino core .cpp dependecies:
		for core_cpp_file in ${CORE_CPP_FILES}; do \
		    $(CPP) -c -mmcu=$(MCU) -DF_CPU=$(DF_CPU) $(INCLUDE) \
		           $(CPP_FLAGS) $(ARDUINO_CORE)/$$core_cpp_file.cpp \
			   -o $(TMP_DIR)/$$core_cpp_file.o; \
		done

		@#Compiling Arduino libraries .cpp dependecies:
		for lib_cpp_file in ${LIB_CPP_FILES}; do \
		    $(CPP) -c -mmcu=$(MCU) -DF_CPU=$(DF_CPU) $(INCLUDE) \
		           $(CPP_FLAGS) $(KERNEL_DIR)/libraries/*/$$lib_cpp_file.cpp \
			   -o $(TMP_DIR)/lib/$$lib_cpp_file.o; \
		done

		@#Compiling Arduino libraries .c dependecies:
		for lib_c_file in ${LIB_C_FILES}; do \
		    $(CC) -c -mmcu=$(MCU) -DF_CPU=$(DF_CPU) $(INCLUDE) \
		          $(CC_FLAGS) $(KERNEL_DIR)/libraries/*/$$lib_c_file.c \
			  -o $(TMP_DIR)/lib/$$lib_c_file.o; \
		done

		@#Compiling Drivers .cpp dependecies:
		for drivers_cpp_file in ${DRIVERS_CPP_FILES}; do \
		    $(CPP) -c -mmcu=$(MCU) -DF_CPU=$(DF_CPU) $(INCLUDE) \
		           $(CPP_FLAGS) $(KERNEL_DIR)/drivers/*/$$drivers_cpp_file.cpp \
			   -o $(TMP_DIR)/$$drivers_cpp_file.o; \
		done


		@#TODO: compile external libraries here
		@#TODO: use .d files to track dependencies and compile them
		@#      change .c by -MM and use -MF to generate .d

		$(CC) -mmcu=$(MCU) -lm -Wl,--gc-sections -Os \
		      -o $(TMP_DIR)/bin/$(SKETCH_NAME).elf $(TMP_DIR)/*.o
		$(AVR_OBJCOPY) -O ihex -R .eeprom \
		               $(TMP_DIR)/bin/$(SKETCH_NAME).elf \
			       $(TMP_DIR)/bin/$(SKETCH_NAME).hex
		@echo '# *** Compiled successfully! \o/'


reset:
		@echo '# *** Resetting...'
		stty --file $(PORT) hupcl
		sleep 0.1
		stty --file $(PORT) -hupcl
		

ifeq ($(CONFIG_UPLOAD),y)
upload:
		@echo '# *** Uploading...'
		sudo $(AVRDUDE) -q -V -p $(MCU) -C $(AVRDUDE_CONF) -c $(BOARD_TYPE) \
		           -b $(BAUD_RATE) -P $(PORT) \
			   -U flash:w:$(TMP_DIR)/bin/$(SKETCH_NAME).hex:i
		@echo '# *** Done - enjoy your sketch!'
else
upload:
endif

