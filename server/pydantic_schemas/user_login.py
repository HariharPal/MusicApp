#Type validation by pydantic_schemas
from pydantic import BaseModel
class UserLogin(BaseModel):
    email : str
    password: str