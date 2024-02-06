# HPC usage

In this course, you will be assigned with labs requiring CUDA programming and GPU utilization.  We use the NYU HPC in this course for the GPU computing resources.  This instruction will help you with the usage of NYU HPC in this course.

Everyone in the course is assigned with 300 GPU hours. And the following partitions are allowed to use:

```
CSCI_GA_3033_077_2024sp = {
  accounts = { "csci_ga_3033_077-2024sp" },
  partitions = { "interactive", "n1s8-v100-1", "n1s16-v100-2", "n2c48m24" }
}
```

All the following operations should be done within the NYU network environment, because the servers have internal IP address and cannot be accessed from the public Internet. If you are not at campus, you can use the VPN.



## NYU HPC Greene

Each of you should already have access to the NYU HPC. To use the HPC, users login to the Greene cluster first. Instructions are available from https://sites.google.com/nyu.edu/nyu-hpc/accessing-hpc?authuser=0.



## Burst

From one Greene login node, run `ssh burst`, and you will be connected to the log-burst node. On this log-burst node, you can launch instances with GPU.

For example, if you want to launch a simple CPU only interactive job for 4 hours, you can type this following command in the log-burst node:

```bash
srun --account=csci_ga_3033_077-2024sp --partition=interactive --time=04:00:00 --pty /bin/bash
```

This command will open up a shell in the target partition/instance for you, and you can use that shell in your current terminal window.

Other examples:

```bash
# A GPU job with 1 V100 GPU for 4 hours
srun --account=csci_ga_3033_077-2024sp --partition=n1s8-v100-1 --gres=gpu:v100:1 --time=04:00:00 --pty /bin/bash

# A GPU job with 2 V199 GPUs for 4 hours 
srun --account=csci_ga_3033_077-2024sp --partition=n1s16-v100-2 --gres=gpu:2 --pty /bin/bash
```

Greene Data transfer nodes is available with hostname greene-dtn. On a Cloud instances, run `scp`, for example:

```bash
scp -rp greene-dtn:/scratch/work/public/singularity/ubuntu-20.04.3.sif .
```



## Conda environment

Greene has a limited inode resource for each of your `$HOME` directory, so you may not put a huge amount of files like the conda environment in your home directory. 

The way to fix this and use conda is through singularity and overlay file.

Instructions to setup Conda enviorment with Singularity and overlay file: https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/software/singularity-with-miniconda. Overlay file templates are available from `/share/apps/overlay-fs-ext3`. Singularity OS images are available from `/share/apps/images`. 

I personally find it convenient to put conda installation at other file systems.



## CUDA environment

The computing instances themselves do not have CUDA environment. In order to access the CUDA developing environment like `nvcc`, please run the wrapper script to open the singlarity container.

```bash
/share/apps/images/run-cuda-12.2.2.bash
```

Let's now have a look at the whole procedure:

```bash
[NetID@log-burst ~]$ srun --account=csci_ga_3033_077-2024sp --partition=n1s8-v100-1 --gres=gpu:v100:1 --time=04:00:00 --pty /bin/bash

bash-4.4$ /share/apps/images/run-cuda-12.2.2.bash
Singularity> which nvcc
/usr/local/cuda/bin/nvcc
Singularity> nvcc --version
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2023 NVIDIA Corporation
Built on Tue_Aug_15_22:02:13_PDT_2023
Cuda compilation tools, release 12.2, V12.2.140
Build cuda_12.2.r12.2/compiler.33191640_0
Singularity> nvidia-smi -L
GPU 0: Tesla V100-SXM2-16GB
Singularity> exit
exit
bash-4.4$
```



## Optional Instructions for `ssh` Pro Users

This part is not required for you to be able to use the HPC. But if you are familiar with ssh and you want to for example connect VSCode to the instances, you can take a look at this part. But keep in mind, you need to know what you are doing rather than copy the commands. Otherwise, you can stick to the part above. 

First, you can set up the `~/.ssh/config` file in your laptop and copy your public key to the `~/.ssh/authorized_keys` in the servers (both greene and burst). For example, you can have

```
Host greene
    HostName greene.hpc.nyu.edu
    User NetID
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host burst
    HostName log-burst.hpc.nyu.edu
    User NetID
```

If you do want to directly connect to the instance, either via ssh or VSCode, you need to use `sbatch` rather than `srun` to open up an instance. For example, launching a GPU node for one hour can be

```bash
sbatch --account=csci_ga_3033_077-2024sp --partition=n1s8-v100-1 --gres=gpu:v100:1 --time=01:00:00 --wrap "sleep infinity"
```

Then you can use `squeue --me` to see if your instance is launched.

For example,

```bash
[NetID@log-burst ~]$ squeue --me
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
            167330 n1s8-v100     wrap   hj2533  R       0:41      1 b-3-17
```

When the `ST` field is R, it means the instance is ready, and you can connect to it. In order to connect to the instance from the local computer, you need to add the hostname to your ssh config file, with the proxy field using burst login node. For the above example, it can be

```
Host awesome-node
    HostName b-3-17
    User NetID
    ProxyJump burst
```

And now use `ssh awesome-node` from you *local* shell to access the computing instance.
