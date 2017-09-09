#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/conf/agilefant-API.conf

###############################################################################

# call agilefant-API-createQueryFromJson $RETURN_QUERY $JSON
agilefant-API-createQueryFromJson() {
	log "Creating query from json" 1
	declare -n reVal=$1	
	QUERY=""
	ARR=( $(echo "$2" | jq -r 'keys[]') )
	FIRST="true"
	local key
	for key in "${ARR[@]}";		
	do
		if [ "$FIRST" == "false" ]; then
			QUERY=${QUERY}"&"
		else
			FIRST="false"
		fi
		VALUE=$(echo "$2" | jq --arg KEY $key '. | .[$KEY]')		
		IS_ARR=$(echo "$VALUE" | jq 'if type=="array" then true else false end')
		VALUE=$(echo "$VALUE" | jq -r '.')
		if [ "$IS_ARR" == "true" ]; then
			ARR_LENGTH=$(echo "$VALUE" | jq '. | length')
			local i
			for i in $(seq 1 "$ARR_LENGTH");
			do
				ARR_VALUE=$(echo $VALUE | jq --arg I $i '. | .[$I | tonumber -1]')
				if [ $i -gt 1 ]; then
				QUERY=${QUERY}"&"
				fi
				QUERY=${QUERY}"$key=$ARR_VALUE"
			done
		else 
			QUERY=${QUERY}"$key=$VALUE"
		fi
	done	
	reVal=$QUERY
	log "QUERY is: $QUERY" 0
}

###############################################################################

# call agilefant-API-login
agilefant-API-login() {
	log "Logging into agilefant" 1
	if [ ! -d "$COOKIE_FILE_DIR" ]; then
		log "COOKIE_FILE_DIR ${COOKIE_FILE_DIR} does not exist. Creating it." 1
		mkdir $COOKIE_FILE_DIR
	fi
	local CURL_OUTPUT
	CURL_OUTPUT=$(curl -ivLs --cookie "$COOKIE_FILE_DIR/$COOKIE_FILE_NAME" --cookie-jar "$COOKIE_FILE_DIR/$COOKIE_FILE_NAME" --data "j_username=$AGILEFANT_USER&j_password=$AGILEFANT_PASSWD" --location "${AGILEFANT_HOST}:${AGILEFANT_PORT}${AGILEFANT_PATH}/j_spring_security_check" 2>&1)
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
	log "Logged into agilefant" 1
#TODO check here if we are reallt logged in
}

# call agilefant-API-logout
agilefant-API-logout() {
	log "Logging out of agilefant" 1
    if [ ! -d "$COOKIE_FILE_DIR" ]; then
         log "COOKIE_FILE_DIR does not exist. Cannot logout." 1
         return 1     
	fi	
	local CURL_OUTPUT
     CURL_OUTPUT=$(curl -ivLs --cookie "$COOKIE_FILE_DIR/$COOKIE_FILE_NAME" --cookie-jar "$COOKIE_FILE_DIR/$COOKIE_FILE_NAME" --data "j_username=$AGILEFANT_USER&j_password=$AGILEFANT_PASSWD" --location "${AGILEFANT_HOST}:${AGILEFANT_PORT}${AGILEFANT_PATH}/j_spring_security_logout?exit=Logout" 2>&1)
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
	log "Logged out of agilefant" 1
	if [ $CLEANUP_TMP_DIR == 1 ]; then
		rm -r $COOKIE_FILE_DIR
		log "Cleaned up COOKIE_FILE_DIR - well, just removed it..." 1
	fi
#TODO check if we are logged out
}

###############################################################################

# call agilefant-API-getMenuData $RETURN_VAR
agilefant-API-getMenuData() {
	log "Getting agilefant menuData" 1
	declare -n reVal=$1
	local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/menuData.action)
	reVal=$CURL_OUTPUT
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0 
}

