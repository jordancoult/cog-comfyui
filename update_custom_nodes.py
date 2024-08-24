"""
This script updates all the commit fields in the custom_nodes.json file to the most recent commit for each repository listed, using only the first 7 characters of the commit hash.
It reads the current data, fetches the latest commit SHA using the GitHub API, updates the commit fields with the first 7 characters of the commit hash, and writes the updated data back to the file.
"""

import requests
import json

# Path to the JSON file
json_file_path = 'custom_nodes.json'
print("Starting script to update commit fields in custom_nodes.json")

# Function to get the latest commit SHA (first 7 characters) for a given GitHub repo URL
def get_latest_commit_sha(repo_url):
  print(f"Fetching latest commit for repository: {repo_url}")
  api_url = f"https://api.github.com/repos/{'/'.join(repo_url.split('/')[-2:])}/commits?per_page=1"
  response = requests.get(api_url)
  if response.status_code == 200:
    latest_sha = response.json()[0]['sha'][:7]  # Get only the first 7 characters
    print(f"Latest commit SHA (first 7 characters) for {repo_url}: {latest_sha}")
    return latest_sha
  else:
    print(f"Failed to fetch latest commit for {repo_url}. Status code: {response.status_code}")
    return None

# Read the current data from the JSON file
print("Reading current data from custom_nodes.json")
with open(json_file_path, 'r') as file:
  nodes = json.load(file)

# Update each node with the latest commit SHA (first 7 characters)
for node in nodes:
  repo_url = node['repo']  # Use repo URL to identify the node
  print(f"Updating node with repository URL: {repo_url}")
  latest_commit_sha = get_latest_commit_sha(repo_url)
  if latest_commit_sha:
    node['commit'] = latest_commit_sha
  else:
    print(f"Skipping update for repository URL: {repo_url} due to fetch failure.")

# Function to detect indentation style
def detect_indentation(file_path):
  with open(file_path, 'r') as file:
    for line in file:
      stripped_line = line.lstrip()
      if stripped_line and stripped_line[0] == '{':
        indentation = len(line) - len(stripped_line)
        return ' ' * indentation
  return ' ' * 4  # Default to 4 spaces if not detected

# Detect current indentation
current_indentation = detect_indentation(json_file_path)

# Write the updated data back to the JSON file using detected indentation
print("Writing updated data back to custom_nodes.json")
with open(json_file_path, 'w') as file:
  json.dump(nodes, file, indent=current_indentation)
  file.write('\n')  # Ensure a newline at the end of the file

print("Update complete.")