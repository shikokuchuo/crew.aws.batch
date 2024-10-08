% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/crew_controller_aws_batch.R
\name{crew_controller_aws_batch}
\alias{crew_controller_aws_batch}
\title{Create a controller with an AWS Batch launcher.}
\usage{
crew_controller_aws_batch(
  name = NULL,
  workers = 1L,
  host = NULL,
  port = NULL,
  tls = crew::crew_tls(mode = "automatic"),
  tls_enable = NULL,
  tls_config = NULL,
  seconds_interval = 0.5,
  seconds_timeout = 60,
  seconds_launch = 1800,
  seconds_idle = Inf,
  seconds_wall = Inf,
  retry_tasks = TRUE,
  log_resources = NULL,
  tasks_max = Inf,
  tasks_timers = 0L,
  reset_globals = TRUE,
  reset_packages = FALSE,
  reset_options = FALSE,
  garbage_collection = FALSE,
  launch_max = 5L,
  processes = NULL,
  r_arguments = c("--no-save", "--no-restore"),
  aws_batch_config = list(),
  aws_batch_credentials = list(),
  aws_batch_endpoint = NULL,
  aws_batch_region = NULL,
  aws_batch_job_definition,
  aws_batch_job_queue,
  aws_batch_share_identifier = NULL,
  aws_batch_scheduling_priority_override = NULL,
  aws_batch_parameters = NULL,
  aws_batch_container_overrides = NULL,
  aws_batch_node_overrides = NULL,
  aws_batch_retry_strategy = NULL,
  aws_batch_propagate_tags = NULL,
  aws_batch_timeout = NULL,
  aws_batch_tags = NULL,
  aws_batch_eks_properties_override = NULL
)
}
\arguments{
\item{name}{Name of the client object. If \code{NULL}, a name is automatically
generated.}

\item{workers}{Integer, maximum number of parallel workers to run.}

\item{host}{IP address of the \code{mirai} client to send and receive tasks.
If \code{NULL}, the host defaults to the local IP address.}

\item{port}{TCP port to listen for the workers. If \code{NULL},
then an available ephemeral port is automatically chosen.}

\item{tls}{A TLS configuration object from \code{\link[crew:crew_tls]{crew_tls()}}.}

\item{tls_enable}{Deprecated on 2023-09-15 in version 0.4.1.
Use argument \code{tls} instead.}

\item{tls_config}{Deprecated on 2023-09-15 in version 0.4.1.
Use argument \code{tls} instead.}

\item{seconds_interval}{Number of seconds between
polling intervals waiting for certain internal
synchronous operations to complete,
such as checking \code{mirai::status()}}

\item{seconds_timeout}{Number of seconds until timing
out while waiting for certain synchronous operations to complete,
such as checking \code{mirai::status()}.}

\item{seconds_launch}{Seconds of startup time to allow.
A worker is unconditionally assumed to be alive
from the moment of its launch until \code{seconds_launch} seconds later.
After \code{seconds_launch} seconds, the worker is only
considered alive if it is actively connected to its assign websocket.}

\item{seconds_idle}{Maximum number of seconds that a worker can idle
since the completion of the last task. If exceeded, the worker exits.
But the timer does not launch until \code{tasks_timers} tasks
have completed.
See the \code{idletime} argument of \code{mirai::daemon()}. \code{crew} does not
excel with perfectly transient workers because it does not micromanage
the assignment of tasks to workers, so please allow enough idle
time for a new worker to be delegated a new task.}

\item{seconds_wall}{Soft wall time in seconds.
The timer does not launch until \code{tasks_timers} tasks
have completed.
See the \code{walltime} argument of \code{mirai::daemon()}.}

\item{retry_tasks}{\code{TRUE} to automatically retry a task in the event of
an unexpected worker exit. \code{FALSE} to give up on the first exit and
return a \code{mirai} error code (code number 19).
\code{TRUE} (default) is recommended in most situations.
Use \code{FALSE} for debugging purposes, e.g. to confirm that a task
is causing a worker to run out of memory or crash in some other way.}

\item{log_resources}{Optional character string with a file path to a
text file to log memory consumption.
Set \code{log_resources} to \code{NULL} to avoid writing to a log file.
If you supply a path, then
the \code{log()} method will write memory usage statistics to the file,
and most controller methods will do the same with throttling
so resource consumption is recorded throughout the whole life cycle
of the controller.

The log file is in comma-separated values
(CSV) format which can be easily read by \code{readr::read_csv()}.
The controller automatically deletes the old log file when it starts
(when \code{controller$start()} is called for the first time, but not
subsequent times).

The log file has one row per observation of a process,
including the current
R process ("client") and the \code{mirai} dispatcher. If the dispatcher
is not included in the output, it means the dispatcher process
is not running.
Columns include:
* \code{type}: the type of process (client or dispatcher)
* \code{pid}: the process ID.
* \code{status}: The process status (from \code{ps::ps_status()}).
* \code{rss}: resident set size (RSS). RS is the total memory held by
a process, including shared libraries which may also be
in use by other processes. RSS is obtained
from \code{ps::ps_memory_info()} and shown in bytes.
* \code{elapsed}: number of elapsed seconds since the R process was
started (from \code{proc.time()["elapsed"]}).}

\item{tasks_max}{Maximum number of tasks that a worker will do before
exiting. See the \code{maxtasks} argument of \code{mirai::daemon()}.
\code{crew} does not
excel with perfectly transient workers because it does not micromanage
the assignment of tasks to workers, it is recommended to set
\code{tasks_max} to a value greater than 1.}

\item{tasks_timers}{Number of tasks to do before activating
the timers for \code{seconds_idle} and \code{seconds_wall}.
See the \code{timerstart} argument of \code{mirai::daemon()}.}

\item{reset_globals}{\code{TRUE} to reset global environment
variables between tasks, \code{FALSE} to leave them alone.}

\item{reset_packages}{\code{TRUE} to unload any packages loaded during
a task (runs between each task), \code{FALSE} to leave packages alone.}

\item{reset_options}{\code{TRUE} to reset global options to their original
state between each task, \code{FALSE} otherwise. It is recommended to
only set \code{reset_options = TRUE} if \code{reset_packages} is also \code{TRUE}
because packages sometimes rely on options they set at loading time.}

\item{garbage_collection}{\code{TRUE} to run garbage collection between
tasks, \code{FALSE} to skip.}

\item{launch_max}{Positive integer of length 1, maximum allowed
consecutive launch attempts which do not complete any tasks.
Enforced on a worker-by-worker basis.
The futile launch count resets to back 0
for each worker that completes a task.
It is recommended to set \code{launch_max} above 0
because sometimes workers are unproductive under perfectly ordinary
circumstances. But \code{launch_max} should still be small enough
to detect errors in the underlying platform.}

\item{processes}{\code{NULL} or positive integer of length 1,
number of local processes to
launch to allow worker launches to happen asynchronously. If \code{NULL},
then no local processes are launched. If 1 or greater, then the launcher
starts the processes on \code{start()} and ends them on \code{terminate()}.
Plugins that may use these processes should run asynchronous calls
using \code{launcher$async$eval()} and expect a \code{mirai} task object
as the return value.}

\item{r_arguments}{Optional character vector of command line arguments
to pass to R when starting a worker. Example:
\code{r_arguments = c("--vanilla", "--max-connections=32")}.}

\item{aws_batch_config}{Named list, \code{config} argument of
\code{paws.compute::batch()} with optional configuration details.}

\item{aws_batch_credentials}{Named list. \code{credentials} argument of
\code{paws.compute::batch()} with optional credentials (if not already
provided through environment variables such as \code{AWS_ACCESS_KEY_ID}).}

\item{aws_batch_endpoint}{Character of length 1. \code{endpoint}
argument of \code{paws.compute::batch()} with the endpoint to send HTTP
requests.}

\item{aws_batch_region}{Character of length 1. \code{region} argument of
\code{paws.compute::batch()} with an AWS region string such as \code{"us-east-2"}.}

\item{aws_batch_job_definition}{Character of length 1, name of the AWS
Batch job definition to use. There is no default for this argument,
and a job definition must be created prior to running the controller.
Please see \url{https://docs.aws.amazon.com/batch/} for details.

To create a job definition, you will need to create a Docker-compatible
image which can run R and \code{crew}. You may which to inherit
from the images at \url{https://github.com/rocker-org/rocker-versioned2}.}

\item{aws_batch_job_queue}{Character of length 1, name of the AWS
Batch job queue to use. There is no default for this argument,
and a job queue must be created prior to running the controller.
Please see \url{https://docs.aws.amazon.com/batch/} for details.}

\item{aws_batch_share_identifier}{\code{NULL} or character of length 1.
For details, visit
\url{https://www.paws-r-sdk.com/docs/batch_submit_job/} and the
"AWS arguments" sections of this help file.}

\item{aws_batch_scheduling_priority_override}{\code{NULL} or integer of length 1.
For details, visit
\url{https://www.paws-r-sdk.com/docs/batch_submit_job/} and the
"AWS arguments" sections of this help file.}

\item{aws_batch_parameters}{\code{NULL} or a nonempty list.
For details, visit
\url{https://www.paws-r-sdk.com/docs/batch_submit_job/} and the
"AWS arguments" sections of this help file.}

\item{aws_batch_container_overrides}{\code{NULL} or a nonempty named list of
fields to override
in the container specified in the job definition. Any overrides for the
\code{command} field are ignored because \code{crew.aws.batch} needs to override
the command to run the \code{crew} worker.
For more details, visit
\url{https://www.paws-r-sdk.com/docs/batch_submit_job/} and the
"AWS arguments" sections of this help file.}

\item{aws_batch_node_overrides}{\code{NULL} or a nonempty named list.
For more details, visit
\url{https://www.paws-r-sdk.com/docs/batch_submit_job/} and the
"AWS arguments" sections of this help file.}

\item{aws_batch_retry_strategy}{\code{NULL} or a nonempty named list.
For more details, visit
\url{https://www.paws-r-sdk.com/docs/batch_submit_job/} and the
"AWS arguments" sections of this help file.}

\item{aws_batch_propagate_tags}{\code{NULL} or a logical of length 1.
For more details, visit
\url{https://www.paws-r-sdk.com/docs/batch_submit_job/} and the
"AWS arguments" sections of this help file.}

\item{aws_batch_timeout}{\code{NULL} or a nonempty named list.
For more details, visit
\url{https://www.paws-r-sdk.com/docs/batch_submit_job/} and the
"AWS arguments" sections of this help file.}

\item{aws_batch_tags}{\code{NULL} or a nonempty named list.
For more details, visit
\url{https://www.paws-r-sdk.com/docs/batch_submit_job/} and the
"AWS arguments" sections of this help file.}

\item{aws_batch_eks_properties_override}{\code{NULL} or a nonempty named list.
For more details, visit
\url{https://www.paws-r-sdk.com/docs/batch_submit_job/} and the
"AWS arguments" sections of this help file.}
}
\description{
Create an \code{R6} object to submit tasks and
launch workers on AWS Batch workers.
}
\section{IAM policies}{

In order for the AWS Batch \code{crew} plugin to function properly, your IAM
policy needs permission to perform the \code{SubmitJob} and \code{TerminateJob}
AWS Batch API calls. For more information on AWS policies and permissions,
please visit
\url{https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html}.
}

\section{AWS arguments}{

The AWS Batch controller and launcher accept many arguments
which start with \code{"aws_batch_"}. These arguments are AWS-Batch-specific
parameters forwarded directly to the \code{submit_job()} method for
the Batch client in the \code{paws.compute} R package

For a full description
of each argument, including its meaning and format, please visit
\url{https://www.paws-r-sdk.com/docs/batch_submit_job/}. The upstream API
documentation is at
\url{https://docs.aws.amazon.com/batch/latest/APIReference/API_SubmitJob.html}
and the analogous CLI documentation is at
\url{https://docs.aws.amazon.com/cli/latest/reference/batch/submit-job.html}.

The actual argument names may vary slightly, depending
on which : for example, the \code{aws_batch_job_definition} argument of
the \code{crew} AWS Batch launcher/controller corresponds to the
\code{jobDefinition} argument of the web API and
\code{paws.compute::batch()$submit_job()}, and both correspond to the
\code{--job-definition} argument of the CLI.
}

\section{Verbosity}{

Control verbosity with the \code{paws.log_level} global option in R.
Set to 0 for minimum verbosity and 3 for maximum verbosity.
}

\examples{
if (identical(Sys.getenv("CREW_EXAMPLES"), "true")) {
controller <- crew_controller_aws_batch(
  aws_batch_job_definition = "YOUR_JOB_DEFINITION_NAME",
  aws_batch_job_queue = "YOUR_JOB_QUEUE_NAME"
)
controller$start()
controller$push(name = "task", command = sqrt(4))
controller$wait()
controller$pop()$result
controller$terminate()
}
}
\seealso{
Other plugin_aws_batch: 
\code{\link{crew_class_launcher_aws_batch}},
\code{\link{crew_launcher_aws_batch}()}
}
\concept{plugin_aws_batch}
