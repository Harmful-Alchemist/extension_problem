-- Original variants
CREATE TABLE lit(value,id);
CREATE TABLE addd("left","right",out);

CREATE TRIGGER add_add AFTER INSERT ON addd
BEGIN
    INSERT INTO lit
    VALUES ((SELECT value FROM lit WHERE id = new.left) + (SELECT value FROM lit WHERE id = new.right),new.out);
END;

-- (3+4)+5
INSERT INTO lit VALUES (3, 1);
INSERT INTO lit VALUES (4, 2);
INSERT INTO addd VALUES (1, 2, 3);
INSERT INTO lit VALUES (5, 4);
INSERT INTO addd VALUES (3, 4, 5);

SELECT value FROM lit WHERE id = 5;

-- Extend variants
CREATE TABLE mul("left","right",out);

CREATE TRIGGER mul_mul AFTER INSERT ON mul
BEGIN
    INSERT INTO lit
    VALUES ((SELECT value FROM lit WHERE id = new.left) * (SELECT value FROM lit WHERE id = new.right), new.out);
END;

-- ((3+4)+5)*5
INSERT INTO lit VALUES (5, 6);
INSERT INTO mul VALUES (5, 6, 7);

-- Clear
DELETE FROM lit;
DELETE FROM addd;
DELETE FROM mul;

-- Extend functionality
CREATE TABLE print (expr,id);

CREATE TRIGGER lit_print AFTER INSERT ON lit
BEGIN
    INSERT INTO print VALUES (new.value, new.id);
END;

CREATE TRIGGER addd_print AFTER INSERT ON addd
BEGIN
    INSERT INTO print
    VALUES ((SELECT expr FROM print WHERE id = new.left) || ' + ' || (SELECT expr FROM print WHERE id = new.right),new.out);
END;

CREATE TRIGGER mul_print AFTER INSERT ON mul
BEGIN
    INSERT INTO print
    VALUES ((SELECT expr FROM print WHERE id = new.left) || ' * ' || (SELECT expr FROM print WHERE id = new.right),new.out);
END;

-- ((3+4)+5)*5
INSERT INTO lit VALUES (3, 1);
INSERT INTO lit VALUES (4, 2);
INSERT INTO addd VALUES (1, 2, 3);
INSERT INTO lit VALUES (5, 4);
INSERT INTO addd VALUES (3, 4, 5);
INSERT INTO lit VALUES (5, 6);
INSERT INTO mul VALUES (5, 6, 7);

SELECT expr FROM print WHERE id = (SELECT MAX(id) FROM lit);

-- Clear
DELETE FROM lit;
DELETE FROM addd;
DELETE FROM mul;
DELETE FROM print;

--              (2+3)*(4+5)
-- 2+3
INSERT INTO lit VALUES (2, 1);
INSERT INTO lit VALUES (3, 2);
INSERT INTO addd VALUES (1, 2, 3);
-- 4+5
INSERT INTO lit VALUES (4, 4);
INSERT INTO lit VALUES (5, 5);
INSERT INTO addd VALUES (4, 5, 6);
--  *
INSERT INTO mul VALUES (3, 6, 7);

SELECT expr FROM print WHERE id = (SELECT MAX(id) FROM print);

-- Try and parse with CTE, to get an idea of possibilities, as a toy thing. Very very basic only single digits, no whitespace handling, + after * wont work...
--clear
DELETE FROM lit;
DELETE FROM addd;
DELETE FROM mul;
DELETE FROM print;

create table step_store(content,id,type);

WITH RECURSIVE step(to_read,id_counter,type) AS (
    SELECT '1+2+3*3*4', 1, 'lit'
    UNION ALL
    SELECT substr(step.to_read,2),id_counter+1,
        CASE
            WHEN substr(step.to_read,2,1) = '+' AND id_counter=1 THEN 'first_add'
            WHEN substr(step.to_read,2,1) = '*' AND id_counter=1 THEN 'first_mul'
            WHEN substr(step.to_read,2,1) = '+' THEN 'add'
            WHEN substr(step.to_read,2,1) = '*' THEN 'mul'
            ELSE 'lit'
        END
        FROM step
    LIMIT length('1+2+3*3*4')
)
INSERT INTO step_store (content,id,type) SELECT substr(step.to_read, 1 , 1), id_counter, type FROM step;

INSERT INTO lit (value, id) SELECT content,id FROM step_store WHERE type = 'lit' ORDER BY id;
INSERT INTO addd ("left", "right",out) SELECT id-1,id+1,id FROM step_store WHERE type= 'first_add' ORDER BY id;
INSERT INTO mul ("left", "right",out) SELECT id-1,id+1,id FROM step_store WHERE type= 'first_mul' ORDER BY id;
-- So wont work with adds after muls...... But I need family time too so won't fix :)
INSERT INTO addd ("left", "right",out) SELECT id-2,id+1,id FROM step_store WHERE type= 'add' ORDER BY id;
INSERT INTO mul ("left", "right",out) SELECT id-2,id+1,id FROM step_store WHERE type= 'mul' ORDER BY id;

SELECT expr FROM print WHERE id = (SELECT MAX(id)-1 FROM print);

-- drop so can rerun script
DROP TABLE addd; DROP TABLE lit; DROP TABLE mul; DROP TABLE print;DROP TABLE step_store;