# Continuous deployment to amazon ecs with bitbucket pipeline

First you have to create a user in AWS IAM. For this user you can create the access key and the secret key.

Next you have to define following environment variables in the Bitbucket Pipeline settings:

- AWS\_DEFAULT\_REGION
- AWS\_ACCESS\_KEY\_ID
- AWS\_SECRET\_ACCESS\_KEY [check &quot;Secured&quot; here]
- AWS\_REGISTRY\_URL

Here is how the general deployment workflow looks like

![workflow](/workflow.png?raw=true "")

## Commit code to bitbucket

Once your commit has been made on the master branch, bitbucket pipelines gets triggered automatically and all the steps illustrated under master branch in the bitbucket-pipelines.yml will get executed. In our case we are using master branch for deployment but it is customizable. The environment variables which we have defined earlier in the bitbucket pipeline settings will be used in this bitbucket-pipelines.yml file.

## Test &amp; Build

Run your test cases to make sure that the code is working before it is being deployed. For this i&#39;ve created a file named &quot;Dockerfile&quot; and included some sample commands for testing and building NodeJS application. You can update the commands accordingly w.r.t the technology that you&#39;re using.

The following command mentioned in bitbucket-pipelines.yml will execute the instructions in the Dockerfile and create a docker image

    docker build -t ${AWS\_REGISTRY\_URL}:$BUILD\_ID .

## Push your code to Amazon ECR

The following command mentioned in bitbucket-pipelines.yml will push the docker image to Amazon ECR

    docker push ${AWS\_REGISTRY\_URL}:$BUILD\_ID

## Deploy

For deployment I wrote the &quot;deploy.sh&quot; script and task-definition.json.

A task definition is required to run Docker containers in Amazon ECS. In task definition you need to specify the following parameters based on your requirement:

- The Docker images to use with the containers in your task
- How much CPU and memory to use with each container
- Working directory of the application (In our case we have placed the files under &quot;app&quot; directory)
- The ports from the container to map to the host container instance

 The &quot;deploy.sh&quot; script will create a new revision of your task definition for you and update your service. You only have to pass following parameters from the bitbucket-pipelines.yml file:

-    name of cluster [-b]
-    the service you want to deploy [-s]
-    the deployment environment (&quot;staging&quot; in our case) [-e]
-    the image name [-i]

    bash ./deploy.sh -b CLUSTER\_NAME -s SERVICE\_NAME -e ${DEPLOYMENT\_ENV} -i $BUILD\_ID



Note: Place all the files in the root directory of your project.
