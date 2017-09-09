#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$DIR"
source $DIR/agilefant-API.sh

###############################################################################

# call agilefant-API-getProduct-simple $RETURN_VAL $ID
agilefant-API-getProduct-simple() {
	log "Getting product simple" 1
    declare -n reVal=$1
	
	agilefant-API-getProduct GS_PRODUCT $2
	local GS_PRODUCT=$(echo $GS_PRODUCT | jq '. | del(.description) | del(.class) | del(.standAlone) | del(.product)')
	local GS_PRODUCT_JSON=$(echo $GS_PRODUCT | jq '. | {"id":.id, "type":0, "data": ., "projects": []}')
	
	local GS_JSON=$GS_PRODUCT_JSON
	
	reVal=$GS_JSON
    log "GS_JSON is: $GS_JSON" 0
}

# call agilefant-API-getProject-simple $RETURN_VAL $ID
agilefant-API-getProject-simple() {
	log "Getting project simple" 1
    declare -n reVal=$1
	
	agilefant-API-getProject GS_PROJECT $2
	local GS_PROJECT=$(echo $GS_PROJECT | jq '. | del(.class) | del(.description) | del(.children) | del(.leafStories) | del(.product) | del(.rank) | del(.root) | del(.standAlone) | del(.status)')
	local GS_PROJECT_JSON=$(echo $GS_PROJECT | jq '. | {"id": .id, "type":1, "users": [], "data": ., "stories": [], "iterations": []}')
	local GS_PROJECT_ASSIGNEES_COUNT=$(echo $GS_PROJECT | jq '. | .assignees | length')
	for gs_i in $(seq 1 "$GS_PROJECT_ASSIGNEES_COUNT");
	do
        local GS_PROJECT_ASSIGNEE=$(echo $GS_PROJECT | jq -r --arg I $gs_i '. | .assignees[$I | tonumber -1] | del(.class) | del(.initials)')
        local GS_PROJECT_JSON=$(echo $GS_PROJECT_JSON | jq -r --arg I $gs_i --arg A "$GS_PROJECT_ASSIGNEE" '. | .users[$I | tonumber -1] |= . + ($A | fromjson)')

        local GS_PROJECT_JSON=$(echo $GS_PROJECT_JSON | jq '. | del(.data.assignees)')
	done
	
	local GS_JSON=$GS_PROJECT_JSON
	
	reVal=$GS_JSON
    log "GS_JSON is: $GS_JSON" 0
}

# call agilefant-API-getIteration-simple $RETURN_VAL $ID
agilefant-API-getIteration-simple() {
	log "Getting iteration simple" 1
    declare -n reVal=$1
	
	agilefant-API-getIteration GS_ITERATION $2
	local GS_ITERATION=$(echo $GS_ITERATION | jq '. | del(.class) | del(.tasks) | del(.description) | del(.rankedStories) | del(.root) |  del(.product) | del(.readonlyToken) | del(.iterationMetrics) ')
	local GS_ITERATION_JSON=$(echo $GS_ITERATION | jq '. | {"id": .id, "type": 2, "users": [], "data": ., "tasks": [], "stories":[]}')
	local GS_ITERATION_ASSIGNEES_COUNT=$(echo $GS_ITERATION | jq '. | .assignees | length')
	for gs_i in $(seq 1 "$GS_ITERATION_ASSIGNEES_COUNT");
	do
		local GS_ITERATION_ASSIGNEE=$(echo $GS_ITERATION | jq -r --arg I $gs_i '. | .assignees[$I | tonumber -1] | del(.class) | del(.initials)')
		local GS_ITERATION_JSON=$(echo $GS_ITERATION_JSON | jq -r --arg I $gs_i --arg A "$GS_ITERATION_ASSIGNEE" '. | .users[$I | tonumber -1] |= . + ($A | fromjson)')
        local GS_ITERATION_JSON=$(echo $GS_ITERATION_JSON | jq '. | del(.data.assignees)')
	done
	
	local GS_JSON=$GS_ITERATION_JSON
	
	reVal=$GS_JSON
    log "GS_JSON is: $GS_JSON" 0
}

