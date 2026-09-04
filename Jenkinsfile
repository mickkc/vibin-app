pipeline {
    agent { label 'macos' }

    options {
        skipDefaultCheckout(false)
        buildDiscarder(logRotator(numToKeepStr: '20'))
        timestamps()
        disableConcurrentBuilds()
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
                        cp "$KEYSTORE_FILE" android/app/release.jks
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

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/*.apk',
                                  fingerprint: true
            }
        }
    }

    post {
        always {
            sh '''
                flutter clean || true
                rm -f android/key.properties android/app/release.jks
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