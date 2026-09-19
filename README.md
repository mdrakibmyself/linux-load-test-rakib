# Linux_Load_Test — bgdsvc_rakib

## 0. One-time setup (every new terminal session)
​```bash
export SVC_NAME=bgdsvc_rakib   # pick once, reuse everywhere
chmod +x scripts/*.sh
​```
## Part 1 — Create the user
​```bash
./scripts/01_create_user.sh
​```
📸 Screenshot 1: `echo $SVC_NAME`
📸 Screenshot 2: `id $SVC_NAME`

## Part 2 — tmpfs scratch space
​```bash
./scripts/02_setup_tmpfs.sh
​```
📸 Screenshot 3a: `df -h /mnt/${SVC_NAME}_tmp` (before filling — shown by the script)

## Part 3 — Stress tests
​```bash
./scripts/03_stress_and_populate.sh --disk   # fills tmpfs, watch the 256M cap
​```
📸 Screenshot 3b: `df -h` after filling

In a **second terminal**, while running the combined test:
​```bash
free -h; top; dmesg | grep -i oom
​```
​```bash
./scripts/03_stress_and_populate.sh --cpu
./scripts/03_stress_and_populate.sh --mem
./scripts/03_stress_and_populate.sh --all    # run all three together
​```
📸 Screenshots 4a/4b/4c: `free -h` before / during / after
📸 Screenshot 5: `dmesg | grep -i oom` (empty output is a valid result — take it anyway)

## Part 4 — SSH key access
​```bash
ssh-keygen -t ed25519 -f ~/.ssh/${SVC_NAME}_key -N ""
sudo mkdir -p /home/$SVC_NAME/.ssh
sudo cp ~/.ssh/${SVC_NAME}_key.pub /home/$SVC_NAME/.ssh/authorized_keys
sudo chown -R $SVC_NAME:$SVC_NAME /home/$SVC_NAME/.ssh
sudo chmod 700 /home/$SVC_NAME/.ssh
sudo chmod 600 /home/$SVC_NAME/.ssh/authorized_keys

# No second machine? Install the server locally and hit yourself:
sudo apt install -y openssh-server
sudo systemctl enable --now ssh     # RHEL/CentOS/Fedora/Rocky: use "sshd" instead
                                     # check with: systemctl status ssh sshd 2>/dev/null

ssh -i ~/.ssh/${SVC_NAME}_key $SVC_NAME@localhost
​```

## Part 5 — SSH hardening (edit the config file — type literal name)
​```bash
sudo nano /etc/ssh/sshd_config
​```
Add/change:
​```
Port 2222
PermitRootLogin no
PasswordAuthentication no
AllowUsers bgdsvc_rakib
​```
⚠️ Test the new port before closing anything — on a remote box, changing
the port before opening it in the firewall locks you out. On your own
laptop this is low-risk since you still have local access.

⚠️ Once `AllowUsers` is active, **your own personal login can no longer
SSH in on this port** — only the listed service account can. That's the
intended least-privilege behavior.

​```bash
sudo systemctl restart ssh          # or sshd
ssh -i ~/.ssh/${SVC_NAME}_key -p 2222 $SVC_NAME@localhost
​```
📸 Screenshot 6: the SSH connection succeeding on port 2222

## Part 6 — Cron monitoring + nightly cleanup
​```bash
# Edit scripts/bgdsvc_yourname_monitor.sh and
# scripts/bgdsvc_yourname_cleanup_old_files.sh:
# replace the placeholder "bgdsvc_yourname" with your literal chosen name.

sudo cp scripts/bgdsvc_<yourname>_monitor.sh /usr/local/bin/
sudo cp scripts/bgdsvc_<yourname>_cleanup_old_files.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/bgdsvc_<yourname>_monitor.sh
sudo chmod +x /usr/local/bin/bgdsvc_<yourname>_cleanup_old_files.sh

sudo mkdir -p /var/log/$SVC_NAME
sudo chown $SVC_NAME:$SVC_NAME /var/log/$SVC_NAME

sudo crontab -e -u $SVC_NAME
​```
Add (literal name, no `$SVC_NAME`):
​```
*/5 * * * * /usr/local/bin/bgdsvc_<yourname>_monitor.sh
0 2 * * * /usr/local/bin/bgdsvc_<yourname>_cleanup_old_files.sh
​```
📸 Screenshot 7: `crontab -l -u $SVC_NAME`

## Part 7 — Logrotate
​```bash
sudo mkdir -p /var/log/$SVC_NAME
sudo chown $SVC_NAME:$SVC_NAME /var/log/$SVC_NAME
sudo nano /etc/logrotate.d/$SVC_NAME
​```
Content (literal name throughout):
​```
/var/log/bgdsvc_<yourname>/*.log {
    daily
    rotate 5
    compress
    missingok
    notifempty
    size 10M
    create 0640 bgdsvc_rakib bgdsvc_rakib
}
​```
​```bash
sudo logrotate -f /etc/logrotate.d/$SVC_NAME
ls -lh /var/log/$SVC_NAME/
​```

## Part 8 — Cleanup (leave no trace)
​```bash
./scripts/04_cleanup.sh
​```
📸 Screenshot 8: the final verification block (`id`, `mount | grep`, `ps -u` all confirming the account is gone)

## Folder structure
linux-load-test-rakib/
├── README.md
├── scripts/
│   ├── 01_create_user.sh
│   ├── 02_setup_tmpfs.sh
│   ├── 03_stress_and_populate.sh
│   ├── 04_cleanup.sh
│   ├── bgdsvc_rakib_monitor.sh
│   └── bgdsvc_rakib_cleanup_old_files.sh
├── screenshots/
│   ├── 00_svc_name.png
│   ├── 01_id_created.png
│   ├── 02_df_before.png
│   ├── 02_df_after.png
│   ├── 03_free_before.png
│   ├── 03_free_during.png
│   ├── 03_free_after.png
│   ├── 03_dmesg_oom.png
│   ├── 04_ssh_success.png
│   ├── 05_crontab_l.png
│   └── 06_cleanup_verify.png
└── observations.md