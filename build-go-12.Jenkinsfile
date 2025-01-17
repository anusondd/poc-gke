// #!groovy
def git_repo_url = params.repository_url
def git_branch = params.repository_branch
env.mode = params.mode // 'develop'
env.project_group = params.project_group
env.project_name = params.project_name
env.tag_version = params.tag_version
env.registry_url = params.registry_url
env.port = params.port

println "mode => " + mode
println "git_repo_url => " + git_repo_url
println "git_branch => " + git_branch
println "project_group => " + env.project_group
println "project_name => " + env.project_name
println "tag => " + env.tag_version
println "registry_url => " + env.registry_url
println "port => " + env.port

pipeline {
    agent {
        node {
            label 'jenkins-slave-go-1-23-2'
        }
    }

    stages {

        stage('Prepare Code') {
            steps {
                // Clone the Git repository
                git credentialsId: 'gitlab', \
                url: git_repo_url, \
                branch: git_branch
            }
        }

        stage('Tag Version') {
            steps {
                container('devsecops') {
                    script {
                        sh "git config --global --add safe.directory '*'"
                        def shortCommitHash = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                        echo "shortCommitHash: ${shortCommitHash}"
                        if (env.tag_version == null || env.tag_version == "") {
                            echo "Set Tag Version == ${shortCommitHash}"
                            env.tag_version = shortCommitHash
                        } else {
                            echo "Tag Version == ${env.tag_version}"
                        }
                    }
                }
            }
        }

       stage('Clean Up Old Images') {
            steps {
                container('devsecops') {
                    script {
                        sh """
                            docker images -a | grep "$project_name" | awk '{print \$3}' | xargs docker rmi -f || true
                            docker images
                            docker volume prune -f
                        """
                    }
                }
            }
        }

        stage('Compile') {
            steps {
                container('golang') {
                    script{
                        sh script: '''
                        id
                            cd $WORKSPACE
                            go mod download
                            go build -o main ./cmd/api/
                            ls -ltr
                        '''
                    }
                }
            }
        }

        stage('Unit Test') {
            steps {
                container('golang') {
                    script{
                        sh script: '''
                        id
                            cd $WORKSPACE
                            go version
                        '''
                    }
                }
            }
        }

        stage('Sonarqube Register') {
            steps {
                container('devsecops') {
                    script{
                        if (params.code_scan == true) {
                            sh "sh +x /home/jenkins/agent/devops/scripts/sonaqube-create-project.sh $project_name"
                        } else {
                            echo "Skipping Sonarqube Register"
                        }
                    }
                }
            }
        }

        stage('Code Scan') {
            steps {
                container('sonar-scanner-cli') {
                    script{
                        if (params.code_scan == true) {
                            sh 'cd $WORKSPACE'
                            sh script: '''
                            id
                                sonar-scanner \
                                -Dsonar.projectKey=${project_name} \
                                -Dsonar.sources=.
                            '''
                        } else {
                            echo "Skipping Code Scan"
                        }
                    }
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {       
                container('devsecops') {
                    // Docker info
                    sh 'docker -v'

                    // Login to the Docker registry
                    sh 'docker login -u ${REGISTRY_USERNAME} -p ${REGISTRY_PASSWORD}  ${registry_url}' 

                    // Build the Docker image
                    sh 'docker build -t ${registry_url}/${project_group}/${project_name}:${tag_version} .'

                    // Push the Docker image to the registry
                    sh 'docker push ${registry_url}/${project_group}/${project_name}:${tag_version}'
                }        
            }
        }

        stage('Image Scan') {
            steps {
                container('trivy') {
                    script{
                        if (params.image_scan == true) {
                            sh 'cd $WORKSPACE'
                            sh 'trivy image ${registry_url}/${project_group}/${project_name}:${tag_version} --scanners vuln --exit-code 0 --severity LOW,MEDIUM,HIGH --no-progress'
                            sh 'trivy image ${registry_url}/${project_group}/${project_name}:${tag_version} --scanners vuln --exit-code 1 --severity CRITICAL --no-progress'
                        } else {
                            echo "Skipping Image Scan"
                        }
                    }
                }
            }
        }

        stage('Trigger job Deployment') {
            steps {
                build job: env.mode+'-'+env.project_group+'-'+env.project_name+'-deployment', 
                wait: true, parameters: [
                    string(name: 'mode', value: env.mode ),
                    string(name: 'project_group', value: env.project_group ),
                    string(name: 'project_name', value: env.project_name ),
                    string(name: 'tag_version', value: env.tag_version ),
                    string(name: 'registry_url', value: env.registry_url ),
                    string(name: 'port', value: env.port )
                ]
            }
        }

    }
    
    post {  
        always {
            cleanWs()
        }
    }
 
}