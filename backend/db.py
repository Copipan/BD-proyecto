import cx_Oracle

# import oracledb

# No la borren pls, es para que la pueda correr yo (el maik xdlol)
# cx_Oracle.init_oracle_client(lib_dir=r"C:\OracleXE\instantclient_23_8")


def get_connection():
    return cx_Oracle.connect("yosirvo", "yosirvo", "localhost:1521/xepdb1")


# Oscar: Ocupe usar driver para hacerlo funcionar
# def get_connection():
#     return oracledb.connect(
#         user="yosirvo", password="yosirvo", dsn="localhost:1521/xepdb1"
#     )
