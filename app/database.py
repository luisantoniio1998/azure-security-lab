import os
import certifi
import psycopg
from azure.identity import AzureCliCredential, ManagedIdentityCredential
from uuid import uuid4
from psycopg.rows import dict_row

def connect():
    production = os.getenv("APP_ENV") == "production"
    credential = (
        ManagedIdentityCredential() if production else AzureCliCredential()
    )

    with credential:
        token = credential.get_token(
            "https://ossrdbms-aad.database.windows.net/.default"
        )

    return psycopg.connect(
        host=os.environ["PGHOST"],
        dbname=os.environ["PGDATABASE"],
        user=os.environ["PGUSER"],
        password=token.token,
        sslmode="verify-full",
        sslrootcert=certifi.where(),
        connect_timeout=10,
        row_factory=dict_row,
    )

def list_notes():
    with connect() as conn:
        return conn.execute(
            "SELECT * FROM notes ORDER BY created_at DESC"
        ).fetchall()


def create_note(text):
    with connect() as conn:
        return conn.execute(
            "INSERT INTO notes (id, text) VALUES (%s, %s) RETURNING *",
            (uuid4(), text),
        ).fetchone()


def delete_note(note_id):
    with connect() as conn:
        result = conn.execute(
            "DELETE FROM notes WHERE id = %s", (note_id,)
        )
        return result.rowcount > 0
