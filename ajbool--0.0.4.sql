-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION ajbool" to load this file. \quit

/* original ajbool type */

CREATE FUNCTION ajbool_in(cstring)
RETURNS ajbool
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;


CREATE FUNCTION ajbool_out(ajbool)
RETURNS cstring
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION ajbool_recv(internal)
RETURNS ajbool
LANGUAGE internal IMMUTABLE AS 'charrecv';

CREATE FUNCTION ajbool_send(ajbool)
RETURNS bytea
LANGUAGE internal IMMUTABLE AS 'charsend';

CREATE TYPE ajbool (
    INPUT          = ajbool_in,
    OUTPUT         = ajbool_out,
    RECEIVE        = ajbool_recv,
    SEND           = ajbool_send,
    INTERNALLENGTH = 1,
ALIGNMENT      = char,
    STORAGE        = plain,
    CATEGORY       = 'B',
    PASSEDBYVALUE
);
COMMENT ON TYPE ajbool IS 'boolean type with explict NULL';

CREATE FUNCTION ajbool_to_bool(ajbool) RETURNS bool AS
'MODULE_PATHNAME'
LANGUAGE c IMMUTABLE STRICT;

CREATE CAST (ajbool AS bool)
WITH FUNCTION ajbool_to_bool(ajbool) AS IMPLICIT;

CREATE FUNCTION bool_to_ajbool(bool) RETURNS ajbool
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE;

CREATE CAST (bool as ajbool) WITH FUNCTION bool_to_ajbool(bool) AS ASSIGNMENT;

CREATE FUNCTION ajbool_eq(ajbool, ajbool)
RETURNS boolean LANGUAGE internal IMMUTABLE AS 'chareq';

CREATE FUNCTION ajbool_ne(ajbool, ajbool)
RETURNS boolean LANGUAGE internal IMMUTABLE AS 'charne';

CREATE FUNCTION ajbool_lt(ajbool, ajbool)
RETURNS boolean LANGUAGE internal IMMUTABLE AS 'charlt';

CREATE FUNCTION ajbool_le(ajbool, ajbool)
RETURNS boolean LANGUAGE internal IMMUTABLE AS 'charle';

CREATE FUNCTION ajbool_gt(ajbool, ajbool)
RETURNS boolean LANGUAGE internal IMMUTABLE AS 'chargt';

CREATE FUNCTION ajbool_ge(ajbool, ajbool)
RETURNS boolean LANGUAGE internal IMMUTABLE AS 'charge';

CREATE FUNCTION ajbool_cmp(ajbool, ajbool)
RETURNS integer LANGUAGE internal IMMUTABLE AS 'btcharcmp';

CREATE FUNCTION hash_ajbool(ajbool)
RETURNS integer LANGUAGE internal IMMUTABLE AS 'hashchar';

CREATE OPERATOR = (
    LEFTARG = ajbool,
    RIGHTARG = ajbool,
    PROCEDURE = ajbool_eq,
    COMMUTATOR = '=',
    NEGATOR = '<>',
    RESTRICT = eqsel,
    JOIN = eqjoinsel
);
COMMENT ON OPERATOR =(ajbool, ajbool) IS 'equals?';

CREATE OPERATOR <> (
    LEFTARG = ajbool,
    RIGHTARG = ajbool,
    PROCEDURE = ajbool_ne,
    COMMUTATOR = '<>',
    NEGATOR = '=',
    RESTRICT = neqsel,
    JOIN = neqjoinsel
);
COMMENT ON OPERATOR <>(ajbool, ajbool) IS 'not equals?';

CREATE OPERATOR < (
    LEFTARG = ajbool,
    RIGHTARG = ajbool,
    PROCEDURE = ajbool_lt,
    COMMUTATOR = > ,
    NEGATOR = >= ,
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);
COMMENT ON OPERATOR <(ajbool, ajbool) IS 'less-than';

CREATE OPERATOR <= (
    LEFTARG = ajbool,
    RIGHTARG = ajbool,
    PROCEDURE = ajbool_le,
    COMMUTATOR = >= ,
    NEGATOR = > ,
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);
COMMENT ON OPERATOR <=(ajbool, ajbool) IS 'less-than-or-equal';

CREATE OPERATOR > (
    LEFTARG = ajbool,
    RIGHTARG = ajbool,
    PROCEDURE = ajbool_gt,
    COMMUTATOR = < ,
    NEGATOR = <= ,
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);
COMMENT ON OPERATOR >(ajbool, ajbool) IS 'greater-than';

