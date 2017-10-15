# A Container-Driven Workflow #

## Demo 1 - ##

* code C:\WIP\Sandbox\DockerDemo
* Go over the layout of the application
    - two projects (api and api.test)
    - infrastructure folder to hold some of my other scripts
* show nothing is running on http://localhost:5000
* build and run the application: dotnet run
* show the API running on http://localhost:5000 and then close
* show unit test project: cd /api.test
* execute unit tests: dotnet test
* Wouldn't it be nice if we could generate a runtime image of our app, but in the process build and test?
* Open Dockerfile and .dockerignore
    - .dockerignore allows us to skip artifacts that aren't necessary for the build (faster, smaller images)
    - There are many solutions here: but testing as a part of the process ensure you don't get an image for a non-passing build
    - We only end up keeping the runtime image

    - Restoring packages can be done at the solution level, but doing it at the project level is good so that you only run a restore when you need to (if I only change deps on test project, I wont restore api project)
    - Generally put what's most likely to change later in the file
    
    - Copy in source code into current working directory (this is where .dockerignore is helpful)

    - Run dotnet test against the test

    - Run dotnet publish, passing in the path, and output directory

    - This is a multi-stage build. Now we're building the runtime image which doesn't have the SDK in it. You wouldn't be able to pushlish using this image alone. But for running a compiled library, you're good!
* Some important notes:
    - 
* To build (NO NETMOTION!), change back into root and run: docker build -t generator .
    - see the new "latest" tag: docker images
    - see all the layers used to build the final image: docker images -a
    - For every line of our dockerfile, we make a new image 'layer'
    - get rid of dangling images to save some space: docker image prune
    
    - Docker takes advantage of build caching so that if we re-do these steps, we only rebuild the layers that have changed
    - Change RangeTests' content
    - Rerun the build: docker build -t generator .
        - Everything uses cache until we copy files over (which have changed)
        - After that point, the layers rebuild

* Verify that nothing is running on http://localhost:8080
* To test, run: docker run --rm -it -p 8080:80 generator
* Show that app is now live on http://localhost:8080

## Demo 2 - Pulling From and Pushing To Registries ##

* Tag image and give it a tag: docker tag generator derekheiser/generator:lunchandlearn
* Show images: docker images
* Push to repository: docker push derekheiser/generator:lunchandlearn

* Show available registries: docker info

* Pull image down from another source: docker pull derekheiser/generator:lunchandlearn
* Run image: docker run --rm -it -p 8080:80 derekheiser/generator:lunchandlearn

## Demo 3 - Running apps in a Container ##

* change into teamcity infrastructure: cd /infrastructure/teamcity
* Start pulling and starting docker-compose: docker-compose up

## Demo 4 - ##

** May want to clear out the teamcity container before doing this

* cd infrastructure/registry
* docker-compose up -d
* navigate to http://localhost:55000/v2/_catalog to show the repository
* edit hosts file to alias registry (as admin!):
    -  notepad C:\Windows\System32\drivers\etc\hosts

* cd ..
* cd teamcity
* run 'code docker-compose.yml'
* docker-compose up
* navigate to http://localhost:8111
* authorize the agent

* Within teamcity, create a new project using URL: https://github.com/killnine/generator
* Add a build step using 'Command Line Runner'
* Put 'docker version' into custom script 
    - This will call out to docker version on the agent
    - Should see server version and client.
* Update VCS to point to branch for 'demo'

* Update the build script
    image="my-registry:55000/generator:ci-%build.number%"
    docker build -t $image .
* Show that the image now shows up in our repository listing 
    docker image ls
* Show that there's now an image in the registry too:
    http://my-registry:55000/v2/_catalog
    http://my-registry:55000/v2/generator/tags/list
* Note that this will take up room on the build server so probably want to remove the images afterward and clean them up.

* Open Range.cs in the Controllers section of the source
* Comment out the ordering
* Commit to demo branch with message "Testing auto-build process (fails)"
* Click on button in VSCode to push source
* Build should start in TeamCity and fail
* Show log and the failed test. This is because of the TEAMCITY_PROJECT_NAME environment variable being 'fake', which ties into xunit
    - This is only for xUnit runner
    - This is only for the build stage and wont exist in runtime stage
* Add ordering back and commit to demo branch with message "Testing auto-build process (pass)"
* Click on button in VSCode to push source
* Summarize
    - Because we're running tests in docker file, if nothing changes, we won't rerun tests. (Not necessarily bad)
    - Our build agent doesn't know about .net. This could just as easily be a python application, ruby, Go, whatever. If the agent can execute docker, then it can run the dockerfile

* I can even deploy to Azure Container Registry, and I'll do that so I can access this from somewhere else:
    docker login qglunchandlearn.azurecr.io -u QGLunchAndLearn -p rPx=8xNKgQEd0dr1RgeKdkfm9pItUV2Z
    image="qglunchandlearn.azurecr.io/generator:ci-%build.number%"
    docker build -t $image .

    docker push $image

* Pull an image
    - docker pull qglunchandlearn.azurecr.io/generator:ci-x
* Run image 
    - docker run --rm -it -p 8080:80 qglunchandlearn.azurecr.io/generator:ci-x
* Now we'll use the pipeline
    - Update Startup.cs to have a new title
* Commit source and push to repository
* Allow to build in TeamCity
* Check Azure Container Registry for new image
* Pull an image
    - docker pull qglunchandlearn.azurecr.io/generator:ci-x
* Run image 
    - docker run --rm -it -p 8090:80 qglunchandlearn.azurecr.io/generator:ci-x

## Demo 5 - DC/OS ##

* eval `ssh-agent -s`
* 'ssh-add -l'
*  ssh-add myPrivateKey_rsa
* ssh qgadmin@qgorchestratormgmt.centralus.cloudapp.azure.com -p 2200 -L 8000:localhost:80
* Connect to http://localhost:8000


## Cleanup ##

* Clean up containers
    - docker rm xxxx

* Clean up images
    - docker images rm xxxx
