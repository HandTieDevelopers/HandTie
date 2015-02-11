#ifndef FILTER_H
#define FILTER_H

#include <Arduino.h>

enum{
   FIR_FILTER,
   MEDIAN_FILTER

};

typedef struct FilterConfig{
	int filterType;
	uint16_t* inputVals;
	uint32_t numInputVals;
	float* inputCoeffs;
	//fast initialization
	FilterConfig(): filterType(0),inputVals(NULL),numInputVals(0),inputCoeffs(NULL)
	{}

} FilterConfig;


class Filter {

public:
	static uint16_t compute(FilterConfig *config);

};

#endif