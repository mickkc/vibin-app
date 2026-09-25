import java.text.SimpleDateFormat

/*
    Creates a new app release. This pipeline is run when a new tag is created.

    Currently, only the android version is built and archived, but in the future more platforms will be added and the
    artifacts will get published as a Codeberg release and in app stores.
*/
pipeline {
    agent { label 'macos' }

    options {
        skipDefaultCheckout(false)
        buildDiscarder(logRotator(numToKeepStr: '20'))
        timestamps()
        disableConcurrentBuilds()
    }

    stages {
        stage("Validate") {
            steps {
                script {
                    if (!env.TAG_NAME) {
                        error('This pipeline must be triggered by a git tag.')
                    }
                }
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

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/app-release.apk*',
                                  fingerprint: true
            }
        }

        stage("Create Codeberg Release") {
            steps {
                withCredentials([string(credentialsId: 'RELEASE_CODEBERG_TOKEN', variable: 'RELEASE_CODEBERG_TOKEN')]) {
                    script {
                        def date = new Date()
                        def sdf = new SimpleDateFormat("yyyy-MM-dd")

                        def currentHash = env.GIT_COMMIT
                        def tagName = env.TAG_NAME

                        def commitList = sh(
                            script: "git --no-pager log \$(git describe --tags --abbrev=0 \"${currentHash}^\")..${currentHash} --oneline --merges --color=never --reverse | awk '{print \"- \"\$0}'",
                            returnStdout: true
                        ).trim()

                        def body = readFile 'RELEASE.md'
                        body = body.replace('{version}', tagName).replace('{date}', sdf.format(date)).replace('{commits}', commitList)

                        def repoUrl = env.GIT_URL
                        def parts = repoUrl.split('/')
                        def owner = parts[-2]
                        def repo = parts[-1].replace('.git', '')

                        echo "Repo URL: ${repoUrl}, Owner: ${owner}, Repo: ${repo}"

                        def json = groovy.json.JsonOutput.toJson([
                            body: body,
                            draft: true,
                            name: tagName,
                            prerelease: true,
                            tag_name: tagName,
                            target_commitish: currentHash
                        ])

                        writeFile file: 'payload.json', text: json

                        def response = sh(
                            script: """
                                curl -sS --fail-with-body -X POST \
                                    -H "Authorization: token \$RELEASE_CODEBERG_TOKEN" \
                                    -H "Content-Type: application/json" \
                                    -d @payload.json \
                                    "https://codeberg.org/api/v1/repos/${owner}/${repo}/releases"
                            """,
                            returnStdout: true
                        )

                        def release = readJSON text: response
                        def id = release.id

                        def uploadResponse = sh(
                            script: """
                                curl -sS --fail-with-body -X POST \
                                    -H "Authorization: token \$RELEASE_CODEBERG_TOKEN" \
                                    -F "attachment=@build/app/outputs/flutter-apk/app-release.apk" \
                                    "https://codeberg.org/api/v1/repos/${owner}/${repo}/releases/${id}/assets"
                            """,
                            returnStdout: true
                        )
                    }
                }
            }
        }
    }

    post {
        always {
            sh '''
                flutter clean || true
                rm -f android/key.properties android/release.jks payload.json
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