# call agilefant-API-getProjectStoryTree $RETURN_VAL $PROJECT_BACKLOG_ID
agilefant-API-getProjectStoryTree() {
	log "Getting projectStoryTree of project with backlogId: $2" 1
	declare -n reVal=$1
	local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "projectId=$2" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/getProjectStoryTree.action)
	reVal=$CURL_OUTPUT
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-API-getStory $RETURN_VAL $STORY_ID
agilefant-API-getStory() {
	log "Getting story with id $2" 1
	declare -n reVal=$1
	local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/retrieveStory.action?storyId=$2)
	reVal=$CURL_OUTPUT
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-API-getProduct $RETURN_VAL $PRODUCT_BACKLOG_ID
agilefant-API-getProduct() {
    log "Getting product with backlogId $2" 1
    declare -n reVal=$1
    local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/retrieveProduct.action?productId=$2)
    reVal=$CURL_OUTPUT
    log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-API-getProject $RETURN_VAL $PROJECT_BACKLOG_ID
agilefant-API-getProject() {
    log "Getting project with backlogId $2" 1
    declare -n reVal=$1
    local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/projectData.action?projectId=$2)
    reVal=$CURL_OUTPUT
    log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-API-getProjectTotalSpentEffort $RETURN_VAL $PROJECT_BACKLOG_ID
agilefant-API-getProjectTotalSpentEffort() {
    log "Getting total spend effort of project with backlogId $2" 1
    declare -n reVal=$1
    local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/projectTotalSpentEffort.action?projectId=$2)
    reVal=$CURL_OUTPUT
    log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-API-getIteration $RETURN_VAL $ITERATION_BACKLOG_ID
# this gives us the tasks that have no story and belong to an iteration
agilefant-API-getIteration() {
    log "Getting iteration with backlogId $2" 1
    declare -n reVal=$1
    local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/iterationData.action?iterationId=$2)
    reVal=$CURL_OUTPUT
    log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-API-getTask $RETURN_VAL $TASK_ID
# this is a dirty hack - there is no getTaskData call as far as i could see
agilefant-API-getTask() {
    log "Getting task with taskId $2" 1
    declare -n reVal=$1
    local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "taskId=$2" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeTask.action)
    reVal=$CURL_OUTPUT
    log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-API-getUsers $RETURN_VAL
agilefant-API-getUsers() {
    log "Getting all users" 1
    declare -n reVal=$1
    local CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/retrieveAllUsers.action)
    reVal=$CURL_OUTPUT
    log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

################################################################################

