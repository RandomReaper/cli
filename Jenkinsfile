pipeline
{
    environment
    {
        PROJECTNAME = "cli.pignat.org"
    }

    agent
    {
        docker
        {
            image 'jekyll/jekyll'
            args '''
                -u root:root
                -v "${WORKSPACE}:/srv/jekyll"
                -v "${JENKINS_HOME}/caches/${env.PROJECTNAME}-bundle-cache:/usr/local/bundle:rw"
                -v "${JENKINS_HOME}/caches/${env.PROJECTNAME}-html-proofer-cache:/tmp/cache:rw"
            '''
        }
    }
    
    stages
    {
		stage('Build')
		{
			steps
			{
				sh '''
					cd /srv/jekyll
					cd site
					jekyll build -d ./_site
				'''
            }
		}
        stage('Test')
        {
            steps {
				sh '''
					cd /srv/jekyll
                    ruby ./ci/html-proofer.rb site/_site
                '''
            }
        }
		
    }

    post
    {
        always
        {
            emailext (
                subject: "[jenkins][${env.JOB_NAME}] Build ${env.BUILD_NUMBER} status:${currentBuild.currentResult}",
                mimeType: 'text/html',
                body: '${JELLY_SCRIPT,template="html"}',
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }


        fixed
        {
            emailext (
                subject: "[jenkins][${env.JOB_NAME}] Build ${env.BUILD_NUMBER} fixed",
                mimeType: 'text/html',
                body: '${JELLY_SCRIPT,template="html"}',
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }
        regression
        {
            emailext (
                subject: "[jenkins][${env.JOB_NAME}] Build ${env.BUILD_NUMBER} regression",
                mimeType: 'text/html',
                body: '${JELLY_SCRIPT,template="html"}',
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }
    }
}
