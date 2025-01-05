# app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1.endpoints import router as job_router
from app.models import job
from app.database import engine  # Add this import

# # Drop all tables
# job.Base.metadata.drop_all(bind=engine)
#
# # Create all tables
# job.Base.metadata.create_all(bind=engine)


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include the job router
app.include_router(job_router)  # Add this line

@app.get("/")
def read_root():
    return {"Hello": "World"}
#
# @app.get("/live-data")
# async def get_live_data():
#     # Your data processing logic here
#     return {"data": processed_data}