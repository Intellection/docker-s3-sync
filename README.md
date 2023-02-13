# S3 Sync

This Docker container syncs a local directory to an AWS S3 bucket, allowing for easy backups and synchronization of data.

If the specified local directory is empty, it performs an initial sync from the specified S3 bucket. Then, it syncs that directory with the specified S3 bucket. If the local directory was not empty to begin with, it skips the initial sync.

This container is suitable for creating a recent backup copy of data in S3, which can then be easily retrieved when launching new nodes.

Note: This container is designed for syncing files to S3 from a single node and is not recommended as a permanent backup solution.

By default, the download location inside the container is set to /sync. However, this can be changed via the SYNCDIR environment variable.

## Commands

The image supports the following commands:

* `download`: (default) downloads the files and exits
* `upload`: uploads the files and exits
* `sync`: uses inotify to upload a directory to S3 when files change (see `SYNCDIR`)
* `periodic_upload`: sets up a cron job to upload files to S3 periodically (see `CRON_TIME` and `INITIAL_DOWNLOAD`)
* `periodic_download`: sets up a cron job to download files from S3 periodically (see `CRON_TIME` and `INITIAL_DOWNLOAD`)

## Environment variables

| Environment variables | Required | Description |
| --- | --- | --- |
| AWS_ACCESS_KEY_ID | Yes | (or functional IAM profile) |
| AWS_SECRET_ACCESS_KEY | Yes | (or functional IAM profile) |
| AWS_DEFAULT_REGION | Yes | (or functional IAM profile) |
| S3PATH | Yes | the S3 synchronize location (ex: `s3://mybucket/myprefix`) |
| SYNCDIR | Yes | the local synchronize location |
| AWS_S3_SSE | No | use S3 Server Side Encryption; it can be `false` for no encryption, `aes256` or `true` for Server-Side Encryption with Amazon S3-Managed Keys (SSE-S3) and `kms` for Server-Side Encryption with AWS KMS-Managed Keys (SSE-KMS) (defaults to `false`). For more information refer to <https://docs.aws.amazon.com/AmazonS3/latest/dev/serv-side-encryption.html> (Note: Server-Side Encryption with Customer-Provided Keys (SSE-C) is not currently supported) |
| AWS_S3_SSE_KMS_KEY_ID | No | The AWS KMS key ID that should be used to server-side encrypt the object in S3 (only available if use in conjunction with `AWS_S3_SSE`) |
| CRON_TIME | No | a valid cron expression (ex: `CRON_TIME='0 */6 * * *'` runs every 6 hours; defaults to hourly) |
| INITIAL_DOWNLOAD | No | whether to download files initially (defaults to `true`); this will only download the files if the directory is empty. Set this to `force` to skip this check |
| SYNCEXTRA | No | add extra options to aws-cli sync command |


## Usage

### Download files and exit

```console
docker run --rm \
  -e S3PATH='s3://mybucket/myprefix' \
  zappi/s3sync
```

### Upload files and exit

```console
docker run --rm \
  -e S3PATH='s3://mybucket/myprefix' \
  zappi/s3sync upload
```

### Upload files periodically (every 6 hours)

```console
docker run -d \
  -e S3PATH='s3://mybucket/myprefix' \
  -e CRON_TIME='0 */6 * * *' \
  zappi/s3sync cron
```

### Watch local directory

```console
docker run -d \
  -e S3PATH='s3://mybucket/myprefix' \
  zappi/s3sync sync
```

### Watch the specified local directory (host mount)

```console
docker run -d \
  -e S3PATH='s3://mybucket/myprefix' \
  -e SYNCDIR='/mydir' \
  -v $(pwd):/mydir \
  zappi/s3sync sync
```

### External AWS credentials

```console
docker run -d \
  -e S3PATH='s3://mybucket/myprefix' \
  -v ~/.aws:/root/.aws:ro \
  zappi/s3sync
```

Notes:

* The `--rm` flag in the "Download files and exit" command removes the container after it exits, avoiding a build-up of stopped containers.
* In "Upload files and exit" command, the `upload` argument tells the container to upload files before exiting.
* In "Watch the specified local directory (host mount)" command, `$(pwd)` is used to specify the current directory as the one to sync. Change this to the appropriate directory for your use case.

## Credits

This image is based heavily on the work of @vladgh's [s3sync](https://github.com/vladgh/docker_base_images/blob/main/s3sync) base image.