# call agilefant-API-getStory-simple $RETURN_VAL $ID
agilefant-API-getStory-simple() {
	log "Getting story simple $2" 1
    declare -n reVal=$1
	
	agilefant-API-getStory GS_STORY $2

	local GS_STORY=$(echo $GS_STORY | jq '. | del(.backlog) | del(.class) | del(.children) | del(.description) | del(.highestPoints) | del(.metrics) | del(.tasks) | del(.treeRank) | del(.workQueueRank) | del(.labels)')
	local GS_STORY_PARENT=$(echo $GS_STORY | jq '. | .parent.id')
	if [ $GS_STORY_PARENT == "null" ]; then
		GS_STORY_PARENT="-1"
	fi

	local GS_STORY=$(echo $GS_STORY | jq '. | del(.parent)')
	local GS_STORY_JSON=$(echo $GS_STORY | jq --arg P "$GS_STORY_PARENT" '. | {"id": .id, "type": 3, "parent": ($P | tonumber -1),"users":[], "iteration": .iteration.id, "data": ., "tasks":[]}')
	local GS_STORY_RESPONSIBLES_COUNT=$(echo $GS_STORY | jq '. | .responsibles | length')
	for gs_i in $(seq 1 "$GS_STORY_RESPONSIBLES_COUNT");
	do
		local GS_STORY_RESPONSIBLE=$(echo $GS_STORY | jq -r --arg I $gs_i '. | {"id": (.responsibles[$I | tonumber -1] | .id), "name":  (.responsibles[$I | tonumber -1] | .name)}')
		local GS_STORY_JSON=$(echo $GS_STORY_JSON | jq -r --arg I $gs_i --arg A "$GS_STORY_RESPONSIBLE" '. | .users[$I | tonumber -1] |= . + ($A | fromjson)')
		 local GS_STORY_JSON=$(echo $GS_STORY_JSON | jq '. | del(.data.responsibles) | del(.data.iteration)')
	done
	
	local GS_JSON=$GS_STORY_JSON
	
	reVal=$GS_JSON
    log "GS_JSON is: $GS_JSON" 0
}

# call agilefant-API-getTask-simple $RETURN_VAL $ID
agilefant-API-getTask-simple() {
	log "Getting task simple" 1
    declare -n reVal=$1
	
	agilefant-API-getTask GS_TASK $2
	local GS_TASK=$(echo $GS_TASK | jq '. | del(.class) | del(.rank) | del(.description) | del(.rank)')
	local GS_TASK_JSON=$(echo $GS_TASK | jq '. | {"id": .id, "type": 4, "users":[], "data": .}')
	local GS_TASK_RESPONSIBLES_COUNT=$(echo $GS_TASK | jq '. | .responsibles | length')
	for gs_i in $(seq 1 "$GS_TASK_RESPONSIBLES_COUNT");
	do
		local GS_TASK_RESPONSIBLE=$(echo $GS_TASK | jq -r --arg I $gs_i '. | {"id": (.responsibles[$I | tonumber -1] | .id), "name":  (.responsibles[$I | tonumber -1] | .name)}')
		local GS_TASK_JSON=$(echo $GS_TASK_JSON | jq -r --arg I $gs_i --arg A "$GS_TASK_RESPONSIBLE" '. | .users[$I | tonumber -1] |= . + ($A | fromjson)')
		local GS_TASK_JSON=$(echo $GS_TASK_JSON | jq '. | del(.data.responsibles) | del(.data.iteration)')
	done
	
	local GS_JSON=$GS_TASK_JSON
	
	reVal=$GS_JSON
    log "GS_JSON is: $GS_JSON" 0
}

################################################################################

