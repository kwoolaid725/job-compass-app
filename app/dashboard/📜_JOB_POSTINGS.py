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
import logging
from PIL import Image
from job_locations_map import add_job_locations_to_page


logging.basicConfig(
    filename='dashboard.log',
    format='%(asctime)s %(levelname)s %(name)s %(message)s',
    level=logging.INFO
)

logger = logging.getLogger(__name__)

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

STATUS_COLORS = {
    "new": "white",
    "applied": "#e9ff70",
    "phone_screen": "#ff8811",
    "technical": "#3bceac",
    "onsite": "#0ead69",
    "offer": "#f15bb5",
    "skipped": "#9E9E9E",
    "rejected": "#d90429"
}

API_BASE_URL = "http://localhost:8000"
ITEMS_PER_PAGE = 20

@st.cache_data(ttl=3600)
def fetch_skills():
    """Fetch all skills"""
    try:
        response = requests.get(f"{API_BASE_URL}/jobs/skills/")
        response.raise_for_status()
        skills_data = response.json()
        # Extract the 'name' from each skill dictionary
        skills = [skill["name"] for skill in skills_data]
        logger.info(f"Fetched {len(skills)} skills.")
        return skills
    except requests.exceptions.RequestException as e:
        st.error(f"Error fetching skills: {str(e)}")
        logger.error(f"Error fetching skills: {str(e)}")
        return []
    except (KeyError, TypeError) as e:
        st.error(f"Unexpected response format when fetching skills: {str(e)}")
        logger.error(f"Unexpected response format when fetching skills: {str(e)}")
        return []

@st.cache_data(ttl=3600)
def fetch_job_categories():
    """Fetch all job categories"""
    try:
        response = requests.get(f"{API_BASE_URL}/jobs/categories")
        response.raise_for_status()
        categories = response.json()["categories"]
        logger.info(f"Fetched {len(categories)} job categories.")
        return categories
    except requests.exceptions.RequestException as e:
        st.error(f"Error fetching job categories: {str(e)}")
        logger.error(f"Error fetching job categories: {str(e)}")
        return []

@st.cache_data(ttl=3600)
def fetch_job_sources():
    """Fetch all unique job sources"""
    try:
        response = requests.get(f"{API_BASE_URL}/jobs/sources")
        response.raise_for_status()
        sources = response.json()["sources"]
        logger.info(f"Fetched {len(sources)} job sources.")
        return sources
    except requests.exceptions.RequestException as e:
        st.error(f"Error fetching job sources: {str(e)}")
        logger.error(f"Error fetching job sources: {str(e)}")
        return []

def fetch_jobs_count(
    status=None,
    categories=None,
    skills=None,  # Added parameter
    search_query=None,
    job_source=None
):
    """Fetch total count of jobs matching the filters"""
    try:
        params = {}
        if status:
            params["status"] = status  # Pass as list
        if categories:
            params["categories"] = categories  # Pass as list
        if skills:
            params["skills"] = skills  # Pass as list
        if job_source:
            params["job_source"] = job_source  # Pass as list

        response = requests.get(f"{API_BASE_URL}/jobs/processed/count", params=params)
        response.raise_for_status()
        total = response.json()["total"]
        logger.info(f"Fetched jobs count: {total}")
        return total
    except requests.exceptions.RequestException as e:
        st.error(f"Error fetching count: {str(e)}")
        logger.error(f"Error fetching count: {str(e)}")
        return 0

