#!/bin/bash

# Prompt user for file paths
echo "Enter the path to your transcript PDF:"
read transcript_path
echo "Enter the path to the course plan PDF:"
read course_plan_path

# Check if files exist
if [[ ! -f "$transcript_path" || ! -f "$course_plan_path" ]]; then
    echo "Error: One or both files do not exist."
    exit 1
fi

# Extract text from PDFs
transcript_text=$(pdftotext -layout "$transcript_path" -)
course_plan_text=$(pdftotext -layout "$course_plan_path" -)

# Extract course codes and grades from transcript
completed_courses=$(echo "$transcript_text" | grep -oE "[A-Z]{3,4}[0-9]{4} .* [A-F][+-]?")

# Extract course codes from course plan
plan_courses=$(echo "$course_plan_text" | grep -oE "[A-Z]{3,4}[0-9]{4}")

# Prepare output
output_file="course_analysis.txt"
{
    echo "=============================================="
    echo "           AHMED WALID LAB PROJECT"
    echo "          Created on $(date '+%Y-%m-%d')"
    echo "=============================================="
    echo
    echo "COMPLETED COURSES"
    echo "----------------"
    echo "$completed_courses" | while read -r line; do
        course=$(echo "$line" | cut -d' ' -f1)
        grade=$(echo "$line" | grep -oE "[A-F][+-]?$")
        printf "%-10s %s\n" "$course" "$grade"
    done
    echo
    echo "COURSES TO BE TAKEN"
    echo "------------------"
    echo "$plan_courses" | grep -vFf <(echo "$completed_courses" | awk '{print $1}') | \
    while read -r course; do
        printf "%s\n" "$course"
    done
} > "$output_file"

# Notify user
echo "Analysis completed. Results saved to $output_file."