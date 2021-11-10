/*!
 @header
 diffEngine.h
 Created by max on 17.03.05.

 @copyright 2009 Localization Suite. All rights reserved.

 @discussion Simplified C++ version of Wikipedias's DifferenceEngine.
 See http://cvs.sourceforge.net/viewcvs.py/wikipedia/phase3/includes/DifferenceEngine.php for details.
 */

#include <vector>
using namespace std;

class DiffOperation;
class Dict;

class DiffEngine {
  private:
	bool *xchanged;
	bool *ychanged;

	Dict *xhash;
	Dict *yhash;

	const char **xv;
	int *xind;
	const char **yv;
	int *yind;
	int xv_len;
	int yv_len;

	const char **from_lines;
	const char **to_lines;
	int n_from;
	int n_to;

  public:
	DiffEngine();
	~DiffEngine();

	void set_from(const char *from_lines[], int n_from);
	void set_to(const char *to_lines[], int n_to);
	vector<DiffOperation *> *diff();
};

typedef enum {
	DiffOpCopy = 0,
	DiffOpChange = 1,
	DiffOpDelete = 2,
	DiffOpAdd = 3
} DiffOpType;

class DiffOperation {
  public:
	vector<const char *> oldLines;
	vector<const char *> newLines;
	DiffOpType type;

	DiffOperation(vector<const char *> *oldL, vector<const char *> *newL, DiffOpType t);
};
