# dashboard/pages/2_analytics.py
import streamlit as st
import pandas as pd
import plotly.express as px
import requests

API_BASE_URL = "http://localhost:8000"


def fetch_analytics():
    try:
        response = requests.get(f"{API_BASE_URL}/jobs/analytics")
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Error fetching analytics: {str(e)}")
        return None


def main():
    st.title("Job Market Analytics")

    analytics = fetch_analytics()
    if not analytics:
        return

    # Convert to DataFrames
    salary_df = pd.DataFrame(analytics['salary_distribution'])
    job_type_df = pd.DataFrame(analytics['job_type_distribution'])
    remote_df = pd.DataFrame(analytics['remote_distribution'])

    # Salary Distribution
    st.header("Salary Distribution")
    col1, col2 = st.columns(2)

    with col1:
        fig = px.bar(salary_df,
                     x='experience_level',
                     y=['avg_min', 'avg_max'],
                     title="Salary Range by Experience Level",
                     barmode='group')
        st.plotly_chart(fig, use_container_width=True)

    with col2:
        fig = px.pie(job_type_df,
                     values='count',
                     names='job_type',
                     title="Job Type Distribution")
        st.plotly_chart(fig, use_container_width=True)

    # Remote Work Distribution
    st.header("Remote Work Status")
    fig = px.pie(remote_df,
                 values='count',
                 names='remote_status',
                 title="Remote Work Distribution")
    st.plotly_chart(fig, use_container_width=True)


if __name__ == "__main__":
    main()