# call agilefant-API-createProduct $PRODUCT_JSON $RETURN_VAL $NEW_ID
# $PROJECT_JSON should look like:
# '{"teamsChanged": true, "product.name": "PRODUCT555555555", "product.description": "DESCRIPTION", "teamIds": [2,3]}'
# set "teamsChanged" to != true for no team access
agilefant-API-createProduct() {
	log "Creating product" 1		
	declare -n reVal=$2
	declare -n reId=$3	
	agilefant-API-createQueryFromJson CURL_DATA "$1"
	log "CURL_DATA: $CURL_DATA" 0
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeNewProduct.action)	
	reVal=$CURL_OUTPUT
	reId=$(echo $CURL_OUTPUT | jq ' . | .id')
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-API-createProject $PRODUCT_JSON $RETURN_VAL $NEW_ID
# $PRODUCT_JSON should look like:
# '{"productId": 69, "project.startDate": 1503964800000, "project.endDate": 1505210400000, "assigneesChanged": true,"project.name": "555555555", "project.description": "DESCRIPTION", "assigneeIds": [5,3], "project.backlogSize": "5h", "project.baselineLoad": "6h", "project.status": "BLACK"}'
# set "assigneesChanged" to != true for no assignees
# set status to one of: "GREEN", "YELLOW", "RED", "GREY", "BLACK", default is "GREEN"
# "backlogSize", "baselineLoad" and "status" can be blank, they are not in the original creation call for projects (http://10.254.0.33:8080/ajax/storeNewProject.action) but in the change iteration call (http://10.254.0.33:8080/ajax/storeProject.action), but they can be set on project creation as well
agilefant-API-createProject() {
	log "Creating project" 1
	declare -n reVal=$2
	declare -n reId=$3
	agilefant-API-createQueryFromJson CURL_DATA "$1"
	log "CURL_DATA: $CURL_DATA" 0
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeNewProject.action)
	reVal=$CURL_OUTPUT
	reId=$(echo $CURL_OUTPUT | jq ' . | .id')
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-API-createIteration $ITERATION_JSON $RETURN_VAL $NEW_ID
# $ITERATION_JSON should look like:
# '{"parentBacklogId": 1, "iteration.startDate": 1503964800000, "iteration.endDate": 1505210400000, "assigneesChanged": true,"iteration.name": "ITERATION1111111111111111", "iteration.description": "DESCRIPTION", "teamsChanged": true, "assigneeIds": [5,3], "teamIds": [2,3],"iteration.backlogSize": "5h", "iteration.baselineLoad": "6h"}'
# do not set "parentBacklogId" for standalone iteration
# set "assigneesChanged" to != true for no assignees
# set "teamsChanged" to != true for no team access, only for standalone iterations neccessary
# "backlogSize" and "baselineLoad" can be blank, they are not in the original creation call for iterations (http://10.254.0.33:8080/ajax/storeNewIteration.action) but in the change iteration call (http://10.254.0.33:8080/ajax/storeIteration.action), but they can be set on iteration creation as well
agilefant-API-createIteration() {
	declare -n reVal=$2
	declare -n reId=$3
	log "Creating iteration" 1
	agilefant-API-createQueryFromJson CURL_DATA "$1"
	log "CURL_DATA: $CURL_DATA" 0
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeNewIteration.action)
	reVal=$CURL_OUTPUT
	reId=$(echo $CURL_OUTPUT | jq ' . | .id')
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-API-createStory $STORY_JSON $RETURN_VAL $NEW_ID
# $STORY_JSON should look like:
# '{"backlogId": 72, "iteration": 71, "usersChanged": true, "story.name": "11111111111111111111111", "story.description": "DESCRIPTION", "userIds": [5,3], "story.storyValue": 1, "story.storyPoints": 2, "story.state": "NOT_STARTED"}'
# backlogId/iteration must be one of the following combinations:
#	targeting project without iteration: "backlogId"=iteration_backlog_id / "iteration"="" (empty string)
#	targeting iteration in project: {backlogId=iteration_backlog_id / "iteration"=iteration_backlog_id} or {backlogId=project_backlog_id / "iteration"=iteration_backlog_id} 
#	targeting standalone iteration: {"backlogId"=iteration_backlog_id / "iteration"=iteration_backlog_id}
# 	if "iteration" is set its only important is that backlogId is set to an existing backlog (no matter if project, iteration or product!) even a {"itaration"=iteration_backlog_id1 / "iteration"=iteration_backlog_id2} works. it will palce the story in the iteration with iteration_backlog_id2
# set "usersChanged" to != true for no users
# set "status" to one of: "NOT_STARTED", "STARTED" (aka 'In Progress'), "PENDING", "BLOCKED", "IMPLEMENTED" (aka 'Ready'), "DONE", "DEFERRED"
agilefant-API-createStory() {
	declare -n reVal=$2
	declare -n reId=$3
	log "Creating story" 1		
	agilefant-API-createQueryFromJson CURL_DATA "$1"	
	log "CURL_DATA: $CURL_DATA" 0
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/createStory.action)
	reVal=$CURL_OUTPUT
	reId=$(echo $CURL_OUTPUT | jq ' . | .id')
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0	
}

# call agilefant-API-createTask $TASK_JSON $RETURN_VAL $NEW_ID
# $TASK_JSON should look like:
#'{"storyId": 19, "responsiblesChanged": true, "name": "TASK1", "description": "DESCRIPTION", "newResponsibles": [5,3], "state": "NOT_STARTED", "task.effortLeft": 123}'
# "storyId" does not need to be a 'LeafStory'
# replace "storyId" with "iterationId" for standalone iteration task
# set "state" to one of: "NOT_STARTED", "STARTED" (aka 'In Progress'), "PENDING", "BLOCKED", "IMPLEMENTED" (aka 'Ready'), "DONE", "DEFERRED"
agilefant-API-createTask() {
	declare -n reVal=$2
	declare -n reId=$3
	log "Creating task" 1		
	agilefant-API-createQueryFromJson CURL_DATA "$1"
	log "CURL_DATA: $CURL_DATA" 0
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/createTask.action)
	reVal=$CURL_OUTPUT
	reId=$(echo $CURL_OUTPUT | jq ' . | .id')
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

