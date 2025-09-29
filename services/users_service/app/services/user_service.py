from typing import List, Optional

from app.repositories.user_repository import UserRepository
from app.schemas.user import UserCreate, UserUpdate, UserResponse


class UserService:
    """Service for user business logic"""
    
    def __init__(self, repository: UserRepository):
        self.repository = repository
    
    def get_user(self, user_id: int) -> Optional[UserResponse]:
        """Get a user by ID"""
        user = self.repository.get_by_id(user_id)
        if not user:
            return None
        return UserResponse.model_validate(user)
    
    def get_user_by_email(self, email: str) -> Optional[UserResponse]:
        """Get a user by email"""
        user = self.repository.get_by_email(email)
        if not user:
            return None
        return UserResponse.model_validate(user)
    
    def list_users(self, skip: int = 0, limit: int = 100) -> List[UserResponse]:
        """Get a list of users with pagination"""
        users = self.repository.list_users(skip, limit)
        return [UserResponse.model_validate(user) for user in users]
    
    def create_user(self, user_data: UserCreate) -> UserResponse:
        """Create a new user"""
        user = self.repository.create(user_data)
        return UserResponse.model_validate(user)
    
    def update_user(self, user_id: int, user_data: UserUpdate) -> Optional[UserResponse]:
        """Update a user's information"""
        update_data = {k: v for k, v in user_data.model_dump().items() if v is not None}
        
        if not update_data:
            user = self.repository.get_by_id(user_id)
            return UserResponse.model_validate(user) if user else None
        
        updated_user = self.repository.update(user_id, **update_data)
        if not updated_user:
            return None
        return UserResponse.model_validate(updated_user)
    
    def delete_user(self, user_id: int) -> bool:
        """Delete a user"""
        return self.repository.delete(user_id)
    
