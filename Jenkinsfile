node('node') {


    currentBuild.result = "SUCCESS"

    try {

       stage('Checkout'){

          checkout scm
       }

       stage('Test'){

         env.NODE_ENV = "test"

         print "Environment will be : ${env.NODE_ENV}"

         sh 'composer install'

       }

       stage('Build Docker'){

            sh './dockerBuild.sh'
       }

       stage('Deploy'){

         echo 'Push to Repo'

         echo 'ssh to web server and tell it to pull new image'

       }

       stage('Cleanup'){

         echo 'prune and cleanup'
         

         mail body: 'project build successful',
            from: 'jenkines@outsellinc.com',
            subject: 'project build failed for editors ',
            to: 'melayyoub@outsellinc.com'
       }



    }
    catch (err) {

        currentBuild.result = "FAILURE"

            mail body: "project build error is here: ${env.BUILD_URL}" ,
            from: 'jenkines@outsellinc.com',
            subject: 'project build failed for editors ',
            to: 'melayyoub@outsellinc.com'

        throw err
    }

}