import random
import string
import pyodbc
# hosting a database locally, got connection timeout sometimes when u use Ethernet instead of Wifi, turn of Ethernet, 
# try Wifi and plug again

# đổi tên Server để chạy được trên máy của mn nha
conn = pyodbc.connect('Driver={ODBC Driver 17 for SQL Server};'
                      'Server=LAPTOP-6KGH4NMD;'
                      'Database=QLPHONGKHAM;'
                      'Trusted_Connection=yes;', autocommit=True) # autocommit for fast transaction

# Create a cursor object.
cursor = conn.cursor()

command = """
EXEC sys.sp_msforeachtable 'DELETE FROM ?'
"""
cursor.execute(command)

cursor.close()
conn.close()