
from sqlalchemy import TEXT, VARCHAR, Column, LargeBinary
from models.base import Base
from sqlalchemy.orm import relationship


class User(Base):
    #Creating table named users
    __tablename__ = 'users'
    #Defining user table attributes
    id = Column(TEXT, primary_key=True )
    name = Column(VARCHAR(100)) 
    email = Column(VARCHAR(100))
    password = Column(LargeBinary)
    #Two sided relationship
    favorites = relationship('Favorite', back_populates='user')