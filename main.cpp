/* Copyright (c) 2013 Owen McAree
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#include "pru.h"

// Entry point
int main() {
	// Initialise PRU
	PRU *myPRU0 = new PRU(0);
	PRU *myPRU1 = new PRU(1);
	myPRU0->stop();
	myPRU1->stop();
	
	// Set up output data for PRU0
	// Offset of 2048 is there for legacy reasons (compatibility with node-pru)
	// Because this is shared memory we use offset of 50
	// So we don't conflict with PRU1
	myPRU0->setSharedMemoryInt(2048 + 50 + 0, 0);
	myPRU0->setSharedMemoryInt(2048 + 50 + 1, 0);
	myPRU0->setSharedMemoryInt(2048 + 50 + 2, 0);
	myPRU0->setSharedMemoryInt(2048 + 50 + 3, 1);
	myPRU0->setSharedMemoryInt(2048 + 50 + 4, 0);
	myPRU0->setSharedMemoryInt(2048 + 50 + 5, 0);
	myPRU0->setSharedMemoryInt(2048 + 50 + 6, 0xF);
	myPRU0->setSharedMemoryInt(2048 + 50 + 7, 0xF);
	myPRU0->setSharedMemoryInt(2048 + 50 + 8, 0xF);
	myPRU0->setSharedMemoryInt(2048 + 50 + 9, 0xF);
	myPRU0->setSharedMemoryInt(2048 + 50 + 10, 0);
	myPRU0->setSharedMemoryInt(2048 + 50 + 11, 0xF);
	
	// Run PRU1, this will block until PRU0 pulls pin high at start of sync
	myPRU1->execute("rc_switch_in.bin");
	
	// Wait a while to make sure PRU1 is happy
	usleep(1000000);
	
	// Execute PRU0 to send dummy signal
	myPRU0->execute("rc_switch_out.bin");	

	// Wait until PRU1 status is set to 1, indicating data has arrived
	while (myPRU1->getSharedMemoryInt(2048 + 0) != 1) {
	}
	myPRU1->setSharedMemoryInt(2048 + 0, 0);
	
	// Get data
	int data = myPRU1->getSharedMemoryInt(2048 + 1);
	
	// Print out data
	for (int i = 0; i < 12; i++) {
		int bit = (data >> (i*2)) & 3;
		switch (bit) {
			case 0:
				printf("0");
				break;
			case 1:
				printf("?");
				break;
			case 2:
				printf("F");
				break;
			case 3:
				printf("1");
				break;
		}
	}
	printf("\n");
		
	// Clear the status register so we know data has been dealt with
	myPRU1->setSharedMemoryInt(0, 0);
}
 