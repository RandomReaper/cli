pipeline
{
    environment
    {
        PROJECTNAME = "cli.pignat.org"
        SUBJECT_SUB = "${env.PROJECTNAME} (${env.JOB_NAME},  build ${env.BUILD_NUMBER})"
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
                    cd site
                    check-links ./_site --max-threads 1
                    htmlproofer ./_site
                '''
            }
        }
		
    }

    post
    {
        always
        {
            emailext (
                subject: "[jenkins] Job always ${env.SUBJECT_SUB}",
                mimeType: 'text/html',
                body: '${JELLY_SCRIPT,template="html"}',
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }

        fixed
        {
            emailext (
                subject: "[jenkins] Job fixed ${env.SUBJECT_SUB}",
                mimeType: 'text/html',
                body: '${JELLY_SCRIPT,template="html"}',
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }
        
        regression
        {
            emailext (
                subject: "[jenkins] Job regression ${env.SUBJECT_SUB}",
                mimeType: 'text/html',
                body: '${JELLY_SCRIPT,template="html"}',
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }
    }
}
