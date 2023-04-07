import sqlite3

con = sqlite3.connect(":memory:")

cur = con.cursor()

cur.execute("CREATE TABLE lit(value, id)")
cur.execute("CREATE TABLE addd(left,right)")

cur.execute("""
    CREATE  TRIGGER add_add AFTER INSERT ON addd
    BEGIN
        INSERT INTO lit VALUES ((SELECT value FROM lit WHERE id = new.left)+(SELECT value FROM lit WHERE id = new.right),(SELECT MAX(id) + 1 FROM lit));
    END
""")

# (3+4)+5
cur.execute("INSERT INTO lit VALUES (3,1)")
cur.execute("INSERT INTO lit VALUES (4,2)")
cur.execute("INSERT INTO addd VALUES (1,2)")
cur.execute("INSERT INTO lit VALUES (5,4)")
cur.execute("INSERT INTO addd VALUES (3,4)")

(res,) = cur.execute("SELECT value FROM lit WHERE id = (SELECT MAX(id) FROM lit)").fetchone()

print(res)


# Extend type
cur.execute("CREATE TABLE mul(left,right)")

cur.execute("""
    CREATE  TRIGGER mul_mul AFTER INSERT ON mul
    BEGIN
        INSERT INTO lit VALUES ((SELECT value FROM lit WHERE id = new.left)*(SELECT value FROM lit WHERE id = new.right),(SELECT MAX(id) + 1 FROM lit));
    END
""")

# Execute
# ((3+4)+5)*5
cur.execute("INSERT INTO lit VALUES (5,6)")
cur.execute("INSERT INTO mul VALUES (5,6)")

(res,) = cur.execute("SELECT value FROM lit WHERE id = (SELECT MAX(id) FROM lit)").fetchone()

print(res)

# Clear
cur.execute("DELETE FROM addd")
cur.execute("DELETE FROM mul")

# Extend functionality
cur.execute("CREATE TABLE print(expr,id)")

# Only insert first lit
cur.execute("INSERT INTO print VALUES ('',1)")
cur.execute("""
    CREATE  TRIGGER lit_print AFTER INSERT ON lit
    BEGIN
        INSERT INTO print VALUES ((SELECT expr FROM print WHERE id = (SELECT MAX(id) FROM print)) || new.value ,(SELECT MAX(id) + 1 FROM print));
    END
""")

cur.execute("""
    CREATE  TRIGGER addd_print AFTER INSERT ON addd
    BEGIN
        INSERT INTO print VALUES ((SELECT expr FROM print WHERE id = (SELECT MAX(id) FROM print)) || ' + ' || (SELECT value FROM lit WHERE id = new.right) ,(SELECT MAX(id) + 1 FROM print));
    END
""")

cur.execute("""
    CREATE  TRIGGER mul_print AFTER INSERT ON mul
    BEGIN
        INSERT INTO print VALUES ((SELECT expr FROM print WHERE id = (SELECT MAX(id) FROM print)) || ' * ' || (SELECT value FROM lit WHERE id = new.right) ,(SELECT MAX(id) + 1 FROM print));
    END
""")

# ((3+4)+5)*5
cur.execute("INSERT INTO lit VALUES (3,1)")
cur.execute("INSERT INTO lit VALUES (4,2)")
cur.execute("INSERT INTO addd VALUES (1,2)")
cur.execute("INSERT INTO lit VALUES (5,4)")
cur.execute("INSERT INTO addd VALUES (3,4)")
cur.execute("INSERT INTO lit VALUES (5,6)")
cur.execute("INSERT INTO mul VALUES (5,6)")

(res,) = cur.execute("SELECT expr FROM print WHERE id = (SELECT MAX(id) FROM print)").fetchone()

print(res)

# Clear
cur.execute("DELETE FROM lit")
cur.execute("DELETE FROM addd")
cur.execute("DELETE FROM mul")
cur.execute("DELETE FROM print")
cur.execute("INSERT INTO print VALUES ('',1)")


# (2+3)*(4+5)
# 2+3
cur.execute("INSERT INTO lit VALUES (2,1)")
cur.execute("INSERT INTO lit VALUES (3,2)")
cur.execute("INSERT INTO addd VALUES (1,2)") # 3
# 4+5
cur.execute("INSERT INTO lit VALUES (4,4)")
cur.execute("INSERT INTO lit VALUES (5,5)")
cur.execute("INSERT INTO addd VALUES (4,5)") # 6

cur.execute("INSERT INTO mul VALUES (3,6)")

print("")
(res,) = cur.execute("SELECT expr FROM print WHERE id = (SELECT MAX(id) FROM print)").fetchone()
print(res)
(res,) = cur.execute("SELECT value FROM lit WHERE id = (SELECT MAX(id) FROM lit)").fetchone()
print(res)

print(cur.execute("SELECT value FROM lit").fetchall())

