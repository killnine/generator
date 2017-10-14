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

-- start up teamcity
-- start up repository
-- add project to teamcity
-- add project to github
-- add build project to teamcity
-- deploy to registry in automated fashion
