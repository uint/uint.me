#!/usr/bin/env groovy

pipeline {
    agent {
        label "bitfolk_vps_ssh"
    }

    stages {
        stage('Verify Zola is installed') {
            steps {
                sh "zola --version"
            }
        }

        stage('Build the static website') {
            steps {
                sh """
                    zola build
                    chown -R :www-data public
                """
            }
        }

        stage('Build docker image') {
            when {
                branch 'master'
            }

            steps {
                sh "docker build -t uint.me ."
            }
        }

        stage('Clean the current static website') {
            when {
                branch 'master'
            }
            
            steps {
                sh "groups"
                sh "rm -rf /var/www/uint.me/public_html"
            }
        }

        stage('Deploy the static website') {
            when {
                branch 'master'
            }

            steps {
                sh "mv public /var/www/uint.me/public_html"
            }
        }
    }
}