# call agilefant-API-getMainStructure $RETURN_VAL
# function to create a simple representation of the agilefant object structure (products, projects, iterations, stories, tasks)
# it cuts out crosslinks between objects (except for stories with parents) and leaves out text heavy fields like descriptions
# this funtion is meant to give a json representation of all agilefant objects to run searches and other operations on
# see the agilefant-API-ExecForAll function below for an example on how to iterate over the structure this funtion creates
agilefant-API-getMainStructure() {
	log "Getting main structure" 1
    declare -n reVal=$1
	MAIN_JSON='{"products": [], "users": []}'
	agilefant-API-getMenuData MENU_DATA
	MAIN=$(echo $MENU_DATA | jq -r '[.[] | {type: .addClass, id: .id, title: .title, childs: [(.children[] | {type: .addClass, id: .id, title: .title, childs: [(.children[] | {class: .addClass, id: .id, title: .title})]})]}]')
	PRODUCT_COUNT="$(echo $MAIN | jq '. | length')"
	log "PRODUCT_COUNT is: $PRODUCT_COUNT" 0
	for i in $(seq 1 "$PRODUCT_COUNT"); 
	do
		PRODUCT="$(echo $MAIN | jq -r --arg I $i '.[$I | tonumber -1]')"
		PRODUCT_ID=$(echo $PRODUCT | jq '. | .id')
		log "Working on product with id: $PRODUCT_ID" 0
		if [ ! "$PRODUCT_ID" == "-1" ]; then
			agilefant-API-getProduct-simple X_PRODUCT $PRODUCT_ID
		else
			X_PRODUCT='{"id": -1, "type": 0, "iterations":[]}'
		fi
		PRODUCT_CHILD_COUNT="$(echo $PRODUCT | jq '. | .childs | length')"
		log "PRODUCT_CHILD_COUNT is $PRODUCT_CHILD_COUNT" 0
		for j in $(seq 1 "$PRODUCT_CHILD_COUNT");
		do
			PROJECT_OR_ITERATION=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1] | .type')
			BACKLOG_ID=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1] | .id')
			if [ "$PROJECT_OR_ITERATION" == "PROJECT" ]; then
				log "Working on project with id: $BACKLOG_ID" 0
				agilefant-API-getProject-simple X_PROJECT $BACKLOG_ID
				PROJECT_ITERATION_COUNT=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1] | .childs | length')
				log "Number of project iterations:  $PROJECT_ITERATION_COUNT" 1
				PROJECT=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1]')
				for k in $(seq 1 "$PROJECT_ITERATION_COUNT"); 
				do
					ITERATION=$(echo $PRODUCT | jq -r --arg J $j --arg K $k '. | .childs[$J | tonumber -1] | .childs[$K | tonumber -1]') 
					ITERATION_ID=$(echo $ITERATION | jq '. | .id')
					agilefant-API-getIteration ITERATION_JSON  $ITERATION_ID
					agilefant-API-getIteration-simple X_ITERATION $ITERATION_ID
					ITERATION_TASKS_COUNT=$(echo $ITERATION_JSON | jq '. | .tasks | length')
					for x in $(seq 1 "$ITERATION_TASKS_COUNT");
					do
						TASK_ID=$(echo $ITERATION_JSON | jq -r --arg X $x '. | .tasks[$X | tonumber -1]  | .id')
						log "Working on task with ID: $TASK_ID" 1
						agilefant-API-getTask-simple X_TASK $TASK_ID
						X_ITERATION=$(echo $X_ITERATION | jq --arg Z $x --arg X "$X_TASK" '. | .tasks[$Z | tonumber -1] |= .+ ($X | fromjson)')	
					done
					X_PROJECT=$(echo $X_PROJECT | jq --arg K $k --arg X "$X_ITERATION" '. | .iterations[$K | tonumber -1] |= .+ ($X | fromjson)')
				done
				agilefant-API-getProjectStoryTree PROJECT_STORY_TREE $BACKLOG_ID	
				PROJECT_STORIES=$(echo $PROJECT_STORY_TREE | grep -o -E "storyid\S+" | grep -o "[0-9]*")
				if [ ! "$PROJECT_STORIES" == "" ]; then
					count=1
					while read -ra STORIES; do
						for l in "${STORIES[@]}"; do
							log "Working on story with id: $l" 0
							agilefant-API-getStory-simple X_STORY $l
							agilefant-API-getStory STORY_TASKS $l
							STORY_TASKS_COUNT=$(echo $STORY_TASKS | jq -r '. | .tasks | length')
							for z in $(seq 1 "$STORY_TASKS_COUNT");
							do
								TASK_ID=$(echo $STORY_TASKS | jq --arg Z $z '. | .tasks[$Z | tonumber -1] | .id')
								log "Working on task: $TASK_ID" 0
								agilefant-API-getTask-simple X_TASK $TASK_ID
								X_STORY=$(echo $X_STORY | jq --arg Z $z --arg X "$X_TASK" '. | .tasks[$Z | tonumber -1] |= .+ ($X | fromjson)')
							done
						done
						X_PROJECT=$(echo $X_PROJECT | jq --arg L "$count" --arg X "$X_STORY" '. | .stories[$L | tonumber -1] |= .+ ($X | fromjson)')
						count=$(($count+1))
					done <<< "$PROJECT_STORIES"
				fi
				X_PRODUCT=$(echo $X_PRODUCT | jq --arg J $j --arg X "$X_PROJECT" '. | .projects[$J | tonumber -1] |= .+ ($X | fromjson)')
			fi
			if [ "$PROJECT_OR_ITERATION" == "ITERATION" ]; then
				ITERATION=$(echo $PRODUCT | jq -r --arg J $j '. | .childs[$J | tonumber -1]')
				log "Working on iteration with id: $BACKLOG_ID" 0
				agilefant-API-getIteration-simple X_ITERATION $BACKLOG_ID
				ITERATION_ID=$(echo $ITERATION | jq '. | .id')
				agilefant-API-getIteration ITERATION_JSON  $ITERATION_ID
				ITERATION_TASKS_COUNT=$(echo $ITERATION_JSON | jq '. | .tasks | length')
				ITERATION_STORY_COUNT=$(echo $ITERATION_JSON | jq '. | .rankedStories | length')
				for f in $(seq 1 "$ITERATION_STORY_COUNT");
				do
					STORY_ID=$(echo $ITERATION_JSON | jq --arg F $f '. | .rankedStories[$F | tonumber -1].id')
					agilefant-API-getStory-simple X_STORY $STORY_ID
					agilefant-API-getStory STORY_TASKS $STORY_ID
					STORY_TASKS_COUNT=$(echo $STORY_TASKS | jq -r '. | .tasks | length')
					for z in $(seq 1 "$STORY_TASKS_COUNT");
					do
						TASK_ID=$(echo $STORY_TASKS | jq --arg Z $z '. | .tasks[$Z | tonumber -1] | .id')
						log "Working on task: $TASK_ID" 0
						agilefant-API-getTask-simple X_TASK $TASK_ID
						X_STORY=$(echo $X_STORY | jq --arg Z $z --arg X "$X_TASK" '. | .tasks[$Z | tonumber -1] |= .+ ($X | fromjson)')
					done
					X_ITERATION=$(echo $X_ITERATION | jq --arg L "$f" --arg X "$X_STORY" '. | .stories[$L | tonumber -1] |= .+ ($X | fromjson)')
				done
				for x in $(seq 1 "$ITERATION_TASKS_COUNT");
				do
					TASK_ID=$(echo $ITERATION_JSON | jq -r --arg X $x '. | .tasks[$X | tonumber -1]  | .id')
					log "Working on task with ID: $TASK_ID" 0
					agilefant-API-getTask-simple X_TASK $TASK_ID
					X_ITERATION=$(echo $X_ITERATION | jq --arg Z $x --arg X "$X_TASK" '. | .tasks[$Z | tonumber -1] |= .+ ($X | fromjson)')
				done
				X_PRODUCT=$(echo $X_PRODUCT | jq --arg J $j --arg X "$X_ITERATION" '. | .iterations[$J | tonumber -1] |= .+ ($X | fromjson)')	
			fi
		done
		MAIN_JSON=$(echo $MAIN_JSON | jq --arg I "$i" --arg X "$X_PRODUCT" '. | .products[ $I | tonumber -1] |= .+ ($X | fromjson)')
	done
	agilefant-API-getUsers USERS
	USERS_COUNT=$(echo $USERS | jq '. | length')
	for i in $(seq 1 "$USERS_COUNT");
	do
		USER=$(echo $USERS | jq --arg I $i '.[($I | tonumber -1)] | del(.class)')
		MAIN_JSON=$(echo $MAIN_JSON | jq --arg I $i --arg U "$USER" '. | .users[($I | tonumber -1)] |= .+ ($U | fromjson)')
	done	
	reVal=$MAIN_JSON
	log "MAIN_JSON is: $MAIN_JSON" 0
	log "Got main structure" 1
}

