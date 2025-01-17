// #!groovy
def git_repo_url = params.repository_url
def git_branch = params.repository_branch
env.mode = params.mode // 'develop'
env.project_group = params.project_group // 'template'
env.project_name = params.project_name
env.tag_version = params.tag_version
env.registry_url = params.registry_url
env.port = params.port
env.images = env.registry_url + "/" + env.project_group + "/" + env.project_name
env.app_name = env.mode +"-" + env.project_group + "-" + env.project_name
env.host_name = env.app_name+"."+params.host

println "mode => " + mode
println "git_repo_url => " + git_repo_url
println "git_branch => " + git_branch
println "project_group => " + env.project_group
println "project_name => " + env.project_name
println "tag => " + env.tag_version
println "registry_url => " + env.registry_url
println "port => " + env.port
println "images => " + env.images
println "app_name => " + env.app_name
println "host_name => " + env.host_name

pipeline {
    agent {
        node {
            label 'jenkins-slave-devsecops'
        }
    }

    stages {

        stage('Approve') {
            steps {
                script {
                    if (mode != "develop") {
                        timeout(time: 30, unit: 'MINUTES') { 
                            script {
                                def userInput = input(
                                    id: 'userInput', message: 'Approve for Promote?', parameters: [
                                        [$class: 'BooleanParameterDefinition', name: 'Approve', defaultValue: true]
                                    ]
                                )

                                echo ("Env: "+userInput)

                                if (!userInput) {
                                    error "Deployment not approved for Promote. Aborting."
                                }
                            }
                        }
                    } else {
                        println "No approval required for mode: " + mode
                    }
                }
            }
        }

        stage('Prepare Code') {
            steps {
                // Clone the Git repository
                git credentialsId: 'gitlab', \
                url: git_repo_url, \
                branch: git_branch
            }
        }

        stage('Prepare Argocd') {
            steps {       
                container('devsecops') {
                    // Login to Argo CD using a username and password
                    sh 'argocd login ${ARGOCD_URL} --username ${ARGOCD_USERNAME} --password ${ARGOCD_PASSWORD} --insecure'
                    // argocd version
                    sh 'argocd version --short'
                    // kubectl version
                    sh 'kubectl version'
                    // kubectl set
                    // sh 'kubectl config view'
                    // argocd add cluster
                    sh 'argocd cluster add kubernetes-admin@kubernetes || true'
                }        
            }
        }

        stage('Update Chart Value') {
            steps {       
                container('devsecops') {
                    script {
                        // Update Chart Value
                        sh "yq e '.app.namespace = \"${env.project_group}\"' ./values.yaml > ./tmp.yaml"
                        sh "mv ./tmp.yaml ./values.yaml"
                        sh "yq e '.app.port = \"${env.port}\"' ./values.yaml > ./tmp.yaml"
                        sh "mv ./tmp.yaml ./values.yaml"
                        sh "yq e '.image.repository = \"${env.images}\"' ./values.yaml > ./tmp.yaml"
                        sh "mv ./tmp.yaml ./values.yaml"
                        sh "yq e '.image.tag = \"${env.tag_version}\"' ./values.yaml > ./tmp.yaml"
                        sh "mv ./tmp.yaml ./values.yaml"
                        sh "yq e '.service.name = \"${env.app_name}\"' ./values.yaml > ./tmp.yaml"
                        sh "mv ./tmp.yaml ./values.yaml"
                        sh "yq e '.ingress.name = \"${env.app_name}\"' ./values.yaml > ./tmp.yaml"
                        sh "mv ./tmp.yaml ./values.yaml"
                        sh "yq e '.ingress.host = \"${env.host_name}\"' ./values.yaml > ./tmp.yaml"
                        sh "mv ./tmp.yaml ./values.yaml"
                        // Update Argocd App Value
                        sh "yq e '.metadata.name = \"${env.app_name}\"' ./argocd-app.yaml > ./argocd-tmp.yaml"
                        sh "mv ./argocd-tmp.yaml ./argocd-app.yaml"
                        sh "yq e '.spec.destination.namespace = \"${env.project_group}\"' ./argocd-app.yaml > ./argocd-tmp.yaml"
                        sh "mv ./argocd-tmp.yaml ./argocd-app.yaml"
                        sh "yq e '.spec.source.repoURL = \"${git_repo_url}\"' ./argocd-app.yaml > ./argocd-tmp.yaml"
                        sh "mv ./argocd-tmp.yaml ./argocd-app.yaml"
                        sh "yq e '.spec.source.targetRevision = \"${git_branch}\"' ./argocd-app.yaml > ./argocd-tmp.yaml"
                        sh "mv ./argocd-tmp.yaml ./argocd-app.yaml"
                    }
                }        
            }
        }

        stage('Sync Code') {
            steps {       
                container('devsecops') {
                    script {
                        sh "git config --global --add safe.directory '*'"
                        def changes = sh(returnStdout: true, script: 'git diff --shortstat').trim()
                        echo "changes ${changes}"
                        if (changes  == null || changes == "") {
                            echo "No Change"
                        } else {
                            echo "Change"
                            sh "git status"
                            sh "git add ."
                            sh "git commit -m 'deploy tag ${env.tag_version}'"
                            sh "git push origin HEAD:${git_branch}"
                        }
                    }
                }        
            }
        }

        stage('Argocd Crate App And Sync') {
            steps {       
                container('devsecops') {
                    script {
                        // Print App Name
                        sh "echo 'Service Name: ${env.app_name}'"
                        // Check App Name
                        def appExists = sh(returnStdout: true, script: "argocd app get '${env.app_name}' && echo 'true' || echo 'false'").trim()
                        if (appExists == 'false') {
                            sh 'argocd repo add '+git_repo_url+' --username ${GIT_USERNAME} --password ${GIT_PASSWORD} --insecure-skip-server-verification || true'
                            // Create App
                            sh "kubectl apply -f argocd-app.yaml"
                            println "App ${env.app_name} created successfully"
                            println "Refresh application data when retrieving"  
                            sh "argocd app get ${env.app_name} --refresh"
                            println "Sync an app"
                            sh "argocd app sync ${env.app_name}"
                        } else {
                            println "App ${env.app_name} already exists"
                            println "Refresh application data when retrieving"  
                            sh "argocd app get ${env.app_name} --refresh"
                            println "Sync an app"
                            sh "argocd app sync ${env.app_name}"
                        }

                        // Initialize variables for health check loop
                        def timeoutMinutes = 5
                        def checkInterval = 30 // seconds
                        def totalChecks = timeoutMinutes * 60 / checkInterval
                        def checkCount = 0
                        def appHealth = ""
                        def appStatus = ""

                        // Loop to check health
                        while (checkCount < totalChecks) {
                            // Validate the app's health and status
                            appHealth = sh(returnStdout: true, script: "argocd app get '${env.app_name}' -o json | jq -r '.status.health.status'").trim()
                            appStatus = sh(returnStdout: true, script: "argocd app get '${env.app_name}' -o json | jq -r '.status.sync.status'").trim()
                            
                            echo "Application Health: ${appHealth}"
                            echo "Application Status: ${appStatus}"

                            // Check if the application is healthy and synced
                            if (appHealth.contains("Healthy") && appStatus.contains("Synced")) {
                                println "Application is healthy and synced. Proceeding to sync..."
                                sh "argocd app sync ${env.app_name}"
                                break // Exit loop if synced
                            } else {
                                println "Application is not healthy or not synced. Checking again in ${checkInterval} seconds..."
                                sleep(checkInterval) // Wait before next check
                                checkCount++
                            }
                        }

                        // If the loop completes without syncing, we can throw an error
                        if (checkCount >= totalChecks) {
                            sh "argocd app rollback ${env.app_name}"
                            error "Timeout reached while waiting for application to become healthy or synced. Sync aborted."
                        }

                    }
                }        
            }
        }

    }   

    post {  
        always {
            cleanWs()
        }
    }
}