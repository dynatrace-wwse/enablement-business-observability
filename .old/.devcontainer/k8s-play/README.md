# how to install in a Ubuntu machine, you'll need a public ip and Ubuntu LTS

SSH into your machine

Make the shell file executable

```bash 
chmod +x k8splay-install.sh
```

Edit the variables at the end of the file.


Execute the file with sudo rights.
```bash 
sudo bash -c './k8splay-install.sh &'
```

For inspecting the installation on realtime type:

```bash 
less +F /tmp/k8splay-install.log
```