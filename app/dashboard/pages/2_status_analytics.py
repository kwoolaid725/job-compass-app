# dashboard/pages/2_status_analytics.py
import streamlit as st
import pandas as pd
from streamlit_calendar import calendar
from datetime import datetime, timedelta
import requests


API_BASE_URL = "http://localhost:8000"  

def fetch_status_analytics():
    try:
        response = requests.get(f"{API_BASE_URL}/jobs/status-analytics")
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Error fetching status analytics: {str(e)}")
        return None


def convert_to_calendar_events(status_data):
    events = []
    for item in status_data:
        updated_at = item['updated_at']
        if updated_at:
            if item['new'] > 0:
                events.append({
                    "title": f"New: {item['new']}",
                    "start": updated_at,
                    "allDay": False,
                    "color": "#FFFFFF"
                })
            if item['applied'] > 0:
                events.append({
                    "title": f"Applied: {item['applied']}",
                    "start": updated_at,
                    "allDay": False,
                    "color": "#FF9800"
                })
            if item['phone_screen'] > 0:
                events.append({
                    "title": f"Phone Screen: {item['phone_screen']}",
                    "start": updated_at,
                    "allDay": False,
                    "color": "#FFC107"
                })
            if item['technical'] > 0:
                events.append({
                    "title": f"Technical: {item['technical']}",
                    "start": updated_at,
                    "allDay": False,
                    "color": "#8BC34A"
                })
            if item['onsite'] > 0:
                events.append({
                    "title": f"Onsite: {item['onsite']}",
                    "start": updated_at,
                    "allDay": False,
                    "color": "#2196F3"
                })
            if item['offer'] > 0:
                events.append({
                    "title": f"Offer: {item['offer']}",
                    "start": updated_at,
                    "allDay": False,
                    "color": "#AB47BC"
                })
            if item['rejected'] > 0:
                events.append({
                    "title": f"Rejected: {item['rejected']}",
                    "start": updated_at,
                    "allDay": False,
                    "color": "#F44336"
                })
    return events



def get_status_color(status):
    colors = {
        "new": "#FFFFFF",
        "applied": "#FF9800",
        "phone_screen": "#FFC107",
        "technical": "#8BC34A",
        "onsite": "#2196F3",
        "offer": "#AB47BC",
        "skipped": "#9E9E9E",
        "rejected": "#F44336"
    }
    return colors.get(status, "#FFFFFF")

def fetch_day_details(date_str):
    try:
        # Parse the full timestamp and extract just the date part
        date = datetime.fromisoformat(date_str).strftime("%Y-%m-%d")
        response = requests.get(f"{API_BASE_URL}/jobs/status-analytics/day/{date}")
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Error fetching details: {str(e)}")
        return None

def fetch_job_details(job_id):
    """Fetch full details for a specific job"""
    try:
        response = requests.get(f"{API_BASE_URL}/jobs/processed/{job_id}")
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        st.error(f"Error fetching job details: {str(e)}")
        return None

def main():
    st.title("Application Status Timeline")

    analytics = fetch_status_analytics()
    if not analytics:
        return

    calendar_options = {
        "headerToolbar": {
            "left": "prev,next today",
            "center": "title",
            "right": "dayGridMonth,timeGridWeek"
        },
        "initialView": "dayGridMonth",
        "selectable": True,
        "editable": False,
        "displayEventTime": False  # Hide time in month view
    }

    custom_css = """
        .fc-event-title {
            font-weight: 700;
            padding: 4px;
            white-space: normal;
            word-break: break-word;
            font-size:1em;
        }
        .fc-toolbar-title {
            font-size: 0.8rem;
        }
        .fc-event {
            margin: 1px 0 !important;
            padding: 0 !important;
        }
        .fc-daygrid-event {
            overflow: visible;
        }
        .fc-view {
            width: 100% !important;
        }
    """

    calendar_events = convert_to_calendar_events(analytics['status_by_date'])
    state = calendar(events=calendar_events, options=calendar_options, custom_css=custom_css)

    # Handle calendar click events
    if state.get("eventClick"):
        clicked_date = state["eventClick"]["event"]["start"]
        details = fetch_day_details(clicked_date)

        if details:
            st.header(f"Updates on {clicked_date}")
            for job in details:
                with st.expander(f"{job['title']} at {job['company']}"):
                    st.write(f"Status: {job['status']}")
                    st.write(f"Updated at: {job['updated_at']}")
                    if job.get('url'):
                        st.write(f"[View Job]({job['url']})")

if __name__ == "__main__":
    main()