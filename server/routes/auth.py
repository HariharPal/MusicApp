import uuid
import bcrypt
from fastapi import Depends, HTTPException, Header
from database import get_db
from middleware.auth_middleware import auth_middleware
from models.user import User
from pydantic_schemas.user_create import UserCreate
from pydantic_schemas.user_login import UserLogin
from fastapi import APIRouter
from sqlalchemy.orm import Session, joinedload
import jwt

router = APIRouter()

@router.post('/signup', status_code= 201)
def signup_user(user: UserCreate, db : Session = Depends(get_db)):
    #Check if user exists in the database
    user_db = db.query(User).filter(User.email == user.email).first()
    
    if user_db:
        raise HTTPException(400, "User with same email already exists!!")
        

    #Just like git we initialize at user_db , add at db.add(__) and commit our data as db.commit(__)
    ## bcrypt.gensalt() is a method which add some random value among the variable passed to ensure even same variable have different hashes
    ## bcrypt.hashpw hashes password using given salt. (variable , salt ) in this case salt is bcrypt.gensalt() 
    hashed_pw = bcrypt.hashpw(user.password.encode(), bcrypt.gensalt() )
    user_db = User(id=str(uuid.uuid4()), email= user.email, password = hashed_pw, name = user.name)
    #adding user in the database
    db.add(user_db)
    db.commit()
    db.refresh(user_db)
    return user_db

@router.post('/login')
def login_user(user: UserLogin, db: Session = Depends(get_db)):
    
    #Check if user with same email already exists or not
    user_db = db.query(User).filter(User.email == user.email).first()
    if not user_db:
        raise HTTPException(400, "User with this Email does not exists")
    #Password matching or not
    ## bcrypt.checkpw: extracts salts added in hashedpassword
    isMatch = bcrypt.checkpw(user.password.encode(), user_db.password)
    if not isMatch:
        raise HTTPException(400, "Password doesn't match, Incorrect Password!")
        
    #Creating twt token 
    token  = jwt.encode({'id':user_db.id}, 'password_key')

    return {'token': token , 'user':user_db}
    #Return data or not depends upon matching
   

@router.get('/')
def current_user_data(db: Session = Depends(get_db), user_dict  = Depends(auth_middleware)):
    user = db.query(User).filter(User.id == user_dict['uid']).options(joinedload(User.favorites)).first()
    if not user:
        raise HTTPException(404, "User not found!")
    return user