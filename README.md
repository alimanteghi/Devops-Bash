In this course, you must implement the following scripts:

 Write a script to get a path from the user, make a backup, compress it and send it to an S3 bucket. For S3 storage, you can use Amazon S3 or MinIO in on-perm environments.

 Extend the above script to do incremental backups instead of getting everything from scratch. You're able to use other tools like Restic, Kopia, etc.

 Write a script to serve an HTTP server using bash and create two endpoints for the index page and health check.

 Extend the above script and implement a simple API /api/v1/users to manage users. As a database, use local files.

 Write a script to capture the current state of the file system and show if abnormal changes happened to the files.

 Extend the above script to allow the user to recover the files that were changed to their previous state.

 Write a script to watch the Docker config "/etc/docker/daemon.json" to catch the changes and automatically restart the service.