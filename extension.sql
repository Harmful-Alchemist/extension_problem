-- Original variants
CREATE TABLE lit(value,id);
CREATE TABLE addd(left,right);

CREATE TRIGGER add_add AFTER INSERT ON addd
BEGIN
    INSERT INTO lit
    VALUES ((SELECT value FROM lit WHERE id = new.left) + (SELECT value FROM lit WHERE id = new.right),
            (SELECT MAX(id) + 1 FROM lit));
END;

-- (3+4)+5
INSERT INTO lit VALUES (3, 1);
INSERT INTO lit VALUES (4, 2);
INSERT INTO addd VALUES (1, 2);
INSERT INTO lit VALUES (5, 4);
INSERT INTO addd VALUES (3, 4);

SELECT value FROM lit WHERE id = (SELECT MAX(id) FROM lit);

-- Extend variants
CREATE TABLE mul("left","right");

CREATE TRIGGER mul_mul AFTER INSERT ON mul
BEGIN
    INSERT INTO lit
    VALUES ((SELECT value FROM lit WHERE id = new.left) * (SELECT value FROM lit WHERE id = new.right),
            (SELECT MAX(id) + 1 FROM lit));
END;

-- ((3+4)+5)*5
INSERT INTO lit VALUES (5, 6);
INSERT INTO mul VALUES (5, 6);

-- SELECT value FROM lit WHERE id = (SELECT MAX(id) FROM lit);

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
    VALUES ((SELECT expr FROM print WHERE id = new.left) || ' + ' || (SELECT expr FROM print WHERE id = new.right),
            (SELECT MAX(id) + 1 FROM lit));
END;

CREATE TRIGGER mul_print AFTER INSERT ON mul
BEGIN
    INSERT INTO print
    VALUES ((SELECT expr FROM print WHERE id = new.left) || ' * ' || (SELECT expr FROM print WHERE id = new.right),
            (SELECT MAX(id) + 1 FROM lit));
END;

-- ((3+4)+5)*5
INSERT INTO lit VALUES (3, 1);
INSERT INTO lit VALUES (4, 2);
INSERT INTO addd VALUES (1, 2);
INSERT INTO lit VALUES (5, 4);
INSERT INTO addd VALUES (3, 4);
INSERT INTO lit VALUES (5, 6);
INSERT INTO mul VALUES (5, 6);

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
INSERT INTO addd VALUES (1, 2); -- 3
-- 4+5
INSERT INTO lit VALUES (4, 4);
INSERT INTO lit VALUES (5, 5);
INSERT INTO addd VALUES (4, 5); -- 6
--  *
INSERT INTO mul VALUES (3, 6);

SELECT expr FROM print WHERE id = (SELECT MAX(id) FROM print);
-- SELECT value FROM lit WHERE id = (SELECT MAX(id) FROM lit);







-- drop so can rerun script
DROP TABLE addd; DROP TABLE lit; DROP TABLE mul; DROP TABLE print;