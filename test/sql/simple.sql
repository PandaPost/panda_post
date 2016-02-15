\set ECHO none

\i test/pgxntool/setup.sql

CREATE TEMP TABLE test_cast(
  input 		text
  , test_type 	regtype
  , element_out	text
  , array_out	text
);
INSERT INTO test_cast VALUES
	  ('{t,f,t}',	'boolean[]',	'True',				'[ True False  True]' )
	, ('{1,2,3}',	'smallint[]',	'1',				'[1 2 3]' )
	, ('{1,2,3}',	'int[]',		'1',				'[1 2 3]' )
	, ('{1,2,3}',	'bigint[]',		'1',				'[1 2 3]' )
	, ('{1,2,3}',	'real[]',		'1.0',				'[ 1.  2.  3.]' )
	, ('{1,2,3}',	'float[]',		'1.0',				'[ 1.  2.  3.]' )
	, ('{1,2,3}',	'numeric[]',	'1',				$$[Decimal('1') Decimal('2') Decimal('3')]$$ )
	, ('{a,b,c}',	'text[]',		'a',				$$['a' 'b' 'c']$$ )
;

SELECT plan( (
	1
	+ 6 * (SELECT count(*) FROM test_cast)
		- 2 -- Can't run 2 tests on numeric
)::int );

--SET client_min_messages=debug;
SELECT is(
  str( pg_temp.test_value() )
  , '[  1   2   3 444]'
  , 'Simple test of str'
);

CREATE FUNCTION pg_temp.test_cast(
	i test_cast
) RETURNS SETOF text LANGUAGE plpgsql AS $body$
DECLARE
	element_type CONSTANT regtype := replace( i.test_type::text, '[]', '' );
	n ndarray;
	out text;
BEGIN
	-- ARRAY
	EXECUTE format(
			$$SELECT $1::%s::ndarray$$
			, i.test_type
		)
		INTO n
		USING i.input
	;
	IF element_type <> 'numeric'::regtype THEN
		RETURN NEXT is(
			str(eval('np.'||repr(n)))
			, str(n)
			, 'Test str(eval(repr(n))) = str(ndarray)'
		);
	END IF;

	RETURN NEXT is(
		str(n)
		, i.array_out
		, 'str() output of ' || i.test_type || '::ndarray'
	);

	EXECUTE format(
			$fmt$SELECT is(
				$1::%1$s
				, $2::%1$s
				, 'Cast %1$s to ndarray and back'
			)$fmt$
			, i.test_type
		)
		INTO out
		USING n, i.input
	;
	RETURN NEXT out;


	-- SINGLE ELEMENT
	EXECUTE format(
			$$SELECT ($1::%s)[1]::ndarray$$
			, i.test_type
		)
		INTO n
		USING i.input
	;
	IF element_type <> 'numeric'::regtype THEN
		RETURN NEXT is(
			str(eval('np.'||repr(n)))
			, str(n)
			, 'Test str(eval(repr(n))) = str(ndarray)'
		);
	END IF;

	RETURN NEXT is(
		str(n)
		, i.element_out
		, 'str() output of ' || element_type  || '::ndarray'
	);

	EXECUTE format(
			$fmt$SELECT is(
				$1::%2$s
				, ($2::%1$s)[1]
				, 'Cast %2$s to ndarray and back'
			)$fmt$
			, i.test_type
			, element_type
		)
		INTO out
		USING n, i.input
	;
	RETURN NEXT out;
END
$body$;

SELECT pg_temp.test_cast(t.*) FROM test_cast t;

\i test/pgxntool/finish.sql

-- vi: noexpandtab sw=4 ts=4
