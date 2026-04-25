from app.database import SessionLocal, engine, Base
from app.models.user import User
from app.models.region import Region
from app.core.auth_utils import hash_password

def init_db():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        # Create Pangasinan (ID 0)
        if not db.query(Region).filter(Region.id == 0).first():
            db.add(Region(id=0, name="Pangasinan", level=1))
            print("✅ Created Province ID 0")
        
        # Create Admin
        if not db.query(User).filter(User.username == "admin").first():
            db.add(User(
                username="admin", password_hash=hash_password("admin123"),
                role=1, first_name="System", last_name="Admin",
                mobile="0900000000", city_id=0
            ))
            print("✅ Created Admin User")
        db.commit()
    finally:
        db.close()

if __name__ == "__main__":
    init_db()