#!/usr/bin/env bash

HOME_PATH=$HOME
GHOST_PATH="${HOME_PATH}/.ghost/current"
GHOST_SERVER_URL="localhost:2373/"
gh_username="VenkatTeja"
remote_url="git@github.com:VenkatTeja/hashstack-docs-demo.git"
gh_repo="hashstack-docs-demo"

first_deploy() {
	if [ -d "$GHOST_PATH" ]; then
		cd "$GHOST_PATH"

		# Expects an input from user to provide a Git remote URL in which Ghost will be deployed.
		echo ' -------------------- INFORMATION NEEDED -------------------- '
		echo ''
		echo "Following you'll be asked to enter a Github Username and Git Remote URL in which you would like to deploy Ghost."
		echo "Example:"
		echo "       git@github.com:YOUR_USERNAME/YOUR_REPOSITORY.git"
		echo ''
		# Setting up buster on the current folder.
		buster setup --gh-repo="$remote_url"
		buster generate --domain="$GHOST_SERVER_URL"
		
		# Remote static/.git, else commit will fail
		rm -rf static/.git
		
		# Fixing Links
		find static -name *.html -type f -exec sed -i '''s#http://localhost:2373#'$gh_username'.github.io/'$gh_repo'#g' {} \;

		# Git initialize
		git init
		git remote add origin "$remote_url"

		# Add .gitignore
		if [ -f "gitignore.base" ]; then
			$(rm -f .gitignore)
			$(cp gitignore.base .gitignore)
		fi

		git add -A
		git commit -m "First commit on Github Pages using Ghost."
		GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_hashstack_docs' git push origin master:master master:gh-pages -f
	fi
}

update() {
	if [ -d "$GHOST_PATH" ]; then
		cd "$GHOST_PATH"

		# Generating static files
		buster generate --domain="$GHOST_SERVER_URL"

		echo ' -------------------- FIXING LINKS  -------------------- '
		echo ''
		
		# Fixing Links
		find static -name *.html -type f -exec sed -i '''s#http://localhost:2373#'$gh_username'.github.io/'$gh_repo'#g' {} \;

		# Commiting changes to repository in order to deploy new content.
		git add -A
		git commit -m "Update on the website at $(date)"
		GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_hashstack_docs' git push origin master:master master:gh-pages -f
	fi
}
		
deploy() {
	if [ -d "$GHOST_PATH" ]; then
		cd "$GHOST_PATH"

		# Check if repo already exists on current path
		repo_exists="$(git status)"
		case "fatal" in 
  			*"$repo_exists"*)
				echo '[INFO] Configuring git repository...'
				echo '[INFO] Generating static files from Ghost server...'
				first_deploy
    			exit
    		;;
		esac
		echo '[INFO] Deploying to your Github repository...'
		update
	fi
}
deploy


