from faker import Faker
import random
import sys
import os
from sqlalchemy.orm import Session

# Add the parent directory to sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.models.user import User
from app.models.base import SessionLocal

faker = Faker()

def seed_users(db: Session):
    """Seed the database with users"""
    print("Seeding users...")
    for i in range(10):  # Reduced to 10 users for faster seeding
        user = User(
            name=faker.name(),
            email=faker.email(),
            hashed_password=User.hash_password(faker.password()),
            phone_number=faker.phone_number(),
            image_url=faker.image_url(),
            address=faker.address()
        )
        db.add(user)
        print(f"Added user {i+1}/10")
    
    db.commit()
    print("Users seeded successfully!")

if __name__ == "__main__":
    db = SessionLocal()
    try:
        seed_users(db)
    finally:
        db.close()