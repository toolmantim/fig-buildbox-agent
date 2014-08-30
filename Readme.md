# fig-buildbox-agent

A [Docker](http://docker.io/) and [Fig](http://fig.sh/) enabled version of the [Buildbox agent](https://github.com/buildbox/buildbox-agent), which allows you to run each CI job in separate Docker containers. Just add a `fig.yml` to each project ([example](https://github.com/toolmantim/fig-ci-test-app)).

Each project can define as many containers as it needs (e.g. Ruby, Postgres, Redis, etc) using the standard [Fig yml config syntax](http://www.fig.sh/yml.html). Before a build step is run, Fig builds and links all the required containers, and then destroys them afterwards. And the containers are namespaced to the one build job.

*How does it work?* It uses a [customised bootstrap.sh](bootstrap.fig.sh#L59) file which calls fig before and after the build script is run.

## Agent Setup

```bash
git clone https://github.com/toolmantim/fig-buildbox-agent.git
cd fig-buildbox-agent
cp fig.sample.yml fig.yml
sed -i '' "s/abc123/<yout agent token>/g" fig.yml
$ fig scale agent=2
Starting figbuildboxagent_agent_1...
Starting figbuildboxagent_agent_2...
$ fig logs
Attaching to figbuildboxagent_agent_2, figbuildboxagent_agent_1
agent_2 | 2014-08-30 15:34:36 [INFO ] Registering agent (name:  hostname: 8bff65bc5094 meta-data: [fig])
agent_2 | 2014-08-30 15:34:39 [INFO ] Started agent `8bff65bc5094` (pid: 1 version: 1.0-beta.1)
agent_1 | 2014-08-30 15:34:36 [INFO ] Registering agent (hostname: 5cd0389ccd95 meta-data: [fig] name: )
agent_1 | 2014-08-30 15:34:39 [INFO ] Started agent `5cd0389ccd95` (version: 1.0-beta.1 pid: 1)
agent_1 | 2014-08-30 15:35:43 [INFO ] Starting job d5feb2f5-7ee3-44eb-8999-91b58d0f4a7b
agent_2 | 2014-08-30 15:35:44 [INFO ] Starting job 916200f4-57f8-435b-831b-6def4d413b7f
agent_2 | 2014-08-30 15:35:45 [INFO ] Starting to run script: /.buildbox/bootstrap.fig.sh
agent_2 | 2014-08-30 15:35:45 [INFO ] Process is running with PID: 16
agent_1 | 2014-08-30 15:35:45 [INFO ] Starting to run script: /.buildbox/bootstrap.fig.sh
agent_1 | 2014-08-30 15:35:45 [INFO ] Process is running with PID: 16
agent_1 | 2014-08-30 15:36:14 [INFO ] Finished job d5feb2f5-7ee3-44eb-8999-91b58d0f4a7b
agent_2 | 2014-08-30 15:36:14 [INFO ] Finished job 916200f4-57f8-435b-831b-6def4d413b7f
^C
Aborting.
$ fig stop
Stopping figbuildboxagent_agent_2...
Stopping figbuildboxagent_agent_1...
```

### Running the agent yourself

You don't need to run the agent itself using fig. You can run it as [as you'd normally do](https://github.com/buildbox/agent), but you'll need to make sure fig is installed, Docker is installed and running, and to copy [bootstrap.fig.sh](bootstrap.fig.sh) and tell the agent to use that instead of the standard one.

## Project Setup

### fig.yml

Every app must have a `fig.yml` which defines an `app` container. The app container is assumed to exist, and is where the bootstrap will attempt to run your build scripts.

See [fig-ci-test-app](https://github.com/toolmantim/fig-ci-test-app) for an example and [http://fig.sh/](http://fig.sh/) for more details.

### Build pipeline

The agent starts with the metadata `fig=true` so you can easily target fig-enabled agents in your build pipeline.

Set your build steps as normal. They'll be executed relative to the `app` fig container root.
