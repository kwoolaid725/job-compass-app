import streamlit as st

STATUSES = {
    "new": "#FF4B4B",
    "applied": "#0083B8",
    "phone_screen": "#00C851",
    "technical": "#FFA900",
}

# Inject CSS to target data-status, but only change the border color.
styles = []
for status, color in STATUSES.items():
    styles.append(f"""
    button[data-status="{status}"] {{
       /* Keep the button background white */
       background-color: #ffffff !important;
       /* Make text color black for good contrast on white */
       color: #000000 !important;
       border-radius: 6px !important;
       /* Use the status color for the border */
       border: 2px solid {color} !important;
       margin-bottom: 0.5rem !important;
       cursor: pointer;
    }}
    """)

style_block = "<style>" + "".join(styles) + "</style>"
st.markdown(style_block, unsafe_allow_html=True)

st.sidebar.title("Sidebar Buttons")

for status in STATUSES:
    # Use st.write to inject custom HTML
    st.sidebar.write(
        f'<button data-status="{status}">Test Button {status.title()}</button>',
        unsafe_allow_html=True
    )
