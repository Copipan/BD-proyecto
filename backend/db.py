import os
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv

# Cargar las variables de entorno desde el archivo .env
load_dotenv()

def get_connection():
    connection = None
    try:
        # Conectamos usando parámetros individuales para evitar errores de parseo con símbolos
        connection = psycopg2.connect(
            host=os.getenv('DB_HOST'),
            port=os.getenv('DB_PORT'),
            database=os.getenv('DB_NAME'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD')
        )

        cursor = connection.cursor(cursor_factory=RealDictCursor)

        yield cursor

        connection.commit()

    except Exception as e:
        if connection:
            connection.rollback()
        raise e
    finally:
        if connection:
            connection.close()