################################################################################

# call agilefant-API-storeProduct $PRODUCT_JSON $RETURN_VAL
# $PRODUCT_JSON should look like: 
# '{"productId": 67,"teamsChanged": true, "product.name": "PRODUCT-NAME", "product.description": "DESCRIPTION", "teamIds": [2,3]}'
# as soon as a key/value pair is given it will be changed
# "productId" must be provided
# "teamsChanged" == true without "teamIds" array will remove access for all teams
agilefant-API-storeProduct() {
	log "Storeing product" 1
	declare -n reVal=$2
	agilefant-API-createQueryFromJson CURL_DATA "$1"
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeProduct.action)
	reVal=$CURL_OUTPUT
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-API-storeProject $PROJECT_JSON $RETURN_VAL
# $PRODUCT_JSON should look like: 
# '{"projectId": 80, "project.startDate": 1703964845678, "project.endDate": 1705210445678, "assigneesChanged": true,"project.name": "STORE_PROJECT1", "project.description": "1DESCRIPTION", "assigneeIds": [5,3], "project.backlogSize": "33h", "project.baselineLoad": "33h", "project.status": "BLACK"}'
# as soon as a key/value pair is given it will be changed
# "projectId" must be provided
# "teamsChanged" == true without "teamIds" array will remove access for all teams, same for "assigneesChanged" == true
# set status to one of: "GREEN", "YELLOW", "RED", "GREY", "BLACK"
agilefant-API-storeProject() {
	log "Storeing project" 1
	declare -n reVal=$2
	agilefant-API-createQueryFromJson CURL_DATA "$1"
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeProject.action)
	reVal=$CURL_OUTPUT
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-API-storeIteration $ITERATION_JSON $RETURN_VAL
# $ITERATION_JSON should look like:
# '{"iterationId": 78, "iteration.startDate": 1703964800000, "iteration.endDate": 1705210400000, "assigneesChanged": true, "iteration.name": "ITERATION", "iteration.description": "DESCRIPTION", "assigneeIds": [5,3],"iteration.backlogSize": "5h", "iteration.baselineLoad": "6h", "teamsChanged": true, "teamIds": [3]}'
# "iterationId" must be provided
# set "assigneesChanged" to != true for no assignees
# set "teamsChanged" to != true for no team access, only for standalone iterations neccessary
# both "iteration.assigneesChanged" and "assigneesChanged" need to be true to have an effect
# ATTENTION: the result when removing an assignee is flawed. the result is false, thats why we run the call twice to get the right result!
agilefant-API-storeIteration() {
	log "Storeing project" 1
	declare -n reVal=$2
	agilefant-API-createQueryFromJson CURL_DATA "$1"
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeIteration.action)
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeIteration.action)
	reVal=$CURL_OUTPUT
	log "CURL_OUTPUT is: $CURL_OUTPUT" 1
}

# call agilefant-API-storeStory $STORY_JSON $RETURN_VAL
# $STORY_JSON should look like:
# '{"storyId": 0, "backlogId": 72, "iteration": 71, "usersChanged": true, "story.name": "11111111111111111111111", "story.description": "DESCRIPTION", "userIds": [5,3], "story.storyValue": 1, "story.storyPoints": 2, "story.state": "NOT_STARTED"}'
# "storyId" must be provided
# backlogId/iteration must be one of the following combinations:
#	targeting project without iteration: "backlogId"=iteration_backlog_id / "iteration"="" (empty string)
#	targeting iteration in project: {backlogId=iteration_backlog_id / "iteration"=iteration_backlog_id} or {backlogId=project_backlog_id / "iteration"=iteration_backlog_id} 
#	targeting standalone iteration: {"backlogId"=iteration_backlog_id / "iteration"=iteration_backlog_id}
# 	if "iteration" is set its only important is that backlogId is set to an existing backlog (no matter if project, iteration or product!) even a {"itaration"=iteration_backlog_id1 / "iteration"=iteration_backlog_id2} works. it will palce the story in the iteration with iteration_backlog_id2
# set "usersChanged" to != true for no users
# set "status" to one of: "NOT_STARTED", "STARTED" (aka 'In Progress'), "PENDING", "BLOCKED", "IMPLEMENTED" (aka 'Ready'), "DONE", "DEFERRED"
agilefant-API-storeStory() {
	declare -n reVal=$2
	log "Store story" 1		
	agilefant-API-createQueryFromJson CURL_DATA "$1"	
	log "CURL_DATA: $CURL_DATA" 0
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeStory.action)
	reVal=$CURL_OUTPUT
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0	
}

