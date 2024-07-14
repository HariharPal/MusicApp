from sqlalchemy import Column, ForeignKey, TEXT
from models.base import Base
from sqlalchemy.orm import relationship

class Favorite(Base):

    __tablename__ = "favorites"
    id = Column(TEXT, primary_key=True)
    song_id = Column(TEXT, ForeignKey("songs.id"))
    user_id = Column(TEXT, ForeignKey("users.id"))
    #Establishing relationship between song pydantic_schemas
    song = relationship('Song')
    user = relationship('User', back_populates='favorites')