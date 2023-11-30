#!/bin/bash

# Jenkins server configuration
JENKINS_URL="http://localhost:8080"
JENKINS_USER="admin"
JENKINS_TOKEN="11bd5bcbdb106a4e81e17734cfbcbdb94b"

# Function to get the list of running jobs
get_running_jobs() {
    /usr/local/opt/openjdk/bin/java -jar jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_TOKEN list_jobs_in_view "All" | grep ".*\s(Running)\s*$" | awk '{print $1}'
}

# Function to stop jobs running for more than 1 hour
stop_long_running_jobs() {
    running_jobs=$(get_running_jobs)
    for job in $running_jobs; do
        build_info=$(/usr/local/opt/openjdk/bin/java -jar jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_TOKEN get_build_info $job lastBuild --format=json)
        build_start_time=$(echo $build_info | jq -r '.timestamp')
        current_time=$(date +%s)
        elapsed_time=$((current_time - build_start_time / 1000))
        
        if [ $elapsed_time -gt 3600 ]; then  # 1 hour in seconds
            echo "Stopping job $job (running for $elapsed_time seconds)"
            /usr/local/opt/openjdk/bin/java -jar jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_TOKEN stop_build $job lastBuild
        fi
    done
}

# Function to start a job at a specific hour
start_job_at_hour() {
    job_name=$1
    start_hour=$2
    scheduled_time=$(date -d "today $start_hour:00:00" +%s)
    current_time=$(date +%s)

    while [ $current_time -lt $scheduled_time ]; do
        sleep 60  # Sleep for a minute
        current_time=$(date +%s)
    done

    echo "Starting job $job_name at $(date)"
    /usr/local/opt/openjdk/bin/java -jar jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_TOKEN build $job_name
}

# Main script
# Download Jenkins CLI JAR file
wget $JENKINS_URL/jnlpJars/jenkins-cli.jar

# Get running jobs and stop those running for more than 1 hour
stop_long_running_jobs

# Start a job at a specific hour (e.g., 15:00)
start_job_at_hour "your_job_name" 15
