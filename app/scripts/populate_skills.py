# scripts/populate_skills.py

import re
from flashtext import KeywordProcessor
import inflect
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.job import ProcessedJob, Skill
from sqlalchemy.exc import IntegrityError
import os

# Initialize inflect engine for pluralization
p = inflect.engine()

# Define the paths to your skills and synonyms lists
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SKILLS_FILE_PATH = os.path.join(SCRIPT_DIR, 'skills_list.txt')
SYNONYMS_FILE_PATH = os.path.join(SCRIPT_DIR, 'synonyms_list.txt')


# Function to load skills from the skills_list.txt file
def load_skills(skills_file_path: str):
    with open(skills_file_path, 'r') as file:
        skills = {line.strip().lower() for line in file if line.strip()}
    return skills


# Function to load synonyms from the synonyms_list.txt file
def load_synonyms(synonyms_file_path: str):
    synonym_mapping = {}
    with open(synonyms_file_path, 'r') as file:
        for line in file:
            if line.strip():
                parts = line.strip().split(',')
                if len(parts) == 2:
                    synonym, standard = parts[0].strip().lower(), parts[1].strip()
                    synonym_mapping[synonym] = standard
    return synonym_mapping


# Function to generate plural forms of skills and add them as synonyms
def generate_plural_synonyms(skills):
    plural_synonyms = {}
    for skill in skills:
        # Use inflect to get plural form
        plural = p.plural(skill)
        # Handle cases where plural is same as singular
        if plural != skill:
            plural_synonyms[plural] = skill.title()
    return plural_synonyms


# Initialize KeywordProcessor with FlashText
def create_keyword_processor(skills, synonyms, plural_synonyms):
    keyword_processor = KeywordProcessor(case_sensitive=False)
    # Add standardized skills
    keyword_processor.add_keywords_from_list([skill.title() for skill in skills])
    # Add synonyms mapping to standardized skills
    for synonym, standard in synonyms.items():
        keyword_processor.add_keyword(synonym, standard)
    # Add plural synonyms mapping to standardized skills
    for plural, standard in plural_synonyms.items():
        keyword_processor.add_keyword(plural, standard)
    return keyword_processor


# Extract skills using FlashText
def extract_skills_flashtext(text: str, keyword_processor):
    return {keyword.lower() for keyword in keyword_processor.extract_keywords(text)}


# Populate skills in the database with handling for emerging skills
def populate_skills(skills_file_path: str, synonyms_file_path: str, threshold: int = 5):
    db: Session = SessionLocal()
    try:
        # Load skills and synonyms
        skills = load_skills(skills_file_path)
        synonyms = load_synonyms(synonyms_file_path)
        plural_synonyms = generate_plural_synonyms(skills)
        matcher = create_keyword_processor(skills, synonyms, plural_synonyms)

        # Fetch all processed jobs
        jobs = db.query(ProcessedJob).all()
        print(f"Total jobs to process: {len(jobs)}")

        # Dictionary to count skill occurrences
        skill_counts = {}

        # First pass: Count skill frequencies
        for job in jobs:
            combined_text = (job.requirements or "") + " " + (job.description or "")
            skills_found = extract_skills_flashtext(combined_text, matcher)
            for skill in skills_found:
                skill_counts[skill] = skill_counts.get(skill, 0) + 1

        print("Skill frequencies computed.")

        # Determine emerging skills based on threshold
        emerging_skills = {skill for skill, count in skill_counts.items() if count >= threshold and skill not in skills}
        print(f"Emerging skills (count >= {threshold}): {emerging_skills}")

        # Add emerging skills to skills_list.txt if they are not already present
        if emerging_skills:
            with open(skills_file_path, 'a') as file:
                for skill in emerging_skills:
                    formatted_skill = skill.title()
                    if formatted_skill.lower() not in skills:
                        file.write(f"{formatted_skill}\n")
                        print(f"Added new skill to skills_list.txt: {formatted_skill}")

        # Reload skills, synonyms, and generate new plural synonyms after adding emerging skills
        updated_skills = load_skills(skills_file_path)
        updated_synonyms = load_synonyms(synonyms_file_path)
        updated_plural_synonyms = generate_plural_synonyms(updated_skills)
        updated_matcher = create_keyword_processor(updated_skills, updated_synonyms, updated_plural_synonyms)

        # Second pass: Associate skills with jobs
        for job in jobs:
            combined_text = (job.requirements or "") + " " + (job.description or "")
            skills_found = extract_skills_flashtext(combined_text, updated_matcher)
            # Normalize skills to title case for consistency
            skills_found = {skill.title() for skill in skills_found}

            for skill_name in skills_found:
                # Fetch or create Skill instance
                skill = db.query(Skill).filter(Skill.name.ilike(skill_name)).first()
                if not skill:
                    skill = Skill(name=skill_name)
                    db.add(skill)
                    try:
                        db.commit()
                        db.refresh(skill)
                        print(f"Added new skill: {skill_name}")
                    except IntegrityError:
                        db.rollback()
                        skill = db.query(Skill).filter(Skill.name.ilike(skill_name)).first()

                if skill not in job.skills:
                    job.skills.append(skill)
                    print(f"Associated skill '{skill_name}' with job ID {job.id}")

            # Commit after processing each job to handle large datasets efficiently
            db.commit()

        print("Skill population completed successfully.")

    except Exception as e:
        db.rollback()
        print(f"An error occurred: {e}")

    finally:
        db.close()


if __name__ == "__main__":
    populate_skills(SKILLS_FILE_PATH, SYNONYMS_FILE_PATH)
