!

# Adding a local repository to GitHub with GitHub CLI

# Initialize the local directory as a Git repository.
git init -b main

# Stage and commit all the files in your project.
git add . && git commit -m "initial commit"

# To create a repository for your project on GitHub, use the gh repo create subcommand.
gh repo create lentix/monorepo-workspaces