pipeline {
    agent { label 'macos' }

    options {
        skipDefaultCheckout(false)
        buildDiscarder(logRotator(numToKeepStr: '20'))
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        LANG = 'en_US.UTF-8'
        LC_ALL = 'en_US.UTF-8'

        // Dedicated, persistent keychain for iOS code signing.
        CI_KEYCHAIN = "${env.HOME}/Library/Keychains/ci.keychain-db"
        MATCH_KEYCHAIN_NAME = "${env.HOME}/Library/Keychains/ci.keychain-db"
        MATCH_KEYCHAIN_PASSWORD = 'ci'

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

        stage('Prepare iOS Keychain') {
            steps {
                sh '''
                    set -e
                    KC="$CI_KEYCHAIN"
                    PW="$MATCH_KEYCHAIN_PASSWORD"

                    # Create once, reused on every subsequent build.
                    if [ ! -f "$KC" ]; then
                        security create-keychain -p "$PW" "$KC"
                    fi

                    # No auto-lock (can't lock mid-build), unlock for this run.
                    security set-keychain-settings "$KC"
                    security unlock-keychain -p "$PW" "$KC"

                    # Add to the search list ALONGSIDE login + System.
                    security list-keychains -d user -s "$HOME/Library/Keychains/login.keychain-db" "$KC" "/Library/Keychains/System.keychain"
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

                # Lock the dedicated CI keychain and restore the plain search list.
                security lock-keychain "$CI_KEYCHAIN" 2>/dev/null || true
                security list-keychains -d user -s ~/Library/Keychains/login.keychain-db /Library/Keychains/System.keychain || true

                # TODO: remove after this ran once
                security delete-keychain ~/Library/Keychains/fastlane_tmp_keychain-db 2>/dev/null || true
                security default-keychain -d user -s ~/Library/Keychains/login.keychain-db || true

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