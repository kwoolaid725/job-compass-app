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


def convert_to_calendar_events(status_events):
    # First, group events by date and status
    grouped_events = {}
    for event in status_events:
        date = event['date']
        status = event['status']
        key = (date, status)

        if key not in grouped_events:
            grouped_events[key] = {
                'count': event['count'],
                'event_time': event['event_time'],
                'status': status,
                'date': date
            }
        else:
            grouped_events[key]['count'] += event['count']

    # Convert grouped events to calendar events
    events = []
    for (date, status), event_data in grouped_events.items():
        if event_data['count'] > 0:
            events.append({
                "title": f"{status}: {event_data['count']}",
                "start": event_data['event_time'],
                "allDay": False,
                "color": get_status_color(status.lower()),
                "extendedProps": {
                    "status": status,
                    "date": date
                }
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

def fetch_day_details(date_str, status=None):
    try:
        # Parse the full timestamp and extract just the date part
        date = datetime.fromisoformat(date_str).strftime("%Y-%m-%d")
        url = f"{API_BASE_URL}/jobs/status-analytics/day/{date}"
        if status:
            url += f"?status={status}"
        response = requests.get(url)
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
        "displayEventTime": False
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

    calendar_events = convert_to_calendar_events(analytics['status_events'])
    state = calendar(events=calendar_events, options=calendar_options, custom_css=custom_css)

    # Handle calendar click events
    if state.get("eventClick"):
        event_data = state["eventClick"]["event"]
        clicked_date = event_data["start"]
        status = event_data["extendedProps"]["status"]

        details = fetch_day_details(clicked_date, status)

        if details:
            st.header(f"{status} Updates on {event_data['extendedProps']['date']}")
            for job in details:
                with st.expander(f"{job['title']} at {job['company']}"):
                    st.write(f"Status: {job['status']}")
                    if status == "NEW":
                        st.write(f"Created at: {job['created_at']}")
                    else:
                        st.write(f"Updated at: {job['updated_at']}")
                    if job.get('url'):
                        st.write(f"[View Job]({job['url']})")

if __name__ == "__main__":
    main()