# call agilefant-API-storeTask $TASK_JSON $RETURN_VAL
# $TASK_JSON should look like:
# '{"taskId": 58, "responsiblesChanged": true, "task.name": "XXXXXXXX", "task.description": "DESCRIPTION", "newResponsibles": [5,3], "task.state": "STARTED", "task.effortLeft": 123}'
# "taskId" must be provided
# set "responsiblesChanged" to != true for no responsibles
# set "state" to one of: "NOT_STARTED", "STARTED" (aka 'In Progress'), "PENDING", "BLOCKED", "IMPLEMENTED" (aka 'Ready'), "DONE", "DEFERRED"
agilefant-API-storeTask() {
	log "Storeing task" 1
	declare -n reVal=$2
	agilefant-API-createQueryFromJson CURL_DATA "$1"
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "$CURL_DATA" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/storeTask.action)
	reVal=$CURL_OUTPUT
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

################################################################################

# call agilefant-API-deleteProduct $PRODUCT_BACKLOG_ID
agilefant-API-deleteProduct() {
	log "Deleting product with id $1" 1
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "confirmationString=yes&productId=$1" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/deleteProduct.action)
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-API-deleteProject $PROJECT_BACKLOG_ID
agilefant-API-deleteProject() {
	log "Deleting project with id $1" 1
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "confirmationString=yes&projectId=$1" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/deleteProject.action)
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-API-deleteIteration $ITERATION_BACKLOG_ID
agilefant-API-deleteIteration() {
	log "Deleting iteration with id $1" 1
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "confirmationString=yes&iterationId=$1" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/deleteIteration.action)
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-API-deleteStory $STORY_ID $CHILD_HANDLING
# this has 3 cases:
#	1: story without parent and children
#	2: story that has children and no parent
#	3: story that has children and parent
# depending on the case there is more than one possible action
#	1: delete story
#	2: (1)delete with children / (2)delete and move children to root	
#	3: (1)delete with children / (2)delete and move children to parent
# $CHILD_HANDLING must be set as follows:
#	1: 	 $CHILD_HANDLING must be "DELETE" or "MOVE" see remark about default value
#	2.1: $CHILD_HANDLING == "DELETE"
#	2.2: $CHILD_HANDLING == "MOVE"
#	3.1: $CHILD_HANDLING == "DELETE"
#	3.2: $CHILD_HANDLING == "MOVE"
# if $CHILD_HANDLING is not explicitly set to "DELETE" this function sets it to "MOVE". Only "DELETE" or "MOVE" are accepted by the agilefant as values.
agilefant-API-deleteStory() {
	log "Deleting story with id $1" 1
	CHILD_HANDLING=$2
	if [ ! $CHILD_HANDLING == "DELETE" ]; then
		CHILD_HANDLING="MOVE"
	fi		
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "storyId=$1&childHandlingChoice=$CHILD_HANDLING" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/deleteStory.action)
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

# call agilefant-API-deleteTask $TASK_ID
agilefant-API-deleteTask() {
	log "Deleting task with id $1" 1
	CURL_OUTPUT=$(curl -s --cookie $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --cookie-jar $COOKIE_FILE_DIR/$COOKIE_FILE_NAME --data "taskId=$1" --location $AGILEFANT_HOST:$AGILEFANT_PORT$AGILEFANT_PATH/ajax/deleteTask.action)
	log "CURL_OUTPUT is: $CURL_OUTPUT" 0
}

################################################################################