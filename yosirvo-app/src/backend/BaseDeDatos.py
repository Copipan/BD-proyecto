import cx_Oracle

def get_connection():
    return cx_Oracle.connect("usuario", "contraseña", "host:")
