import jenkins
from datetime import datetime, timedelta
import time

# Jenkins server details
jenkins_url = 'http://localhost:8080'
jenkins_username = 'playwithjenkinsuser'
jenkins_password = '11bd5bcbdb106a4e81e17734cfbcbdb94b'

# Connect to Jenkins server
server = jenkins.Jenkins(jenkins_url, username=jenkins_username, password=jenkins_password)

def list_running_jobs():
    print("Running Jobs:")
    running_jobs = server.get_running_builds()
    for job in running_jobs:
        print(f"Job Name: {job['name']}, Build Number: {job['number']}")

def stop_long_running_jobs(max_duration_seconds=3):
    running_jobs = server.get_running_builds()
    current_time = datetime.now()

    for job in running_jobs:
        build_info = server.get_build_info(job['name'], job['number'])
        start_time_timestamp = build_info['timestamp'] / 1000.0
        start_time = datetime.fromtimestamp(start_time_timestamp)
        duration = current_time - start_time

        if duration.total_seconds() > max_duration_seconds:
            print(f"Stopping Job: {job['name']}, Build Number: {job['number']}")
            server.stop_build(job['name'], job['number'])




if __name__ == "__main__":
    list_running_jobs()
    stop_long_running_jobs()


