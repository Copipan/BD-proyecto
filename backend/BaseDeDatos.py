import cx_Oracle

#cx_Oracle.init_oracle_client(lib_dir=r"C:\OracleXE\instantclient_23_8")

def get_connection():
    return cx_Oracle.connect("yosirvo", "yosirvo", "localhost:1521/xepdb1")
