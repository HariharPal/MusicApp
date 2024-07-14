from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker


#Setup connection with database
DATABASE_URL = "postgresql://postgres:1507@localhost:5432/musicapp"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit = False, autoflush=False, bind= engine)

#Access to database
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally: 
        db.close()
