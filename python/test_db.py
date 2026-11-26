import psycopg

conn = psycopg.connect(
    host="localhost",
    port=5432,
    dbname="window_orders",
    user="admin",
    password="12345",
)

cur = conn.cursor()

cur.execute("SELECT version()")

print(cur.fetchone())