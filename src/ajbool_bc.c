#include "postgres.h"
#include "ajbool_bc.h"
#include "libpq/pqformat.h"
#include "utils/builtins.h"
#include "common/hashfn.h"

/* matches boolean false */
#define AJBOOL_BC_FALSE                 0
/* matches boolean true */
#define AJBOOL_BC_TRUE                  1
#define AJBOOL_BC_UNKNOWN               255

/* PG_MODULE_MAGIC; */

PG_FUNCTION_INFO_V1(ajbool_bc_to_bool);
/* PG_FUNCTION_INFO_V1(bool_to_ajbool_bc); */
PG_FUNCTION_INFO_V1(ajbool_bc_in);
PG_FUNCTION_INFO_V1(ajbool_bc_out);
/* add extra function */
PG_FUNCTION_INFO_V1(ajbool_bc_recv);
PG_FUNCTION_INFO_V1(ajbool_bc_send);
PG_FUNCTION_INFO_V1(ajbool_bc_eq);
PG_FUNCTION_INFO_V1(ajbool_bc_ne);
PG_FUNCTION_INFO_V1(ajbool_bc_lt);
PG_FUNCTION_INFO_V1(ajbool_bc_le);
PG_FUNCTION_INFO_V1(ajbool_bc_gt);
PG_FUNCTION_INFO_V1(ajbool_bc_ge);
PG_FUNCTION_INFO_V1(ajbool_bc_cmp);

/*
 * cast from ajbool_bc to bool - no change
 */
Datum
ajbool_bc_to_bool(PG_FUNCTION_ARGS)
{
    switch(PG_GETARG_AJBOOL_BC(0))
    {
        case 0: PG_RETURN_BOOL(false);
        case 1: PG_RETURN_BOOL(true);
        default: PG_RETURN_NULL();
    }
}

/*
 * cast from bool to ajbool_bc will not use a function since we make types
 * binary coercible that way
 *
 * Datum
 * bool_to_ajbool_bc(PG_FUNCTION_ARGS)
 * {
 *     if (PG_ARGISNULL(0))
 *         PG_RETURN_AJBOOL_BC(-1);
 *
 *     if (PG_GETARG_BOOL(0) == false)
 *         PG_RETURN_AJBOOL_BC(0);
 *     else
 *         PG_RETURN_AJBOOL_BC(1);
 * }
 */

/*
 * input function - handles boolean-compatible input plus new values
 */
Datum
ajbool_bc_in(PG_FUNCTION_ARGS)
{
    char *str = PG_GETARG_CSTRING(0);

    /* Handle boolean-compatible values first */
    if (pg_strcasecmp(str, "true") == 0 || pg_strcasecmp(str, "t") == 0 ||
        pg_strcasecmp(str, "yes") == 0 || pg_strcasecmp(str, "y") == 0 ||
        pg_strcasecmp(str, "on") == 0 || pg_strcasecmp(str, "1") == 0)
        PG_RETURN_AJBOOL_BC(AJBOOL_BC_TRUE);

    if (pg_strcasecmp(str, "false") == 0 || pg_strcasecmp(str, "f") == 0 ||
        pg_strcasecmp(str, "no") == 0 || pg_strcasecmp(str, "n") == 0 ||
        pg_strcasecmp(str, "off") == 0 || pg_strcasecmp(str, "0") == 0)
        PG_RETURN_AJBOOL_BC(AJBOOL_BC_FALSE);

    /* Handle new values */
    if (pg_strcasecmp(str, "unknown") == 0 || pg_strcasecmp(str, "u") == 0)
        PG_RETURN_AJBOOL_BC(AJBOOL_BC_UNKNOWN);

    ereport(ERROR,
            (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
             errmsg("invalid input syntax for type ajbool_bc: \"%s\"", str),
             errhint("Valid values are: true, false, unknown")));

    PG_RETURN_NULL();
}

Datum
ajbool_bc_out(PG_FUNCTION_ARGS)
{
    ajbool_bc val = PG_GETARG_AJBOOL_BC(0);
    char *result = (char *) palloc(20);

    switch (val) {
        case AJBOOL_BC_TRUE:
            strcpy(result, "true");
            break;
        case AJBOOL_BC_FALSE:
            strcpy(result, "false");
            break;
        case AJBOOL_BC_UNKNOWN:
            strcpy(result, "unknown");
            break;
        default:
            strcpy(result, "?");
            break;
    }

    PG_RETURN_CSTRING(result);
}

/* Add: extra functions definition */

/*
 * Binary input function
 */
Datum
ajbool_bc_recv(PG_FUNCTION_ARGS)
{
    StringInfo buf = (StringInfo) PG_GETARG_POINTER(0);
    PG_RETURN_AJBOOL_BC((ajbool_bc) pq_getmsgint(buf, sizeof(ajbool_bc)));
}

/*
 * Binary output function
 */
Datum
ajbool_bc_send(PG_FUNCTION_ARGS)
{
    ajbool_bc val = PG_GETARG_AJBOOL_BC(0);
    StringInfoData buf;

    pq_begintypsend(&buf);
    pq_sendbyte(&buf, (uint8) val);
    PG_RETURN_BYTEA_P(pq_endtypsend(&buf));
}

/* Add: comparison operators */

Datum
ajbool_bc_eq(PG_FUNCTION_ARGS)
{
    ajbool_bc a = PG_GETARG_AJBOOL_BC(0);
    ajbool_bc b = PG_GETARG_AJBOOL_BC(1);
    PG_RETURN_BOOL(a == b);
}

Datum
ajbool_bc_ne(PG_FUNCTION_ARGS)
{
    ajbool_bc a = PG_GETARG_AJBOOL_BC(0);
    ajbool_bc b = PG_GETARG_AJBOOL_BC(1);
    PG_RETURN_BOOL(a != b);
}

Datum
ajbool_bc_lt(PG_FUNCTION_ARGS)
{
    ajbool_bc a = PG_GETARG_AJBOOL_BC(0);
    ajbool_bc b = PG_GETARG_AJBOOL_BC(1);
    PG_RETURN_BOOL(a < b);
}

Datum
ajbool_bc_le(PG_FUNCTION_ARGS)
{
    ajbool_bc a = PG_GETARG_AJBOOL_BC(0);
    ajbool_bc b = PG_GETARG_AJBOOL_BC(1);
    PG_RETURN_BOOL(a <= b);
}

Datum
ajbool_bc_gt(PG_FUNCTION_ARGS)
{
    ajbool_bc a = PG_GETARG_AJBOOL_BC(0);
    ajbool_bc b = PG_GETARG_AJBOOL_BC(1);
    PG_RETURN_BOOL(a > b);
}

Datum
ajbool_bc_ge(PG_FUNCTION_ARGS)
{
    ajbool_bc a = PG_GETARG_AJBOOL_BC(0);
    ajbool_bc b = PG_GETARG_AJBOOL_BC(1);
    PG_RETURN_BOOL(a >= b);
}

Datum
ajbool_bc_cmp(PG_FUNCTION_ARGS)
{
    ajbool_bc a = PG_GETARG_AJBOOL_BC(0);
    ajbool_bc b = PG_GETARG_AJBOOL_BC(1);

    if (a < b)
        PG_RETURN_INT32(-1);
    else if (a > b)
        PG_RETURN_INT32(1);
    else
        PG_RETURN_INT32(0);
}

