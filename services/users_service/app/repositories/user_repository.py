from sqlalchemy.orm import Session
from typing import List, Optional

from app.models.user import User
from app.schemas.user import UserCreate


class UserRepository:
    """Repository for user database operations"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_by_id(self, user_id: int) -> Optional[User]:
        """Get a user by ID"""
        return self.db.query(User).filter(User.user_id == user_id).first()
    
    def get_by_email(self, email: str) -> Optional[User]:
        """Get a user by email"""
        return self.db.query(User).filter(User.email == email).first()
    
    def list_users(self, skip: int = 0, limit: int = 100) -> List[User]:
        """Get a list of users with pagination"""
        return self.db.query(User).offset(skip).limit(limit).all()
    
    def create(self, user_data: UserCreate) -> User:
        """Create a new user"""
        # Extract data from user_data but exclude password
        user_dict = user_data.model_dump(exclude={"password"})
        user = User(**user_dict)
        # Set the hashed password separately
        user.hashed_password = User.hash_password(user_data.password)
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user
    def update(self, user_id: int, **kwargs) -> Optional[User]:
        """Update user attributes"""
        user = self.get_by_id(user_id)
        if not user:
            return None
        
        for key, value in kwargs.items():
            if key == 'password':
                user.hashed_password = User.hash_password(value)
            elif hasattr(user, key):
                setattr(user, key, value)
        
        self.db.commit()
        self.db.refresh(user)
        return user
    
    def delete(self, user_id: int) -> bool:
        """Delete a user by ID"""
        user = self.get_by_id(user_id)
        if not user:
            return False
        
        self.db.delete(user)
        self.db.commit()
        return True
