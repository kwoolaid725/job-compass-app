import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import requests
from datetime import datetime
from typing import List, Dict
import numpy as np


def fetch_jobs_data(selected_categories: List[str]) -> List[dict]:
    """Fetch jobs data from the API for selected categories."""
    try:
        params = [('categories', category) for category in selected_categories]
        response = requests.get("http://localhost:8000/jobs/processed/all/", params=params)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        st.error(f"Error fetching data: {str(e)}")
        return []


def normalize_experience_level(level: str) -> str:
    """Normalize experience level using string matching."""
    level = level.lower().strip()

    if any(entry in level for entry in ['entry', 'junior', 'jr', 'intern']):
        return 'Entry Level'

    if any(mid in level for mid in ['mid', 'intermediate', 'associate']):
        return 'Mid Level'

    if any(senior in level for senior in ['senior', 'sr']):
        return 'Senior Level'

    if 'staff' in level:
        return 'Staff Level'

    if 'principal' in level:
        return 'Principal Level'

    if any(exec_lead in level for exec_lead in
           ['lead', 'chief', 'executive', 'director', 'vp', 'head', 'c-level', 'management']):
        return 'Leadership/Executive Level'

    return 'Other'



def process_jobs_data(jobs: List[dict]) -> Dict:
    """Process raw jobs data into analytics."""
    if not jobs:
        return None

    # Convert salaries to annual based on salary type
    def convert_to_annual(salary: float, salary_type: str) -> float:
        if not salary or not salary_type:
            return 0

        conversion_factors = {
            'hourly': 40 * 52,  # 40 hours per week * 52 weeks
            'daily': 5 * 52,  # 5 days per week * 52 weeks
            'weekly': 52,  # 52 weeks
            'monthly': 12,  # 12 months
            'yearly': 1,  # Already annual
            'contract': 1  # Treat contract same as yearly for now
        }
        factor = conversion_factors.get(salary_type.lower(), 1)
        return float(salary) * factor

    # Process salaries
    salary_data = []
    for job in jobs:
        # Get salary data from both min and max
        if isinstance(job.get('salary_min'), (int, float)) and isinstance(job.get('salary_max'), (int, float)):
            if job.get('salary_type'):
                min_annual = convert_to_annual(job['salary_min'], job['salary_type'])
                max_annual = convert_to_annual(job['salary_max'], job['salary_type'])
                if max_annual > 0:  # Only include if we have valid salary
                    salary_data.append({
                        'min': min_annual,
                        'max': max_annual,
                        'avg': (min_annual + max_annual) / 2
                    })

    # Remove salary outliers using IQR method
    if salary_data:
        max_salaries = [s['max'] for s in salary_data]
        q1 = np.percentile(max_salaries, 25)
        q3 = np.percentile(max_salaries, 75)
        iqr = q3 - q1
        lower_bound = q1 - 1.5 * iqr
        upper_bound = q3 + 1.5 * iqr

        # Filter out outliers
        salary_data = [s for s in salary_data if lower_bound <= s['max'] <= upper_bound]

    # Calculate salary statistics
    avg_salary = np.mean([s['avg'] for s in salary_data]) if salary_data else 0

    # Process skills
    skills_count = {}
    for job in jobs:
        if isinstance(job.get('skills'), list):
            for skill in job['skills']:
                if isinstance(skill, dict):
                    skill_name = skill.get('name', '')
                else:
                    skill_name = str(skill)
                if skill_name:
                    skills_count[skill_name] = skills_count.get(skill_name, 0) + 1

    # Top skills
    top_skills = sorted(skills_count.items(), key=lambda x: x[1], reverse=True)[:10]

    # Remote work distribution for pie chart
    remote_status = {}
    for job in jobs:
        status = str(job.get('remote_status', 'Unknown'))
        # Clean up status names for better display
        status = status.replace('_', ' ').title() if status else 'Unknown'
        remote_status[status] = remote_status.get(status, 0) + 1

    # Calculate percentages for remote status
    total_jobs = sum(remote_status.values())
    remote_status_pct = {
        status: (count / total_jobs * 100)
        for status, count in remote_status.items()
    }

    # Experience level distribution
    exp_level_order = {
        'Entry Level': 1,
        'Mid Level': 2,
        'Senior Level': 3,
        'Staff Level': 4,
        'Principal Level': 5,
        'Leadership/Executive Level': 6,
        'Other': 7
    }

    # Initialize exp_levels dictionary
    exp_levels = {}

    # Populate experience levels with normalized values
    for job in jobs:
        raw_level = str(job.get('experience_level', ''))
        if raw_level:
            # Clean up the raw level string and normalize it
            cleaned_level = raw_level.replace('_', ' ').title()
            level = normalize_experience_level(cleaned_level)
            exp_levels[level] = exp_levels.get(level, 0) + 1

    # Sort experience levels by the defined order after populating
    exp_levels = dict(sorted(exp_levels.items(), key=lambda x: exp_level_order.get(x[0], 999)))

    for job in jobs:
        level = str(job.get('experience_level', 'Not Specified'))
        level = level.replace('_', ' ').title() if level else 'Not Specified'
        exp_levels[level] = exp_levels.get(level, 0) + 1

    # Job posting trend
    posting_dates = {}
    start_date = datetime(2025, 1, 1)
    for job in jobs:
        if job.get('date_posted'):
            date = datetime.fromisoformat(job['date_posted'].split('T')[0])
            if date >= start_date:
                date_str = date.strftime('%Y-%m-%d')
                posting_dates[date_str] = posting_dates.get(date_str, 0) + 1

    return {
        'total_jobs': len(jobs),
        'avg_salary': avg_salary,
        'salary_data': [s['max'] for s in salary_data],  # Include raw salary data for box plot
        'salary_range': {
            'min': min([s['min'] for s in salary_data]) if salary_data else 0,
            'max': max([s['max'] for s in salary_data]) if salary_data else 0
        },
        'top_skills': top_skills,
        'remote_status': remote_status_pct,  # Using percentages
        'experience_levels': exp_levels,
        'posting_dates': posting_dates,
    }


