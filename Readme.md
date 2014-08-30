# fig-buildbox-agent

A [Docker](http://docker.io/) and [Fig](http://fig.sh/) enabled version of the [Buildbox agent](https://github.com/buildbox/buildbox-agent), which allows you to run each CI job in separate Docker containers. Just add a `fig.yml` to each project ([for example](https://github.com/toolmantim/fig-ci-test-app)) and define it’s Docker configuration.

Each project can define as many containers as it needs (e.g. Ruby, Postgres, Redis, etc) using [Fig's concise syntax](http://www.fig.sh/), and they're created and linked together before the tests are run, and then destroyed afterwards.

And because the agent uses fig itself, you can scale up your agents with a simple `fig scale agent=<number of agents>`.

```bash
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

*How does it work?* It uses a customised [bootstrap.sh](bootstrap.sh#59) file which calls fig before and after the build script is run.

## Agent Setup

```bash
git clone https://github.com/toolmantim/fig-buildbox-agent.git
cd fig-buildbox-agent
cp fig.sample.yml fig.yml
sed -i '' "s/abc123/<yout agent token>/g" fig.yml
fig up -d
fig logs
```

By default fig will start 1 agent instance. You can scale up using `fig scale`, for example:

```
fig scale agent=4
```

### Running the agent without fig

You don't need to run the agent itself using fig. ALl you need is fig installed, Docker installed and running, and to use the `bootstrap.fig.sh` for the fig agents.

## Project Setup

### fig.yml

Every app must have a `fig.yml` which defines an `app` container. The app container is where your build scripts are executed inside of.

See [fig-ci-test-app](https://github.com/toolmantim/fig-ci-test-app) for an example and [http://fig.sh/](http://fig.sh/) for more details.

### Build pipeline

The agent starts with the metadata `fig=true`, so you can target fig-enabled agents in your Build Pipeline Settings.

Your build script execute inside your `app` fig container, so they're entered just as normal.
