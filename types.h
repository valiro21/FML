#ifndef TYPES_H
#define TYPES_H
typedef struct var_value {
  union
  {
    char TYPE_BOOL_VAL;
    char TYPE_CHAR_VAL;
    int TYPE_INT_VAL;
    float TYPE_FLOAT_VAL;
    long long TYPE_LONGLONG_VAL;
    double TYPE_DOUBLE_VAL;
  };

  char type;
} var_value;

#define FIELD(var,type) var.type##_VAL

#define CAST(r,t1,t1type,t2,t2type,op) if (t2.type == t2type) {if(t1type <= t2type) { \
																						r.type=t2type; \
                                            FIELD(r, t2type) = FIELD(t1,t1type) op FIELD(t2,t2type); \
																				} \
                                        else { \
																						r.type =t1type; \
                                            FIELD(r, t1type) = FIELD(t1,t1type) op FIELD(t2,t2type); \
                                        } }


#define SVAR TYPE_BOOL,TYPE_CHAR,TYPE_INT,TYPE_FLOAT,TYPE_LONGLONG,TYPE_DOUBLE;
#define SETVARS TYPE_BOOL=0,TYPE_CHAR=1,TYPE_INT=2,TYPE_FLOAT=3,TYPE_LONGLONG=4,TYPE_DOUBLE=5;
extern char SVAR;

#define SET(r,t1,TYPE,t2,op) if (t1.type == TYPE) { \
                            CAST (r,t1,TYPE,t2, TYPE_BOOL, op) \
                            CAST (r,t1,TYPE,t2, TYPE_CHAR, op) \
                            CAST (r,t1,TYPE,t2, TYPE_INT, op) \
                            CAST (r,t1,TYPE,t2, TYPE_FLOAT, op) \
                            CAST (r,t1,TYPE,t2, TYPE_LONGLONG, op) \
                            CAST (r,t1,TYPE,t2, TYPE_DOUBLE, op) \
                            }
#define SOLVE(r,t1,t2,op)  SETVARS \
                            SET (r, t1, TYPE_BOOL, t2, op) \
                            SET (r, t1, TYPE_CHAR, t2, op) \
                            SET (r, t1, TYPE_INT, t2, op) \
                            SET (r, t1, TYPE_FLOAT, t2, op) \
                            SET (r, t1, TYPE_LONGLONG, t2, op) \
                            SET (r, t1, TYPE_DOUBLE, t2, op) \

#define TYPE_ASSIGN(r,t1,TYPE) if(TYPE == t1.type) { \
																	FIELD(r,TYPE) = FIELD(t1,TYPE); \
																	r.type=TYPE; \
																}

#define ASSIGN(r,t1)  SETVARS \
                      TYPE_ASSIGN(r,t1,TYPE_BOOL) \
                      TYPE_ASSIGN(r,t1,TYPE_CHAR) \
                      TYPE_ASSIGN(r,t1,TYPE_INT) \
                      TYPE_ASSIGN(r,t1,TYPE_FLOAT) \
                      TYPE_ASSIGN(r,t1,TYPE_LONGLONG) \
                      TYPE_ASSIGN(r,t1,TYPE_DOUBLE)

const char * format_TYPE_BOOL;
const char * format_TYPE_CHAR;
const char * format_TYPE_INT;
const char * format_TYPE_FLOAT;
const char * format_TYPE_LONGLONG;
const char * format_TYPE_DOUBLE;

#define GET_FORMAT(TYPE) format_##TYPE

#define TYPE_PRINT(r,TYPE) if(TYPE == r.type) { \
																	printf (GET_FORMAT(TYPE), FIELD(r,TYPE)); \
																}

#define PRINT(r)   SETVARS \
                      TYPE_PRINT(r,TYPE_BOOL) \
                      TYPE_PRINT(r,TYPE_CHAR) \
                      TYPE_PRINT(r,TYPE_INT) \
                      TYPE_PRINT(r,TYPE_FLOAT) \
                      TYPE_PRINT(r,TYPE_LONGLONG) \
                      TYPE_PRINT(r,TYPE_DOUBLE)
#endif