def display_analytics(analytics: Dict):
    """Display analytics using Streamlit components."""
    if not analytics:
        st.warning("Please select categories to view analytics.")
        return

    # Summary metrics in columns
    col1, col2 = st.columns(2)
    with col1:
        st.metric("Total Jobs", analytics['total_jobs'])
    with col2:
        if analytics.get('avg_salary', 0) > 0:
            st.metric("Average Annual Salary", f"${analytics['avg_salary']:,.2f}")
        else:
            st.metric("Average Annual Salary", "No salary data")

    # Create two columns for the charts
    col1, col2 = st.columns(2)

    # Remote Status Pie Chart
    with col1:
        st.subheader("Remote Work Distribution")
        if analytics['remote_status']:
            remote_df = pd.DataFrame(
                [(status, pct) for status, pct in analytics['remote_status'].items()],
                columns=['Status', 'Percentage']
            )
            fig_remote = px.pie(
                remote_df,
                values='Percentage',
                names='Status',
                title='Remote Work Distribution',
                hover_data=['Percentage'],
                labels={'Percentage': 'Percentage of Jobs'}
            )
            fig_remote.update_traces(textposition='inside', textinfo='percent+label')
            st.plotly_chart(fig_remote, use_container_width=True)
        else:
            st.info("No remote status data available")

    # Salary Box Plot
    with col2:
        st.subheader("Salary Distribution")
        if analytics['salary_data']:
            fig_salary = go.Figure()
            fig_salary.add_trace(go.Box(
                y=analytics['salary_data'],
                name='Annual Salary',
                boxpoints=False,  # Remove outlier points
                marker_color='rgb(107,164,178)'
            ))
            fig_salary.update_layout(
                title='Annual Salary Distribution (Box Plot)',
                yaxis_title='Salary ($)',
                showlegend=False,
                yaxis=dict(
                    tickformat='$,.0f',
                )
            )
            st.plotly_chart(fig_salary, use_container_width=True)

            # Display salary range
            st.write(
                f"Salary Range (excluding outliers): ${min(analytics['salary_data']):,.2f} - ${max(analytics['salary_data']):,.2f}")
        else:
            st.info("No salary data available")

    # Skills visualization
    st.subheader("Top 10 Required Skills")
    skills_df = pd.DataFrame(analytics['top_skills'], columns=['Skill', 'Count'])
    fig_skills = px.bar(
        skills_df,
        x='Skill',
        y='Count',
        title='Top 10 Required Skills'
    )
    fig_skills.update_layout(xaxis_tickangle=-45)
    st.plotly_chart(fig_skills, use_container_width=True)

    # Job posting trend
    st.subheader("Job Posting Trend")
    if analytics['posting_dates']:
        dates_df = pd.DataFrame(
            [(date, count) for date, count in analytics['posting_dates'].items()],
            columns=['Date', 'Count']
        )
        dates_df['Date'] = pd.to_datetime(dates_df['Date'])
        dates_df = dates_df.sort_values('Date')

        fig_trend = px.line(
            dates_df,
            x='Date',
            y='Count',
            title='Daily Job Posting Trend (From January 2025)'
        )
        fig_trend.update_layout(
            xaxis_title='Date',
            yaxis_title='Number of Jobs Posted',
            xaxis=dict(
                tickformat='%Y-%m-%d',
                tickangle=-45,
            )
        )
        st.plotly_chart(fig_trend, use_container_width=True)
    else:
        st.info("No job posting data available for the selected period")

    # Experience level distribution
    st.subheader("Experience Level Distribution")
    if analytics['experience_levels']:
        exp_df = pd.DataFrame(
            [(level, count) for level, count in analytics['experience_levels'].items()],
            columns=['Level', 'Count']
        )

        # Define the order of levels we want to display
        level_order = [
            'Entry Level',
            'Mid Level',
            'Senior Level',
            'Staff Level',
            'Principal Level',
            'Leadership/Executive Level',
            'Other'
        ]

        fig_exp = px.bar(
            exp_df,
            x='Level',
            y='Count',
            title='Experience Level Distribution',
            category_orders={'Level': level_order}  # Use our defined order
        )
        fig_exp.update_layout(
            xaxis_tickangle=-45,
            xaxis_title='Experience Level',
            yaxis_title='Number of Jobs',
            showlegend=False
        )
        st.plotly_chart(fig_exp, use_container_width=True)
    else:
        st.info("No experience level data available")



def main():
    st.set_page_config(page_title="Job Analytics", layout="wide")
    st.title("Job Market Analytics")

    # Fetch categories
    try:
        categories_response = requests.get("http://localhost:8000/jobs/categories")
        categories = categories_response.json().get('categories', [])
    except requests.RequestException as e:
        st.error(f"Could not fetch job categories: {str(e)}")
        return

    # Category selection in sidebar
    st.sidebar.header("Filters")
    selected_categories = st.sidebar.multiselect(
        "Select Job Categories",
        options=[cat.replace('_', ' ').title() for cat in categories],
        default=None
    )

    if selected_categories:
        # Convert categories back to API format
        api_categories = [cat.replace(' ', '_').lower() for cat in selected_categories]

        # Fetch and process data
        with st.spinner('Fetching data...'):
            jobs_data = fetch_jobs_data(api_categories)
            analytics = process_jobs_data(jobs_data)

        # Display analytics
        display_analytics(analytics)
    else:
        st.info("Please select job categories to view analytics.")


if __name__ == "__main__":
    main()