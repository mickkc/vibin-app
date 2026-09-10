pipeline {
    agent { label 'macos' }

    options {
        skipDefaultCheckout(false)
        buildDiscarder(logRotator(numToKeepStr: '20'))
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        MATCH_PASSWORD = credentials('match-password')
        ASC_KEY_ID = credentials('asc-api-key-id')
        ASC_ISSUER_ID = credentials('asc-api-issuer-id')
        ASC_KEY_FILEPATH = credentials('asc-api-key-p8')
        TEAM_ID = credentials('apple-team-id')
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Prepare Android Signing') {
            steps {
                withCredentials([
                    file(credentialsId: 'android-release-keystore', variable: 'KEYSTORE_FILE'),
                    string(credentialsId: 'android-keystore-password', variable: 'KEYSTORE_PASSWORD'),
                    string(credentialsId: 'android-key-alias', variable: 'KEY_ALIAS'),
                    string(credentialsId: 'android-key-password', variable: 'KEY_PASSWORD')
                ]) {
                    sh '''
                        cp "$KEYSTORE_FILE" android/release.jks
                        cat > android/key.properties <<EOF
storePassword=$KEYSTORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=release.jks
EOF
                    '''
                }
            }
        }

        stage('Flutter Setup') {
            steps {
                sh '''
                    flutter --version
                    flutter doctor -v
                    flutter clean
                    flutter pub get
                '''
            }
        }

        stage('Build API') {
            steps {
                sh '''
                    flutter pub run build_runner build --delete-conflicting-outputs
                '''
            }
        }

        stage('Build Android APK') {
            steps {
                sh '''
                    flutter build apk --release
                '''
            }
        }

        stage('Publish to TestFlight') {
            steps {
                sshagent(credentials: ['match-git-ssh-key']) {
                    dir('ios') {
                        sh 'bundle install'
                        sh 'bundle exec fastlane ios beta'
                    }
                } 
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/*.apk',
                                  fingerprint: true
                archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/*.apk, ios/build/ios/ipa/*.ipa',
                                  fingerprint: true
            }
        }
    }

    post {
        always {
            sh '''
                flutter clean || true
                security delete-keychain ~/Library/Keychains/fastlane_tmp_keychain-db 2>/dev/null || true
                rm -f android/key.properties android/release.jks
            '''
        }
        success {
            echo "Build succeeded"
        }
        failure {
            echo "Build failed"
        }
    }
}