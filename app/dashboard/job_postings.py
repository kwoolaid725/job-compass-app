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
import math

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
    "applied": "#faf0ca",
    "phone_screen": "#f4d35e",
    "technical": "#3bceac",
    "onsite": "#0ead69",
    "offer": "#f15bb5",
    "skipped": "#9E9E9E",
    "rejected": "#d90429"
}

API_BASE_URL = "http://localhost:8000"
ITEMS_PER_PAGE = 20

def fetch_jobs_count(
    status=None,
    position_filter=None,
    search_query=None,
    job_source=None  # Add job source parameter
):
    """Fetch total count of jobs matching the filters"""
    try:
        params = {}
        if status:
            status_list = status if isinstance(status, list) else [status]
            params["status"] = status_list
        if position_filter:
            params["position_filter"] = position_filter
        if search_query:
            params["search_query"] = search_query
        if job_source:  # Add job source to params
            params["job_source"] = job_source

        response = requests.get(f"{API_BASE_URL}/jobs/processed/count", params=params)
        response.raise_for_status()
        return response.json()["total"]
    except requests.exceptions.RequestException as e:
        st.error(f"Error fetching count: {str(e)}")
        return 0

# Add this function in your frontend code
def fetch_job_sources():
    """Fetch all unique job sources"""
    try:
        response = requests.get(f"{API_BASE_URL}/jobs/sources")
        response.raise_for_status()
        return response.json()["sources"]
    except requests.exceptions.RequestException as e:
        st.error(f"Error fetching job sources: {str(e)}")
        return []

def fetch_processed_jobs(
    skip=0,
    limit=ITEMS_PER_PAGE,
    status=None,
    position_filter=None,
    search_query=None,
    job_source=None,  # Add job source parameter
    sort_by="date_posted",
    sort_desc=True
):
    """Fetch paginated processed jobs from the backend"""
    try:
        params = {
            "skip": skip,
            "limit": limit,
            "sort_by": sort_by,
            "sort_desc": sort_desc
        }

        if status:
            status_list = status if isinstance(status, list) else [status]
            params["status"] = status_list
        if position_filter:
            params["position_filter"] = position_filter
        if search_query:
            params["search_query"] = search_query
        if job_source:  # Add job source to params
            params["job_source"] = job_source

        response = requests.get(f"{API_BASE_URL}/jobs/processed/", params=params)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Error fetching data: {str(e)}")
        return []



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

def format_salary_range(salary_min, salary_max, salary_currency):
    """Format salary range for display"""
    if pd.notnull(salary_min) and pd.notnull(salary_max):
        return f"{salary_min:,.0f} - {salary_max:,.0f} {salary_currency}"
    elif pd.notnull(salary_min):
        return f"{salary_min:,.0f} {salary_currency}"
    elif pd.notnull(salary_max):
        return f"{salary_max:,.0f} {salary_currency}"
    return ""

def display_job_details(selected_job):
    """Display detailed job information"""
    st.title(f"{selected_job['title']}")

    # Display posted date
    try:
        if pd.notnull(selected_job.get('date_posted')):
            post_date = pd.to_datetime(selected_job['date_posted'])
        elif pd.notnull(selected_job.get('created_at')):
            post_date = pd.to_datetime(selected_job['created_at'])
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

        # Job details
        job_type = selected_job.get('job_type', 'N/A')
        if job_type is not None:
            st.markdown(f"**Job Type:** {job_type.replace('_', ' ').title()}")
        else:
            st.markdown(f"**Job Type:** N/A")

        remote_status = selected_job.get('remote_status', 'N/A')
        if remote_status is not None:
            st.markdown(f"**Remote Status:** {remote_status.replace('_', ' ').title()}")
        else:
            st.markdown(f"**Remote Status:** N/A")

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
            key=f"status_select_{job_id}_details"  # Add descriptive suffix to make it unique
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

        current_notes = st.text_area(
            "Application Notes",
            value=st.session_state[notes_key],
            key=notes_key,
            height=200
        )

        # Only update session state if the notes have changed
        if current_notes != st.session_state[notes_key]:
            st.session_state[notes_key] = current_notes

        if st.button("Save Notes", key=f"save_notes_{selected_job['id']}"):
            st.success("Notes saved successfully!")


def get_text_color(hex_color):
    # Remove '#' if present
    hex_color = hex_color.lstrip('#')

    # Ensure hex_color is 6 characters long
    if len(hex_color) < 6:
        return 'gray'

    try:
        # Convert hex to RGB
        rgb = tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4))

        # Calculate perceived brightness using the ITU-R BT.709 formula
        brightness = (0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2])

        # Return black for light backgrounds, white for dark backgrounds
        return 'gray' if brightness > 180 else 'white'
    except (ValueError, IndexError):
        return 'black'  # Default to black if color conversion fails


