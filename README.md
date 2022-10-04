# ChaosApp

As Werner Vogels, the CTO at Amazon Web Services, famously put it, **Everything fails, all the time**.

Inspired by [GitLab chaos endpoints](https://gitlab.com/gitlab-org/gitlab/blob/master/doc/development/chaos_endpoints.md), but written in [Ruby](http://ruby-doc.org/) using [Sinatra](http://sinatrarb.com/) and native Threads to schedule jobs.

Currently, there are five endpoints for simulating the following conditions:

* Slow requests.
* CPU-bound requests.
* Memory leaks.
* Unexpected process crashes.
* Disk IO

## Getting Started

Build and run the Docker container.

```bash
$ docker build -t chaos .
$ docker run -d -p 4567:4567 chaos:latest

$ curl localhost:4567/frank-says
{"code":200,"message":"Put this in your pipe & smoke it!"}
```

## Invoking chaos

### Memory leaks

To simulate a memory leak in your application, use the `/leak_mem` endpoint.

```plaintext
GET /leak_mem
GET /leak_mem?memory_mb=1024
GET /leak_mem?memory_mb=1024&duration_s=50
```

| Attribute    | Type    | Required | Description                                                                          |
| ------------ | ------- | -------- | ------------------------------------------------------------------------------------ |
| `memory_mb`  | integer | no       | How much memory, in MB, should be leaked. Defaults to 512MB.                         |
| `duration_s` | integer | no       | Minimum duration_s, in seconds, that the memory should be retained. Defaults to 60s. |

```shell
curl http://localhost:4567/leak_mem
curl http://localhost:4567/leak_mem?memory_mb=1024&duration_s=10
```

### CPU spin

This endpoint attempts to fully utilise a single core, at 100%, for the given period.

Depending on your rack server setup, your request may timeout after a predetermined period (normally 60 seconds).
If you're using Unicorn, this is done by killing the worker process.

```plaintext
GET /cpu_spin
GET /cpu_spin?duration_s=60
```

| Attribute    | Type    | Required | Description                                                           |
| ------------ | ------- | -------- | --------------------------------------------------------------------- |
| `duration_s` | integer | no       | Duration, in seconds, that the core will be utilized. Defaults to 60s |

```shell
curl http://localhost:4567/cpu_spin
curl http://localhost:4567/cpu_spin?duration_s=60
```

### Sleep

This endpoint is similar to the CPU Spin endpoint but simulates off-processor activity, such as network calls to backend services. It will sleep for a given duration_s.

As with the CPU Spin endpoint, this may lead to your request timing out if duration_s exceeds the configured limit.

```plaintext
GET /sleep
GET /sleep?duration_s=50
```

| Attribute    | Type    | Required | Description                                                            |
| ------------ | ------- | -------- | ---------------------------------------------------------------------- |
| `duration_s` | integer | no       | Duration, in seconds, that the request will sleep for. Defaults to 30s |

```shell
curl http://localhost:4567/sleep?duration_s=50
```

### Kill

This endpoint will simulate the unexpected death of a worker process using a `kill` signal.

**Note:** Since this endpoint uses the `KILL` signal, the worker is not given a chance to cleanup or shutdown.

```plaintext
GET /kill
```

```shell
curl http://localhost:4567/kill
```

### Disk IO

This endpoint creates a file or many files at the same time in `/tmp`.

```plaintext
GET /disk_io
```

| Attribute    | Type    | Required | Description                                           |
| ------------ | ------- | -------- | ------------------------------------------------------|
| `fsize_mb`  | integer | no       | File size, in MB, of the temp file. Defaults to 100MB. |
| `num_threads` | integer | no       | Number of threads running in parallel. Defaults to 1 |

```shell
curl http://localhost:4567/disk_io?fsize_mb=1&num_threads=512
```