CREATE OPERATOR >= (
    LEFTARG = ajbool,
    RIGHTARG = ajbool,
    PROCEDURE = ajbool_ge,
    COMMUTATOR = <= ,
    NEGATOR = < ,
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);
COMMENT ON OPERATOR >=(ajbool, ajbool) IS 'greater-than-or-equal';

CREATE OPERATOR CLASS btree_ajbool_ops
DEFAULT FOR TYPE ajbool USING btree
AS
        OPERATOR        1       <  ,
        OPERATOR        2       <= ,
        OPERATOR        3       =  ,
        OPERATOR        4       >= ,
        OPERATOR        5       >  ,
        FUNCTION        1       ajbool_cmp(ajbool, ajbool);

CREATE OPERATOR CLASS hash_ajbool_ops
    DEFAULT FOR TYPE ajbool USING hash AS
        OPERATOR        1       = ,
        FUNCTION        1       hash_ajbool(ajbool);


/* new ajbool_bc type */

CREATE FUNCTION ajbool_bc_in(cstring)
RETURNS ajbool_bc
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;


CREATE FUNCTION ajbool_bc_out(ajbool_bc)
RETURNS cstring
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

/* use C definition */
CREATE FUNCTION ajbool_bc_recv(internal)
RETURNS ajbool_bc
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

/* use C definition */
CREATE FUNCTION ajbool_bc_send(ajbool_bc)
RETURNS bytea
AS 'MODULE_PATHNAME'
LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE ajbool_bc (
    INPUT          = ajbool_bc_in,
    OUTPUT         = ajbool_bc_out,
    RECEIVE        = ajbool_bc_recv,
    SEND           = ajbool_bc_send,
    INTERNALLENGTH = 1,
ALIGNMENT      = char,
    STORAGE        = plain,
    CATEGORY       = 'B',
    PASSEDBYVALUE
);
COMMENT ON TYPE ajbool_bc IS 'boolean type with explict NULL';

CREATE FUNCTION ajbool_bc_to_bool(ajbool_bc) RETURNS bool AS
'MODULE_PATHNAME'
LANGUAGE c IMMUTABLE STRICT;

CREATE CAST (ajbool_bc AS bool)
WITH FUNCTION ajbool_bc_to_bool(ajbool_bc) AS IMPLICIT;

/* remove conversion function
 * CREATE FUNCTION bool_to_ajbool_bc(bool) RETURNS ajbool_bc
 * AS 'MODULE_PATHNAME'
 * LANGUAGE C IMMUTABLE;
 */

/* cast is now without function, that's critical for binary coercible */
CREATE CAST (bool as ajbool_bc) WITHOUT FUNCTION AS IMPLICIT;

/* comparison functions use new C definitions instead of char ones */
CREATE FUNCTION ajbool_bc_eq(ajbool_bc, ajbool_bc)
RETURNS boolean AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION ajbool_bc_ne(ajbool_bc, ajbool_bc)
RETURNS boolean AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION ajbool_bc_lt(ajbool_bc, ajbool_bc)
RETURNS boolean AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION ajbool_bc_le(ajbool_bc, ajbool_bc)
RETURNS boolean AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION ajbool_bc_gt(ajbool_bc, ajbool_bc)
RETURNS boolean AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION ajbool_bc_ge(ajbool_bc, ajbool_bc)
RETURNS boolean AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION ajbool_bc_cmp(ajbool_bc, ajbool_bc)
RETURNS integer AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION hash_ajbool_bc(ajbool_bc)
RETURNS integer LANGUAGE internal IMMUTABLE AS 'hashchar';

CREATE OPERATOR = (
    LEFTARG = ajbool_bc,
    RIGHTARG = ajbool_bc,
    PROCEDURE = ajbool_bc_eq,
    COMMUTATOR = '=',
    NEGATOR = '<>',
    RESTRICT = eqsel,
    JOIN = eqjoinsel
);
COMMENT ON OPERATOR =(ajbool_bc, ajbool_bc) IS 'equals?';

