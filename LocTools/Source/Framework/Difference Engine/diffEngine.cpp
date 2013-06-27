/*!
 @header
 diffEngine.m
 Created by max on 17.03.05.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "diffEngine.h"

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>

#include <time.h>

class Dict
{
public:
	Dict();
	~Dict();
	
	void set(const char *key, int val);
	int get(const char *key);
	
private:
	int *counts;
	int *values;
	const char **keys;
	
	int _length();
	int _index(const char *key);
};


DiffEngine::DiffEngine()
{
	xhash = yhash = NULL;
	xchanged = ychanged = NULL;
	xv = yv = NULL;
	xind = yind = NULL;
	
	from_lines = to_lines = NULL;
	n_from = n_to = 0;
}

DiffEngine::~DiffEngine()
{
    if (xhash) delete xhash;
	if (xchanged) free(xchanged);
	if (xv) free(xv);
	if (xind) free(xind);
	
    if (yhash) delete yhash;
	if (ychanged) free(ychanged);
	if (yv) free(yv);
	if (yind) free(yind);
}

void DiffEngine::set_from(const char *lines[], int n)
{
	// reset
	if (xhash) delete xhash;
	xhash = new Dict;
	
    // rescale
	if (n > n_from) {
		xchanged = (bool*) realloc(xchanged, sizeof(int) * n);
		xv = (const char **) realloc(xv, sizeof(const char*) * n);
		xind = (int *) realloc(xind, sizeof(int) * n);
	}
	
	// set
	from_lines = lines;
	n_from = n;
}

void DiffEngine::set_to(const char *lines[], int n)
{
	// reset
	if (yhash) delete yhash;
	yhash = new Dict;
	
    // rescale
	if (n > n_to) {
		ychanged = (bool*) realloc(ychanged, sizeof(int) * n);
		yv = (const char **) realloc(yv, sizeof(const char*) * n);
		yind = (int *) realloc(yind, sizeof(int) * n);
	}
	
	// set
	to_lines = lines;
	n_to = n;
}

vector<DiffOperation*>* DiffEngine::diff()
{
    vector<DiffOperation*> *edits;
    int skip, endskip, xi, yi;
    
    xv_len = 0;
    yv_len = 0;
	
    // Skip leading common lines.
    for (skip = 0; skip < n_from && skip < n_to; skip++) {
        if (strcmp(from_lines[skip], to_lines[skip]))
            break;
        xchanged[skip] = ychanged[skip] = false;
    }
    
    // Skip trailing common lines.
    xi = n_from; yi = n_to;
    for (endskip = 0; --xi > skip && --yi > skip; endskip++) {
        if (strcmp(from_lines[xi], to_lines[yi]))
            break;
        xchanged[xi] = ychanged[yi] = false;
    }
    
    // Ignore lines which do not exist in both files.
    for (xi = skip; xi < n_from - endskip; xi++)
        xhash->set(from_lines[xi], true);
	
    for (yi = skip; yi < n_to - endskip; yi++) {
        const char *line = to_lines[yi];
        if ((ychanged[yi] = (xhash->get(line) == 0)))
            continue;
        yhash->set(line, true);
        yv[yv_len++] = line;
    }
	
    for (xi = skip; xi < n_from - endskip; xi++) {
        const char *line = from_lines[xi];
        if ((xchanged[xi] = (yhash->get(line) == 0)))
            continue;
        xv[xv_len++] = line;
	}
    
    // Compute the edit operations.
    edits = new vector<DiffOperation*>;
    xi = yi = 0;
    while (xi < n_from || yi < n_to)
     {
        vector<const char*> copy, add, del;
        DiffOperation *op;
        
        // Skip matching "snake".
        while (xi < n_from && yi < n_to && !xchanged[xi] && !ychanged[yi]) {
            copy.push_back(from_lines[xi++]);
            ++yi;
        }
        if (copy.size()) {
            op = new DiffOperation(&copy, &copy, DiffOpCopy);
            edits->push_back(op);
        }
        
        // Find deletes & adds.
        while (xi < n_from && xchanged[xi])
            del.push_back(from_lines[xi++]);
        
        while (yi < n_to && ychanged[yi])
            add.push_back(to_lines[yi++]);
        
        if (del.size() && add.size()) {
            op = new DiffOperation(&del, &add, DiffOpChange);
            edits->push_back(op);
        }
		else if (del.size()) {
            op = new DiffOperation(&del, NULL, DiffOpDelete);
            edits->push_back(op);
        }
		else if (add.size()) {
            op = new DiffOperation(NULL, &add, DiffOpAdd);
            edits->push_back(op);
        }
     }
    
    return edits;
}

#pragma mark - DiffOperation

DiffOperation::DiffOperation(vector<const char *> *oldL, vector<const char *> *newL, DiffOpType t)
{
	if (oldL != NULL)
		oldLines = *oldL;
	if (newL != NULL)
		newLines = *newL;
	type = t;
}

#pragma mark - Dict

Dict::Dict()
{
    values = (int*) calloc(sizeof(int), 1);
    counts = (int*) calloc(sizeof(int), 1);
    keys = (const char**) calloc(sizeof(const char*), 1);
    
    values[0] = NULL;
    counts[0] = NULL;
    keys[0] = NULL;
}

Dict::~Dict()
{
    free(values);
    free(counts);
    free(keys);
}

void Dict::set(const char *key, int val)
{
    int index, len;
    
    index = _index(key);
    if (index == -1) {
        len = _length();
        
        values = (int*) realloc(values, sizeof(int) * (len + 1));
        values[len] = NULL;
        
        counts = (int*) realloc(counts, sizeof(int) * (len + 1));
        counts[len - 1] = 0;
        counts[len] = NULL;
        
        keys = (const char**) realloc(keys, sizeof(const char*) * (len + 1));
        keys[len - 1] = key;
        keys[len] = NULL;
        
        index = len - 1;
    }
    
    // extend array
    values[index] = val;
    counts[index]++;
}

int Dict::get(const char *key)
{
    int index;
    
    index = _index(key);
    
    if (index == -1)
        return NULL;
    
    counts[index]--;
    return values[index];
}

int Dict::_index(const char *key)
{
    int index = -1;
    
    while (keys[++index] != NULL)
        if (!strcmp(key, keys[index]) && counts[index] > 0)
            return index;
    
    return -1;
}

int Dict::_length()
{
    int index = -1;
    
    while (keys[++index] != NULL) ;
    
    return index+1;
}

