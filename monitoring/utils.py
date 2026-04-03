from database_monitoring.database import get_db
from sqlalchemy import text
from sqlalchemy.orm import Session
from fastapi import Depends, FastAPI

def save_to_db(session, table, data):
    """Saves data to the specified table in the database."""
    insert_stmt = table.insert().values(**data)
    session.execute(insert_stmt)
    session.commit()