def fetch_processed_jobs(
    skip=0,
    limit=ITEMS_PER_PAGE,
    status=None,
    categories=None,  # Changed from position_filter
    skills=None,
    job_source=None,
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
            params["status"] = status  # Pass as list
        if categories:
            params["categories"] = categories  # Pass as list
        if skills:
            params["skills"] = skills  # Pass as list
        if job_source:
            params["job_source"] = job_source  # Pass as list

        response = requests.get(f"{API_BASE_URL}/jobs/processed/", params=params)
        response.raise_for_status()
        jobs = response.json()
        logger.info(f"Fetched {len(jobs)} processed jobs.")
        return jobs
    except requests.exceptions.RequestException as e:
        st.error(f"Error fetching data: {str(e)}")
        logger.error(f"Error fetching data: {str(e)}")
        return []

def update_job_status(job_id, new_status):
    """Update job status in the backend."""
    try:
        response = requests.put(
            f"{API_BASE_URL}/jobs/processed/{job_id}/status",
            json={"status": new_status}
        )
        response.raise_for_status()
        logger.info(f"Updated job ID {job_id} to status '{new_status}'.")
        return True
    except requests.exceptions.RequestException as e:
        st.error(f"Error updating job status: {str(e)}")
        logger.error(f"Error updating job status for job ID {job_id}: {str(e)}")
        return False

def handle_status_change(job_id, new_status):
    """Callback function for status changes"""
    st.session_state.pending_status_updates[job_id] = new_status
    st.session_state.update_complete = False

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
        st.markdown(f"**Location:** {selected_job['location_raw'] or 'N/A'}")

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

        # Create a mapping back to the original status values
        status_display = [status.capitalize() for status in JOB_STATUSES]
        status_mapping = {status.capitalize(): status for status in JOB_STATUSES}

        new_status = st.selectbox(
            "Application Status",
            options=status_display,
            index=current_index,
            key=f"status_select_{job_id}_details"  # Add descriptive suffix to make it unique
        )

        if new_status.lower() != current_status.lower():
            update_clicked = st.button(
                "Update Status",
                key=f"update_btn_{job_id}_{new_status}",
                help="Click to update the job status."
            )

            if update_clicked:
                mapped_status = status_mapping.get(new_status.capitalize(), current_status)
                if update_job_status(job_id, mapped_status):
                    st.success("Status updated successfully!")
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
            # Implement saving notes logic if needed
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

def create_pagination_controls(total_pages):
    """Create pagination controls with numbered pages"""
    if total_pages <= 0:
        return

    st.sidebar.markdown("### Pages")

    cols = st.sidebar.columns([1, 4, 1])

    # Previous page button
    with cols[0]:
        if st.button("←", disabled=st.session_state.page == 0, key="prev_page", use_container_width=True):
            st.session_state.page = max(0, st.session_state.page - 1)
            st.rerun()

    # Page numbers
    with cols[1]:
        # Calculate visible page range
        start_page = max(0, min(st.session_state.page - 4, total_pages - 10))
        end_page = min(start_page + 10, total_pages)

        # Only create columns if we have pages to show
        num_pages = end_page - start_page
        if num_pages > 0:
            page_cols = st.sidebar.columns(num_pages)
            for i, col in enumerate(page_cols):
                page_num = start_page + i
                with col:
                    is_current = page_num == st.session_state.page
                    if st.button(
                            str(page_num + 1),
                            key=f"page_{page_num}",
                            type="primary" if is_current else "secondary",
                            use_container_width=True
                    ):
                        st.session_state.page = page_num
                        st.rerun()

    # Next button
    with cols[2]:
        if st.button("→", disabled=st.session_state.page >= total_pages - 1, key="next_page", use_container_width=True):
            st.session_state.page = min(total_pages - 1, st.session_state.page + 1)
            st.rerun()

    # Show current page info
    st.sidebar.markdown(f"<div style='text-align: center'>Page {st.session_state.page + 1} of {total_pages}</div>",
                        unsafe_allow_html=True)

def clear_all_filters():
    """Clear all filters and reset session state values."""
    st.session_state.category_filter = []
    st.session_state.selected_skills = []  # Reset the selected skills list
    st.session_state["skills_multiselect"] = []  # Ensure the multiselect UI is cleared
    st.session_state.status_filter = ["new", "applied"]  # Default status
    st.session_state.job_source_filter = fetch_job_sources()  # Reset to all sources
    st.session_state.page = 0  # Reset pagination


# Add after other constants
BASE_DIR = os.getcwd()
LOGO_PATH = os.path.join(BASE_DIR, "app/dashboard/img/logos")

SOURCE_LOGOS = {
    "linkedin": "linkedin.png",
    "builtinchicago": "builtinchicago.png",
    "indeed": "indeed.png"
}


def get_source_logo_html(source):
    """Generate HTML for source logo"""
    source_lower = str(source).lower()
    if source_lower in SOURCE_LOGOS:
        logo_file = SOURCE_LOGOS[source_lower]
        # Changed to use st.markdown with HTML img
        return f'<img src="app/dashboard/img/logos/{logo_file}" height="15" style="vertical-align: middle; margin-right: 3px;">'
    return "🔍"  # Default icon for unknown sources



def main():
    # Initialize session state
    if 'page' not in st.session_state:
        st.session_state.page = 0
    if 'category_filter' not in st.session_state:
        st.session_state.category_filter = []
    if 'selected_skills' not in st.session_state:
        st.session_state.selected_skills = []
    if 'selected_job_id' not in st.session_state:
        st.session_state.selected_job_id = None
    if 'status_filter' not in st.session_state:
        st.session_state.status_filter = ["new", "applied"]
    if 'sort_desc' not in st.session_state:
        st.session_state.sort_desc = True
    if 'sort_by' not in st.session_state:  # Add this
        st.session_state.sort_by = "date_posted"
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

    # Add pagination styling
    style_blocks.append("""
        /* Pagination buttons */
        [data-testid="stHorizontalBlock"] button[data-testid="baseButton-secondary"],
        [data-testid="stHorizontalBlock"] button[data-testid="baseButton-primary"] {
            font-size: 0.7rem !important;
            padding: 2px 6px !important;
            height: auto !important;
            min-height: 25px !important;
        }

        /* Pagination container */
        [data-testid="stHorizontalBlock"] {
            gap: 4px !important;
        }
    """)

    st.markdown(f"<style>{''.join(style_blocks)}</style>", unsafe_allow_html=True)

    # Sidebar setup
    st.sidebar.title("Job Applications")

    # Status filter
    formatted_statuses = [status.capitalize() for status in JOB_STATUSES]
    status_mapping = dict(zip(formatted_statuses, JOB_STATUSES))
    st.sidebar.markdown("### Filters")
    status_filter_display = st.sidebar.multiselect(
        "Status",
        options=formatted_statuses,
        default=[s.capitalize() for s in st.session_state.status_filter],
        key="status_multiselect_filter"
    )
    # Convert back to original values
    status_filter = [status_mapping.get(status) for status in status_filter_display if status in status_mapping]

    # Job sources with formatting
    all_sources = fetch_job_sources()
    formatted_sources = [source.capitalize() for source in all_sources]
    source_mapping = dict(zip(formatted_sources, all_sources))

    # Job source filter
    job_source_filter_display = st.sidebar.multiselect(
        "Job Source",
        options=formatted_sources,
        default=formatted_sources if not st.session_state.get('job_source_filter') else [source.capitalize() for source in st.session_state.job_source_filter],
        key="source_multiselect",
        help="Filter jobs by source"
    )
    # Convert back to original values
    job_source_filter = [source_mapping[source] for source in job_source_filter_display]

    st.session_state.job_source_filter = job_source_filter  # Update session state

    job_categories = fetch_job_categories()
    # Convert category names to title case
    formatted_categories = [cat.replace('_', ' ').title() for cat in job_categories]
    # Create a mapping from formatted name back to original value
    category_mapping = dict(zip(formatted_categories, job_categories))

    category_filter = st.sidebar.multiselect(
        "Job Category",
        options=formatted_categories,
        default=st.session_state.category_filter,
        key="category_multiselect",
        help="Filter jobs by category"
    )

    # Convert back to original values for API call
    category_filter_values = [category_mapping[cat] for cat in category_filter]

    # Fetch skills
    skills = fetch_skills()
    selected_skills = st.sidebar.multiselect(
        "Skills",
        options=skills,
        default=st.session_state.get("skills_multiselect", []),  # Default is fetched from session state
        key="skills_multiselect",  # Key handles state
        help="Filter jobs by required skills"
    )
    # Ensure session state is updated after change
    st.session_state.selected_skills = selected_skills

    # Fetch only the count first for pagination
    total_items = fetch_jobs_count(
        status=status_filter,
        categories=category_filter_values,
        skills=selected_skills,
        job_source=job_source_filter
    )

    # Calculate pagination
    total_pages = math.ceil(total_items / ITEMS_PER_PAGE)

    # Fetch only the current page of jobs
    current_jobs = fetch_processed_jobs(
        skip=st.session_state.page * ITEMS_PER_PAGE,
        limit=ITEMS_PER_PAGE,
        status=status_filter,
        categories=category_filter_values,
        skills=selected_skills,
        job_source=job_source_filter,
        sort_by=st.session_state.sort_by,
        sort_desc=st.session_state.sort_desc
    )

    # Convert to DataFrame
    df = pd.DataFrame(current_jobs)

    # Add the map visualization
    add_job_locations_to_page(df)

    # Sort options
    st.sidebar.markdown("### Sort")
    sort_options = {
        "date_posted": "Post Date",
        "status": "Status",
        "updated_at": "Last Updated",
        "company": "Company"
    }

    # Create two columns for sort field and direction
    sort_col1, sort_col2 = st.sidebar.columns([4, 1])

    with sort_col1:
        sort_by = st.selectbox(
            "Sort By",
            options=list(sort_options.keys()),
            format_func=lambda x: sort_options[x],
            key="sort_select",
            label_visibility="collapsed"
        )

    with sort_col2:
        # Arrow button that toggles direction
        arrow = "↓" if st.session_state.sort_desc else "↑"
        if st.button(arrow, key="sort_direction"):
            st.session_state.sort_desc = not st.session_state.sort_desc
            st.rerun()

    # Update session state if sort option changes
    if sort_by != st.session_state.sort_by:
        st.session_state.sort_by = sort_by
        st.session_state.page = 0  # Reset to first page
        st.rerun()

    # Display stats
    st.sidebar.markdown(f"Showing {min(ITEMS_PER_PAGE, len(df))} of {total_items} items")

    # # Clear filters button
    # if st.sidebar.button("Clear All Filters"):
    #     clear_all_filters()
    #     st.rerun()

    #     # Show active filters
    # if category_filter or selected_skills or status_filter or (job_source_filter and job_source_filter != all_sources):
    #     st.sidebar.markdown("### Active Filters")
    #     if category_filter:
    #         st.sidebar.markdown(f"- **Category:** {', '.join(category_filter)}")
    #     if selected_skills:
    #         st.sidebar.markdown(f"- **Skills:** {', '.join(selected_skills)}")
    #     if status_filter:
    #         formatted_status_display = [s.capitalize() for s in status_filter]
    #         st.sidebar.markdown(f"- **Status:** {', '.join(formatted_status_display)}")
    #     if job_source_filter and job_source_filter != all_sources:
    #         formatted_source_display = [s.capitalize() for s in job_source_filter]
    #         st.sidebar.markdown(f"- **Source:** {', '.join(formatted_source_display)}")

    # Status legend
    legend_html = " ".join([
        f'<span style="background-color:{color}; padding:1px 4px; border-radius:2px; margin:1px; font-size:0.7em; display:inline-block; color: {get_text_color(color)};">{status.capitalize()}</span>'
        for status, color in STATUS_COLORS.items()
    ])
    st.sidebar.markdown(f'<div style="display:flex; flex-wrap:wrap;">{legend_html}</div>', unsafe_allow_html=True)
    # Job list
    st.sidebar.markdown("### Job List")
    selected_job = None

    # Display jobs
    for idx, row in df.iterrows():
        date_str = "No date"
        if pd.notnull(row.get('date_posted')):
            date_str = pd.to_datetime(row['date_posted']).strftime('%Y-%m-%d')
        elif pd.notnull(row.get('created_at')):
            date_str = pd.to_datetime(row['created_at']).strftime('%Y-%m-%d')

        salary_str = format_salary_range(
            row.get("salary_min"),
            row.get("salary_max"),
            row.get("salary_currency", "")
        )

        # # Just display source name for now
        # source = str(row.get('raw_job_post', {}).get('source', 'N/A')).lower()
        #
        # job_title_raw = (
        #     f"{date_str} | {row['title']} at **{row['company']}**"
        #     f"{' | ' + salary_str if salary_str else ''} | "
        #     f"[{source.capitalize()}]"
        # )
        #
        # status = row.get('status', 'new')
        #
        # if st.sidebar.button(
        #         job_title_raw,
        #         key=f"job_btn_{idx}_{row['id']}_{status}",
        #         type="secondary",
        #         help=f"Status: {status}"
        # ):
        #     st.session_state.selected_job_id = row['id']
        #     selected_job = row

        source = str(row.get('raw_job_post', {}).get('source', 'N/A')).lower()
        job_info = (
            f"{date_str} | {row['title']} at **{row['company']}**"
            f"{' | ' + salary_str if salary_str else ''}"
        )

        status = row.get('status', 'new')

        col1, col2 = st.sidebar.columns([10, 1])
        with col1:
            if st.button(
                    job_info,
                    key=f"job_btn_{idx}_{row['id']}_{status}",
                    type="secondary",
                    help=f"Status: {status}"
            ):
                st.session_state.selected_job_id = row['id']
                selected_job = row

                st.rerun()


        with col2:
            try:
                if source in SOURCE_LOGOS:
                    logo_file = os.path.join(LOGO_PATH, SOURCE_LOGOS[source])
                    img = Image.open(logo_file)
                    st.image(img, width=25)
                else:
                    st.text("🔍")
            except Exception as e:
                print(f"Error loading image for {source}: {e}")
                st.text("🔍")

    create_pagination_controls(total_pages)

    # Handle selected job display
    if selected_job is None and st.session_state.selected_job_id is not None:
        selected_job_df = df[df['id'] == st.session_state.selected_job_id]
        if not selected_job_df.empty:
            selected_job = selected_job_df.iloc[0]

    if selected_job is not None:
        display_job_details(selected_job)

if __name__ == "__main__":
    main()
