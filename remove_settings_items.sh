#!/bin/bash

# Function to remove list tiles containing specific text
remove_list_tile() {
    local file=$1
    local pattern=$2
    
    if [ -f "$file" ]; then
        # Remove lines from the pattern until the closing parenthesis
        sed -i "/$pattern/,/^[[:space:]]*),/d" "$file"
        echo "Removed $pattern from $file"
    fi
}

# Remove from customer_profile_screen.dart
remove_list_tile "lib/screens/customer/customer_profile_screen.dart" "Notifications"
remove_list_tile "lib/screens/customer/customer_profile_screen.dart" "notifications"
remove_list_tile "lib/screens/customer/customer_profile_screen.dart" "Version"
remove_list_tile "lib/screens/customer/customer_profile_screen.dart" "version"

# Remove from any settings screen
find lib -name "*settings*.dart" -type f | while read file; do
    remove_list_tile "$file" "Notifications"
    remove_list_tile "$file" "notifications"
    remove_list_tile "$file" "Version"
    remove_list_tile "$file" "version"
done

# Remove from profile screens
find lib -name "*profile*.dart" -type f | while read file; do
    remove_list_tile "$file" "Notifications"
    remove_list_tile "$file" "notifications"
    remove_list_tile "$file" "Version"
    remove_list_tile "$file" "version"
done

echo "All notifications and version items removed!"
