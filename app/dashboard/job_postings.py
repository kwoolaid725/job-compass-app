# dashboard/job_postings.py
import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import requests
from datetime import datetime, timedelta
import pytz
import time
import os

st.set_page_config(
    page_title="Processed Jobs Analytics",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Job status options - matching the backend enum values
JOB_STATUSES = [
   "new", "applied", "skipped", "phone_screen",
   "technical", "onsite", "offer", "rejected"
]

# Debug the current working directory (optional)
current_dir = os.getcwd()
# st.sidebar.write("Current working directory:", current_dir)


STATUS_COLORS = {
    "new": "white",
    "applied": "#FF9800",     # Vibrant orange
    "phone_screen": "#FFC107",# Bright amber
    "technical": "#8BC34A",   # Light green
    "onsite": "#2196F3",      # Clear blue
    "offer": "#AB47BC",       # Bold purple
    "skipped": "#9E9E9E",     # Mid gray
    "rejected": "#F44336"     # Strong red
}

API_BASE_URL = "http://localhost:8000"


def fetch_processed_jobs(skip=0, limit=100, status=None, sort_by="date_posted", sort_desc=True):
    """Fetch paginated processed jobs from the backend"""
    try:
        params = {
            "skip": skip,
            "limit": limit,
            "sort_by": sort_by,
            "sort_desc": sort_desc
        }
        # Handle status as a list properly
        if status:
            # Convert single status to list if needed
            status_list = status if isinstance(status, list) else [status]
            # Add each status as a separate query parameter
            params["status"] = status_list

        response = requests.get(f"{API_BASE_URL}/jobs/processed/", params=params)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Error fetching data: {str(e)}")
        return []


def fetch_all_processed_jobs(status=None):
    """Fetch all jobs by making multiple requests."""
    all_jobs = []
    page = 0
    while True:
        jobs = fetch_processed_jobs(skip=page * 100, limit=100, status=status)
        if not jobs:  # No more jobs
            break
        all_jobs.extend(jobs)
        if len(jobs) < 100:  # Last page
            break
        page += 1
    return all_jobs


def handle_status_change(job_id, new_status):
    """Callback function for status changes"""
    st.session_state.pending_status_updates[job_id] = new_status
    st.session_state.update_complete = False

def update_job_status(job_id, new_status):
    """Update job status in the backend."""
    try:
        response = requests.put(
            f"{API_BASE_URL}/jobs/processed/{job_id}/status",
            json={"status": new_status}
        )
        return response.status_code == 200
    except Exception as e:
        st.error(f"Error: {str(e)}")
        return False

def on_filter_change():
    """Handle status filter changes"""
    filter_val = st.session_state.status_multiselect
    if not filter_val:
        filter_val = ["new"]  # Default to "new" if nothing selected
    st.session_state.status_filter = filter_val
    st.session_state.page = 0  # Reset to first page when filter changes

def on_job_source_filter_change(job_sources):
    filter_val = st.session_state.job_source_multiselect
    if not filter_val:
        # If nothing is selected, use all sources
        st.session_state.job_source_filter = job_sources
    else:
        st.session_state.job_source_filter = filter_val
    st.session_state.page = 0

def main():
    # Initialize all session state variables at the start
    if 'page' not in st.session_state:
        st.session_state.page = 0
    if 'selected_job_id' not in st.session_state:
        st.session_state.selected_job_id = None
    if 'sort_desc' not in st.session_state:
        st.session_state.sort_desc = True
    if 'status_filter' not in st.session_state:
        st.session_state.status_filter = ["new", "applied"]
    if 'show_success' not in st.session_state:
        st.session_state.show_success = False
    if 'job_source_filter' not in st.session_state:
        st.session_state.job_source_filter = None

    # Show success message if flag is set
    if st.session_state.show_success:
        st.success("Status updated successfully!")
        st.session_state.show_success = False



    # ===== 1. Build dynamic CSS that targets the parent container class + the button test ID. =====
    style_blocks = []
    for status, color in STATUS_COLORS.items():
        style_blocks.append(f"""
        div.stElementContainer[class*="st-key-job_btn_"][class*="_{status}"]
        button[data-testid="stBaseButton-secondary"] {{
            background-color: {color} !important;
            color: black !important;
            border: 2px solid transparent !important;
            border-radius: 5px !important;
            text-align: left !important;
            padding: 10px !important;
            width: 100% !important;
        }}
        """)

    # Inject the combined CSS
    st.markdown(
        f"<style>{''.join(style_blocks)}</style>",
        unsafe_allow_html=True
    )

    st.sidebar.title("Job Applications")

    # Fetch all jobs
    all_jobs = fetch_all_processed_jobs(status=st.session_state.status_filter)
    df = pd.DataFrame(all_jobs)

    # Sidebar filters
    st.sidebar.markdown("### Filters")
    _ = st.sidebar.multiselect(
        "Status",
        options=JOB_STATUSES,
        default=st.session_state.status_filter,
        key="status_multiselect",
        on_change=on_filter_change
    )

    # Get job sources from DataFrame
    job_sources = df['job_source'].unique().tolist() if 'job_source' in df.columns else []

    # Initialize job_source_filter with actual available sources
    if not st.session_state.job_source_filter or not all(
            source in job_sources for source in st.session_state.job_source_filter):
        st.session_state.job_source_filter = job_sources

    # Make sure we only use available sources for both options and default
    available_sources = job_sources
    default_sources = [source for source in st.session_state.job_source_filter if source in available_sources]

    # In the sidebar multiselect
    _ = st.sidebar.multiselect(
        "Job Source",
        options=available_sources,
        default=default_sources,
        key="job_source_multiselect",
        on_change=lambda: on_job_source_filter_change(available_sources)
    )

    legend_html = " ".join([
        f'<span style="background-color:{color}; padding:1px 4px; border-radius:2px; margin:1px; font-size:0.7em; display:inline-block;">{status.replace("_", " ").title()}</span>'
        for status, color in STATUS_COLORS.items()
    ])
    st.sidebar.markdown(f'<div style="display:flex; flex-wrap:wrap;">{legend_html}</div>', unsafe_allow_html=True)

    # Sort options
    st.sidebar.markdown("### Sort")
    sort_desc = st.sidebar.checkbox(
        "Descending Post Date",
        value=st.session_state.sort_desc
    )
    if sort_desc != st.session_state.sort_desc:
        st.session_state.sort_desc = sort_desc
        st.session_state.page = 0  # Reset to first page when sort changes
        st.rerun()



    # Convert datetime columns if present
    datetime_cols = ['date_posted', 'created_at', 'updated_at']
    for col in datetime_cols:
        if col in df.columns:
            df[col] = pd.to_datetime(df[col], format='ISO8601')

    # Apply filters
    filters = []
    if 'status' in df.columns and st.session_state.status_filter:
        filters.append(df['status'].isin(st.session_state.status_filter))

    if ('job_source' in df.columns and
            st.session_state.job_source_filter and
            st.session_state.job_source_filter != job_sources):
        filters.append(df['job_source'].isin(st.session_state.job_source_filter))

    # Apply filters if any exist
    filtered_df = df.copy()
    if filters:
        filter_mask = pd.concat(filters, axis=1).all(axis=1)
        filtered_df = df[filter_mask]

    # Pagination controls
    col1, col2, col3 = st.sidebar.columns([1, 2, 1])

    with col1:
        if st.button("← Prev.", disabled=st.session_state.page == 0):
            st.session_state.page -= 1
            st.rerun()

    with col2:
        st.markdown(f"### Page {st.session_state.page + 1}")

    with col3:
        if st.button("Next →", disabled=len(filtered_df) < 100 * (st.session_state.page + 1)):
            st.session_state.page += 1
            st.rerun()

    st.sidebar.markdown("### Job List")
    selected_job = None

    for idx, row in filtered_df.iloc[st.session_state.page * 100:(st.session_state.page + 1) * 100].iterrows():
        date_str = "No date"
        if pd.notnull(row.get('date_posted')):
            date_str = row['date_posted'].strftime('%Y-%m-%d')
        elif pd.notnull(row.get('created_at')):
            date_str = row['created_at'].strftime('%Y-%m-%d')


        def format_salary_range(salary_min, salary_max, salary_currency):
            if pd.notnull(salary_min) and pd.notnull(salary_max):
                # Use a dash (-) between the salary min and max, with the currency symbol
                return f"{salary_min:,.0f} - {salary_max:,.0f} {salary_currency}"
            elif pd.notnull(salary_min):
                return f"{salary_min:,.0f} {salary_currency}"
            elif pd.notnull(salary_max):
                return f"{salary_max:,.0f} {salary_currency}"
            else:
                return ""

        # Usage in the job listing
        salary_str = format_salary_range(row.get("salary_min"), row.get("salary_max"),
                                         row.get("salary_currency", ""))
        job_title_raw = f"{date_str} |  {row['title']} at **{row['company']}**{' | ' + salary_str if salary_str else ''} | [{row['job_source']}]"

        status = row.get('status', 'new')

        # The key here ensures the parent container class becomes st-key-job_btn_{idx}_{id}_{status}
        # which we can match in CSS.
        if st.sidebar.button(
                job_title_raw,
                key=f"job_btn_{idx}_{row['id']}_{status}",
                type="secondary",
                help=f"Status: {status}"
        ):
            st.session_state.selected_job_id = row['id']
            selected_job = row


    # If no job was selected from buttons, try session state
    if selected_job is None and st.session_state.selected_job_id is not None:
        selected_job_df = filtered_df[filtered_df['id'] == st.session_state.selected_job_id]
        if not selected_job_df.empty:
            selected_job = selected_job_df.iloc[0]

    # Display selected job details
    if selected_job is not None:
        st.title(f"{selected_job['title']}")

        # Display posted date
        try:
            if pd.notnull(selected_job.get('date_posted')):
                post_date = selected_job['date_posted']
            elif pd.notnull(selected_job.get('created_at')):
                post_date = selected_job['created_at']
            else:
                post_date = None

            date_str = post_date.strftime('%Y-%m-%d') if post_date else 'No date'
            st.markdown(f"*Posted on: {date_str}*")
        except Exception as e:
            st.error(f"Error formatting date: {str(e)}")

        # Company & basics
        st.markdown("### Company Details")
        col_a, col_b = st.columns([2, 1])

        with col_a:
            st.markdown(f"**Company:** {selected_job['company']}")
            st.markdown(f"**Location:** {selected_job['location_raw']}")

            # Salary details
            if (pd.notnull(selected_job.get('salary_min'))
                and pd.notnull(selected_job.get('salary_max'))):
                salary_type = selected_job.get('salary_type', '').replace('_', ' ').title()
                salary_type = salary_type if salary_type else 'Salary'
                st.markdown(
                    f"**{salary_type} Range:** "
                    f"{selected_job['salary_min']:,.0f} - {selected_job['salary_max']:,.0f} "
                    f"{selected_job.get('salary_currency', 'USD')}"
                )

            # Handle the case where job_type is None
            job_type = selected_job.get('job_type', 'N/A')
            if job_type is not None:
                st.markdown(f"**Job Type:** {job_type.replace('_', ' ').title()}")
            else:
                st.markdown(f"**Job Type:** N/A")

            # Handle the case where remote_status is None
            remote_status = selected_job.get('remote_status', 'N/A')
            if remote_status is not None:
                st.markdown(f"**Remote Status:** {remote_status.replace('_', ' ').title()}")
            else:
                st.markdown(f"**Remote Status:** N/A")

            # Handle the case where experience_level is None
            experience_level = selected_job.get('experience_level', 'N/A')
            st.markdown(f"**Experience Level:** {experience_level}")

        with col_b:
            current_status = selected_job.get('status', 'new')
            job_id = selected_job['id']

            try:
                current_index = JOB_STATUSES.index(current_status)
            except ValueError:
                current_index = 0

            new_status = st.selectbox(
                "Application Status",
                options=JOB_STATUSES,
                index=current_index,
                key=f"status_select_{job_id}"
            )

            if new_status != current_status:
                update_clicked = st.button(
                    "Update Status",
                    key=f"update_btn_{job_id}_{new_status}"
                )

                if update_clicked:
                    if update_job_status(job_id, new_status):
                        st.session_state.show_success = True
                        st.rerun()
                    else:
                        st.error("Failed to update status. Please try again.")

                #     # Add this near the top of main(), after other session state initializations:
                # if 'show_success' not in st.session_state:
                #     st.session_state.show_success = False
                #
                #     # Show success message if flag is set
                # if st.session_state.show_success:
                #     st.success("Status updated successfully!")
                #     st.session_state.show_success = False

        # Tabs for extra info
        tab_desc, tab_benefits, tab_notes = st.tabs(
            ["Description", "Benefits & Requirements", "Application Notes"]
        )

        with tab_desc:
            st.markdown(selected_job.get('description', 'No description available'))
            if selected_job.get('job_url'):
                st.markdown(f"[View Original Posting]({selected_job['job_url']})")

        with tab_benefits:
            if selected_job.get('benefits'):
                st.markdown("### Benefits")
                st.json(selected_job['benefits'])

            if selected_job.get('requirements'):
                st.markdown("### Requirements")
                st.markdown(selected_job['requirements'])

        with tab_notes:
            notes_key = f"notes_{selected_job['id']}"
            if notes_key not in st.session_state:
                st.session_state[notes_key] = ""

            st.session_state[notes_key] = st.text_area(
                "Application Notes",
                value=st.session_state[notes_key],
                height=200
            )
            if st.button("Save Notes"):
                st.success("Notes saved successfully!")


if __name__ == "__main__":
    main()