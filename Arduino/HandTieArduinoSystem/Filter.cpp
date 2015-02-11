#include "Filter.h"

void shortBubbleSort(uint16_t* vals, int32_t numVals) {
		
	bool exchanges = true;
	int32_t passnum = numVals - 1;
	while(passnum > 0 && exchanges) {
		exchanges = false;
		for(int i = 0;i < passnum;i++) {
			if(vals[i] > vals[i+1]) {
				exchanges = true;
				uint16_t temp = vals[i];
				vals[i] = vals[i+1];
				vals[i+1] = temp;
			}
		}
		passnum--;
	}

}

uint16_t Filter::compute(FilterConfig* config) {
	uint32_t numVals = 0;
	switch(config->filterType) {
		/*
		case FIR_FILTER:
			//not yet implemented XD	
			break;
		*/
		case MEDIAN_FILTER:
			//sorting first and get the median vals
			numVals = config->numInputVals;
			shortBubbleSort(config->inputVals, numVals);
			if(numVals % 2 == 0) { //even number
				return (config->inputVals[numVals/2] + config->inputVals[numVals/2 - 1])/2;
			}
			else {
				return config->inputVals[(numVals-1)/2];
			}
			break;
		default:
			return 0;
			break;

	}

} 