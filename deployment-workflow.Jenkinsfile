// #!groovy
env.project_group = params.project_group
env.project_name = params.project_name
env.tag_version = params.tag_version
env.registry_url = params.registry_url
env.port = params.port

println "project_group => " + env.project_group
println "project_name => " + env.project_name
println "tag => " + env.tag_version
println "registry_url => " + env.registry_url
println "port => " + env.port

// Constants for role names
def REQUIRED_ROLES = ['admin', 'user-manager']

// Function to create parameters for builds
def createBuildParameters(mode) {
    return [
        string(name: 'mode', value: mode),
        string(name: 'project_group', value: env.project_group),
        string(name: 'project_name', value: env.project_name),
        string(name: 'tag_version', value: env.tag_version),
        string(name: 'registry_url', value: env.registry_url),
        string(name: 'port', value: env.port)
    ]
}

pipeline {
    agent any // Use any available agent

    stages {

        stage('Approve For UAT') {
            steps {
                script {
                    def userInput = input(
                        id: 'userInput', message: 'Approve Deployment for UAT?', parameters: [
                            [$class: 'BooleanParameterDefinition', name: 'Approve', defaultValue: true]
                        ]
                    )
                    if (!userInput) {
                        error "Deployment not approved for UAT. Aborting."
                    }
                }
            }
        }

        stage('Deploy for UAT') {
            steps {
                build job: "uat-${env.project_group}-${env.project_name}-deployment",
                wait: true, parameters: createBuildParameters("uat")
            }
        }

        stage('Approve For Production') {
            steps {
                script {
                    def userInput = input(
                        id: 'userInput', message: 'Approve Deployment for Production?', parameters: [
                            [$class: 'BooleanParameterDefinition', name: 'Approve', defaultValue: true]
                        ]
                    )
                    if (!userInput) {
                        error "Deployment not approved for Production. Aborting."
                    }
                }
            }
        }

        stage('Deploy for Production') {
            steps {
                build job: "prord-${env.project_group}-${env.project_name}-deployment",
                wait: true, parameters: createBuildParameters("prord")
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}