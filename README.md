# delphi_task
Delphi_task repo
# HOW TO RUN THIS

step 1: create Azure resources initially before hand by running "terraform init" and "terraform plan -out out.plan"
Step2: Now run "terraform apply"
Step3: once you have successfully created the Azure resources, you will be able to setup the Azure DevOps pipeline project

# DevOps pipeline project

Step1: You can create a pipeline job for build and release 
Step2: set the repo to github or clone this repo..
Step 3: Once the ci-pipeline.yaml file has been successfully imported the "ci-steps.yaml" file will be executed 

ci-steps.yaml --- will build the maven artifact and Docker build will takes place

Once the docker build is completed , image is tagged with build ID and pushed to ACR repo. 

Now the helm chart will be prepared and build_artifact is collected and placed ready for deployment.

cd-steps.yaml ---- will begin deploy the helm chart for spring boot app... Once it is deployed successfully you will get the external IP address (like: xxx.xxx.xxx.xxx) now you can go to your browser and enter xxx.xxx.xxx.xxx:8080 

SPRING BOOT APP will be displayed on browser.....

NOTE: we are using Azure key_vault here so replace the necessary variables...
