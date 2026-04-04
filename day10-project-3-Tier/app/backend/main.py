from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Tech With Diwana Backend")

# CORS for frontend calls
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

COURSES = [
    {"id": 1, "title": "Kubernetes Zero to Hero", "level": "Beginner → Advanced", "duration": "20h", "status": "coming-soon"},
    {"id": 2, "title": "Docker Deep Dive",         "level": "Beginner → Pro",     "duration": "10h", "status": "coming-soon"},
    {"id": 3, "title": "CI/CD with Jenkins & GHA",  "level": "Intermediate",       "duration": "12h", "status": "coming-soon"},
    {"id": 4, "title": "Terraform on AWS",          "level": "Intermediate",       "duration": "14h", "status": "coming-soon"},
]

@app.get("/")
def root():
    return {"message": "Tech With Diwana Backend is live"}

@app.get("/course")
@app.get("/courses")
def get_courses():
    return {"count": len(COURSES), "items": COURSES}

@app.get("/api/info")
def info():
    return {"author": "Tech With Diwana", "version": "prod", "api": "courses"}
