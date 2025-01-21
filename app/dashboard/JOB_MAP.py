import streamlit as st
import folium
from streamlit_folium import st_folium
from folium import CircleMarker
import requests
import pandas as pd
import numpy as np
from folium.plugins import MarkerCluster

# Import the same status colors from dashboard
STATUS_COLORS = {
    "new": "black",
    "applied": "#e9ff70",
    "phone_screen": "#ff8811",
    "technical": "#3bceac",
    "onsite": "#0ead69",
    "offer": "#f15bb5",
    "skipped": "#9E9E9E",
    "rejected": "#d90429"
}


def fetch_jobs_with_coordinates(max_jobs=5000):
    """
    Fetch all jobs with valid coordinates efficiently
    """
    all_jobs = []
    page = 0
    batch_size = 500

    try:
        while len(all_jobs) < max_jobs:
            params = {
                "skip": page * batch_size,
                "limit": batch_size
            }

            st.write(f"Fetching batch {page + 1}")

            response = requests.get(
                "http://localhost:8000/jobs/processed/",
                params=params
            )
            response.raise_for_status()
            batch = response.json()

            if not batch:
                break

            # Filter jobs with valid coordinates
            valid_coord_jobs = [
                job for job in batch
                if (job.get('latitude') is not None and
                    job.get('longitude') is not None and
                    str(job['latitude']).strip() and
                    str(job['longitude']).strip() and
                    job['latitude'] != 'None' and
                    job['longitude'] != 'None')
            ]

            all_jobs.extend(valid_coord_jobs)

            st.write(f"Total valid coordinate jobs: {len(all_jobs)}")

            # Stop if we've reached our max or if the batch is smaller than batch size
            if len(batch) < batch_size or len(all_jobs) >= max_jobs:
                break

            page += 1

        return all_jobs

    except Exception as e:
        st.error(f"Error fetching jobs: {str(e)}")
        return []


def downsample_points(df, max_markers=3000):
    """
    Downsample points to represent the full dataset
    Uses a grid-based approach to ensure geographic distribution
    """
    # Reset index to ensure clean dataframe
    df = df.reset_index(drop=True)

    # Ensure coordinates are numeric
    df['latitude'] = pd.to_numeric(df['latitude'], errors='coerce')
    df['longitude'] = pd.to_numeric(df['longitude'], errors='coerce')

    # Drop invalid coordinates
    df = df.dropna(subset=['latitude', 'longitude'])

    # If fewer points than max, return all
    if len(df) <= max_markers:
        return df

    # Create a grid of points
    lat_min, lat_max = df['latitude'].min(), df['latitude'].max()
    lon_min, lon_max = df['longitude'].min(), df['longitude'].max()

    # Compute grid dimensions
    grid_size = int(np.sqrt(max_markers))
    lat_bins = np.linspace(lat_min, lat_max, grid_size + 1)
    lon_bins = np.linspace(lon_min, lon_max, grid_size + 1)

    # Assign each point to a grid cell
    df['lat_bin'] = pd.cut(df['latitude'], bins=lat_bins, labels=False)
    df['lon_bin'] = pd.cut(df['longitude'], bins=lon_bins, labels=False)

    # Sample method that works without deprecation warnings
    sampled_df = (
        df.groupby(['lat_bin', 'lon_bin'], group_keys=False)
        .apply(lambda x: x.sample(1, random_state=42))
        .reset_index(drop=True)
    )

    return sampled_df


def create_map_with_markers(jobs):
    """Create and return the Folium map with markers."""
    try:
        # Convert to DataFrame
        df = pd.DataFrame(jobs)

        # Downsample points
        df_sampled = downsample_points(df)

        st.write(f"Markers after downsampling: {len(df_sampled)}")

        # Compute map center
        center_lat = df_sampled['latitude'].median()
        center_lon = df_sampled['longitude'].median()

        st.write(f"Map center: {center_lat}, {center_lon}")

        # Create base map
        m = folium.Map(location=[center_lat, center_lon], zoom_start=4)

        # Create marker cluster
        marker_cluster = MarkerCluster(
            options={
                'maxClusterRadius': 50,
                'disableClusteringAtZoom': 8
            }
        ).add_to(m)

        # Add markers
        for idx, row in df_sampled.iterrows():
            status = row.get('status', 'new')
            color = STATUS_COLORS.get(status, '#9E9E9E')

            # Create a simple marker
            CircleMarker(
                location=[row['latitude'], row['longitude']],
                popup=f"{row.get('title', 'N/A')} - {row.get('company', 'N/A')}",
                tooltip=f"{row.get('company', 'Unknown')} - {row.get('title', 'Job')}",
                color="black",
                fill=True,
                fill_color=color,
                fill_opacity=0.8,
                weight=1.5,
                radius=4,
                stroke=True
            ).add_to(marker_cluster)

        return m

    except Exception as e:
        st.error(f"Error creating map: {str(e)}")
        return None


def create_job_map():
    st.title("Job Locations Map")

    # Fetch jobs with coordinates
    with st.spinner("Loading job locations..."):
        try:
            # Fetch jobs
            jobs = fetch_jobs_with_coordinates()

            # Display total job count
            st.write(f"Total jobs with coordinates: {len(jobs)}")

            if not jobs:
                st.warning("No jobs with coordinates found.")
                return

            # Create map
            m = create_map_with_markers(jobs)

            if m is None:
                st.error("Failed to create map.")
                return

            # Display map
            map_data = st_folium(
                m,
                width="100%",
                height=600
            )

        except Exception as e:
            st.error(f"Unexpected error: {str(e)}")


if __name__ == "__main__":
    st.set_page_config(page_title="Job Locations Map", layout="wide")
    create_job_map()