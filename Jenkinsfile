pipeline
{
    environment
    {
        PUBLISH=sh(script: "git describe --exact-match HEAD", returnStatus:true)
    }

    agent
    {
        docker
        {
            image 'jekyll/builder'
            args """
                -u root:root
                -v ${env.JENKINS_HOME}/caches/${env.JOB_NAME}-bundle-cache:/usr/local/bundle:rw
                -v ${env.JENKINS_HOME}/caches/${env.JOB_NAME}-html-proofer-cache:/tmp/cache:rw
            """
        }
    }
    
    stages
    {
		stage('Build')
		{
			steps
			{
				sh '''
        			cd site
					JEKYLL_ENV=production jekyll build -d ./_site
				'''
            }
		}
        stage('Test')
        {
            steps {
				sh '''
                    #FIXME : the cache directory ownen by root on the host machine
                    ruby ./ci/html-proofer.rb site/_site
                '''
            }
        }
        stage('Publish')
        {
            when
            {
                /* PUBLISH is the output value of a shell script, so OK is 0*/
                environment name: 'PUBLISH', value: '0'
            }
            steps
            {
                withCredentials(bindings: [sshUserPrivateKey(credentialsId: 'jenkins-publish-cli_pignat_org', \
                                                             keyFileVariable: 'SSH_KEY')])
                {
                sh '''
                    ci/publish.sh site/_site "$SSH_KEY" ci/publish-known_hosts
                '''
                }
            }
        }	
    }

    post
    {
        fixed
        {
            telegramSend """
            Build *${env.JOB_NAME}* #${env.BUILD_NUMBER} status:*Fixed !*, [details](${env.BUILD_URL})
            """
        }

        regression
        {
            telegramSend """
            Build *${env.JOB_NAME}* #${env.BUILD_NUMBER} status:*Regression!*, [details](${env.BUILD_URL})
            """
        }
    }
}
