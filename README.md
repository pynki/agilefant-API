# IMPORTANT

These scripts are intended to be called from the run.sh wrapper script. Please see [runsh repository](https://github.com/pynki/runsh) on how to use the wrapper script. 

Before cloning this repository clone the runsh wrapper script repository.

`git clone https://github.com/pynki/runsh`

then chaneg the folder to the cloned repo:

`cd ./runsh`

and run the scripts by passing the config file to the runsh wrapper script

`./run.sh /path/to/what/ever/script.conf`

Since these scripts provide only function calls please provide a config file for your own scripts to call with the runsh wrapper script.

# About

Inclomplete agilefant (the opensource version!) API. Provides functions to create, delete and change products, projects, iterations, stories and tasks. Also provides a function to parse the agilefant structure into a JSON object to perform searches etc. on. A function to iterate over all the objects is provided too.

Please read the scripts before you use them! The delete functions for example might be dangerous to use. They will be happy to delete your whole agilefant content without asking you any questions. 

If you are not sure on how to use the functions please have a look at the [agilefant-automation repository](https://github.com/pynki/agilefant-automation) to see the example scripts.

For detailes information on how to use the functions please see the comments above the functions in scripts.

# Remarks

There are things that are totally left out right now: labels, ranking, spending effort, stroy tree management and user management. If i have the time or the need to implement them i will do it.

Sories that belong to products are not handled at all right now. I did not see that when i wrote the scripts, nore do i use this feature in my agilefant installations.

This is work in progress. There might be bugs, unhandled corner cases or plain stupid code in the scripts. It works for me, in the cases i use it. If you need something changed: open an issue or fork the code. I am happy about pull requests.