CREATE OPERATOR <> (
    LEFTARG = ajbool_bc,
    RIGHTARG = ajbool_bc,
    PROCEDURE = ajbool_bc_ne,
    COMMUTATOR = '<>',
    NEGATOR = '=',
    RESTRICT = neqsel,
    JOIN = neqjoinsel
);
COMMENT ON OPERATOR <>(ajbool_bc, ajbool_bc) IS 'not equals?';

CREATE OPERATOR < (
    LEFTARG = ajbool_bc,
    RIGHTARG = ajbool_bc,
    PROCEDURE = ajbool_bc_lt,
    COMMUTATOR = > ,
    NEGATOR = >= ,
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);
COMMENT ON OPERATOR <(ajbool_bc, ajbool_bc) IS 'less-than';

CREATE OPERATOR <= (
    LEFTARG = ajbool_bc,
    RIGHTARG = ajbool_bc,
    PROCEDURE = ajbool_bc_le,
    COMMUTATOR = >= ,
    NEGATOR = > ,
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);
COMMENT ON OPERATOR <=(ajbool_bc, ajbool_bc) IS 'less-than-or-equal';

CREATE OPERATOR > (
    LEFTARG = ajbool_bc,
    RIGHTARG = ajbool_bc,
    PROCEDURE = ajbool_bc_gt,
    COMMUTATOR = < ,
    NEGATOR = <= ,
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);
COMMENT ON OPERATOR >(ajbool_bc, ajbool_bc) IS 'greater-than';

CREATE OPERATOR >= (
    LEFTARG = ajbool_bc,
    RIGHTARG = ajbool_bc,
    PROCEDURE = ajbool_bc_ge,
    COMMUTATOR = <= ,
    NEGATOR = < ,
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);
COMMENT ON OPERATOR >=(ajbool_bc, ajbool_bc) IS 'greater-than-or-equal';

CREATE OPERATOR CLASS btree_ajbool_bc_ops
DEFAULT FOR TYPE ajbool_bc USING btree
AS
        OPERATOR        1       <  ,
        OPERATOR        2       <= ,
        OPERATOR        3       =  ,
        OPERATOR        4       >= ,
        OPERATOR        5       >  ,
        FUNCTION        1       ajbool_bc_cmp(ajbool_bc, ajbool_bc);

CREATE OPERATOR CLASS hash_ajbool_bc_ops
    DEFAULT FOR TYPE ajbool_bc USING hash AS
        OPERATOR        1       = ,
        FUNCTION        1       hash_ajbool_bc(ajbool_bc);

-- adds parallel suport
DO $$
DECLARE version_num integer;
BEGIN
	SELECT current_setting('server_version_num') INTO STRICT version_num;
	IF version_num > 90600 THEN
		EXECUTE $E$ ALTER FUNCTION ajbool_in(cstring) PARALLEL SAFE $E$;
		EXECUTE $E$ ALTER FUNCTION ajbool_out(ajbool) PARALLEL SAFE $E$;
		EXECUTE $E$ ALTER FUNCTION ajbool_recv(internal) PARALLEL SAFE $E$;
		EXECUTE $E$ ALTER FUNCTION ajbool_send(ajbool) PARALLEL SAFE $E$;
		EXECUTE $E$ ALTER FUNCTION ajbool_to_bool(ajbool) PARALLEL SAFE $E$;
		EXECUTE $E$ ALTER FUNCTION bool_to_ajbool(bool) PARALLEL SAFE $E$;
		EXECUTE $E$ ALTER FUNCTION ajbool_eq(ajbool, ajbool) PARALLEL SAFE $E$;
		EXECUTE $E$ ALTER FUNCTION ajbool_ne(ajbool, ajbool) PARALLEL SAFE $E$;
		EXECUTE $E$ ALTER FUNCTION ajbool_lt(ajbool, ajbool) PARALLEL SAFE $E$;
		EXECUTE $E$ ALTER FUNCTION ajbool_le(ajbool, ajbool) PARALLEL SAFE $E$;
		EXECUTE $E$ ALTER FUNCTION ajbool_gt(ajbool, ajbool) PARALLEL SAFE $E$;
		EXECUTE $E$ ALTER FUNCTION ajbool_ge(ajbool, ajbool) PARALLEL SAFE $E$;
		EXECUTE $E$ ALTER FUNCTION ajbool_cmp(ajbool, ajbool) PARALLEL SAFE $E$;
		EXECUTE $E$ ALTER FUNCTION hash_ajbool(ajbool) PARALLEL SAFE $E$;
	END IF;
END;
$$;