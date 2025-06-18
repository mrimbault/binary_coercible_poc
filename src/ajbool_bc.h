#ifndef AJBOOL_BC_H
#define AJBOOL_BC_H
#include "fmgr.h"

/* using unsigned to allow up to 255 positive values */
typedef uint8 ajbool_bc;

/* use char instead of defining our own datum
#define DatumGetAjBoolBc(X) ((ajbool_bc) (X))
#define AjBoolBcGetDatum(X) ((Datum) (X))
#define PG_GETARG_AJBOOL_BC(n)    DatumGetAjBoolBc(PG_GETARG_DATUM(n))
#define PG_RETURN_AJBOOL_BC(x)    return AjBoolBcGetDatum(x)
 */
#define PG_GETARG_AJBOOL_BC(n) ((ajbool_bc) PG_GETARG_CHAR(n))
#define PG_RETURN_AJBOOL_BC(x) PG_RETURN_CHAR((char) (x))

Datum ajbool_bc_to_bool(PG_FUNCTION_ARGS);
/* we don't define a cast function for bool->ajbool
 * Datum bool_to_ajbool(PG_FUNCTION_ARGS);
 */
Datum ajbool_bc_in(PG_FUNCTION_ARGS);
Datum ajbool_bc_out(PG_FUNCTION_ARGS);

/* Add: extra functions definition */
Datum ajbool_bc_recv(PG_FUNCTION_ARGS);
Datum ajbool_bc_send(PG_FUNCTION_ARGS);

/* Add: comparison operators */
Datum ajbool_bc_eq(PG_FUNCTION_ARGS);
Datum ajbool_bc_ne(PG_FUNCTION_ARGS);
Datum ajbool_bc_lt(PG_FUNCTION_ARGS);
Datum ajbool_bc_le(PG_FUNCTION_ARGS);
Datum ajbool_bc_gt(PG_FUNCTION_ARGS);
Datum ajbool_bc_ge(PG_FUNCTION_ARGS);
Datum ajbool_bc_cmp(PG_FUNCTION_ARGS);

#endif   /* AJBOOL_BC_H */
