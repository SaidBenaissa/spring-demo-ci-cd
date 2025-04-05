# Getting Started

### Reference Documentation
For further reference, please consider the following sections:

* [Official Apache Maven documentation](https://maven.apache.org/guides/index.html)
* [Spring Boot Maven Plugin Reference Guide](https://docs.spring.io/spring-boot/3.4.4/maven-plugin)
* [Create an OCI image](https://docs.spring.io/spring-boot/3.4.4/maven-plugin/build-image.html)

### Maven Parent overrides

Due to Maven's design, elements are inherited from the parent POM to the project POM.
While most of the inheritance is fine, it also inherits unwanted elements like `<license>` and `<developers>` from the parent.
To prevent this, the project POM contains empty overrides for these elements.
If you manually switch to a different parent and actually want the inheritance, you need to remove those overrides.

# Jenkins local run
To run the project locally, you need to have a local Jenkins instance running.
You can use the following command to run the project locally:

```bash
docker rm -f jenkins

docker run -d \
  --name jenkins \
  -p 8090:8080 -p 50000:50000 \
  -v jenkins_data:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -u 0 \
  jenkins/jenkins:lts

```

Or start existing Jenkins instance with the following command:

```bash
docker start jenkins
```
# check if Jenkins is running
```bash
docker ps
```
# check if Jenkins is running
```bash
docker logs jenkins
```


Then, you can access Jenkins at `http://localhost:8090` and use the default credentials (admin/admin) to log in.

# To set GitHub webhook for Jenkins
1. Go to your GitHub repository and click on "Settings".
2. In the left sidebar, click on "Webhooks".
3. Click on the "Add webhook" button.
4. In the "Payload URL" field, enter the URL of your Jenkins server followed by `/github-webhook/`. For example: `http://your-jenkins-server/github-webhook/`.
5. In the "Content type" dropdown, select "application/json".
6. To get Payload URL, use ssh -R 80:localhost:8090 serveo.net to expose your localhost jenkins server to the internet.

```bash
ssh -R 80:localhost:8090 serveo.net
```
7. In the "Which events would you like to trigger this webhook?" section, select "Just the push event".
8. Make sure the "Active" checkbox is checked.
9. Click the "Add webhook" button to save the webhook.
10. You should see a green checkmark next to the webhook, indicating that it is active.
11. Now, whenever you push changes to your GitHub repository, GitHub will send a payload to your Jenkins server, triggering the build process.
# To set Jenkins pipeline
1. Go to your Jenkins instance and click on "New Item".
2. Enter a name for your pipeline and select "Pipeline" as the project type.
3. Click "OK" to create the pipeline.
4. In the pipeline configuration page, scroll down to the "Pipeline" section.
5. In the "Definition" dropdown, select "Pipeline script from SCM".
6. In the "SCM" dropdown, select "Git".
7. In the "Repository URL" field, enter the URL of your GitHub repository.
8. In the "Credentials" dropdown, select the credentials you created earlier.
9. In the "Branches to build" field, enter the branch you want to build (e.g., `*/main`).
10. In the "Script Path" field, enter the path to your Jenkinsfile (e.g., `Jenkinsfile`).
11. Click "Save" to save the pipeline configuration.
12. Now, whenever you push changes to your GitHub repository, Jenkins will automatically trigger the pipeline and build your project.
# To set Jenkins credentials
1. Go to your Jenkins instance and click on "Manage Jenkins".
2. Click on "Manage Credentials".
3. Click on the "(global)" domain.
4. Click on "Add Credentials".
5. In the "Kind" dropdown, select "Username with password".
6. In the "Username" field, enter your GitHub username.
7. In the "Password" field, enter your GitHub personal access token.
8. In the "ID" field, enter a unique ID for the credentials (e.g., `github-credentials`).
9. In the "Description" field, enter a description for the credentials (e.g., `GitHub credentials`).
10. Click "OK" to save the credentials.
11. Now, you can use these credentials in your Jenkins pipeline to authenticate with GitHub.
# To set Jenkins GitHub credentials
1. Go to your Jenkins instance and click on "Manage Jenkins".
2. Click on "Manage Credentials".
3. Click on the "(global)" domain.
4. Click on "Add Credentials".
5. In the "Kind" dropdown, select "GitHub Personal Access Token".