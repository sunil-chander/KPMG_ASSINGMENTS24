import requests
import csv
from datetime import datetime

# API endpoint
url = "https://api.tfl.gov.uk/Line/Mode/tube/Status"

# Fetch data from TfL API
response = requests.get(url)
data = response.json()

# Define the output file
output_file = 'tube_line_status.csv'

# Open the file in append mode
with open(output_file, mode='a', newline='') as file:
    writer = csv.writer(file, delimiter=',')
    
# Iterate through each line status
    for line in data:
        line_name = line['name']
        status = line['lineStatuses'][0]['statusSeverityDescription']
        disruption_reason = line['lineStatuses'][0].get('reason', 'None')
        current_timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
# Write data to CSV
        writer.writerow([current_timestamp, line_name, status, disruption_reason])

print(f"Data appended to {output_file}")