def main():
      # Initialize session state
    if 'page' not in st.session_state:
        st.session_state.page = 0
    if 'position_filter' not in st.session_state:
        st.session_state.position_filter = ""
    if 'search_query' not in st.session_state:
        st.session_state.search_query = ""
    if 'selected_job_id' not in st.session_state:
        st.session_state.selected_job_id = None
    if 'status_filter' not in st.session_state:
        st.session_state.status_filter = ["new", "applied"]
    if 'sort_desc' not in st.session_state:
        st.session_state.sort_desc = True
    if 'show_success' not in st.session_state:
        st.session_state.show_success = False

    # Show success message if flag is set
    if st.session_state.show_success:
        st.success("Status updated successfully!")
        st.session_state.show_success = False

    # Build dynamic CSS for status colors
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
    st.markdown(f"<style>{''.join(style_blocks)}</style>", unsafe_allow_html=True)



    # Sidebar setup
    st.sidebar.title("Job Applications")

    # Search and filters
    search_query = st.sidebar.text_input(
        "🔍 Search in description & requirements",
        value=st.session_state.search_query,
        help="Search within job descriptions and requirements"
    )

    position_filter = st.sidebar.text_input(
        "🎯 Filter by position/title",
        value=st.session_state.position_filter,
        help="Filter jobs by position or title"
    )

    # Status filter
    st.sidebar.markdown("### Filters")
    status_filter = st.sidebar.multiselect(
        "Status",
        options=JOB_STATUSES,
        default=st.session_state.status_filter,
        key="status_multiselect_filter"  # Added unique key
    )

    # Get job sources from DataFrame for filter
    initial_jobs = fetch_processed_jobs(
        limit=100,  # Get a larger initial set just to get all sources
        status=status_filter,
    )
    all_sources = fetch_job_sources()

    # Job source filter
    job_source_filter = st.sidebar.multiselect(
        "Job Source",
        options=all_sources,  # They're already sorted from the backend
        default=all_sources,
        key="source_multiselect"
    )

    # Fetch only the count first for pagination
    total_items = fetch_jobs_count(
        status=status_filter,
        position_filter=position_filter,
        search_query=search_query
    )

    # Calculate pagination
    total_pages = math.ceil(total_items / ITEMS_PER_PAGE)

    # Fetch only the current page of jobs
    current_jobs = fetch_processed_jobs(
        skip=st.session_state.page * ITEMS_PER_PAGE,
        limit=ITEMS_PER_PAGE,
        status=status_filter,
        position_filter=position_filter,
        search_query=search_query,
        job_source=job_source_filter,  # Add job source to the fetch
        sort_by="date_posted",
        sort_desc=st.session_state.sort_desc
    )

    # Convert to DataFrame
    df = pd.DataFrame(current_jobs)

    # Get job sources from DataFrame for filter
    job_sources = df['job_source'].unique().tolist() if 'job_source' in df.columns else []


    # Status legend
    legend_html = " ".join([
      f'<span style="background-color:{color}; padding:1px 4px; border-radius:2px; margin:1px; font-size:0.7em; display:inline-block; color: {get_text_color(color)};">{status.replace("_", " ").title()}</span>'
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
        st.session_state.page = 0
        st.rerun()

    # Enhanced pagination controls
    col1, col2, col3, col4, col5 = st.sidebar.columns([1, 1.5, 2, 1.5, 1])

    with col1:
        if st.button("⟪", disabled=st.session_state.page == 0, help="First page"):
            st.session_state.page = 0
            st.rerun()

    with col2:
        if st.button("←", disabled=st.session_state.page == 0, help="Previous page"):
            st.session_state.page -= 1
            st.rerun()

    with col3:
        st.markdown(
            f"<div style='text-align: center'>Page {st.session_state.page + 1} of {total_pages}</div>",
            unsafe_allow_html=True
        )

    with col4:
        if st.button("→", disabled=st.session_state.page >= total_pages - 1, help="Next page"):
            st.session_state.page += 1
            st.rerun()

    with col5:
        if st.button("⟫", disabled=st.session_state.page >= total_pages - 1, help="Last page"):
            st.session_state.page = total_pages - 1
            st.rerun()

    # Page jump feature
    col_jump1, col_jump2 = st.sidebar.columns([3, 1])
    with col_jump1:
        page_number = st.number_input(
            "Go to page",
            min_value=1,
            max_value=max(1, total_pages),
            value=st.session_state.page + 1
        )
    with col_jump2:
        if st.button("Go"):
            st.session_state.page = page_number - 1
            st.rerun()

    # Display stats
    st.sidebar.markdown(f"Showing {min(ITEMS_PER_PAGE, len(df))} of {total_items} items")

    # Clear filters button
    if st.sidebar.button("Clear All Filters"):
        st.session_state.position_filter = ""
        st.session_state.search_query = ""
        st.session_state.status_filter = ["new", "applied"]
        st.session_state.page = 0
        st.rerun()

    # Show active filters
    if position_filter or search_query or status_filter:
        st.sidebar.markdown("### Active Filters")
        if position_filter:
            st.sidebar.markdown(f"- Position: {position_filter}")
        if search_query:
            st.sidebar.markdown(f"- Search: {search_query}")
        if status_filter:
            st.sidebar.markdown(f"- Status: {', '.join(status_filter)}")

    # Job list
    st.sidebar.markdown("### Job List")
    selected_job = None

    # Display jobs
    for idx, row in df.iterrows():
        date_str = "No date"
        if pd.notnull(row.get('date_posted')):
            date_str = pd.to_datetime(row['date_posted']).strftime('%Y-%m-%d')
        # elif pd.notnull(row.get('created_at')):
        #     date_str = pd.to_datetime(row['created_at']).strftime('%Y-%m-%d')

        salary_str = format_salary_range(
            row.get("salary_min"),
            row.get("salary_max"),
            row.get("salary_currency", "")
        )

        job_title_raw = f"{date_str} |  {row['title']} at **{row['company']}**{' | ' + salary_str if salary_str else ''} | [{row['job_source']}]"
        status = row.get('status', 'new')

        if st.sidebar.button(
                job_title_raw,
                key=f"job_btn_{idx}_{row['id']}_{status}",
                type="secondary",
                help=f"Status: {status}"
        ):
            st.session_state.selected_job_id = row['id']
            selected_job = row

    # Handle selected job display
    if selected_job is None and st.session_state.selected_job_id is not None:
        selected_job_df = df[df['id'] == st.session_state.selected_job_id]
        if not selected_job_df.empty:
            selected_job = selected_job_df.iloc[0]

    if selected_job is not None:
        display_job_details(selected_job)


if __name__ == "__main__":
    main()