################################################################################

# call agilefant-API-ExecForAll $MAIN_JSON $PRODUCT_CALLBACK $PROJECT_CALLBACK $ITERATION_CALLBACK $STORY_CALLBACK $TASK_CALLBACK
# simple function to run functions on all objects
# calls callbacks with 3 args:
# callback OBJECT_ID OBJECT_JSON MAIN_JSON
# calls in this order: project-stories-tasks - project-stories - projects - iteration-story-tasks - iteration-stories - iteration-tasks - products
agilefant-API-execForAll() {
MAIN_JSON=$1
	PRODUCTS=$(echo $MAIN_JSON | jq '. | .products')
	PRODUCT_COUNT=$(echo $MAIN_JSON | jq '. | .products | length')
	log "Number of products: $PRODUCT_COUNT" 0
	local i
	for i in $(seq 1 "$PRODUCT_COUNT");
	do
		PROJECTS="[]"
		ITERATIONS="[]"
		PRODUCT=$(echo $PRODUCTS | jq --arg I $i '. | .[$I | tonumber -1]')
		PRODUCT_ID=$(echo $PRODUCTS | jq --arg I $i '. | .[$I | tonumber -1].id')
		log "PRODUCT_ID: $PRODUCT_ID" 0
		PROJECTS=$(echo $PRODUCTS | jq --arg I $i '. | .[$I | tonumber -1].projects')
		if [ $PRODUCT_ID == "-1" ]; then
			ITERATIONS=$(echo $PRODUCTS | jq --arg I $i '. | .[$I | tonumber -1].iterations')
		else
			PROJECT_COUNT=$(echo $PRODUCTS | jq --arg I $i '. | .[$I | tonumber -1].projects | length')
			log "Number of projects: $PROJECT_COUNT" 0
			local j
			for j in $(seq 1 "$PROJECT_COUNT");
			do
				STORIES=[]
				TASKS=[]
				PROJECT=$(echo $PRODUCTS | jq --arg I $i --arg J $j '. | .[$I | tonumber -1].projects[$J | tonumber -1]')
				PROJECT_ID=$(echo $PRODUCTS | jq --arg I $i --arg J $j '. | .[$I | tonumber -1].projects[$J | tonumber -1].id')
				log "PROJECT_ID: $PROJECT_ID" 0
				ITERATIONS=$(echo $PRODUCTS | jq --arg I $i --arg J $j '. | .[$I | tonumber -1].projects[$J | tonumber -1] | .iterations')
				STORIES=$(echo $PRODUCTS | jq --arg I $i --arg J $j '. | .[$I | tonumber -1].projects[$J | tonumber -1] | .stories')
				STORIES_COUNT=$(echo $PRODUCTS | jq --arg I $i --arg J $j '. | .[$I | tonumber -1].projects[$J | tonumber -1] | .stories | length')
				log "Number of stories: $STORIES_COUNT" 0
				local l
				for l in $(seq 1 "$STORIES_COUNT");
				do
					STORY_ID=$(echo $PRODUCTS | jq --arg I $i --arg J $j --arg L $l '. | .[$I | tonumber -1].projects[$J | tonumber -1] | .stories[$L | tonumber -1].id')
					log "STORY_ID: $STORY_ID" 0
					STORY=$(echo $PRODUCTS | jq --arg I $i --arg J $j --arg L $l '. | .[$I | tonumber -1].projects[$J | tonumber -1] | .stories[$L | tonumber -1]')
					TASKS=$(echo $PRODUCTS | jq --arg I $i --arg J $j --arg L $l '. | .[$I | tonumber -1].projects[$J | tonumber -1] | .stories[$L | tonumber -1] | .tasks')
					TASKS_COUNT=$(echo $PRODUCTS | jq --arg I $i --arg J $j --arg L $l '. | .[$I | tonumber -1].projects[$J | tonumber -1] | .stories[$L | tonumber -1] | .tasks | length')
					log "Number of tasks: $TASKS_COUNT" 0
					local m
					for m in $(seq 1 "$TASKS_COUNT");
					do
						TASK_ID=$(echo $PRODUCTS | jq --arg I $i --arg J $j --arg L $l --arg M $m '. | .[$I | tonumber -1].projects[$J | tonumber -1] | .stories[$L | tonumber -1] | .tasks[$M | tonumber -1].id')
						log "TASK_ID: $TASK_ID" 0
						TASK=$(echo $PRODUCTS | jq --arg I $i --arg J $j --arg L $l --arg M $m '. | .[$I | tonumber -1].projects[$J | tonumber -1] | .stories[$L | tonumber -1] | .tasks[$M | tonumber -1]')
						if [ ! -z "$6" ]; then
							$6 "$TASK_ID" "$TASK" "$MAIN_JSON"
						fi
					done
					if [ ! -z "$5" ]; then
						$5 "$STORY_ID" "$STORY" "$MAIN_JSON"
					fi
				done
				ITERATION_COUNT=$(echo $ITERATIONS | jq '. | length')
				log "Number of iterations: $ITERATION_COUNT" 0
				local k
				for k in $(seq 1 "$ITERATION_COUNT");
				do
					STORIES=[]
					TASKS=[]
					ITERATION=$(echo $ITERATIONS | jq --arg K $k '. | .[$K | tonumber -1]')
					ITERATION_ID=$(echo $ITERATIONS | jq --arg K $k '. | .[$K | tonumber -1].id')
					log "ITERATION_ID: $ITERATION_ID" 0
					STORIES=$(echo $ITERATIONS | jq --arg K $k '. | .[$K | tonumber -1] | .stories')
					STORIES_COUNT=$(echo $ITERATIONS | jq --arg K $k '. | .[$K | tonumber -1] | .stories | length')
					log "Number of stories: $STORIES_COUNT" 0
					local l
					for l in $(seq 1 "$STORIES_COUNT");
					do	
						STORY_ID=$(echo $ITERATIONS | jq --arg K $k --arg L $l '. | .[$K | tonumber -1] | .stories[$L | tonumber -1].id')
						log "STORY_ID: $STORY_ID" 0
						STORY=$(echo $ITERATIONS | jq --arg K $k --arg L $l '. | .[$K | tonumber -1] | .stories[$L | tonumber -1]')
						TASKS=$(echo $ITERATIONS | jq --arg K $k --arg L $l '. | .[$K | tonumber -1] | .stories[$L | tonumber -1] | .tasks')
						TASKS_COUNT=$(echo $ITERATIONS | jq --arg K $k --arg L $l '. | .[$K | tonumber -1] | .stories[$L | tonumber -1] | .tasks | length')
						log "Number of tasks: $TASKS_COUNT" 0
						local m
						for m in $(seq 1 "$TASKS_COUNT");
						do
							TASK_ID=$(echo $ITERATIONS | jq --arg K $k --arg L $l --arg M $m '. | .[$K | tonumber -1] | .stories[$L | tonumber -1] | .tasks[$M | tonumber -1].id')
							log "TASK_ID: $TASK_ID" 0
							TASK=$(echo $ITERATIONS | jq --arg K $k --arg L $l --arg M $m '. | .[$K | tonumber -1] | .stories[$L | tonumber -1] | .tasks[$M | tonumber -1]')
							if [ ! -z "$6" ]; then
								$6 "$TASK_ID" "$TASK" "$MAIN_JSON"
							fi
						done
						if [ ! -z "$5" ]; then
							$5 "$STORY_ID" "$STORY" "$MAIN_JSON"
						fi
					done
					TASKS=$(echo $ITERATIONS | jq --arg K $k '. | .[$K | tonumber -1] | .tasks')
					TASKS_COUNT=$(echo $ITERATIONS | jq --arg K $k '. | .[$K | tonumber -1] | .tasks | length')
					log "Number of tasks: $TASKS_COUNT" 0
					local m
					for m in $(seq 1 "$TASKS_COUNT");
					do
						TASK_ID=$(echo $ITERATIONS | jq --arg K $k --arg M $m '. | .[$K | tonumber -1] | .tasks[$M | tonumber -1].id')
						log "TASK_ID: $TASK_ID" 0
						TASK=$(echo $ITERATIONS | jq --arg K $k --arg M $m '. | .[$K | tonumber -1] | .tasks[$M | tonumber -1]')
						if [ ! -z "$6" ]; then
							$6 "$TASK_ID" "$TASK" "$MAIN_JSON"
						fi
					done
					if [ ! -z "$4" ]; then
						$4 "$ITERATION_ID" "$ITERATION" "$MAIN_JSON"
					fi
				done
				if [ ! -z "$3" ]; then
					$3 "$PROJECT_ID" "$PROJECT" "$MAIN_JSON"
				fi				
			done
		fi
		ITERATION_COUNT=$(echo $ITERATIONS | jq '. | length')
		log "Number of iterations: $ITERATION_COUNT" 0
		local k
		for k in $(seq 1 "$ITERATION_COUNT");
		do
			STORIES=[]
			TASKS=[]
			ITERATION=$(echo $ITERATIONS | jq --arg K $k '. | .[$K | tonumber -1]')
			ITERATION_ID=$(echo $ITERATIONS | jq --arg K $k '. | .[$K | tonumber -1].id')
			log "ITERATION_ID: $ITERATION_ID" 0
			STORIES=$(echo $ITERATIONS | jq --arg K $k '. | .[$K | tonumber -1] | .stories')
			STORIES_COUNT=$(echo $ITERATIONS | jq --arg K $k '. | .[$K | tonumber -1] | .stories | length')
			log "Number of stories: $STORIES_COUNT" 0
			local l
			for l in $(seq 1 "$STORIES_COUNT");
			do
				STORY_ID=$(echo $ITERATIONS | jq --arg K $k --arg L $l '. | .[$K | tonumber -1] | .stories[$L | tonumber -1].id')
				log "STORY_ID: $STORY_ID" 0
				STORY=$(echo $ITERATIONS | jq --arg K $k --arg L $l '. | .[$K | tonumber -1] | .stories[$L | tonumber -1]')
				TASKS=$(echo $ITERATIONS | jq --arg K $k --arg L $l '. | .[$K | tonumber -1] | .stories[$L | tonumber -1] | .tasks')
				TASKS_COUNT=$(echo $ITERATIONS | jq --arg K $k --arg L $l '. | .[$K | tonumber -1] | .stories[$L | tonumber -1] | .tasks | length')
				log "Number of tasks: $TASKS_COUNT" 0
				local m
				for m in $(seq 1 "$TASKS_COUNT");
				do
					TASK_ID=$(echo $ITERATIONS | jq --arg K $k --arg L $l --arg M $m '. | .[$K | tonumber -1] | .stories[$L | tonumber -1] | .tasks[$M | tonumber -1].id')
					log "TASK_ID: $TASK_ID" 0
					TASK=$(echo $ITERATIONS | jq --arg K $k --arg L $l --arg M $m '. | .[$K | tonumber -1] | .stories[$L | tonumber -1] | .tasks[$M | tonumber -1]')
					if [ ! -z "$6" ]; then
						$6 "$TASK_ID" "$TASK" "$MAIN_JSON"
					fi
				done
				if [ ! -z "$5" ]; then
					$5 "$STORY_ID" "$STORY" "$MAIN_JSON"
				fi
			done
			TASKS=$(echo $ITERATIONS | jq --arg K $k '. | .[$K | tonumber -1] | .tasks')
			TASKS_COUNT=$(echo $ITERATIONS | jq --arg K $k '. | .[$K | tonumber -1] | .tasks | length')
			log "Number of tasks: $TASKS_COUNT" 0
			local m
			for m in $(seq 1 "$TASKS_COUNT");
			do
				TASK_ID=$(echo $ITERATIONS | jq --arg K $k --arg M $m '. | .[$K | tonumber -1] | .tasks[$M | tonumber -1].id')
				log "TASK_ID: $TASK_ID" 0
				TASK=$(echo $ITERATIONS | jq --arg K $k --arg M $m '. | .[$K | tonumber -1] | .tasks[$M | tonumber -1]')
				if [ ! -z "$6" ]; then
					$6 "$TASK_ID" "$TASK" "$MAIN_JSON"
				fi
			done
			if [ ! -z "$4" ]; then
				$4 "$ITERATION_ID" "$ITERATION" "$MAIN_JSON"
			fi
		done
		if [ ! -z "$2" ]; then
		 $2 "$PRODUCT_ID" "$PRODUCT" "$MAIN_JSON"
		fi
	done
}