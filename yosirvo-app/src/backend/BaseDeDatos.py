import cx_Oracle

def get_connection():
    return cx_Oracle.connect("yosirvo", "yosirvo", "localhost:1521/xepdb1")
