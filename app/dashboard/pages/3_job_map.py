# app/visualization/job_map.py
import streamlit as st
import folium
from streamlit_folium import st_folium
from folium import CircleMarker
import requests
import pandas as pd


# Import the same status colors from dashboard
STATUS_COLORS = {
    "new": "fdf0d5",
    "applied": "#faf0ca",
    "phone_screen": "#f4d35e",
    "technical": "#3bceac",
    "onsite": "#0ead69",
    "offer": "#f15bb5",
    "skipped": "#9E9E9E",
    "rejected": "#d90429"
}



def fetch_processed_jobs():
    """Fetch all jobs from the FastAPI endpoint"""
    try:
        all_jobs = []
        page = 0
        while True:
            response = requests.get(
                "http://localhost:8000/jobs/processed/",
                params={
                    "skip": page * 100,
                    "limit": 100
                }
            )
            response.raise_for_status()

            jobs = response.json()
            if not jobs:  # No more records
                break

            all_jobs.extend(jobs)

            if len(jobs) < 100:  # Last page
                break

            page += 1

        return all_jobs
    except Exception as e:
        st.error(f"Error connecting to the API: {str(e)}")
        return []


def create_job_map():
    st.title("Job Locations Map")

    # Add loading indicator
    with st.spinner('Loading job data...'):
        jobs = fetch_processed_jobs()

    if not jobs:
        st.warning("No jobs found.")
        return

    # Convert to DataFrame
    df = pd.DataFrame(jobs)

    # Filter out jobs without coordinates
    df = df[df['latitude'].notna() & df['longitude'].notna()]

    if df.empty:
        st.warning("No job locations found with valid coordinates.")
        return

    # Create filters in sidebar
    st.sidebar.title("Filters")

    # Job status filter
    if 'status' in df.columns:
        status_values = [s for s in df['status'].unique() if s is not None]
        status_filter = st.sidebar.multiselect(
            "Job Status",
            options=sorted(status_values)
        )

    # Remote status filter
    if 'remote_status' in df.columns:
        remote_values = [r for r in df['remote_status'].unique() if r is not None]
        remote_filter = st.sidebar.multiselect(
            "Remote Status",
            options=sorted(remote_values)
        )

    # Apply filters
    if status_filter:
        df = df[df['status'].isin(status_filter)]
    if remote_filter:
        df = df[df['remote_status'].isin(remote_filter)]

    # Create base map
    center_lat = df['latitude'].mean()
    center_lon = df['longitude'].mean()
    m = folium.Map(location=[center_lat, center_lon], zoom_start=4)

    # Add job markers
    for _, row in df.iterrows():
        # Get status color, default to gray if status not found
        status = row.get('status', 'new')
        color = STATUS_COLORS.get(status, '#9E9E9E')

        # Create popup content
        popup_html = f"""
          <div style='width: 300px'>
              <h4>{row['title']}</h4>
              <b>Company:</b> {row['company']}<br>
              <b>Location:</b> {row['location_raw']}<br>
              <b>Status:</b> <span style="color:{color}">{status}</span><br>
              <b>Remote:</b> {row['remote_status']}<br>
              """

        # Add salary information if available
        if pd.notnull(row.get('salary_min')) and pd.notnull(row.get('salary_max')):
            popup_html += f"<b>Salary Range:</b> {row['salary_currency']}{row['salary_min']:,.0f} - {row['salary_max']:,.0f}<br>"

        popup_html += f"""
              <br>
              <a href='{row['job_url']}' target='_blank'>View Job</a>
          </div>
          """

        # Set different marker properties based on status
        marker_props = {
            'location': [row['latitude'], row['longitude']],
            'popup': folium.Popup(popup_html, max_width=350),
            'tooltip': f"{row['company']} - {row['title']}",
            'color': color,
            'fill': True,
            'fill_color': color,
            'fill_opacity': 0.7,
            'weight': 2
        }

        # Adjust size and style for 'new' status
        if status == 'new':
            marker_props.update({
                'radius': 4,  # Smaller radius
                'fill_opacity': 0.5,  # More transparent
                'weight': 1  # Thinner border
            })
        else:
            marker_props.update({
                'radius': 8  # Normal size for other statuses
            })

        # Add circle marker with properties
        CircleMarker(**marker_props).add_to(m)

    # Add a legend
    legend_html = """
    <div style="position: fixed; 
                bottom: 50px; right: 50px; 
                border:2px solid grey; z-index:9999;
                background-color: white;
                padding: 10px;
                border-radius: 5px;
                ">
    <h4>Job Status</h4>
    """

    for status, color in STATUS_COLORS.items():
        legend_html += f"""
        <div style="display: flex; align-items: center; margin-bottom: 5px;">
            <div style="width: 12px; height: 12px; border-radius: 50%; 
                        background-color: {color}; margin-right: 5px;
                        border: 1px solid #666;">
            </div>
            <span>{status.replace('_', ' ').title()}</span>
        </div>
        """

    legend_html += "</div>"
    m.get_root().html.add_child(folium.Element(legend_html))

    # Display map
    col1, col2 = st.columns([2, 1])

    with col1:
        st.subheader("Job Locations")
        try:
            map_data = st_folium(
                m,
                width='100%',
                height=600,
                returned_objects=[]  # Important: this prevents hanging
            )
            if map_data is None:
                st.error("Error loading map. Please try refreshing the page.")
        except Exception as e:
            st.error(f"Error displaying map: {str(e)}")
    with col2:
        st.subheader("Statistics")
        st.write(f"Total Jobs: {len(df)}")

        if 'remote_status' in df.columns:
            st.write("Remote Status Distribution:")
            st.write(df['remote_status'].value_counts())

        if 'status' in df.columns:
            st.write("Job Status Distribution:")
            st.write(df['status'].value_counts())


if __name__ == "__main__":
    st.set_page_config(page_title="Job Locations Map", layout="wide")
    create_job_map()