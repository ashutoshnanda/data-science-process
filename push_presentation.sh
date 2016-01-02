#!/usr/bin/env bash

# Usage
usage="./push_presentation.sh \"<commit message for current branch>\" [\"<commit message for gh-pages>\"]"
# You can specify one commit message for both branches by including one argument. However, you do have the ability to do different commit messages for the two branches by including two different messages; the first message will be for the current branch, and the second message will be for the gh-pages branch. 

# Assumptions
# - One already has a gh-pages branch
# - One's GitHub remote is called origin
# - One is on the current branch
# - One has compiled the new presentation into index.html
# - One isn't tracking index.html in the current branch

if (( $# <= 0 || $# >= 3 )); then
    echo "Expecting 1 or 2 parameters, received $# parameters..."
    echo "Usage: $usage"
    exit 1
fi

if [ ! -f "index.html" ]; then
    echo "No presentation found!"
    echo "Please recompile the presentation, and make sure its name is \"index.html\"."
    exit 1
fi

current_branch_message=""
gh_pages_branch_message=""
if (( $# == 1 )); then
    current_branch_message=$1
    gh_pages_branch_message=$current_branch_message  
else
    current_branch_message=$1
    gh_pages_branch_message=$2
fi

echo "Message for current branch: \"$current_branch_message\""
echo "Message for gh-pages branch: \"$gh_pages_branch_message\""

# Get current branch
current_branch=$(git branch | awk '/^\*/{print $2}')

# Add all files that have been modified since last commit
for file in $(git ls-files -m); do
    git add $file
done

# Commit current branch
git commit -m "$current_branch_message"

# Push current branch
git push -u origin $current_branch

# Move presentation into parent folder
mv index.html ..

# Switch branches
git checkout gh-pages

# Move presentation into current folder
mv ../index.html .

# Add presentation
git add index.html

# Commit gh-pages branch
git commit -m "$gh_pages_branch_message"

# Push gh-pages branch 
git push -u origin gh-pages

#Switch back branches
git checkout $current_branch
