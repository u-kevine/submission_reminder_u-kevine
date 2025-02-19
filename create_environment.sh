#!/bin/bash

#user's name
read -p "What's your name?:" yourname

# Define the value

subr="submission_reminder_$yourname"

# Create the main directory and move into it
mkdir -p "$subr"
cd "$subr"

# subdirectories
mkdir app modules assets config

# Create script and data files
touch app/reminder.sh modules/functions.sh assets/submissions.txt config/config.env

# Give execution permissions only to script files
chmod +x app/reminder.sh modules/functions.sh

# Populate reminder.sh
cat <<EOL >"app/reminder.sh"
#!/bin/bash

# Source environment variables and helper functions
source ./config/config.env
source ./modules/functions.sh

# Path to the submissions file
submissions_file="./assets/submissions.txt"

# Print remaining time and run the reminder function
echo "Assignment: \$ASSIGNMENT"
echo "Days remaining to submit: \$DAYS_REMAINING days"
echo "--------------------------------------------"

check_submissions \$submissions_file
EOF

# Populate functions.sh
cat <<EOF >"modules/functions.sh"
#!/bin/bash

# Function to read submissions file and output students who have not submitted
function check_submissions {
    local submissions_file=\$1
    echo "Checking submissions in \$submissions_file"

    # Skip the header and iterate through the lines
    while IFS=, read -r student assignment status; do
        # Remove leading and trailing whitespace
        student=\$(echo "\$student" | xargs)
        assignment=\$(echo "\$assignment" | xargs)
        status=\$(echo "\$status" | xargs)

        # Check if assignment matches and status is 'not submitted'
        if [[ "\$assignment" == "\$ASSIGNMENT" && "\$status" == "not submitted" ]]; then
            echo "Reminder: \$student has not submitted the \$ASSIGNMENT assignment!"
        fi
    done < <(tail -n +2 "\$submissions_file") # Skip the header
}
EOL

# Populate config.env
cat <<EOF >"config/config.env"
# This is the config file
ASSIGNMENT="Shell Navigation"
DAYS_REMAINING=2
EOF

# Populate submissions.txt
cat <<EOF >"assets/submissions.txt"
student, assignment, submission status
Chinemerem, Shell Navigation, not submitted
Chiagoziem, Git, submitted
Divine, Shell Navigation, not submitted
Anissa, Shell Basics, submitted
EOF

# Creating startup.sh
cat <<EOF >"startup.sh"
#!/bin/bash
echo "App opening....."
bash app/reminder.sh
EOF

# Making startup.sh executable
chmod +x startup.sh
./startup.sh
