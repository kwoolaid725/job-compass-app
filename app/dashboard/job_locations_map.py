import streamlit as st
import folium
from streamlit_folium import st_folium
from folium import CircleMarker, Icon, Marker
import pandas as pd
from folium.plugins import MarkerCluster
from typing import Optional

# Reuse the status colors from the main page
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


def create_job_locations_map(df, selected_job_id=None):
    """
    Create a Folium map for the current page of jobs with a star marker for selected job

    Args:
        df (pd.DataFrame): DataFrame of current page jobs
        selected_job_id: ID of the currently selected job

    Returns:
        folium.Map: Map with job location markers
    """
    # Filter jobs with valid coordinates
    df = df[
        df['latitude'].notna() &
        df['longitude'].notna() &
        (df['latitude'] != '') &
        (df['longitude'] != '')
        ]

    # If no jobs with coordinates, return None
    if df.empty:
        st.warning("No job locations found for the current page.")
        return None

    # Compute map center
    center_lat = df['latitude'].median()
    center_lon = df['longitude'].median()

    # Create base map
    m = folium.Map(location=[center_lat, center_lon], zoom_start=4)

    # Create marker cluster
    marker_cluster = MarkerCluster(
        options={
            'maxClusterRadius': 50,
            'disableClusteringAtZoom': 5
        }
    ).add_to(m)

    # Add markers for each job
    for _, row in df.iterrows():
        status = row.get('status', 'new')
        color = STATUS_COLORS.get(status, '#9E9E9E')
        is_selected = row['id'] == selected_job_id

        # Detailed popup HTML
        popup_html = f"""
            <div style='width:250px;font-size:12px'>
                <h5 style='margin:0;'>{row['title']}</h5>
                <b>Company:</b> {row['company']}<br>
                <b>Location:</b> {row.get('location_raw', 'N/A')}<br>
                <b>Status:</b> {status.replace('_', ' ').title()}<br>
                <a href='{row.get('job_url', '#')}' target='_blank'>View Job Details</a>
            </div>
        """

        if is_selected:
            # Create star marker for selected job
            icon = Icon(
                color='red',
                icon_color='black',
                icon='star',
                prefix='fa',
                angle=0
            )

            Marker(
                location=[row['latitude'], row['longitude']],
                popup=folium.Popup(popup_html, max_width=250),
                tooltip=f"{row['company']} - {row['title']} (Selected)",
                icon=icon
            ).add_to(m)  # Add directly to map, not to cluster
        else:
            # Create circle marker for other jobs
            CircleMarker(
                location=[row['latitude'], row['longitude']],
                popup=folium.Popup(popup_html, max_width=250),
                tooltip=f"{row['company']} - {row['title']}",
                color="black",
                fill=True,
                fill_color=color,
                fill_opacity=0.9,
                weight=1.5,
                radius=6,
                stroke=True
            ).add_to(marker_cluster)

    return m


def display_job_locations_map(df: pd.DataFrame, selected_job_id: Optional[int] = None) -> None:
    """
    Display job locations map within the current page context
    """
    # Initialize map_key in session state if not present
    if 'map_key' not in st.session_state:
        st.session_state.map_key = 0

    # Create map
    m = create_job_locations_map(df, selected_job_id)

    # Display map if created successfully
    if m is not None:
        st.subheader("Job Locations")
        map_data = st_folium(
            m,
            width="100%",
            height=400,
            key=f"map_{st.session_state.map_key}"  # Use session state key
        )


def add_job_locations_to_page(df):
    """
    Add job locations map to the existing page
    """
    # Check if the DataFrame has latitude and longitude columns
    if 'latitude' in df.columns and 'longitude' in df.columns:
        # Get selected job ID from session state
        selected_job_id = st.session_state.get('selected_job_id')

        # Only increment map key if it's not already set
        if 'map_key' not in st.session_state:
            st.session_state.map_key = 0

        display_job_locations_map(df, selected_job_id)
    else:
        st.warning("No location data available for current jobs.")