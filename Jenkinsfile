pipeline
{
    agent
    {
        docker
        {
            image 'jekyll/jekyll'
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
                buildingTag()
            }
            steps
            {
                // FIXME
                withCredentials(bindings: [sshUserPrivateKey(credentialsId: 'jenkins-publish-cli_pignat_org', \
                                                             keyFileVariable: 'SSH_KEY')])
                {
                sh '''
                    eval $(ssh-agent -s) 
                    ssh-add <(echo "$SSH_KEY") 
                    ssh-add -l
                    ssh-agent -k
                    touch a
                    touch b
                    ci/publish.sh site/_site a b
                    ssh-agent -k
                '''
                }
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
